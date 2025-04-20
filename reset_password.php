<?php
include 'config.php';

$user_id = $_GET['user_id'] ?? '';
$message = "";

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['new_password'])) {
  $newPassword = trim($_POST['new_password']);


    if (empty($newPassword)) {
        $message = "Password cannot be empty.";
    } else {
        $hashedPassword = password_hash($newPassword, PASSWORD_DEFAULT);
        $stmt = $conn->prepare("UPDATE users SET password = ? WHERE user_id = ?");
        $stmt->bind_param("ss", $hashedPassword, $user_id);

        if ($stmt->execute()) {
            $message = "✅ Password reset successfully!";
        } else {
            $message = "❌ Error resetting password. Please try again.";
        }
    }
}
?>

<!DOCTYPE html>
<html>
<head>
  <title>Reset Password</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background-color: #0D4A45;
      color: white;
      text-align: center;
      padding: 50px;
    }
    .container {
      background-color: #ffffff10;
      padding: 30px;
      border-radius: 10px;
      display: inline-block;
    }
    input[type="password"], input[type="submit"] {
      padding: 10px;
      width: 250px;
      border-radius: 8px;
      border: none;
      margin-bottom: 20px;
    }
    input[type="submit"] {
      background-color: yellow;
      color: black;
      font-weight: bold;
      cursor: pointer;
    }
    .msg {
      margin-top: 20px;
      font-weight: bold;
    }
  </style>
</head>
<body>
  <div class="container">
    <h2>🔐 Reset Your Password</h2>
    <form method="POST">
      <input type="password" name="new_password" placeholder="Enter new password" required /><br>
      <input type="submit" value="Reset Password" />
    </form>

    <?php if (!empty($message)): ?>
      <div class="msg"><?= $message ?></div>
    <?php endif; ?>
  </div>
</body>
</html>
