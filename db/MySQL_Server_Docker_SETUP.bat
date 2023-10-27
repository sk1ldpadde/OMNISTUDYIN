docker build -t mysql_server .
docker run --name mysql_server_container -p 3306:3306 -d mysql_server
pause