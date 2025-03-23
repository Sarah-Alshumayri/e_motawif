<?php
include 'config.php';

header('Content-Type: application/json');

// Try to decode JSON input
$data = json_decode(file_get_contents("php://input"), true);

// Fallback to form-data (e.g., $_POST) if JSON is null
if (!$data) {
    $data = $_POST;
}

// Get task ID
$taskId = $data['id'] ?? null;

// Validate
if (!$taskId) {
    echo json_encode(["status" => "error", "message" => "Missing task ID"]);
    exit;
}

// Prepare and execute delete query
$stmt = $conn->prepare("DELETE FROM tasks WHERE id = ?");
$stmt->bind_param("i", $taskId);

if ($stmt->execute()) {
    echo json_encode(["status" => "success"]);
} else {
    echo json_encode(["status" => "error", "message" => $stmt->error]);
}

$conn->close();
?>
