<?php
include 'config.php';
header('Content-Type: application/json');

$data = $_POST;

if (!isset($data['user_id'])) {
    echo json_encode(["success" => false, "message" => "Missing user_id"]);
    exit;
}

$user_id = $conn->real_escape_string($data['user_id']);
$delete_query = "DELETE FROM users WHERE user_id = '$user_id'";

if ($conn->query($delete_query)) {
    echo json_encode(["success" => true, "message" => "User deleted"]);
} else {
    echo json_encode(["success" => false, "message" => "Failed to delete user"]);
}

$conn->close();
?>
