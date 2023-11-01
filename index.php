<?php

$secret_key = 'YOUR_SECRET_KEY';
$db_path = '/path/to/your/tasks.db';
file

if (!isset($_GET['key']) || $_GET['key'] !== $secret_key) {
    die('Unauthorized request.');
}

$source = $_GET['source'];

$db = new SQLite3($db_path);

// Create table if it doesn't exist
$db->exec("CREATE TABLE IF NOT EXISTS tasks (id INTEGER PRIMARY KEY, url 
TEXT, status TEXT)");

// Insert new task with 'queued' status
$stmt = $db->prepare("INSERT INTO tasks (url, status) VALUES (:url, 
'queued')");
$stmt->bindValue(':url', $source);
$stmt->execute();

echo "Task added.";
?>

