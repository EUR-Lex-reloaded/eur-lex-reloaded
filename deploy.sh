#!/usr/bin/env bash
# by Markus Melcher (merlin)
#
# Deploy toccata from git repo, adjusting shebang line with path to proper Ruby version

set -e

REPO_PATH="${HOME}/toccata.git/"
DEPLOY_BRANCH="master"
DEST_PATH="${HOME}/cgi-bin/"
SCRIPT_NAME="toccata.rb"
RUBY_PATH="$(which ruby)"

cd "${REPO_PATH}"
git show "${DEPLOY_BRANCH}:${SCRIPT_NAME}" | sed -e "1d" -e "2i\\
#!/usr/bin/env ${RUBY_PATH}" >"${DEST_PATH}${SCRIPT_NAME}"
chmod +x "${DEST_PATH}${SCRIPT_NAME}"
