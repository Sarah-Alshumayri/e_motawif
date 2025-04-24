<?php
include 'config.php';

header('Content-Type: application/json');

$response = [];

try {
    $query = "
        SELECT u.name AS motawif_name, COUNT(mp.pilgrim_id) AS total_pilgrims
        FROM users u
        LEFT JOIN motawif_pilgrim mp ON u.id = mp.motawif_id
        WHERE u.role = 'motawif'
        GROUP BY u.id
    ";

    $result = mysqli_query($conn, $query);
    $data = [];

    while ($row = mysqli_fetch_assoc($result)) {
        $data[] = [
            'motawif_name' => $row['motawif_name'],
            'total_pilgrims' => (int)$row['total_pilgrims']
        ];
    }

    $response['status'] = 'success';
    $response['data'] = $data;
} catch (Exception $e) {
    $response['status'] = 'error';
    $response['message'] = $e->getMessage();
}

echo json_encode($response);
?>
