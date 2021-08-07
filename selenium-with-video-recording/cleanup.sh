#!/bin/bash

ROOT_DIR=$(dirname "$(pwd)")

kubectl delete \
    -f "$ROOT_DIR/common/app/service-app.yaml" \
    -f "$ROOT_DIR/common/app/deployment-app.yaml" \
    -f selenium/service-selenium-grid.yaml \
    -f selenium/service-selenium-video-status.yaml \
    -f selenium/pv-volume.yaml \
    -f selenium/pv-claim.yaml \
    -f selenium/deployment-selenium.yaml \
    -f tests/pod-tests.yaml
