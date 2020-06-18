# Kubernetes (K8) running in Docker
This project is to get [Kubernetes](https://kubernetes.io/) running locally in Docker.  Notes below.

# Running
By default, the `docker-compose` will run a single instance of each of the following:
- `kubectl` => used to issue commands, also the base image
- `kube-api-server` =>
- `kube-scheduler` =>
- `kube-controller-manager` =>
- `etcd` =>
It will also run three (3) `kubelet` workers acting as nodes for deployment.

## Configuration
The `.env` file contains values that will be used by `docker-compose`.  _CAUTION: only update these if you know what you're doing!!_

## Compose run command:
`docker-compose up` or `docker-compose up -d` for a daemonized version

# License
This project is licensed under Apache-2.0.
