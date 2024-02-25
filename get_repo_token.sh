#!/bin/bash
# Check if both arguments are provided
if [ "$#" -ne 1 ]; then
    echo "Missing arguments. Usage: $0 <repo_to_add_runner>"
    exit 1
fi

repo_to_add_runner=$1

# Create GitHub runner registration token to be used in config.sh input
curl -L -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer ${{ secrets.GITHUB_TOKEN }}" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/chefgs/$repo_to_add_runner/actions/runners/registration-token | jq .token --raw-output # > token.txt
# repo_token=$(cat token.txt)
