<?php
header('Content-Type: application/json'); // Ensure ONLY JSON is returned

// Optional: turn off error display to avoid HTML output
error_reporting(0);
ini_set('display_errors', 0);

$host = "localhost";
$user = "root";
$password = "";
$database = "motawif_db";

$conn = new mysqli($host, $user, $password, $database);

if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode([
        "success" => false,
        "message" => "Database connection failed: " . $conn->connect_error
    ]);
    exit();
}
?>
