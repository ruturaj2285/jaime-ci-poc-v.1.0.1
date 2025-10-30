DURATION=10 # How long the script will wait for approval, in days. Defaults to 10 days.
POLL_INTERVAL=10 # The polling interval in seconds.
EXECUTION_DATE=$(date -u)
PROJECT= #Azure DevOps Project name
ORG= # Azure DevOps Organization url
BRANCH= # Azure Pipeline Branch
PIPELINE_NAME= # Azure Pipeline Name
ENVIRONMENT=Development
RUN_ID=

print_usage() {
  printf '\nUsage: %s: -interval [POLL_INTERVAL] -duration [DURATION]\n'
}

main(){
  request_approval
  verify_approval
}

verify_request_expired(){
  local current_date=$(date +%s)
  local exec_date=$(date --date "${EXECUTION_DATE} ${DURATION} day" +%s)

  if [ $exec_date -le  $current_date ]
  then
    echo "Aprroval request as past the duration timeout"
    echo "Request date: $EXECUTION_DATE"
    echo "Current date: $(date -u)"
    echo "Timeout duration days: $DURATION"
    exit 1
  fi
}

request_approval(){
  echo "Requesting approval for [${ENVIRONMENT}]... deployment"

  # Sets global RUN_ID variable...
  RUN_ID=`az pipelines run --name $PIPELINE_NAME --branch $BRANCH  --parameters "environment=$ENVIRONMENT" --project $PROJECT --org $ORG --query "id" -o tsv`

  echo "Approval request successfully sent."
}

verify_approval(){
  verify_request_expired

  local response=`az pipelines runs show --id $RUN_ID --project $PROJECT --org $ORG  --query "join('-', [result || 'queued', status])" -o tsv`

  case $response in
    "succeeded-completed")
      echo "Request Approved."
      exit 0
      ;;
    "failed-completed")
      echo "Request Rejected."
      exit 1
      ;;
    "queued-notStarted" | "queued-inProgress")
      echo "waiting 10 secs before checking approval again..."
      sleep $POLL_INTERVAL
      verify_approval
      ;;
    *)
      echo "Unexpected approval response: $response"
      exit 1
      ;;
  esac
}


# CLI
# needs to run at top level, cannot be wrapped within a function.
while test $# -gt 0; do
  case "$1" in
    -project)
        shift
        PROJECT=$1
        shift
        ;;
    -org)
        shift
        ORG=$1
        shift
        ;;
    -branch)
        shift
        BRANCH=$1
        shift
        ;;
    -environment)
        shift
        ENVIRONMENT=$1
        shift
        ;;
    -name)
        shift
        PIPELINE_NAME=$1
        shift
        ;;
    -interval)
        shift
        POLL_INTERVAL=$1
        shift
        ;;
    -duration)
        shift
        DURATION=$1
        shift
        ;;
    *)
        print_usage
        exit 1;
        ;;
  esac
done


# Entrypoint
main