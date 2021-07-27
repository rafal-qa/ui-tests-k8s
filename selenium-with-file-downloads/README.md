# Single Selenium node with file downloads

Run below commands from `selenium-with-file-downloads` directory.


## Application

Build Docker image
```bash
docker build -t ui-tests/app-with-file app
```

(Optional) Check if app works before using in K8s
```bash
docker run -p 3000:3000 ui-tests/app-with-file
```

Push image to minikube
```bash
minikube image load ui-tests/app-with-file
```

Deploy to K8s
```bash
kubectl apply \
    -f app/service-app.yml \
    -f app/deployment-app.yml
```

Display logs
```bash
kubectl logs --tail=-1 -l component=app
```


## Selenium (Chrome browser)

Deploy to K8s
```bash
kubectl apply \
    -f selenium/service-selenium-grid.yml \
    -f selenium/service-selenium-vnc.yml \
    -f selenium/deployment-selenium.yml
```

Display logs
```bash
kubectl logs --tail=-1 -l component=selenium
```

(Optional) Connect to Selenium container using VNC viewer to check if works
1. Run `minikube service --url selenium-vnc-service` to get IP and port (remove `http://`)
2. Connect using VNC
3. Open browser and go to app URL `http://app-service:3000`


## Test runner

Build Docker image
```bash
docker build -t ui-tests/tests-runner tests
```

Push image to minikube
```bash
minikube image load ui-tests/tests-runner
```

Deploy to K8s, run tests and exit
```bash
kubectl apply -f tests/pod-tests.yml
```

Display logs
```bash
kubectl logs --tail=-1 -l component=tests
```

## TODO

* Selenium Grid healthcheck
* File downloads service
