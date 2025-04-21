<?php
header('Content-Type: application/json');
error_reporting(0);
ini_set('display_errors', 0);
include 'config.php';

$pilgrim_id = $_POST['user_id'];  // ⚠️ Use 'user_id' because Flutter sends this
$message = $_POST['message'];
$latitude = $_POST['latitude'];
$longitude = $_POST['longitude'];

if (!$pilgrim_id || !$message || !$latitude || !$longitude) {
    echo json_encode(["success" => false, "message" => "Missing required fields."]);
    exit();
}

$sql = "INSERT INTO sos_alerts (pilgrim_id, message, latitude, longitude, status)
        VALUES ('$pilgrim_id', '$message', '$latitude', '$longitude', 'Active')";

if (mysqli_query($conn, $sql)) {
    echo json_encode(["success" => true, "message" => "SOS alert sent!"]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "MySQL error: " . mysqli_error($conn)
    ]);
}
?>
