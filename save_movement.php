<?php
header('Content-Type: application/json');
error_reporting(E_ALL);
ini_set('display_errors', 1);

include 'config.php'; // or db_connection.php if you're using that

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $user_id = $_POST['user_id'] ?? null;
    $latitude = $_POST['latitude'] ?? null;
    $longitude = $_POST['longitude'] ?? null;

    // ✅ Validate input
    if (!$user_id || !$latitude || !$longitude) {
        echo json_encode([
            "status" => "error",
            "message" => "Missing required parameters"
        ]);
        exit;
    }

    // ✅ Prepare and execute insert
    $stmt = $conn->prepare("INSERT INTO movement_history (user_id, latitude, longitude) VALUES (?, ?, ?)");
    if ($stmt === false) {
        echo json_encode([
            "status" => "error",
            "message" => "Prepare failed: " . $conn->error
        ]);
        exit;
    }

    $stmt->bind_param("idd", $user_id, $latitude, $longitude);

    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Movement saved"]);
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "Execute failed: " . $stmt->error
        ]);
    }

    $stmt->close();
    $conn->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method"]);
}
