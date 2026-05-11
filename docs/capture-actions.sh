#!/bin/bash

START_TIME="2026-05-10T15:48:27Z"
END_TIME="2026-05-10T16:01:18Z"
REGION="eu-west-1"
IAM_REGION="us-east-1"
ROLE_NAME="github-actions-eks-role"

> all-events.json
> all-iam-events.json

echo "=== Fetching $REGION events ==="
NEXT_TOKEN=""
while true; do
  if [ -z "$NEXT_TOKEN" ]; then
    RESPONSE=$(aws cloudtrail lookup-events \
      --lookup-attributes AttributeKey=Username,AttributeValue=GitHubActions \
      --start-time "$START_TIME" \
      --end-time "$END_TIME" \
      --region "$REGION" \
      --output json)
  else
    RESPONSE=$(aws cloudtrail lookup-events \
      --lookup-attributes AttributeKey=Username,AttributeValue=GitHubActions \
      --start-time "$START_TIME" \
      --end-time "$END_TIME" \
      --region "$REGION" \
      --next-token "$NEXT_TOKEN" \
      --output json)
  fi

  echo "$RESPONSE" | jq -r '.Events[].CloudTrailEvent' >> all-events.json

  NEXT_TOKEN=$(echo "$RESPONSE" | jq -r '.NextToken // empty')
  echo "NextToken: '$NEXT_TOKEN' | Events in page: $(echo "$RESPONSE" | jq '.Events | length')"
  [ -z "$NEXT_TOKEN" ] && break
done

echo ""
echo "=== Fetching $IAM_REGION IAM events ==="
NEXT_TOKEN=""
while true; do
  if [ -z "$NEXT_TOKEN" ]; then
    RESPONSE=$(aws cloudtrail lookup-events \
      --lookup-attributes AttributeKey=EventSource,AttributeValue=iam.amazonaws.com \
      --start-time "$START_TIME" \
      --end-time "$END_TIME" \
      --region "$IAM_REGION" \
      --output json)
  else
    RESPONSE=$(aws cloudtrail lookup-events \
      --lookup-attributes AttributeKey=EventSource,AttributeValue=iam.amazonaws.com \
      --start-time "$START_TIME" \
      --end-time "$END_TIME" \
      --region "$IAM_REGION" \
      --next-token "$NEXT_TOKEN" \
      --output json)
  fi

  echo "$RESPONSE" | jq -r '.Events[].CloudTrailEvent' >> all-iam-events.json

  NEXT_TOKEN=$(echo "$RESPONSE" | jq -r '.NextToken // empty')
  echo "NextToken: '$NEXT_TOKEN' | Events in page: $(echo "$RESPONSE" | jq '.Events | length')"
  [ -z "$NEXT_TOKEN" ] && break
done

echo ""
echo "=== Combined unique actions ==="
#(
#  jq -rn '[inputs | "\((.eventSource | split(".")[0])):\(.eventName)"] | unique[]' all-events.json
#  jq -rn '[inputs | select(.userIdentity.arn | contains("github-actions-eks-role")) | "iam:\(.eventName)"] | unique[]' all-iam-events.json
#) | sort -u | tee all-actions.txt
#

(jq -n '[inputs | "\((.eventSource | split(".")[0])):\(.eventName)"]' all-events.json;
 jq -n '[inputs | select(.userIdentity.arn | contains("github-actions-eks-role")) | "iam:\(.eventName)"]' all-iam-events.json; ) | \
 jq -n '[inputs | .[]] | unique' | tee all-actions.json

echo ""
echo "=== Total unique action count ==="
jq '. | length' all-actions.json