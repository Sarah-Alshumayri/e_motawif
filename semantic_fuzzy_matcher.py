import sys
import json
import pymysql
from sentence_transformers import SentenceTransformer
from rapidfuzz.fuzz import partial_ratio
from sklearn.metrics.pairwise import cosine_similarity

# Validate CLI args
if len(sys.argv) != 5:
    print(json.dumps({
        "status": "error",
        "message": "Expected 4 arguments: itemName, description, location, date"
    }))
    sys.exit(1)

item_name, description, location, date = sys.argv[1:]

try:
    model = SentenceTransformer("all-MiniLM-L6-v2")
    query = f"{item_name} {description} {location} {date}"
    query_embedding = model.encode([query])[0]

    conn = pymysql.connect(
        host='localhost',
        user='root',
        password='',
        database='motawif_db',
        charset='utf8mb4',
        cursorclass=pymysql.cursors.DictCursor
    )
    cursor = conn.cursor()
    cursor.execute("SELECT id, itemName, description, location, date FROM lost_found")
    items = cursor.fetchall()

    results = []
    for row in items:
        combined = f"{row['itemName']} {row['description']} {row['location']} {row['date']}"
        text_embedding = model.encode([combined])[0]
        semantic_score = cosine_similarity([query_embedding], [text_embedding])[0][0]
        fuzzy_score = partial_ratio(item_name.lower(), row['itemName'].lower()) / 100
        total_score = 0.7 * semantic_score + 0.3 * fuzzy_score

        if total_score > 0.65:
            results.append({
                "id": row['id'],
                "itemName": row['itemName'],
                "description": row['description'],
                "location": row['location'],
                "date": str(row['date']),
                "score": float(round(total_score, 2))
            })

    cursor.close()
    conn.close()

    print(json.dumps({
        "status": "success",
        "results": sorted(results, key=lambda x: -x["score"])
    }, ensure_ascii=False))

except Exception as e:
    print(json.dumps({
        "status": "error",
        "message": f"Internal error: {str(e)}"
    }))
    sys.exit(1)
