<?php
include 'config.php';
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $user_id_string = $_POST['motawif_id']; // E001, E002, etc.

    if (empty($user_id_string)) {
        echo json_encode(["success" => false, "message" => "Missing Motawif ID"]);
        exit;
    }

    // Get numeric ID from users table
    $lookupQuery = "SELECT id FROM users WHERE user_id = ?";
    $lookupStmt = $conn->prepare($lookupQuery);
    $lookupStmt->bind_param("s", $user_id_string);
    $lookupStmt->execute();
    $lookupResult = $lookupStmt->get_result();

    if ($lookupResult->num_rows === 0) {
        echo json_encode(["success" => false, "message" => "Motawif not found"]);
        exit;
    }

    $motawifRow = $lookupResult->fetch_assoc();
    $motawif_db_id = $motawifRow['id'];

    // Get assigned pilgrims with coordinates
    $query = "
        SELECT u.user_id, u.name, u.latitude, u.longitude
        FROM motawif_pilgrim mp
        JOIN users u ON mp.pilgrim_id = u.id
        WHERE mp.motawif_id = ?
    ";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("i", $motawif_db_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $pilgrims = [];
    while ($row = $result->fetch_assoc()) {
        $pilgrims[] = [
            "pilgrim_id" => $row['user_id'],
            "name" => $row['name'],
            "latitude" => $row['latitude'] ?? null,
            "longitude" => $row['longitude'] ?? null,
            "lastSeen" => date("H:i")
        ];
    }

    echo json_encode(["success" => true, "data" => $pilgrims]);

    $stmt->close();
    $lookupStmt->close();
} else {
    echo json_encode(["success" => false, "message" => "Invalid request method"]);
}

$conn->close();
?>
