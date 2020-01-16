<?php
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');
require_once "database.php";
$name = $_POST['name'];
$latitude = $_POST['latitude'];
$longitude = $_POST['longitude'];
$sql = "INSERT INTO marker(name,latitude,longitude) VALUES('$name','$latitude','$longitude')";
 if(mysqli_query($link,$sql)){
    header("HTTP/1.1 200 OK");
 }else{
    header("HTTP/1.1 400 Bad request");
 }
// Close connection
mysqli_close($link);
?>