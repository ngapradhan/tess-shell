#!/bin/bash

post_docker_run() {
  JENKINS_URL="http://ip172-18-0-96-cspqi10l2o9000e0l3e0-8080.direct.labs.play-with-docker.com/"
  API_ENDPOINT="/api/json?tree=jobs%5Bname,_class,url,jobs%5D"

  # Set Jenkins credentials
  USER="admin"
  API_TOKEN="Admin123"

  # Wait for Jenkins to be up
  wait_for_jenkins "$JENKINS_URL" || return 1

  # Find multibranch jobs
  find_multibranch_jobs "$JENKINS_URL" "$API_ENDPOINT" "$USER" "$API_TOKEN"
}

wait_for_jenkins() {
  local jenkins_url=$1
  echo "Waiting for Jenkins to be up..."
  for i in {1..20}; do
    if [ "$(curl -o /dev/null -s -w '%{http_code}' "$jenkins_url/login")" -eq 200 ]; then
      echo "Jenkins is up!"
      return 0
    fi
    echo "Jenkins not available yet, retrying..."
    sleep 10
  done
  echo "Error: Jenkins did not become available."
  return 1
}

find_multibranch_jobs() {
  local parent_url=$1
  local api_endpoint=$2
  local user=$3
  local api_token=$4
  # local MULTIBRANCH_JOB_URLS=()

  # Fetch all items in the current directory
  local items=$(curl -sS --user "$user:$api_token" "$parent_url$api_endpoint")
  # Check if the curl command was successful
  if [ $? -ne 0 ]; then
    echo "Error: Failed to retrieve the list of jobs from Jenkins"
    return 1
  fi

  # Parse each item and look for multibranch pipelines and folders
  local job_urls=$(echo "$items" | jq -r '.jobs[] | select(._class=="org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject") | .url')

  # Recurse into folders
  local folders=$(echo "$items" | jq -r '.jobs[] | select(._class=="com.cloudbees.hudson.plugins.folder.Folder") | .url')
  for folder in $folders; do
    find_multibranch_jobs "$(echo "$folder" | tr -d '\r')" "$api_endpoint" "$user" "$api_token"
    echo $folder
  done
  reapply_configuration "$user" "$api_token" "$job_urls"
}

# Reapply configuration for every multibranch job
reapply_configuration() {
  echo "Entering reapply_configuration"
  local user="$1"
  local api_token="$2"
  # local MULTIBRANCH_JOB_URLS=("${@:3}")
  local job_urls="$3"
  local MULTIBRANCH_JOB_URLS=()

  # Add multibranch pipeline job URLs to the array and reapply configuration
  for url in $job_urls; do
    echo "print the url and set multi_branch_job_urls: $url"
    MULTIBRANCH_JOB_URLS+=("$url")
  done

  echo 'Reapplying configuration for multibranch jobs:'
  echo "$job_urls" | while IFS= read -r url; do
    url="$(echo "$url" | tr -d '\r' | sed 's:/$::')"  # Remove carriage return and trailing slash
  
    # Ensure config.xml is appended to the URL
    url="$url/config.xml"
    
    # Clean up any previous job config.xml, ignore fail
    rm -f config.xml

    # Use curl to fetch the config.xml, and explicitly define output filename
    curl -v -u "$user:$api_token" "$url" -o "$(basename "$url")"
    
    # Reapply the same config.xml to the job
    curl -s -u "$user:$api_token" "$url" --data-binary "@config.xml" -H "Content-Type: application/xml"
 done

  # Clean up any previous job config.xml, ignore fail
  rm -f config.xml
}

post_docker_run
