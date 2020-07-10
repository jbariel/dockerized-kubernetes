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

function _start_apiserver
{
    /usr/local/bin/kube-apiserver \
        --advertise-address=${KUBE_IP} \
        --allow-privileged=true \
        --apiserver-count=1 \
        --audit-log-maxage=30 \
        --audit-log-maxbackup=3 \
        --audit-log-maxsize=100 \
        --audit-log-path=/var/log/audit.log \
        --authorization-mode=Node,RBAC \
        --bind-address=0.0.0.0 \
        --client-ca-file=/var/lib/kubernetes/ca.pem \
        --enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \
        --etcd-cafile=/var/lib/kubernetes/ca.pem \
        --etcd-certfile=/var/lib/kubernetes/etcd.pem \
        --etcd-keyfile=/var/lib/kubernetes/etcd-key.pem \
        --etcd-servers=https://${K8_ETCD_IP}:2379 \
        --event-ttl=1h \
        --encryption-provider-config=/var/lib/kubernetes/encryption-config.yaml \
        --external-hostname=kube-apiserver
        --kubelet-certificate-authority=/var/lib/kubernetes/ca.pem \
        --kubelet-client-certificate=/var/lib/kubernetes/kubernetes.pem \
        --kubelet-client-key=/var/lib/kubernetes/kubernetes-key.pem \
        --runtime-config=api/all=true \
        --service-account-key-file=/var/lib/kubernetes/service-account.pem \
        --service-cluster-ip-range="${K8_NET_SVC_IP_RANGE}" \
        --service-node-port-range=30000-32767 \
        --tls-cert-file=/var/lib/kubernetes/kubernetes.pem \
        --tls-private-key-file=/var/lib/kubernetes/kubernetes-key.pem \
        --v=2
}

function _start_controller_manager
{
    /usr/local/bin/kube-controller-manager \
        --bind-address=0.0.0.0 \
        --cluster-cidr=${K8_NET_IP_RANGE} \
        --cluster-name=dockerized-kubernetes \
        --cluster-signing-cert-file=/var/lib/kubernetes/ca.pem \
        --cluster-signing-key-file=/var/lib/kubernetes/ca-key.pem \
        --kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig \
        --leader-elect=true \
        --root-ca-file=/var/lib/kubernetes/ca.pem \
        --service-account-private-key-file=/var/lib/kubernetes/service-account-key.pem \
        --service-cluster-ip-range="${K8_NET_SVC_IP_RANGE}" \
        --use-service-account-credentials=true \
        --v=2
}

function _start_scheduler
{
    /usr/local/bin/kube-scheduler \
        --config=/var/lib/kubernetes/kube-scheduler.yaml \
        --v=2
}

if [ "$1" = 'all' ]; then
    _start_controller_manager &
    _start_scheduler &
    _start_apiserver
else
    exec "$@"
fi
