gcloud services enable apigateway.googleapis.com
cd task1
while true; do
  deployment_result=$(gcloud functions deploy GCFunction \
    --region=$REGION \
    --runtime=nodejs18 \
    --max-instances 3 \
    --entry-point=helloWorld \
    --trigger-http \
    --allow-unauthenticated \
    --gen2 \
    --source=. 2>&1)
  if echo "$deployment_result" | grep -q "state: ACTIVE"; then
    echo "Cloud function deployed successfully Cloud Hustlers"
    break
  else
    echo "Retrying in 5 seconds..."
    sleep 5
  fi
done
gcloud functions add-invoker-policy-binding GCFunction \
--region=$REGION \
--member="allUsers"
cd ../task2
export PROJECT_NUMBER=$(gcloud projects describe $DEVSHELL_PROJECT_ID --format="value(projectNumber)")
gcloud api-gateway apis create gcfunction-api-dev \
--project=$DEVSHELL_PROJECT_ID
gcloud api-gateway api-configs create gcfunction-api \
--api=gcfunction-api-dev \
--openapi-spec=openapispec.yaml \
--backend-auth-service-account=$PROJECT_NUMBER-compute@developer.gserviceaccount.com
gcloud api-gateway gateways create gcfunction-api \
--api=gcfunction-api-dev \
--api-config=gcfunction-api \
--location=$REGION
cd ../task3
gcloud pubsub topics create demo-topic
gcloud functions deploy GCFunction \
--runtime=nodejs18 \
--trigger-http \
--allow-unauthenticated \
--entry-point=helloWorld \
--region=$REGION \
--max-instances 3 \
--gen2 \
--source=.