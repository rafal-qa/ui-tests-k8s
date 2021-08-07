# Application

Simple Flask application used in infrastructure examples.

---

Build Docker image
```bash
docker build -t ui-tests/app .
```

(Optional) Run with Docker only, without K8s
```bash
docker run -p 3000:3000 ui-tests/app
```

Push image to minikube
```bash
minikube image load ui-tests/app
```

Deploy to K8s
```bash
kubectl apply \
    -f service-app.yaml \
    -f deployment-app.yaml
```

Display logs
```bash
kubectl logs --tail=-1 -l component=app
```
