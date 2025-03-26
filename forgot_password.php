<?php
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require 'PHPMailer/src/Exception.php';
require 'PHPMailer/src/PHPMailer.php';
require 'PHPMailer/src/SMTP.php';

ob_start();
error_reporting(E_ALL);
ini_set('display_errors', 1);
header('Content-Type: application/json');
include 'config.php';

if (!isset($_POST['user_id']) || !isset($_POST['email'])) {
    echo json_encode(["status" => "error", "message" => "Missing parameters"]);
    exit();
}

$user_id = trim($_POST['user_id']);
$email_input = trim($_POST['email']);

$stmt = $conn->prepare("SELECT name, email FROM users WHERE user_id = ?");
$stmt->bind_param("s", $user_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode(["status" => "error", "message" => "User ID not found."]);
    exit();
}

$row = $result->fetch_assoc();
$email = $row['email'];
$name = $row['name'];

if (strcasecmp($email_input, $email) !== 0) {
    echo json_encode(["status" => "error", "message" => "Email does not match."]);
    exit();
}

// ✅ Send email using PHPMailer
$mail = new PHPMailer(true);
try {
    $mail->isSMTP();
    $mail->Host       = 'smtp.gmail.com';
    $mail->SMTPAuth   = true;
    $mail->Username   = 'emotawif@gmail.com'; // YOUR GMAIL
    $mail->Password   = 'tied zmuv dxrk phlq';    // YOUR GMAIL APP PASSWORD
    $mail->SMTPSecure = 'tls';
    $mail->Port       = 587;
    $mail->SMTPOptions = [
    'ssl' => [
        'verify_peer'       => false,
        'verify_peer_name'  => false,
        'allow_self_signed' => true
    ]
];

    $mail->setFrom('emotawif@gmail.com', 'E-Motawif');
    $mail->addAddress($email, $name);
    $mail->Subject = 'E-Motawif Password Reset';
    $mail->Body    = "Dear $name,\n\nClick the link below to reset your password:\n\nhttp://192.168.56.1/e_motawif_new/reset_password.php?user_id=$user_id\n\nThank you,\nE-Motawif Team";

    $mail->send();
    echo json_encode(["status" => "success", "email" => $email]);
} catch (Exception $e) {
    echo json_encode(["status" => "error", "message" => "Mailer Error: " . $mail->ErrorInfo]);
}