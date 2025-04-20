<?php
include 'config.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $user_id = $_POST['user_id'];
    $latitude = $_POST['latitude'];
    $longitude = $_POST['longitude'];
    $message = $_POST['message'];

    $stmt = $conn->prepare("INSERT INTO sos_alerts (pilgrim_id, message, latitude, longitude) VALUES (?, ?, ?, ?)");
    $stmt->bind_param("issd", $user_id, $message, $latitude, $longitude);

    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "SOS alert sent successfully"]);
    } else {
        echo json_encode(["success" => false, "message" => "Failed to send alert"]);
    }
    $stmt->close();
    $conn->close();
}
?>
