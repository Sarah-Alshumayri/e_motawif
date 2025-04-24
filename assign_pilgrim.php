<?php
// File: assign_pilgrim.php
include 'config.php'; // DB connection

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $motawif_id = trim($_POST['motawif_id']);
    $pilgrim_id = trim($_POST['pilgrim_id']);

    // Debug output
    echo "<pre>";
    echo "motawif_id = [" . $motawif_id . "]\n";
    echo "pilgrim_id = [" . $pilgrim_id . "]\n";
    // exit; // uncomment this if you want to inspect values

    if (empty($motawif_id) || empty($pilgrim_id)) {
        echo json_encode(["success" => false, "message" => "Missing IDs"]);
        exit;
    }

    // Check if already assigned
    $checkQuery = "SELECT * FROM motawif_pilgrim WHERE motawif_id = ? AND pilgrim_id = ?";
    $checkStmt = $conn->prepare($checkQuery);
    $checkStmt->bind_param("ss", $motawif_id, $pilgrim_id);
    $checkStmt->execute();
    $result = $checkStmt->get_result();

    if ($result->num_rows > 0) {
        echo json_encode(["success" => false, "message" => "Already assigned"]);
        exit;
    }

    // Insert new link
    $query = "INSERT INTO motawif_pilgrim (motawif_id, pilgrim_id) VALUES (?, ?)";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("ss", $motawif_id, $pilgrim_id);

    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Pilgrim assigned to Motawif"]);
    } else {
        echo json_encode(["success" => false, "message" => "Error: " . $stmt->error]);
    }

    $stmt->close();
} else {
    echo json_encode(["success" => false, "message" => "Invalid request method"]);
}

$conn->close();
?>