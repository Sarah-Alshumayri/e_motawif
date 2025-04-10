<?php
header("Content-Type: application/json");
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(["status" => "error", "message" => "Invalid request"]);
    exit;
}

$user_id = $_POST['user_id'] ?? '';
$email = $_POST['email'] ?? '';
$phone = $_POST['phone'] ?? '';
$dob = $_POST['dob'] ?? '';
$emergencyContact = $_POST['emergencyContact'] ?? '';
$sickness = $_POST['sickness'] ?? '';

if (empty($user_id)) {
    echo json_encode(["status" => "error", "message" => "Missing user_id"]);
    exit;
}

$updateQuery = "UPDATE users SET 
    email = ?, 
    phone = ?, 
    dob = ?, 
    emergencyContact = ?, 
    sickness = ?
    WHERE user_id = ?";

$stmt = $conn->prepare($updateQuery);
$stmt->bind_param("ssssss", $email, $phone, $dob, $emergencyContact, $sickness, $user_id);

if (!$stmt->execute()) {
    echo json_encode(["status" => "error", "message" => "Database update failed"]);
    $stmt->close();
    $conn->close();
    exit;
}
$stmt->close();

// Respond
echo json_encode(["status" => "success", "message" => "Profile updated"]);
$conn->close();
