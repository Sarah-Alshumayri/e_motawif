<?php
include 'config.php';
header('Content-Type: application/json');

$response = [];

try {
    $query = "
        SELECT u.id, u.user_id, u.name, u.email,
            CASE 
                WHEN mp.pilgrim_id IS NULL THEN 'Unassigned'
                ELSE 'Assigned'
            END AS status,
            mu.name AS motawif_name
        FROM users u
        LEFT JOIN motawif_pilgrim mp ON u.id = mp.pilgrim_id
        LEFT JOIN users mu ON mp.motawif_id = mu.id
        WHERE u.role = 'pilgrim'
    ";

    $result = mysqli_query($conn, $query);
    $data = [];

    while ($row = mysqli_fetch_assoc($result)) {
        $data[] = [
            'id' => $row['id'],
            'user_id' => $row['user_id'],
            'name' => $row['name'],
            'email' => $row['email'],
            'status' => $row['status'],
            'motawif_name' => $row['motawif_name']
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
