FROM debian:stable-slim

RUN apt-get update && apt-get install -y --no-install-recommends bash git jq rsync python3 python3-venv unzip debianutils ca-certificates && rm -rf /var/lib/apt/lists/*
RUN python3 -m venv /opt/emudeck-test-venv && /opt/emudeck-test-venv/bin/pip install -q requests vdf screeninfo
RUN git config --global --add safe.directory '*'

ENV EMUDECK_TEST_VENV=/opt/emudeck-test-venv
WORKDIR /repo
ENTRYPOINT ["bash", "tests/migration/compare.sh"]
