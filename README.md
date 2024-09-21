# User Authentication System

## Overview

The User Authentication System is a full-stack application designed to handle user registration, login, and password recovery functionalities. This system utilizes a backend built with Go using the Fiber framework, and a React-based frontend.

## Features

- **User Registration**: Allows new users to register by providing required details.
- **User Login**: Users can log in to the system using their credentials.
- **Password Recovery**: Supports sending a token via email to reset the password if forgotten.

## Technologies

- **Backend**: Go with Fiber framework
- **Frontend**: React
- **Database**: MySQL
- **Email Service**: Mailjet for sending password recovery emails
- **Containerization**: Docker
- **Orchestration**: Kubernetes for managing and deploying the application
- **Infrastructure as Code**: Terraform for provisioning and managing infrastructure

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

You need to have Docker and Docker Compose installed on your machine to run the services locally.

### Installing

**Clone the repository**
```
git clone https://github.com/yourusername/user-auth-system.git
cd user-auth-system
```

## Set Up Environment Variables

Copy the `.env.example` file to `.env` and update the environment variables accordingly.

## Build and Run the Docker Containers

```
docker-compose up --build
```

# User Authentication System

## Overview

The User Authentication System is a full-stack application designed to handle user registration, login, and password recovery functionalities. This system utilizes a backend built with Go using the Fiber framework, and a React-based frontend.

## Features

- **User Registration**: Allows new users to register by providing required details.
- **User Login**: Users can log in to the system using their credentials.
- **Password Recovery**: Supports sending a token via email to reset the password if forgotten.

## Technologies

- **Backend**: Go with Fiber framework
- **Frontend**: React
- **Database**: MySQL
- **Email Service**: Mailjet for sending password recovery emails
- **Containerization**: Docker
- **Orchestration**: Kubernetes for managing and deploying the application
- **Infrastructure as Code**: Terraform for provisioning and managing infrastructure

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

You need to have Docker and Docker Compose installed on your machine to run the services locally.

## Architecture

This section describes the high-level architecture of the system:

- **Backend**: Handles all the business logic including user authentication, session management, and interactions with the database.
- **Frontend**: Provides the user interface for registration, login, and password recovery.
- **Database**: Stores user credentials and session data securely.
- **Email Service**: Manages the sending of emails for password recovery.

## API Documentation

The backend offers several API endpoints for handling user interactions:

- **POST /register** - Register a new user.
- **POST /login** - Authenticate a user and start a session.
- **POST /recover** - Send a password recovery email.

Sample request and response for each endpoint can be added here.

## Deployment

### Kubernetes with Terraform

Follow these steps to deploy the application on Kubernetes using Terraform:

1. **Initialize Terraform**
```
terraform init
```
2. **Apply Terraform Configuration**
```
terraform apply
```
This will set up the necessary Kubernetes resources, including deployments, services, and persistent volume claims as specified in your Terraform configurations.

Contributing
Contributions make the open-source community an amazing place to learn, inspire, and create. Any contributions you make are greatly appreciated:

Fork the Project: Fork the repository to your own GitHub account.
Create your Feature Branch:
```
git checkout -b feature/AmazingFeature
```
Commit your Changes:
```
git commit -m 'Add some AmazingFeature'
```
Push to the Branch:
```
git push origin feature/AmazingFeature
```
Open a Pull Request: Compare the changes you made and submit a pull request.

## License
This project is distributed under the MIT License. 

See the [LICENSE](LICENSE) file for more information.

## Contact
[@toticavalcanti](https://github.com/toticavalcanti)  
Project Link: [https://github.com/toticavalcanti/user-auth-system](https://github.com/toticavalcanti/user-auth-system)

Feel free to reach out if you have any questions or suggestions!

