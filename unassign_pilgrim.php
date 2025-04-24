<?php
include 'config.php';
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(["success" => false, "message" => "Invalid request"]);
    exit;
}

$input = json_decode(file_get_contents("php://input"), true);
$pilgrim_user_id = $input['pilgrim_user_id'] ?? '';

if (empty($pilgrim_user_id)) {
    echo json_encode(["success" => false, "message" => "Missing pilgrim ID"]);
    exit;
}

// Get internal pilgrim ID
$query = "SELECT id FROM users WHERE user_id = ? AND role = 'pilgrim' LIMIT 1";
$stmt = $conn->prepare($query);
$stmt->bind_param("s", $pilgrim_user_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode(["success" => false, "message" => "Pilgrim not found"]);
    exit;
}

$internal_id = $result->fetch_assoc()['id'];

// Delete from motawif_pilgrim table
$deleteQuery = "DELETE FROM motawif_pilgrim WHERE pilgrim_id = ?";
$deleteStmt = $conn->prepare($deleteQuery);
$deleteStmt->bind_param("i", $internal_id);

if ($deleteStmt->execute()) {
    echo json_encode(["success" => true, "message" => "Pilgrim unassigned successfully"]);
} else {
    echo json_encode(["success" => false, "message" => "Failed to unassign pilgrim"]);
}

$conn->close();
?>
