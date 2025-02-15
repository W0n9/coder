FROM ghcr.io/coder/coder:v2.18.2

USER root

RUN apk add curl unzip

# Create directory for the Terraform CLI (and assets)
RUN mkdir -p /opt/terraform

# # Terraform is already included in the official Coder image.
# # See https://github.com/coder/coder/blob/main/scripts/Dockerfile.base#L15
# # If you need to install a different version of Terraform, you can do so here.
# # The below step is optional if you wish to keep the existing version.
# # See https://github.com/coder/coder/blob/main/provisioner/terraform/install.go#L23-L24
# # for supported Terraform versions.
# ARG TERRAFORM_VERSION=1.5.6
# RUN apk update && \
#     apk del terraform && \
#     curl -LOs https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
#     && unzip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
#     && mv terraform /opt/terraform \
#     && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
# ENV PATH=/opt/terraform:${PATH}

# Additionally, a Terraform mirror needs to be configured
# to download the Terraform providers used in Coder templates.
# There are two options:

# Option 1) Use a filesystem mirror.
#  We can seed this at build-time or by mounting a volume to
#  /opt/terraform/plugins in the container.
#  https://developer.hashicorp.com/terraform/cli/config/config-file#filesystem_mirror
#  Be sure to add all the providers you use in your templates to /opt/terraform/plugins

RUN mkdir -p /home/coder/.terraform.d/plugins/registry.terraform.io
ADD filesystem-mirror-example.tfrc /home/coder/.terraformrc

# Optionally, we can "seed" the filesystem mirror with common providers.
# Comment out lines 40-49 if you plan on only using a volume or network mirror:
WORKDIR /home/coder/.terraform.d/plugins/registry.terraform.io

ARG CODER_PROVIDER_VERSION=2.1.0
RUN echo "Adding coder/coder v${CODER_PROVIDER_VERSION}" \
    && mkdir -p coder/coder && cd coder/coder \
    && curl -LOs https://github.com/coder/terraform-provider-coder/releases/download/v${CODER_PROVIDER_VERSION}/terraform-provider-coder_${CODER_PROVIDER_VERSION}_linux_amd64.zip

ARG DOCKER_PROVIDER_VERSION=3.0.2
RUN echo "Adding kreuzwerker/docker v${DOCKER_PROVIDER_VERSION}" \
    && mkdir -p kreuzwerker/docker && cd kreuzwerker/docker \
    && curl -LOs https://github.com/kreuzwerker/terraform-provider-docker/releases/download/v${DOCKER_PROVIDER_VERSION}/terraform-provider-docker_${DOCKER_PROVIDER_VERSION}_linux_amd64.zip

ARG KUBERNETES_PROVIDER_VERSION=2.35.1
RUN echo "Adding kubernetes/kubernetes v${KUBERNETES_PROVIDER_VERSION}" \
    && mkdir -p hashicorp/kubernetes && cd hashicorp/kubernetes \
    && curl -LOs https://releases.hashicorp.com/terraform-provider-kubernetes/${KUBERNETES_PROVIDER_VERSION}/terraform-provider-kubernetes_${KUBERNETES_PROVIDER_VERSION}_linux_amd64.zip

ARG HARVESTER_PROVIDER_VERSION=0.6.6
RUN echo "Adding harvester/harvester v${HARVESTER_PROVIDER_VERSION}" \
    && mkdir -p harvester/harvester && cd harvester/harvester \
    && curl -LOs https://github.com/harvester/terraform-provider-harvester/releases/download/v${HARVESTER_PROVIDER_VERSION}/terraform-provider-harvester_${HARVESTER_PROVIDER_VERSION}_linux_amd64.zip

RUN terraform init
RUN chown -R coder:coder /home/coder/.terraform*
WORKDIR /home/coder

# Option 2) Use a network mirror.
#  https://developer.hashicorp.com/terraform/cli/config/config-file#network_mirror
#  Be sure uncomment line 60 and edit network-mirror-example.tfrc to
#  specify the HTTPS base URL of your mirror.

# ADD network-mirror-example.tfrc /home/coder/.terraformrc

USER coder

# Use the .terraformrc file to inform Terraform of the locally installed providers.
ENV TF_CLI_CONFIG_FILE=/home/coder/.terraformrc