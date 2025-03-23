<?php
include 'config.php';

header('Content-Type: application/json');

// Attempt to decode JSON input
$data = json_decode(file_get_contents("php://input"), true);

// Fallback to form-data if JSON is not provided
if (!$data) {
    $data = $_POST;
}

// Check for required fields
if (
    !isset($data['motawif_id']) ||
    !isset($data['title']) ||
    !isset($data['assigned_to']) ||
    !isset($data['status']) ||
    !isset($data['date']) ||
    !isset($data['completed']) ||
    !isset($data['reminder'])
) {
    echo json_encode(["status" => "error", "message" => "Missing required fields."]);
    exit;
}

// Extract fields safely
$taskId = $data['id'] ?? null;
$motawifId = $data['motawif_id'];
$title = $data['title'];
$assignedTo = $data['assigned_to'];
$status = $data['status'];
$date = $data['date'];
$completed = $data['completed'] ? 1 : 0;
$reminder = $data['reminder'] ? 1 : 0;

if ($taskId) {
    // Update existing task
    $stmt = $conn->prepare("UPDATE tasks SET title=?, assigned_to=?, status=?, date=?, completed=?, reminder=? WHERE id=? AND motawif_id=?");
    $stmt->bind_param("ssssiiis", $title, $assignedTo, $status, $date, $completed, $reminder, $taskId, $motawifId);
} else {
    // Insert new task
    $stmt = $conn->prepare("INSERT INTO tasks (motawif_id, title, assigned_to, status, date, completed, reminder) VALUES (?, ?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("ssssssi", $motawifId, $title, $assignedTo, $status, $date, $completed, $reminder);
}

if ($stmt->execute()) {
    echo json_encode(["status" => "success"]);
} else {
    echo json_encode(["status" => "error", "message" => $stmt->error]);
}

$conn->close();
?>
