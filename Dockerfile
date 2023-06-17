FROM cloudron/base:4.0.0@sha256:31b195ed0662bdb06a6e8a5ddbedb6f191ce92e8bee04c03fb02dd4e9d0286df

ARG VERSION=4.14.0
ARG DEB=code-server_${VERSION}_amd64.deb
ARG URL=https://github.com/coder/code-server/releases/download/v${VERSION}/${DEB}
ARG USER=cloudron
ARG HOME=/home/${USER}

RUN apt update && apt install -y docker.io
RUN curl -L -O ${URL} && apt install ./${DEB} && rm ${DEB}

COPY config.yaml ${HOME}/.config/code-server/config.yaml
COPY start.sh /app/pkg/start.sh

RUN ln -s /run/.cache/ ${HOME}/.cache \
    && ln -s /app/data/ ${HOME}/data \
    && chown -R ${USER}:${USER} ${HOME}

CMD [ "/app/pkg/start.sh" ]
