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

K8_ETCD_HOSTNAME=$(hostname)

if [ "$1" = 'etcd' ]; then
    /usr/local/bin/etcd \
        --name ${K8_ETCD_HOSTNAME} \
        --logger=zap \
        --cert-file=/etc/etcd/etcd.pem \
        --key-file=/etc/etcd/etcd-key.pem \
        --peer-cert-file=/etc/etcd/etcd.pem \
        --peer-key-file=/etc/etcd/etcd-key.pem \
        --trusted-ca-file=/etc/etcd/ca.pem \
        --peer-trusted-ca-file=/etc/etcd/ca.pem \
        --peer-client-cert-auth \
        --auto-tls=true \
        --client-cert-auth \
        --initial-advertise-peer-urls https://${K8_ETCD_IP}:2380 \
        --listen-peer-urls https://${K8_ETCD_IP}:2380 \
        --listen-client-urls https://${K8_ETCD_IP}:2379 \
        --advertise-client-urls https://${K8_ETCD_IP}:2379 \
        --initial-cluster-token etcd-cluster-0 \
        --initial-cluster ${K8_ETCD_HOSTNAME}=https://${K8_ETCD_IP}:2380 \
        --initial-cluster-state new \
        --data-dir=/var/lib/etcd
else
    exec "$@"
fi
