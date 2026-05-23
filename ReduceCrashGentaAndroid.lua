-- Script ini dibuat untuk mengurangi crash saat load script yang berat di Genta Android. Dengan memisahkan script utama ke dalam file terpisah sehingga bisa mengurangi beban saat load dan menghindari crash.

Name = "GANTI NAMA" -- Ganti dengan nama file script utama kamu (contoh: "MainScript.lua")

Script = io.input("/storage/emulated/0/Android/media/GENTAHAX/Script/" ..Name):read("*a")
load(Script)()