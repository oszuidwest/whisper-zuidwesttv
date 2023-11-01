<?php

$secret_key = 'YOUR_SECRET_KEY';
$db_path = '/path/to/your/tasks.db';

if (!isset($_GET['key']) || $_GET['key'] !== $secret_key) {
    die('Unauthorized request.');
}

$source = $_GET['source'];
$id = basename(dirname($source));  // Extract ID from the URL

$db = new SQLite3($db_path);

// Create table if it doesn't exist
$db->exec("CREATE TABLE IF NOT EXISTS tasks (id TEXT PRIMARY KEY, url TEXT, status TEXT)");

// Check if the ID is already present in the database
$result = $db->querySingle("SELECT EXISTS(SELECT 1 FROM tasks WHERE id='$id')");

if ($result) {
    die("Error: ID already exists in the database.");
}

// Insert new task with 'queued' status
$stmt = $db->prepare("INSERT INTO tasks (id, url, status) VALUES (:id, :url, 'queued')");
$stmt->bindValue(':id', $id);
$stmt->bindValue(':url', $source);
$stmt->execute();

echo "Task added.";
?>
