#!/bin/bash

# Function that echoes the command, executes it and raises an error if it fails
function run {
  echo "$ $@"
  "$@" || exit 1
}

# If GCP_SERVICE_ACCOUNT_KEY is set, decode it and write it to a file
if [ -n "$GCP_SERVICE_ACCOUNT_KEY" ]; then
  echo "GCP_SERVICE_ACCOUNT_KEY is set. Saving to /tmp/gcp-service-account-key.json"
  echo "$GCP_SERVICE_ACCOUNT_KEY" | base64 -d > /tmp/gcp-service-account-key.json
else 
  echo "Environment GCP_SERVICE_ACCOUNT_KEY not set"
  exit 1
fi

# Login to gcloud using the service account key
run gcloud auth activate-service-account --key-file=/tmp/gcp-service-account-key.json

# Set GOOGLE_APPLICATION_CREDENTIALS to the path of the service account key
export GOOGLE_APPLICATION_CREDENTIALS=/tmp/gcp-service-account-key.json

# Assert that GKE_CLUSTER_NAME is set and start to build the "get-credentials" command
if [ -n "$GKE_CLUSTER_NAME" ]; then
  echo "GKE_CLUSTER_NAME is set. Building gcloud command"
  gcloud_command="gcloud container clusters get-credentials $GKE_CLUSTER_NAME"
else 
  echo "Environment GKE_CLUSTER_NAME not set"
  exit 1
fi

# Either GKE_CLUSTER_REGION or GKE_CLUSTER_ZONE must be set
if [ -n "$GKE_CLUSTER_REGION" ]; then
  echo "GKE_CLUSTER_REGION is set. Adding --region flag to gcloud command"
  gcloud_command="$gcloud_command --region $GKE_CLUSTER_REGION"
elif [ -n "$GKE_CLUSTER_ZONE" ]; then
  echo "GKE_CLUSTER_ZONE is set. Adding --zone flag to gcloud command"
  gcloud_command="$gcloud_command --zone $GKE_CLUSTER_ZONE"
else
  echo "Either GKE_CLUSTER_REGION or GKE_CLUSTER_ZONE must be set"
  exit 1
fi

# GKE_CLUSTER_PROJECT must be set
if [ -n "$GKE_CLUSTER_PROJECT" ]; then
  echo "GKE_CLUSTER_PROJECT is set. Adding --project flag to gcloud command"
  gcloud_command="$gcloud_command --project $GKE_CLUSTER_PROJECT"
else
  echo "Environment GKE_CLUSTER_PROJECT not set"
  exit 1
fi

# Echo the final gcloud command and run it
echo "Running gcloud command: $gcloud_command"
run $gcloud_command

# Assert that we have GKE_SERVICE_NAMESPACE set and start to build the "kubectl proxy" command
if [ -n "$GKE_SERVICE_NAMESPACE" ]; then
  echo "GKE_SERVICE_NAMESPACE is set. Building kubectl command"
  kubectl_command="kubectl port-forward --namespace=$GKE_SERVICE_NAMESPACE"
else 
  echo "Environment GKE_SERVICE_NAMESPACE not set"
  exit 1
fi

# Assert that we have GKE_SERVICE_NAME set
if [ -n "$GKE_SERVICE_NAME" ]; then
  echo "GKE_SERVICE_NAME is set. Adding it to kubectl command"
  kubectl_command="$kubectl_command service/$GKE_SERVICE_NAME"
else 
  echo "Environment GKE_SERVICE_NAME not set"
  exit 1
fi

# Assert that we have GKE_SERVICE_PORT set
if [ -n "$GKE_SERVICE_PORT" ]; then
  echo "GKE_SERVICE_PORT is set. Adding it to kubectl command"
  kubectl_command="$kubectl_command $GKE_SERVICE_PORT:$GKE_SERVICE_PORT"
else 
  echo "Environment GKE_SERVICE_PORT not set"
  exit 1
fi

# Echo the final kubectl command and run it
echo "Running kubectl command: $kubectl_command"
run $kubectl_command
