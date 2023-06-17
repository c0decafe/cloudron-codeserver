#!/bin/bash

set -eu

OWN="cloudron:cloudron"
GSU="/usr/local/bin/gosu $OWN"
ENV="/app/data/env"

if [[ ! -f $ENV  ]]; then
     $GSU cat > $ENV <<EOF
CS_DISABLE_GETTING_STARTED_OVERRIDE=false
FOLDER=/app/data/workspace
EOF
fi

source $ENV

export XDG_DATA_HOME=/app/data/.local/share
export XDG_STATE_HOME=/app/data/.local/state
export XDG_CACHE_HOME=/run/.cache

if [ -n "$FOLDER" ]; then
     mkdir -p $FOLDER
fi

echo "==> Ensure permissions"
chown -R $OWN /run/.cache /app/data

if [[ ! -f /app/data/.initialized  ]]; then
     echo "Fresh installation, init"
     $GSU code-server --install-extension Gitlab.gitlab-workflow
     touch /app/data/.initialized
fi

if [[ -d /app/data/.vscode/logs  ]]; then
      $GSU mv /app/data/.vscode/logs /run
      $GSU ln -s /run/logs /app/data/.vscode/logs
fi

echo "==> Starting code-server"
exec $GSU code-server $FOLDER
