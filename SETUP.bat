@echo off

cd /d "%~dp0db"
call MySQL_Server_Docker_SETUP.bat
echo MySQL Docker container has been started successfully.

cd ..

docker-compose build
docker-compose up

pause