<?php
header("Content-Type: application/json");

// Database connection
$host = "localhost"; 
$username = "root";  // Change if needed
$password = "";      // Change if needed
$dbname = "motawif_db"; 

$conn = new mysqli($host, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Database connection failed"]));
}

// Get data from request
$data = json_decode(file_get_contents("php://input"), true);

$name = $data['name'];
$email = $data['email'];
$password = password_hash($data['password'], PASSWORD_DEFAULT); // Encrypt password
$phone = $data['phone'];
$id_type = $data['id_type'];
$id_number = $data['id_number'];
$dob = $data['dob'];

// Check if email already exists
$checkEmail = $conn->prepare("SELECT id FROM users WHERE email = ?");
$checkEmail->bind_param("s", $email);
$checkEmail->execute();
$result = $checkEmail->get_result();

if ($result->num_rows > 0) {
    echo json_encode(["status" => "error", "message" => "Email already registered"]);
    exit;
}

// Insert new pilgrim record
$stmt = $conn->prepare("INSERT INTO users (name, email, password, phone, id_type, id_number, dob, role) VALUES (?, ?, ?, ?, ?, ?, ?, 'pilgrim')");
$stmt->bind_param("sssssss", $name, $email, $password, $phone, $id_type, $id_number, $dob);

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "message" => "Sign-up successful"]);
} else {
    echo json_encode(["status" => "error", "message" => "Sign-up failed"]);
}

$stmt->close();
$conn->close();
?>
