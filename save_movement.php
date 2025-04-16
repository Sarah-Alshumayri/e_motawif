<?php
header('Content-Type: application/json');
error_reporting(E_ALL);
ini_set('display_errors', 1);

include 'config.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $user_id = $_POST['user_id'] ?? null;
    $latitude = $_POST['latitude'] ?? null;
    $longitude = $_POST['longitude'] ?? null;

    if (!$user_id || !$latitude || !$longitude) {
        echo json_encode([
            "status" => "error",
            "message" => "Missing required parameters"
        ]);
        exit;
    }

    // ✅ Insert into movement_history
    $stmt = $conn->prepare("INSERT INTO movement_history (user_id, latitude, longitude) VALUES (?, ?, ?)");
    if (!$stmt) {
        echo json_encode([
            "status" => "error",
            "message" => "Prepare failed: " . $conn->error
        ]);
        exit;
    }

    $stmt->bind_param("sdd", $user_id, $latitude, $longitude);

    if ($stmt->execute()) {
        $stmt->close();

        // ✅ Update users table with latest location and timestamp
        $update = $conn->prepare("UPDATE users SET latitude = ?, longitude = ?, lastSeen = NOW() WHERE user_id = ?");
        if (!$update) {
            echo json_encode([
                "status" => "error",
                "message" => "Update prepare failed: " . $conn->error
            ]);
            exit;
        }

        $update->bind_param("dds", $latitude, $longitude, $user_id);

        if ($update->execute()) {
            echo json_encode(["status" => "success", "message" => "Movement saved and user updated"]);
        } else {
            echo json_encode(["status" => "error", "message" => "User update failed: " . $update->error]);
        }

        $update->close();
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "Execute failed: " . $stmt->error
        ]);
    }

    $conn->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method"]);
}
