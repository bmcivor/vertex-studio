FROM python:3.14.2-slim

ENV PYTHONUNBUFFERED=1

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openssh-client \
    git \
    dnsutils \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir ansible-core==2.20.1

RUN ansible-galaxy collection install community.general:==12.2.0

WORKDIR /app

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["ansible --version"]
