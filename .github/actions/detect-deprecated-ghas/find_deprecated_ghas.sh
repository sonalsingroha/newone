#!/bin/bash

# Environment setup
GH_HOST=github.com
ORG=merit
COUNT=149 # TODO: May have to set higher or make more dynamic as this is the current repo count

# Get all repos
#repos=$(gh api /orgs/ORGANIZATION/repos?sort=full_name --jq .[].full_name) TODO: For local testing, use a different gh cli command
# Possible new "get all repos command"
repos=$(gh repo list $ORG -L $COUNT --json name --jq '.[].name')

#ago=$(date -r $(($(date +%s) - 10800)) -Iseconds)
ago=$(date -r $(($(date +%s) - 3600)) -Iseconds)
echo "DEBUG: ago=$ago"
# echo "DEBUG: ago=$ago"

for repo in $repos; do
  echo "Checking repo $repo"
  # For each repo, get the check suite ID
  check_suite_ids=$(gh api "/repos/$ORG/$repo/actions/runs" --jq .workflow_runs.[].check_suite_id)
#   echo "DEBUG: check_suite_ids=$check_suite_ids"

  # For each suite, get the annotation URLs
  for check_suite_id in $check_suite_ids; do
    echo "Checking for REPO: $repo"
    annotation_urls=$(gh api "/repos/$ORG/$repo/check-suites/$check_suite_id/check-runs" --jq .check_runs.[].output.annotations_url)
    # echo "DEBUG: annotation_urls=$annotation_urls"

    # from each annotation url, get the message
    for url in $annotation_urls; do
      message=$(gh api "$url" --jq .[].message)
      if [[ -n "$message" ]]; then
        echo "- $message"
      fi
    done
  done
  echo ""
done
