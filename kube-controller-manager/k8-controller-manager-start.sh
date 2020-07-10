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

if [ "$1" = 'controller-manager' ]; then
    /usr/local/bin/kube-controller-manager \
        --bind-address=0.0.0.0 \
        --cluster-cidr=172.18.0.0/20 \
        --cluster-name=dockerized-kubernetes \
        --cluster-signing-cert-file=/var/lib/kubernetes/ca.pem \
        --cluster-signing-key-file=/var/lib/kubernetes/ca-key.pem \
        --kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig \
        --leader-elect=true \
        --root-ca-file=/var/lib/kubernetes/ca.pem \
        --service-account-private-key-file=/var/lib/kubernetes/service-account-key.pem \
        --service-cluster-ip-range=172.18.15.0/24 \
        --use-service-account-credentials=true \
        --v=2
else
    exec "$@"
fi