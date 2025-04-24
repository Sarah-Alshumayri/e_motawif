<?php
include 'config.php';
header('Content-Type: application/json');

$response = [];

try {
    $query = "
        SELECT u.id, u.user_id, u.name, u.email, COUNT(mp.pilgrim_id) AS assigned_count
        FROM users u
        LEFT JOIN motawif_pilgrim mp ON u.id = mp.motawif_id
        WHERE u.role = 'motawif'
        GROUP BY u.id
    ";

    $result = mysqli_query($conn, $query);
    $data = [];

    while ($row = mysqli_fetch_assoc($result)) {
        $data[] = [
            'id' => $row['id'],
            'user_id' => $row['user_id'],
            'name' => $row['name'],
            'email' => $row['email'],
            'assigned_count' => (int)$row['assigned_count']
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
