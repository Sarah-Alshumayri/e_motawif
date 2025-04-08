<?php
header('Content-Type: application/json');
include 'config.php'; // 🔁 Your DB connection

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $motawif_id = $_POST['motawif_id'];

    if (empty($motawif_id)) {
        echo json_encode(["status" => "error", "message" => "Missing Motawif ID"]);
        exit;
    }

    // 1. Get all pilgrim IDs assigned to this motawif
    $stmt = $conn->prepare("
        SELECT u.user_id, u.name, m.latitude, m.longitude, m.timestamp 
        FROM users u
        JOIN residency_allocation r ON u.user_id = r.pilgrim_id
        LEFT JOIN (
            SELECT user_id, latitude, longitude, timestamp 
            FROM movement_history 
            WHERE (user_id, timestamp) IN (
                SELECT user_id, MAX(timestamp) 
                FROM movement_history 
                GROUP BY user_id
            )
        ) m ON u.user_id = m.user_id
        WHERE r.motawif_id = ?
    ");
    $stmt->bind_param("s", $motawif_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $pilgrims = [];

    while ($row = $result->fetch_assoc()) {
        $pilgrims[] = [
            "user_id" => $row["user_id"],
            "name" => $row["name"],
            "latitude" => $row["latitude"],
            "longitude" => $row["longitude"],
            "last_update" => $row["timestamp"]
        ];
    }

    echo json_encode(["status" => "success", "pilgrims" => $pilgrims]);
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method"]);
}
?>
