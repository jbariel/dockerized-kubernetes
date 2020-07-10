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

ARG KUBECTL_TAG

FROM kubectl:${KUBECTL_TAG}

ARG K8_VERSION
ARG CRICTL_VERSION
ARG RUNC_VERSION
ARG CNI_VERSION
ARG CONTAINERD_VERSION

WORKDIR /k8/kubelet

RUN apk -U --no-cache add socat conntrack-tools ipset wget && \
    for I in kube-proxy kubelet; do \
    curl https://storage.googleapis.com/kubernetes-release/release/${K8_VERSION}/bin/linux/amd64/${I} --output /usr/local/bin/${I}; \
    chown +x /usr/local/bin/${I}; \
    done && \
    wget -q --show-progress --https-only --timestamping \
    https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz \
    https://github.com/opencontainers/runc/releases/download/${RUNC_VERSION}/runc.amd64 \
    https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-amd64-${CNI_VERSION}.tgz \
    https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION}.linux-amd64.tar.gz
