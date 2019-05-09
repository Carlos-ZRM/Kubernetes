#!/bin/bash
kubectl run hello-world --replicas=2 --labels="run=load-balancer-example" --image=gcr.io/google-samples/node-hello:1.0  --port=8080
kubectl get deployments hello-world
kubectl describe deployments hello-world
kubectl get replicasets
kubectl describe replicasets
kubectl expose deployment hello-world --type=NodePort --name=example-service
kubectl describe services example-service
kubectl get pods --selector="run=load-balancer-example" --output=wide
