# CI/CD Pipeline with Automated Health Checks and Rollback

A DevOps project that automates application testing, Docker image creation, deployment to an Azure Linux VM, health checks, and rollback when a deployment fails.

## Project Overview

The goal of this project is to reduce deployment downtime and improve application reliability by using a CI/CD pipeline with automated health checks and rollback capabilities.

GitHub Actions runs the pipeline, Docker packages the Node.js application, and an Azure Linux VM hosts the application.

## Technologies Used

- **GitHub Actions** — CI/CD automation
- **Git** — Version control
- **Node.js** — Application runtime
- **Express.js** — Web application framework
- **Docker** — Containerization
- **Linux (Ubuntu)** — Server environment
- **Microsoft Azure** — Cloud infrastructure
- **Bash scripting** — Deployment and rollback automation
- **SSH** — Secure remote deployment

## Architecture

```text
Developer
   |
   v
GitHub Repository
   |
   v
GitHub Actions Pipeline
   |
   +--> Install dependencies
   |
   +--> Validate application
   |
   +--> Build Docker image
   |
   +--> Run application health tests
   |
   +--> Connect to Azure VM using SSH
   |
   v
Deploy candidate container
   |
   v
Automated health check
   |
   +--> Healthy: Keep deployment
   |
   +--> Unhealthy: Attempt rollback
   |
   v
Azure Linux VM
```

## Application Endpoints

| Endpoint | Purpose |
|---|---|
| `/` | Displays the application running message |
| `/health` | Returns the application's health status |

Example health-check response:

```json
{
  "status": "healthy"
}
```

## CI/CD Pipeline Workflow

1. **Source control:** Application code and workflow files are maintained in GitHub.
2. **Continuous integration:** GitHub Actions checks out the repository, installs dependencies, and validates the application.
3. **Docker build:** A Docker image is built for the application.
4. **Automated testing:** The application container is started and its health endpoint is checked.
5. **Deployment:** The pipeline connects to the Azure VM through SSH and runs the deployment script.
6. **Health monitoring:** The script checks whether the candidate application responds successfully.
7. **Rollback:** If deployment or health verification fails, the script attempts to restore the previous container image.
8. **Failure reporting:** A failed deployment remains a failed pipeline run, even if rollback succeeds.

## Rollback Strategy

The deployment script, `scripts/deploy-and-rollback.sh`, automates deployment verification and recovery.

- Builds the candidate application image.
- Starts a candidate container on a separate port.
- Checks the application's health endpoint.
- Replaces the live container after the candidate passes its health check.
- Verifies the live application.
- Attempts to restore the previous image if the new deployment fails.

**Note:** Successful rollback depends on the previous image being available and the recovery steps succeeding. The pipeline includes failure simulation and integration tests for the tested scenarios.

## Project Structure

```text
cicd-rollback-project/
├── .github/
│   └── workflows/
│       └── cicd.yml
├── scripts/
│   └── deploy-and-rollback.sh
├── app.js
├── Dockerfile
├── package.json
├── package-lock.json
├── .gitignore
├── CI_CD_Rollback_Project_Documentation.pdf
└── README.md
```

## Verification Commands

Check the running containers:

```bash
sudo docker ps
```

Check application health locally on the Azure VM:

```bash
curl -i http://localhost:3000/health
```

Check the application response:

```bash
curl http://localhost:3000/
```

Inspect container logs:

```bash
sudo docker logs rollback-node-app
```

Review GitHub Actions runs in the repository's **Actions** tab.

## Key Learning Outcomes

- Building a CI/CD workflow using GitHub Actions.
- Containerizing a Node.js application with Docker.
- Deploying applications to an Azure Linux VM over SSH.
- Implementing automated health checks.
- Writing Bash scripts for deployment and recovery.
- Testing failure scenarios and validating rollback behavior.
- Troubleshooting deployment and container health issues.

## Future Improvements

- Store production images in Azure Container Registry (ACR).
- Add approval gates before production deployment.
- Integrate monitoring, alerts, and centralized logging.
- Improve deployment concurrency and recovery safeguards.
- Expand rollback testing with different previous and candidate images.
- Add stronger readiness checks and deployment security controls.

## Project Documentation

See [`CI_CD_Rollback_Project_Documentation.pdf`](CI_CD_Rollback_Project_Documentation.pdf) for the detailed project documentation.

## Author

**Tharun Vipperla**

Cloud and DevOps | Azure | Linux | Docker | Terraform | Git

---

This is a learning project demonstrating CI/CD automation and deployment recovery. It is not intended to imply that every production failure scenario has been tested.
