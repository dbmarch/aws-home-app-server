# Server hosted in AWS EC2.  
Provides the backend for react-aws-home-app

This project is run on an ECS FARGATE cluster.  
The ping health check ensures there is always an instance running.

To publish a new version on the server, update the version in the package.json file:
npm version patch
