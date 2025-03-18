<?php
include 'config.php';

$user_id = $_POST['user_id']; // ID, Iqama, Passport, Visa
$name = $_POST['name'];
$email = $_POST['email'];
$password = password_hash($_POST['password'], PASSWORD_BCRYPT);
$phone = $_POST['phone'];
$dob = $_POST['dob'];

$sql = "INSERT INTO users (user_id, name, email, password, phone, dob, role) 
        VALUES ('$user_id', '$name', '$email', '$password', '$phone', '$dob', 'pilgrim')";

if ($conn->query($sql)) {
    echo json_encode(["status" => "success", "message" => "Pilgrim registered successfully"]);
} else {
    echo json_encode(["status" => "error", "message" => $conn->error]);
}
$conn->close();
?>
