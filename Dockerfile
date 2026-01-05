FROM python:3-slim

ENV PYTHONUNBUFFERED=1

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openssh-client \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir ansible-core

RUN ansible-galaxy collection install community.general

WORKDIR /app

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["ansible --version"]
