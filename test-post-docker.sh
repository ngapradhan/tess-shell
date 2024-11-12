#!/bin/bash

JENKINS_URL="http://ip172-18-0-96-cspqi10l2o9000e0l3e0-8080.direct.labs.play-with-docker.com/"
API_ENDPOINT="/api/json?tree=jobs%5Bname,_class,url,jobs%5D"

# Set Jenkins credentials
USER="admin"
API_TOKEN="Admin123"

# Fetch all items in the current directory
items=$(curl -sS --user "$USER:$API_TOKEN" "$JENKINS_URL$API_ENDPOINT")
# Check if the curl command was successful
if [ $? -ne 0 ]; then
  echo "Error: Failed to retrieve the list of jobs from Jenkins"
   return 1
fi

# Parse each item and look for multibranch pipelines and folders
job_urls=$(echo "$items" | jq -r '.jobs[] | select(._class=="org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject") | .url')

echo 'Reapplying configuration for multibranch jobs:'
echo "$job_urls" | while IFS= read -r url; do
  url="$(echo "$url" | tr -d '\r' | sed 's:/$::')"  # Remove carriage return and trailing slash
  
  # Ensure config.xml is appended to the URL
  url="${url}/config.xml"
  
  echo "Fetching config for job: $url"
  
  # Check if the URL is not empty
  if [ -z "$url" ]; then
    echo "Error: Empty URL, skipping."
    continue
  fi

  # Use curl to fetch the config.xml, and explicitly define output filename
  curl -v -u "$USER:$API_TOKEN" "$url" -o "$(basename "$url")"
done
