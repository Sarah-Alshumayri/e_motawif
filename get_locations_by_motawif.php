<?php
header('Content-Type: application/json');
include 'config.php';

if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $motawif_id = $_POST['motawif_id'] ?? '';

    if (empty($motawif_id)) {
        echo json_encode(["success" => false, "message" => "Missing motawif_id"]);
        exit();
    }

    // Step 1: Get motawif's numeric database ID
    $queryUser = "SELECT id FROM users WHERE user_id = ?";
    $stmtUser = $conn->prepare($queryUser);
    $stmtUser->bind_param("s", $motawif_id);
    $stmtUser->execute();
    $resultUser = $stmtUser->get_result();

    if ($resultUser->num_rows === 0) {
        echo json_encode(["success" => false, "message" => "Motawif not found."]);
        exit();
    }

    $motawifRow = $resultUser->fetch_assoc();
    $motawifDbId = $motawifRow['id'];

    // Step 2: Fetch the latest location per pilgrim assigned to this motawif
    $query = "
        SELECT 
            u.name, 
            u.user_id, 
            l.hotel_name, 
            l.hotel_location 
        FROM motawif_pilgrim mp
        JOIN users u ON mp.pilgrim_id = u.id
        LEFT JOIN (
            SELECT * FROM location ORDER BY location_id DESC
        ) l ON l.pilgrim_id = u.user_id
        WHERE mp.motawif_id = ?
        GROUP BY u.user_id
    ";

    $stmt = $conn->prepare($query);
    $stmt->bind_param("i", $motawifDbId);
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
}
?>
