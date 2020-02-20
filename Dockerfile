FROM node:13-alpine

RUN apk add --no-cache \
  python \
  py-pip \
  py-setuptools \
  ca-certificates \
  openssl \
  openssh-client \
  groff \
  less \
  bash \
  curl \
  jq \
  git \
  zip && \
  pip install --no-cache-dir --upgrade pip awscli

ENV TERRAFORM_VERSION 0.12.20

RUN wget -O terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
  unzip terraform.zip -d /usr/local/bin && \
  rm -f terraform.zip

ENV TERRAGRUNT_VERSION 0.22.3

ADD https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 /usr/local/bin/terragrunt

RUN chmod +x /usr/local/bin/terragrunt

RUN npm init -y
RUN npm install @commitlint/cli
RUN npm install @commitlint/config-conventional
RUN npm install @semantic-release/changelog
RUN npm install @semantic-release/commit-analyzer
RUN npm install @semantic-release/git
RUN npm install @semantic-release/release-notes-generator
RUN npm install husky
RUN npm install jest
RUN npm install lint-staged
RUN npm install semantic-release
RUN npm install terraunit
RUN rm package*.json

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["node"]