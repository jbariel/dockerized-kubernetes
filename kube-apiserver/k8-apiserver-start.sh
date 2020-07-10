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

# see `docker-compose.yml`
# |||jbariel TODO => should probably turn most of the IPs into ENV variables and generate
#    passthrough values to prevent fat-fingering....
ECTD_IP=172.18.6.90
K8_APISERVER_IP=172.18.6.100

if [ "$1" = 'apiserver' ]; then
    /usr/local/bin/kube-apiserver \
        --advertise-address=${K8_APISERVER_IP} \
        --allow-privileged=true \
        --apiserver-count=3 \
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
        --etcd-servers=https://${ECTD_IP}:2379 \
        --event-ttl=1h \
        --encryption-provider-config=/var/lib/kubernetes/encryption-config.yaml \
        --kubelet-certificate-authority=/var/lib/kubernetes/ca.pem \
        --kubelet-client-certificate=/var/lib/kubernetes/kubernetes.pem \
        --kubelet-client-key=/var/lib/kubernetes/kubernetes-key.pem \
        --runtime-config=api/all=true \
        --service-account-key-file=/var/lib/kubernetes/service-account.pem \
        --service-cluster-ip-range=172.18.15.0/24 \
        --service-node-port-range=30000-32767 \
        --tls-cert-file=/var/lib/kubernetes/kubernetes.pem \
        --tls-private-key-file=/var/lib/kubernetes/kubernetes-key.pem \
        --v=2
else
    exec "$@"
fi