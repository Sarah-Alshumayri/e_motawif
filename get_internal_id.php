<?php
header('Content-Type: application/json');
include 'config.php';

$user_id = $_POST['user_id'];

$result = mysqli_query($conn, "SELECT id FROM users WHERE user_id = '$user_id'");

if ($row = mysqli_fetch_assoc($result)) {
    echo json_encode(["success" => true, "id" => $row['id']]);
} else {
    echo json_encode(["success" => false, "message" => "Motawif not found"]);
}
?>
