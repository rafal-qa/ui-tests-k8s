#!/bin/bash

LOGS_DIR="logs/$(date '+%Y-%m-%d_%H-%M-%S')"
mkdir -p "$LOGS_DIR"

# Create application
ROOT_DIR=$(dirname "$(pwd)")
kubectl apply \
  -f "$ROOT_DIR/common/app/service-app.yaml" \
  -f "$ROOT_DIR/common/app/deployment-app.yaml"

# Create Selenium server with video and wait for application
kubectl apply \
  -f selenium/service-selenium-grid.yaml \
  -f selenium/service-selenium-video-status.yaml \
  -f selenium/pv-volume.yaml \
  -f selenium/pv-claim.yaml \
  -f selenium/deployment-selenium.yaml

# Create tests runner and wait for Selenium
kubectl apply -f tests/pod-tests.yaml

# Wait for tests start
kubectl wait --timeout=300s --for=condition=Ready pod -l component=tests

# Wait for tests completion
kubectl wait --timeout=600s --for=condition=Ready=False pod -l component=tests

# Save logs from Selenium
LOGS_SELENIUM="$LOGS_DIR/selenium"
mkdir "$LOGS_SELENIUM"

for CONTAINER_NAME in "selenium-4-standalone-chrome" "selenium-video" "init-app"
do
  kubectl logs --tail=-1 -l component=selenium -c $CONTAINER_NAME > "$LOGS_SELENIUM/$CONTAINER_NAME.log"
done

# Stop Selenium pod
kubectl scale --replicas=0 -f selenium/deployment-selenium.yaml
kubectl wait --timeout=60s --for=delete pod -l component=selenium

# Save video file
scp -i "$(minikube ssh-key)" "docker@$(minikube ip):/tmp/data/video.mp4" "$LOGS_DIR/video.mp4"

# Save logs from app
kubectl logs --tail=-1 -l component=app > "$LOGS_DIR/app.log"

# Save logs from tests
LOGS_TESTS="$LOGS_DIR/tests"
mkdir "$LOGS_TESTS"

for CONTAINER_NAME in "tests-video-runner" "init-selenium-server" "init-selenium-video"
do
  kubectl logs --tail=-1 -l component=tests -c $CONTAINER_NAME > "$LOGS_TESTS/$CONTAINER_NAME.log"
done

# Get tests status (exit code)
TESTS_STATUS_CODE=$(kubectl get pod tests-runner-pod --output="jsonpath={.status.containerStatuses[].state.terminated.exitCode}")

# Delete infrastructure
./cleanup.sh

# Display tests result
echo "=============== Tests result ==============="
if [[ $TESTS_STATUS_CODE -eq 0 ]]
then
  echo "PASSED"
  exit 0
else
  echo "FAILED with exit code $TESTS_STATUS_CODE"
  exit 1
fi
