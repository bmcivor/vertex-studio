FROM python:3.14.2-slim

ENV PYTHONUNBUFFERED=1
# ansible-vault edit shells out to $EDITOR. Without this the documented command
# fails before it opens anything, which is what happened the first time anyone
# tried to rotate a secret.
ENV EDITOR=vim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openssh-client \
    git \
    dnsutils \
    vim \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir ansible-core==2.20.1

RUN ansible-galaxy collection install community.general:==12.2.0

WORKDIR /app

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["ansible --version"]
