<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
include 'config.php';

header("Content-Type: application/json");

// Capture raw data
$rawData = file_get_contents("php://input");
$data = json_decode($rawData, true);

if ($data === null) {
    echo json_encode(["status" => "error", "message" => "Invalid JSON format"]);
    exit();
}

// Check required fields
if (
    !isset($data['name']) || !isset($data['email']) || !isset($data['password']) ||
    !isset($data['phone']) || !isset($data['id_type']) || !isset($data['id_number']) || 
    !isset($data['dob'])
) {
    echo json_encode(["status" => "error", "message" => "Missing required fields"]);
    exit();
}

// Extract values
$name = $data['name'];
$email = $data['email'];
$password = password_hash($data['password'], PASSWORD_BCRYPT);
$phone = $data['phone'];
$id_type = $data['id_type'];
$user_id = $data['id_number']; // ✅ Save id_number as user_id
$dob = $data['dob'];
$role = "pilgrim"; // Default role

// Check if email already exists
$checkEmail = $conn->prepare("SELECT * FROM users WHERE email = ?");
$checkEmail->bind_param("s", $email);
$checkEmail->execute();
$result = $checkEmail->get_result();

if ($result->num_rows > 0) {
    echo json_encode(["status" => "error", "message" => "Email already exists"]);
} else {
    // ✅ Use user_id instead of id_number
    $stmt = $conn->prepare("INSERT INTO users (user_id, name, email, password, phone, id_type, dob, role) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
    
    if (!$stmt) {
        echo json_encode(["status" => "error", "message" => "SQL Error: " . $conn->error]);
        exit();
    }

    $stmt->bind_param("ssssssss", $user_id, $name, $email, $password, $phone, $id_type, $dob, $role);

    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Registration successful!"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Database insertion failed: " . $stmt->error]);
    }
    
}

$conn->close();
?>
