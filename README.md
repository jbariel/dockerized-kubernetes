# Kubernetes (K8) running in Docker
This project is to get [Kubernetes](https://kubernetes.io/) running locally in Docker.  Notes below.

# Security
K8 is moving to systems that require secure connectivity, so the core security is built into the base `kubectl` image.

# Running
By default, the `docker-compose` will run a single instance of each of the following:
- `kubectl` => used to issue commands, also the base image
- `etcd` => Builds out an [etcd]() instance for [k8](https://kubernetes.io/docs/concepts/overview/components/#etcd)
- `kube-api-server` => Builds out the k8 [api-server](https://kubernetes.io/docs/concepts/overview/components/#kube-apiserver)
- `kube-scheduler` => Builds out the k8 [scheduler](https://kubernetes.io/docs/concepts/overview/components/#kube-scheduler)
- `kube-controller-manager` => Builds out the k8 [controller-manager](https://kubernetes.io/docs/concepts/overview/components/#kube-controller-manager)
- `kubelet` => Builds out three (3) [kubelet nodes](https://kubernetes.io/docs/concepts/overview/components/#node-components)

## Configuration
The `.env` file contains values that will be used by `docker-compose`.  _CAUTION: only update these if you know what you're doing!!_

## Compose run command:
`docker-compose up` or `docker-compose up -d` for a daemonized version

# Attribution
This is _loosely_ based on [Kubernetes the Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way), with several liberties and customizations done to manage services as individual containers vs daemons on a single machine.

# License
This project is licensed under Apache-2.0.
