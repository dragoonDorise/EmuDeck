FROM --platform=linux/amd64 archlinux:latest

RUN pacman -Sy --disable-sandbox --noconfirm --needed bash git jq rsync python unzip which && pacman -Scc --noconfirm
RUN python -m venv /opt/emudeck-test-venv && /opt/emudeck-test-venv/bin/pip install -q requests vdf screeninfo
RUN git config --global --add safe.directory '*'

ENV EMUDECK_TEST_VENV=/opt/emudeck-test-venv
WORKDIR /repo
ENTRYPOINT ["bash", "tests/migration/compare.sh"]
