# Single Selenium node with video recording

This testing infrastructure consists of 3 Pods:

1. Application (website displaying and refreshing current time with milliseconds) - simple Flask server
2. Selenium - Pod with 2 containers, both from [Selenium Grid Server](https://github.com/SeleniumHQ/docker-selenium) repository
   * Selenium server (`standalone-chrome` image)
   * `video` image - recording remote display from Selenium server
3. E2E tests project (tests runner) - simple Pytest tests using Selenium remote browser

---

Run below commands from `selenium-with-video-recording` directory.


## Application

Build Docker image
```bash
docker build -t ui-tests/app-clock app
```

Push image to minikube
```bash
minikube image load ui-tests/app-clock
```

Deploy to K8s
```bash
kubectl apply \
    -f app/service-app.yaml \
    -f app/deployment-app.yaml
```

Display logs
```bash
kubectl logs --tail=-1 -l component=app
```


## Selenium Server

Deploy to K8s
```bash
kubectl apply \
    -f selenium/service-selenium-grid.yaml \
    -f selenium/pv-volume.yaml \
    -f selenium/pv-claim.yaml \
    -f selenium/deployment-selenium.yaml
```

Display logs
```bash
kubectl logs --tail=-1 -l component=selenium -c selenium-4-standalone-chrome
kubectl logs --tail=-1 -l component=selenium -c selenium-video
```


## Tests runner

Build and push image
```bash
docker build -t ui-tests/tests-video-runner tests
minikube image load ui-tests/tests-video-runner
```

Deploy to K8s, run tests and exit
```bash
kubectl apply -f tests/pod-tests.yaml
```

Display logs
```bash
kubectl logs --tail=-1 -l component=tests
```


## Access to video

At this moment (August 2021) video recording feature is simple with limited configuration possibilities. It starts recording as soon as remote screen is available and stops only when container is shut down.

It has 25s non-configurable timeout waiting for the remote screen. When you start Pod with Selenium server and video containers, this timeout could be exceeded when Selenium image is being downloaded for the first time.

The way of accessing video file depends on infrastructure and can be solved many ways. In this learning example it's saved in K8s node (minikube).

Video file can be copied only after graceful shutdown of the container, when `ffmpeg` saves all the data. Otherwise, file will be corrupted.

When tests finished, terminate containers
```bash
kubectl delete -f selenium/deployment-selenium.yaml
```

Copy file from minikube node
```bash
scp -i $(minikube ssh-key) docker@$(minikube ip):/tmp/data/video.mp4 ./video.mp4
```
