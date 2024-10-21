# GitHub Actions Self-Hosted Runner Setup Guide for Ubuntu

This guide explains how to set up a GitHub Actions self-hosted runner on an Ubuntu instance.

## Prerequisites

- A GitHub repository where you want to add the self-hosted runner.
- A GitHub Personal Access Token (PAT) with `repo` scope.
- An Ubuntu system (can be an EC2 instance on AWS or any other Ubuntu machine).
- Administrative privileges on the Ubuntu system.

## Step-by-Step Guide

### Step 1: Launch an Ubuntu EC2 Instance (if using AWS)

1. Log in to your AWS Management Console.
2. Navigate to the EC2 Dashboard.
3. Click on "Launch Instance".
4. Choose an Amazon Machine Image (AMI) with Ubuntu (e.g., Ubuntu Server 20.04 LTS).
5. Select an instance type (e.g., t2.micro for testing).
6. Configure instance details, add storage, and configure security groups as needed.
7. Launch the instance and connect to it via SSH.

### Step 2: Set Up the Runner on Ubuntu

1. SSH into your Ubuntu instance.
2. Create a shell script file named `SETUP-RUNNER-LINUX.SH` and add the following code:

    ```shell
    #!/bin/bash
    # Check if both arguments are provided
    if [ "$#" -ne 2 ]; then
        echo "Missing arguments. Usage: $0 <repo_to_add_runner> <github_token>"
        exit 1
    fi

    repo_to_add_runner=$1
    github_token=$2

    # Create a folder
    mkdir actions-runner && cd actions-runner
    # Download the latest runner package
    curl -o actions-runner-linux-x64-2.313.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.313.0/actions-runner-linux-x64-2.313.0.tar.gz

    # Optional: Validate the hash
    # echo "5697e222e71c4  actions-runner-linux-x64-2.313.0.tar.gz" | shasum -a 256 -c

    # Create directory to extract the tar
    mkdir runner-files && cd runner-files
    # Extract the installer
    tar xzf ../actions-runner-linux-x64-2.313.0.tar.gz

    # Create GitHub runner registration token to be used in config.sh input
    curl -L -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $github_token" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/chefgs/$repo_to_add_runner/actions/runners/registration-token | jq .token --raw-output > token.txt
    repo_token=$(cat token.txt)

    # Create the runner and start the configuration experience
    ./config.sh --unattended --url https://github.com/chefgs/$repo_to_add_runner --token $repo_token

    # Config.sh installs the service files. 
    # So as a last step, setup runner service & run it!
    ./svc.sh install && ./svc.sh start

    # Otherwise, If you want to run the runner interactively, you can run ./run.sh

    # Clean up
    if [ ! -z token.txt ]; then
        rm token.txt
    fi
    ```

3. Make the script executable:

    ```sh
    chmod +x SETUP-RUNNER-LINUX.SH
    ```

4. Run the script with your repository name and GitHub token as arguments:

    ```sh
    ./SETUP-RUNNER-LINUX.SH <repo_to_add_runner> <github_token>
    ```

### Step 3: Update Your Workflow File

Add the following line to your workflow file to use the self-hosted runner:

```yml
runs-on: self-hosted
```

Example workflow file (`.github/workflows/ci.yml`):

```yml
name: CI
on: [push, pull_request]
jobs:
  build:
    runs-on: self-hosted
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
      - name: Run build
        run: make build
```

## Explanation

### How a Specific Repository Uses the Self-Hosted Runner

When you set up a self-hosted runner, you are adding a custom machine to your GitHub repository that can execute GitHub Actions workflows. Here's how it works:

1. **Runner Setup**: You download and configure the runner software on your machine.
2. **Registration Token**: You generate a registration token from GitHub, which is used to link the runner to your specific repository.
3. **Configuration**: You configure the runner with the repository URL and the registration token.
4. **Service Installation**: The runner is installed as a service on your machine, allowing it to start automatically and run in the background.
5. **Workflow Execution**: When a workflow is triggered in your repository, GitHub Actions will use the self-hosted runner to execute the jobs defined in the workflow.

### Linking the Runner to a Repository

- **Registration Token**: The registration token generated from GitHub is specific to the repository you want to link the runner to. This token ensures that the runner is securely associated with the correct repository.
- **Repository URL**: During the configuration step, you provide the URL of the repository. This URL, combined with the registration token, links the runner to the repository.
- **GitHub Actions Workflow**: In your workflow file, you specify `runs-on: self-hosted` to indicate that the job should run on the self-hosted runner.

By specifying `runs-on: self-hosted`, GitHub Actions will use the self-hosted runner you set up to execute the job.

## Conclusion

You have now set up a GitHub Actions self-hosted runner on an Ubuntu system. Update your workflow files to use this runner by specifying `runs-on: self-hosted`. This allows you to run your CI/CD jobs on your own hardware, providing more control over the environment and potentially reducing costs.

## Reference
- [GitHub Self-hosted Runner Docs](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/about-self-hosted-runners)