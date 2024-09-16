# ACR Deploy

This bash script deploys a Docker image to an Azure Container Registry (ACR).

## Usage

To deploy the Docker image to the ACR, follow these steps:

1. Make sure you have the necessary dependencies installed, such as Docker and the Azure CLI.

2. Open a terminal and navigate to the project directory.

3. Run the `deploy_to_acr.sh` script with the following command:

   ```bash
   ./deploy_to_acr.sh [-b|--build]
   ```

   The script accepts an optional parameter `-b` or `--build` to determine whether to build the Docker image or skip the build and only tag the image. If the parameter is provided, the script will build the Docker image using the `docker build` command. If the parameter is not provided, the script will skip the build step and proceed to tag the image.

4. After the image is built or tagged, the script will log in to the Azure Container Registry using the `az acr login -n` command.

5. Finally, the script will push the Docker image to the ACR.