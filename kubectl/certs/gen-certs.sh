#!/bin/sh

set -e

# Create the root cert
cfssl gencert -initca ca-csr.json | cfssljson -bare ca
# Yields =>
#   ca-key.pem
#   ca.pem

BASE_CERT_PARAMS="-ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes"

K8_API_SERVER_IP=172.18.6.130

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
    sed "s/CERTNAME_HERE/${2}/g" generic-csr.json > ${1}-csr.json
    sed -i "s/CERTORG_HERE/${3}/g" ${1}-csr.json
    cfssl gencert ${4} ${1}-csr.json | cfssljson -bare ${1}

    kubectl config set-cluster dockerized-kubernetes \
        --certificate-authority=ca.pem \
        --embed-certs=true \
        --server=https://${K8_API_SERVER_IP}:6443 \
        --kubeconfig=${1}.kubeconfig

    kubectl config set-credentials ${2} \
        --client-certificate=${1}.pem \
        --client-key=${1}-key.pem \
        --embed-certs=true \
        --kubeconfig=${1}.kubeconfig

    kubectl config set-context default \
        --cluster=dockerized-kubernetes \
        --user=${2} \
        --kubeconfig=${1}.kubeconfig

    kubectl config use-context default --kubeconfig=${1}.kubeconfig
}

# Create the admin cert
genCsrAndCertAndConfig 'admin' 'admin' 'system:masters' "${BASE_CERT_PARAMS}"

# Create the client cert(s)
for I in {0..2}; do
    genCsrAndCertAndConfig


 "kublet-${I}" "system:node:kublet_${I}" 'system:nodes' "${BASE_CERT_PARAMS} -hostname=kublet_${I},172.18.6.18${I}"
done

# Create the kube controller manager client cert
genCsrAndCertAndConfig 'kube-controller-manager' 'system:kube-controller-manager' 'system:kube-controller-manager' "${BASE_CERT_PARAMS} -hostname=172.18.6.100,kube-controller-manager"



# Create the kube proxy client cert
genCsrAndCertAndConfig 'kube-proxy' 'system:kube-proxy' 'system:node-proxier' "${BASE_CERT_PARAMS}"



# Create the kube scheduler client cert
genCsrAndCertAndConfig 'kube-scheduler' 'system:kube-scheduler' 'system:kube-scheduler' "${BASE_CERT_PARAMS} -hostname=172.18.6.120,kube-scheduler"



# Create the kube api server cert
genCsrAndCertAndConfig 'kubernetes' 'kubernetes' 'Kubernetes' "${BASE_CERT_PARAMS} -hostname=${K8_API_SERVER_IP},kube-api-server"



# Create the kube service accounts cert
genCsrAndCertAndConfig 'service-account' 'service-accounts' 'Kubernetes Service Accounts' "${BASE_CERT_PARAMS}"


