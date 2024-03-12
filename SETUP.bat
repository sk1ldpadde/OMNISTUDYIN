@echo off

cd /d "%~dp0db"
echo MySQL Docker container has been started successfully.

cd ..

docker-compose build
docker-compose up

pause