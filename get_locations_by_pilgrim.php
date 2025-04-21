<?php
header('Content-Type: application/json');
include 'config.php'; // make sure this file connects $conn

if (!isset($_POST['pilgrim_id'])) {
    echo json_encode([
        "success" => false,
        "message" => "Missing pilgrim_id"
    ]);
    exit;
}

$pilgrim_id = $_POST['pilgrim_id'];

$stmt = $conn->prepare("SELECT hotel_name, hotel_location FROM location WHERE pilgrim_id = ?");
$stmt->bind_param("s", $pilgrim_id);
$stmt->execute();
$result = $stmt->get_result();

$locations = [];
while ($row = $result->fetch_assoc()) {
    $locations[] = $row;
}

echo json_encode([
    "success" => true,
    "locations" => $locations
]);

$stmt->close();
$conn->close();
?>
