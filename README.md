# ITKannadigaru

ITKannadigaru is a simple blogging platform built with Java and Spring Boot. It allows users to register, log in, and create posts.

## Features

-   **User Authentication**: Users can register for a new account and log in.
-   **Post Management**: Authenticated users can create and delete their own posts.
-   **Public Feed**: The home page displays a feed of all posts from all users.

## Project Structure

The project follows a standard Spring Boot application structure:

-   `src/main/java`: Contains the main application source code.
    -   `com.itkannadigaru.controller`: Handles incoming web requests.
    -   `com.itkannadigaru.model`: Defines the data models (e.g., `User`, `Post`).
    -   `com.itkannadigaru.repository`: Manages data access and database operations.
    -   `com.itkannadigaru.service`: Contains the business logic.
    -   `com.itkannadigaru.security`: Configures application security.
-   `src/main/resources`: Contains application resources.
    -   `templates`: HTML templates for the user interface.
    -   `application.properties`: Configuration file for the application.
-   `Dockerfile`: Defines the Docker image for the application.

## How to Run

1.  **Build the application**:
    ```bash
    mvn clean install
    ```
2.  **Run the application**:
    ```bash
    java -jar target/itkannadigaru-webapp-1.0.0.jar
    ```
3.  **Access the application**:
    Open your web browser and go to `http://localhost:8080`.

## CI/CD Pipeline

This project is configured with a CI/CD pipeline that automates the build, test, and deployment process. The pipeline is defined in the `Jenkinsfile` and includes the following stages:

1.  **Checkout**: Checks out the latest code from the repository.
2.  **Build**: Compiles the Java code and builds the application.
3.  **Test**: Runs automated tests to ensure code quality.
4.  **Build Docker Image**: Builds a Docker image of the application.
5.  **Push Docker Image**: Pushes the Docker image to a container registry.
6.  **Deploy**: Deploys the application to a target environment.
