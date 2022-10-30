FROM debian:stable

RUN apt-get update && \
    apt-get install -y \
      wget \
      curl \
      zip \
      unzip \
      netcat-openbsd \
      git \
      python3 \
      python3-pip \
      python3-setuptools && \
    rm -rf /var/lib/apt/list/*

# [Terraform]
RUN wget --no-check-certificate https://releases.hashicorp.com/terraform/1.0.8/terraform_1.0.8_linux_amd64.zip
RUN unzip terraform_1.0.8_linux_amd64.zip
RUN mv terraform /usr/local/bin/

# [GO]
RUN wget --no-check-certificate https://golang.org/dl/go1.16.2.linux-amd64.tar.gz
RUN tar -C /usr/local -xzf go1.16.2.linux-amd64.tar.gz
ENV PATH="/usr/local/go/bin:/root/go/bin:/root/.local/bin:${PATH}"

# [Gitleaks]
RUN GO111MODULE=on go get github.com/zricethezav/gitleaks/v7

# [pre-commit]
RUN pip3 install pre-commit==2.6.0

# [github-markdown-toc]
RUN wget https://raw.githubusercontent.com/ekalinin/github-markdown-toc/master/gh-md-toc
RUN chmod a+x gh-md-toc
RUN mv gh-md-toc /usr/local/bin

ARG COMPONENT
WORKDIR /usr/src
COPY .util/lint/generic /usr/src
COPY $COMPONENT /usr/src/app
CMD ["/usr/src/run_lint_generic.sh"]
