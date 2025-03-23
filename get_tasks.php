<?php
include 'config.php';

header('Content-Type: application/json');

$motawifId = $_GET['motawif_id'] ?? '';

if (empty($motawifId)) {
    echo json_encode(["status" => "error", "message" => "Missing motawif_id"]);
    exit;
}

$stmt = $conn->prepare("SELECT * FROM tasks WHERE motawif_id = ?");
$stmt->bind_param("s", $motawifId);
$stmt->execute();
$result = $stmt->get_result();

$tasks = [];

while ($row = $result->fetch_assoc()) {
    $tasks[] = $row;
}

echo json_encode(["status" => "success", "tasks" => $tasks]);
?>
