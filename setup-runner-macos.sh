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
curl -o actions-runner-osx-x64-2.313.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.313.0/actions-runner-osx-x64-2.313.0.tar.gz

# Optional: Validate the hash
# echo "5697e222e71c4  actions-runner-osx-x64-2.313.0.tar.gz" | shasum -a 256 -c

# Create diectory to extract the tar
mkdir runner-files && cd runner-files
# Extract the installer
tar xzf ../actions-runner-osx-x64-2.313.0.tar.gz

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

