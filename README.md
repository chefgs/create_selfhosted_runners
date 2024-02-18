# Setup GitHub Runner for Setting up Self-hosted Runner Instance

## Objective
This shell script is used to set up a GitHub Actions runner on a Linux machine. A GitHub Actions runner is a server that GitHub uses to run your CI/CD jobs. This script automates the process of downloading, installing, and configuring the runner.

## How to run the script
The script takes two arguments: the name of the repository where the runner will be added (`repo_to_add_runner`), and a GitHub bearer PAT token (`github_token`) that has the necessary permissions to setup a runner to the repository.

## Script Steps to Setup Runner

1. First, the script creates a directory named actions-runner and navigates into it. It then downloads the latest version of the GitHub Actions runner package for Linux x64 from GitHub's servers using the curl command.
Optionally, you can validate the hash of the downloaded file to ensure its integrity. 

2. Next, the script creates another directory named runner-files within the actions-runner directory and navigates into it. It then extracts the downloaded runner package using the tar command.

3. The script then uses curl to make a POST request to the GitHub API to create a registration token for the runner. This token is necessary to register the runner with the specified repository. The jq command is used to extract the token from the JSON response.

4. The script then runs the config.sh script that comes with the runner package. This script configures the runner, specifying the repository URL and the registration token. The --unattended flag means that the script runs without requiring user input.

5. Finally, the script runs the svc.sh script, also included in the runner package, to install the runner as a service and start it. This means that the runner will automatically start running jobs as soon as they are available in the repository's Actions queue.