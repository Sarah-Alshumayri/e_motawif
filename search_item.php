<?php
include 'config.php';

$itemName = $_POST['itemName'];

$sql = "SELECT * FROM lost_found WHERE LOWER(itemName) LIKE LOWER('%$itemName%') AND status = 'found'";
$result = $conn->query($sql);

$items = [];
while ($row = $result->fetch_assoc()) {
    $items[] = $row;
}

echo json_encode(["status" => "success", "items" => $items]);
$conn->close();
?>
