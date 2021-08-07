# Single Selenium node with file downloads

This testing infrastructure consists of 3 Pods:

1. [Application](../common/app)
2. Selenium - Pod with 2 containers
   * [Selenium Grid Server](https://github.com/SeleniumHQ/docker-selenium)
   * Service for accessing downloaded files by HTTP. It's Nginx server which shares downloads directory with Selenium Server and displays files list in JSON format.
3. E2E tests project (tests runner) - simple Pytest tests using Selenium remote browser

---

Run below commands from `selenium-with-file-downloads` directory.


## Selenium Server

It uses version 3 image (stable).

Prepare file downloads API service
```bash
docker build -t ui-tests/downloads-api selenium/downloads
minikube image load ui-tests/downloads-api
```

Deploy to K8s
```bash
kubectl apply \
    -f selenium/service-selenium-grid.yml \
    -f selenium/service-selenium-downloads.yml \
    -f selenium/deployment-selenium.yml
```

Display logs
```bash
kubectl logs --tail=-1 -l component=selenium -c selenium-3-standalone-chrome
kubectl logs --tail=-1 -l component=selenium -c selenium-downloads-api
```


## Tests runner

Build and push image
```bash
docker build -t ui-tests/tests-download-runner tests
minikube image load ui-tests/tests-download-runner
```

Deploy to K8s, run tests and exit
```bash
kubectl apply -f tests/pod-tests.yml
```

Display logs
```bash
kubectl logs --tail=-1 -l component=tests
```

Alternative one-in-all command: Start tests, switch to log and cleanup
```bash
kubectl apply -f tests/pod-tests.yml \
    && kubectl wait --timeout=30s --for=condition=Ready pod -l component=tests \
    && kubectl logs --tail=-1 -f -l component=tests \
    && kubectl delete -f tests/pod-tests.yml
```

## Development / debugging

### See the browser and interact with it

1. Allow access to VNC server
```bash
kubectl apply -f selenium/dev/service-selenium-vnc-node.yml
```

2. Get VNC address
```bash
minikube service --url selenium-vnc-node-service | sed 's#http://##'
```

3. Connect using VNC, open browser and go to app URL `http://app-service:3000`

### Execute tests locally using K8s infrastructure

1. Allow access to Selenium Grid and downloads API
```bash
kubectl apply \
    -f selenium/dev/service-selenium-grid-node.yml \
    -f selenium/dev/service-selenium-downloads-node.yml
```

2. Get Selenium and downloads API hosts/IPs
```bash
minikube service --url selenium-grid-node-service
minikube service --url selenium-downloads-node-service
```

3. Run tests without container \
(replace `192.168.49.2` with IP from `minikube service` command) \
(run in `tests` directory)
```bash
DOWNLOADS_API_URL=http://192.168.49.2:30080 pytest -v \
    --base-url=http://app-service:3000 \
    --driver=Remote \
    --selenium-host=192.168.49.2 \
    --selenium-port=30044 \
    --capability browserName chrome
```

Remove downloaded file from Selenium Pod before rerunning test (assuming that only 1 `selenium` Pod is listed)
```bash
kubectl exec \
    $(kubectl get pods -l component=selenium --no-headers -o custom-columns=":metadata.name") \
    -c selenium-downloads-api \
    -- rm /usr/share/nginx/html/file.bin
```
