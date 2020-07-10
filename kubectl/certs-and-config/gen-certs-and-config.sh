#!/bin/bash

#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e

# Create the root cert
cfssl gencert -initca ca-csr.json | cfssljson -bare ca
# Yields =>
#   ca-key.pem
#   ca.pem

# These are core params we use when generating a cert, can be appended as needed...
BASE_CERT_PARAMS="-ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes"

# see `docker-compose.yml`
# |||jbariel TODO => should probably turn most of the IPs into ENV variables and generate
#    passthrough values to prevent fat-fingering....
K8_API_SERVER_IP=172.18.6.100

# Generate the CSR JSON file and the Cert.
#  $1 => base name
#  $2 => CERTNAME
#  $3 => CERTORG
#  $4 => `cfssl gencert` PARAMS
#
# Yields:
#  $1-csr.json
#  $1-key.pem
#  $1.pem
#  $1.kubeconfig
function genCsrAndCertAndConfig
{
    echo "Generating ${1}..."
    echo -e "\t${1}\n\t${2}\n\t${3}\n\t${4}"

    sed "s/CERTNAME_HERE/${2}/g" generic-csr.json > ${1}-csr.json
    sed -i "s/CERTORG_HERE/${3}/g" ${1}-csr.json
    cfssl gencert ${4} ${1}-csr.json | cfssljson -bare ${1}

    ## All the fun of k8 configuration based on certs
    kubectl config set-cluster dockerized-kubernetes --certificate-authority=ca.pem --embed-certs=true --server=https://${K8_API_SERVER_IP}:6443 --kubeconfig=${1}.kubeconfig
    kubectl config set-credentials ${2} --client-certificate=${1}.pem --client-key=${1}-key.pem --embed-certs=true --kubeconfig=${1}.kubeconfig
    kubectl config set-context default --cluster=dockerized-kubernetes --user=${2} --kubeconfig=${1}.kubeconfig
    kubectl config use-context default --kubeconfig=${1}.kubeconfig
}

# Create the admin cert
genCsrAndCertAndConfig 'admin' 'admin' 'system:masters' "${BASE_CERT_PARAMS}"

# Create the client cert(s)
for I in {0..2}; do
    genCsrAndCertAndConfig "kublet-${I}" "system:node:kublet_${I}" 'system:nodes' "${BASE_CERT_PARAMS} -hostname=kublet_${I},172.18.6.18${I}"
done

# Create the kube controller manager client cert
genCsrAndCertAndConfig 'kube-controller-manager' 'system:kube-controller-manager' 'system:kube-controller-manager' "${BASE_CERT_PARAMS} -hostname=172.18.6.110,kube-controller-manager"

# Create the kube proxy client cert
genCsrAndCertAndConfig 'kube-proxy' 'system:kube-proxy' 'system:node-proxier' "${BASE_CERT_PARAMS}"

# Create the kube scheduler client cert
genCsrAndCertAndConfig 'kube-scheduler' 'system:kube-scheduler' 'system:kube-scheduler' "${BASE_CERT_PARAMS} -hostname=172.18.6.120,kube-scheduler"

# kube scheduler config file
cat <<EOF | tee kube-scheduler.yaml
apiVersion: kubescheduler.config.k8s.io/v1beta1
kind: KubeSchedulerConfiguration
clientConnection:
  kubeconfig: "/var/lib/kubernetes/kube-scheduler.kubeconfig"
leaderElection:
  leaderElect: true
EOF

# Create the kube api server cert
genCsrAndCertAndConfig 'kubernetes' 'kubernetes' 'Kubernetes' "${BASE_CERT_PARAMS} -hostname=${K8_API_SERVER_IP},kube-apiserver"

# Create the kube api server cert
genCsrAndCertAndConfig 'etcd' 'etcd' 'K8 etcd' "${BASE_CERT_PARAMS} -hostname=172.18.6.90,etcd"

# Create the kube service accounts cert
genCsrAndCertAndConfig 'service-account' 'service-accounts' 'Kubernetes Service Accounts' "${BASE_CERT_PARAMS}"

# Encryption key for data at rest...
# @see https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/06-data-encryption-keys.md
ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
cat > encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF
