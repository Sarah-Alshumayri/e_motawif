<?php
header("Content-Type: application/json");
include("config.php");

if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $userIdentifier = $_POST['motawif_id'];

    // Get numeric ID from user_id
    $queryUser = "SELECT id FROM users WHERE user_id = ?";
    $stmtUser = $conn->prepare($queryUser);
    $stmtUser->bind_param("s", $userIdentifier);
    $stmtUser->execute();
    $resultUser = $stmtUser->get_result();

    if ($resultUser->num_rows === 0) {
        echo json_encode(["success" => false, "message" => "Motawif not found."]);
        exit;
    }

    $motawifRow = $resultUser->fetch_assoc();
    $motawifId = $motawifRow['id'];

    // Main query to get assigned pilgrims
    $query = "
        SELECT u.user_id AS pilgrim_id, u.name, u.latitude, u.longitude, NOW() AS lastSeen
        FROM motawif_pilgrim mp
        JOIN users u ON mp.pilgrim_id = u.id
        WHERE mp.motawif_id = ?
    ";

    $stmt = $conn->prepare($query);
    $stmt->bind_param("i", $motawifId);
    $stmt->execute();
    $result = $stmt->get_result();

    $pilgrims = [];
    while ($row = $result->fetch_assoc()) {
        $pilgrims[] = $row;
    }

    echo json_encode(["success" => true, "data" => $pilgrims]);
} else {
    echo json_encode(["success" => false, "message" => "Invalid request method"]);
}
?>
