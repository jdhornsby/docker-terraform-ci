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
  zip

RUN pip install --no-cache-dir --upgrade pip awscli

ENV TERRAFORM_VERSION 0.12.20

RUN wget --quiet -O terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
  unzip terraform.zip -d /usr/local/bin && \
  rm -f terraform.zip

ENV TERRAGRUNT_VERSION 0.22.3

ADD https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 /usr/local/bin/terragrunt

RUN chmod +x /usr/local/bin/terragrunt

RUN npm init -y \
    && npm install @commitlint/cli \
    && npm install @commitlint/config-conventional \
    && npm install @semantic-release/changelog \
    && npm install @semantic-release/commit-analyzer \
    && npm install @semantic-release/git \
    && npm install @semantic-release/release-notes-generator \
    && npm install husky \
    && npm install jest \
    && npm install lint-staged \
    && npm install semantic-release \
    && npm install terraunit
RUN rm package*.json

ENV GOLANG_VERSION 1.13.8

RUN goRelArch='linux-amd64'; \
    goRelSha256='0567734d558aef19112f2b2873caa0c600f1b4a5827930eb5a7f35235219e9d8' && \
    wget --quiet -O go.tgz https://golang.org/dl/go${GOLANG_VERSION}.${goRelArch}.tar.gz && \
	echo "$goRelSha256 *go.tgz" | sha256sum -c - && \
	tar -C /usr/local -xzf go.tgz && \
	rm go.tgz && \
	mkdir /lib64 && \
	ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2 && \
	export PATH="/usr/local/go/bin:$PATH" && \
	go version

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && \
    go get github.com/gruntwork-io/terratest/modules/terraform && \
    go get -u github.com/golang/dep/cmd/dep

WORKDIR $GOPATH/src/github.com/gruntwork-io/terratest/modules/terraform

RUN go install

WORKDIR $GOPATH/src/app/test/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["node"]
