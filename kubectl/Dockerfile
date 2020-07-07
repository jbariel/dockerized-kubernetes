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

FROM alpine:latest

ARG K8_VERSION
ARG CFSSL_VERSION

# Get everything installed
RUN apk -U --no-cache add bash curl && \
    mkdir -p /k8/certs-and-config && \
    curl https://storage.googleapis.com/kubernetes-release/release/${K8_VERSION}/bin/linux/amd64/kubectl --output /usr/local/bin/kubectl && \
    for I in cfssl cfssljson; do curl -L https://github.com/cloudflare/cfssl/releases/download/v${CFSSL_VERSION}/${I}_${CFSSL_VERSION}_linux_amd64 -o /usr/local/bin/$I; done && \
    for I in kubectl cfssl cfssljson; do chmod +x /usr/local/bin/$I; done && \
    kubectl version --client && \
    cfssl version && \
    cfssljson -version 

# Setup the certs
WORKDIR /k8/certs-and-config
COPY certs-and-config/ .

RUN chmod +x *.sh && \
    ./gen-certs-and-config.sh

WORKDIR /k8

CMD ["/bin/bash", "-l"]