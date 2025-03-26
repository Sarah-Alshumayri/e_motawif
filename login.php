<?php
ob_start();
error_reporting(E_ALL);
ini_set('display_errors', 1);
header('Content-Type: application/json');
include 'config.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $user_id = $_POST["user_id"] ?? '';
    $password = $_POST["password"] ?? '';

    if (empty($user_id) || empty($password)) {
        echo json_encode(["status" => "error", "message" => "Missing credentials"]);
        exit();
    }

    // Check if user exists
    $stmt = $conn->prepare("SELECT id, role, password FROM users WHERE user_id = ?");
    $stmt->bind_param("s", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $user = $result->fetch_assoc();
        $hashedPassword = $user["password"];
        $role = $user["role"];

        // ✅ If user is a pilgrim, use password_verify() for hashed passwords
        if ($role === "pilgrim") {
            if (password_verify($password, $hashedPassword)) {
                echo json_encode(["status" => "success", "role" => $role]);
            } else {
                echo json_encode(["status" => "error", "message" => "Invalid credentials"]);
            }
        } else { 
            // ✅ Keep direct password comparison for Motawif
            if ($password === $hashedPassword) {
                echo json_encode(["status" => "success", "role" => $role]);
            } else {
                echo json_encode(["status" => "error", "message" => "Invalid credentials"]);
            }
        }
    } else {
        echo json_encode(["status" => "error", "message" => "User not found"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request"]);
}

