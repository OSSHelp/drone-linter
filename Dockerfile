FROM hadolint/hadolint:v1.19.0-alpine as hadolint
FROM koalaman/shellcheck:v0.7.1 as shellcheck

FROM alpine:3.10.5 as python_linters
COPY requirements.txt /tmp/
# hadolint ignore=DL3018
RUN apk add --no-cache python3 \
    && pip3 install -r /tmp/requirements.txt

FROM alpine:3.10.5 as nodelinters
# hadolint ignore=DL3018
RUN apk add --no-cache npm \
    && npm i -g markdownlint-cli jsonlint

FROM alpine:3.10.5
# hadolint ignore=DL3018
RUN apk add --no-cache bash python3 nodejs \
    && ln -s ../lib/node_modules/markdownlint-cli/markdownlint.js /usr/bin/markdownlint \
    && ln -s ../lib/node_modules/jsonlint/lib/cli.js /usr/bin/jsonlint

COPY entrypoint.sh /usr/local/bin/
COPY confs/*.yml /etc/
COPY --from=hadolint /bin/hadolint /usr/bin/
COPY --from=shellcheck /bin/shellcheck /usr/bin/
COPY --from=python_linters /usr/lib/python3.7/site-packages/ /usr/lib/python3.7/site-packages/
COPY --from=python_linters /usr/bin/yamllint /usr/bin/
COPY --from=python_linters /usr/bin/flake8 /usr/bin/
COPY --from=nodelinters /usr/lib/node_modules/ /usr/lib/node_modules/
ENTRYPOINT ["entrypoint.sh"]
