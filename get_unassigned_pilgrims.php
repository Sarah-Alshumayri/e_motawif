<?php
include 'config.php';
header('Content-Type: application/json');

$response = [];

try {
    $query = "
        SELECT u.id, u.user_id, u.name, u.email
        FROM users u
        WHERE u.role = 'pilgrim'
        AND u.id NOT IN (
            SELECT pilgrim_id FROM motawif_pilgrim
        )
    ";

    $result = mysqli_query($conn, $query);
    $data = [];

    while ($row = mysqli_fetch_assoc($result)) {
        $data[] = [
            'id' => $row['id'],
            'user_id' => $row['user_id'],
            'name' => $row['name'],
            'email' => $row['email']
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

