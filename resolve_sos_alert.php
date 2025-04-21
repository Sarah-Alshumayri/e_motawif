<?php
header('Content-Type: application/json');
include 'config.php';
file_put_contents("debug.log", print_r($_POST, true)); // 🔍 See what was received


if (!isset($_POST['id'])) {
    echo json_encode([
        "success" => false,
        "message" => "Missing SOS alert ID"
    ]);
    exit();
}

$id = $_POST['id'];

$sql = "UPDATE sos_alerts SET status = 'Resolved' WHERE id = '$id'";

if (mysqli_query($conn, $sql)) {
    echo json_encode([
        "success" => true,
        "message" => "SOS alert marked as resolved"
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Failed to update SOS alert"
    ]);
}
?>
