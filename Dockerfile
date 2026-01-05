FROM python:3-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openssh-client \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir ansible-core

WORKDIR /app

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["ansible --version"]
