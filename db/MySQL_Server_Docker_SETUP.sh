#!/bin/bash

# Docker-Image mit dem Tag "mysql_server" erstellen
docker build -t mysql_server .

# MySQL-Server-Container erstellen und ausführen
docker run --name mysql_server_container -p 3306:3306 -d mysql_server

# Warte, um den Container für eine Weile laufen zu lassen
echo "MySQL Server Container wurde gestartet. Drücken Sie 'Enter', um fortzufahren ..."
read


