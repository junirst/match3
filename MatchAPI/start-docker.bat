@echo off
echo Building and starting MatchAPI Docker container...

:: Build and start the container
docker-compose up --build -d

:: Wait a moment for the container to start
timeout /t 5 /nobreak > nul

:: Show container status
docker-compose ps

echo.
echo MatchAPI is now running at: http://localhost:5000
echo Swagger UI available at: http://localhost:5000/swagger
echo.
echo To stop the container, run: docker-compose down
echo To view logs, run: docker-compose logs -f
