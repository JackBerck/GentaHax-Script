-- This script is made to reduce crashes when loading heavy scripts in Genta Android. By separating the main script into a different file, it helps reduce the load and avoid crashes.

Name = "CHANGE NAME" -- Change to your main script file name (example: "MainScript.lua")

Script = io.input("/storage/emulated/0/Android/media/GENTAHAX/Script/" ..Name):read("*a")
load(Script)()