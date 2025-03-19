<?php
include 'config.php';

$user_id = $_POST['user_id'];
$itemName = $_POST['itemName'];
$description = $_POST['description'];
$location = $_POST['location'];
$status = $_POST['status'];

$sql = "INSERT INTO lost_found (user_id, itemName, description, location, status) 
        VALUES ('$user_id', '$itemName', '$description', '$location', '$status')";

if ($conn->query($sql)) {
    echo json_encode(["status" => "success", "message" => "Item reported successfully"]);
} else {
    echo json_encode(["status" => "error", "message" => $conn->error]);
}
$conn->close();
?>
