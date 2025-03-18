<?php
$host = "localhost";
$user = "root";  // Change this if needed
$password = "";
$database = "motawif_db";  // Ensure this database exists

$conn = new mysqli($host, $user, $password, $database);
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Database connection failed"]));
}
?>
