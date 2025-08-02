@echo off
echo Stopping MatchAPI Docker container...

:: Stop and remove containers
docker-compose down

echo Container stopped successfully.
