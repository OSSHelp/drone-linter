#!/bin/bash
# shellcheck disable=SC2015

[ "${PLUGIN_DEBUG}" = "true" ] && { set -x; env; }

# no new line
function show_pre_notice() { echo -en "\e[34m[NOTICE. $(date '+%Y/%m/%d-%H:%M:%S')]\e[39m ${1}"; }
# standart output
function show_notice()  { echo -e "\e[34m[NOTICE. $(date '+%Y/%m/%d-%H:%M:%S')]\e[39m ${1}"; }
function show_warning() { echo -e "\e[31m[WARNING. $(date '+%Y/%m/%d-%H:%M:%S')]\e[39m ${1}" >&2; err=1; }
function show_error()   { echo -e "\e[31m[ERROR. $(date '+%Y/%m/%d-%H:%M:%S')]\e[39m ${1}" >&2; exit 1; }

function find_yml_files() {
    find . -iname '*.yml' -o -iname '*.yaml' | grep -v '\./vault.yml' | sed 's|./||' | grep -vE "$exclude_regex"
}

function find_shell_scripts() {
    grep -rlE '#!/bin/(bash|sh)' . | grep -vE '\.(git|j2$|md$)' | sed 's|./||' | grep -vE "$exclude_regex"
}

function find_dockerfiles() {
    find . -name 'Dockerfile' | sed 's|./||' | grep -vE "$exclude_regex"
}

function find_python_files() {
    find . -name '*.py' | sed 's|./||' | grep -vE "$exclude_regex"
}

function find_markdown_files() {
    find . -name '*.md' | sed 's|./||' | grep -vE "$exclude_regex"
}

function find_json_files() {
    find . -name '*.json' | sed 's|./||' | grep -vE "$exclude_regex"
}

function linter() {
    local linter="${1}"; local files="${2}"
    for target_file in ${files//,/ }; do
        show_pre_notice "Linting ${target_file} file - "
        $linter "${target_file}" && echo -e "\e[32mOK\e[39m" \
        || { echo -e "\e[31mFAIL\e[39m"; err=1; }
    done
}

function prepare_vars() {
    err=0

    # compatibility for use as part of a drone plugin
    PLUGIN_EXCLUDE_REGEX="${PLUGIN_LINTER_EXCLUDE_REGEX:-$PLUGIN_EXCLUDE_REGEX}"
    PLUGIN_SKIP_YML="${PLUGIN_LINTER_SKIP_YML:-$PLUGIN_SKIP_YML}"
    PLUGIN_YML_FILES="${PLUGIN_LINTER_YML_FILES:-$PLUGIN_YML_FILES}"
    PLUGIN_SKIP_SH="${PLUGIN_LINTER_SKIP_SH:-$PLUGIN_SKIP_SH}"
    PLUGIN_SH_FILES="${PLUGIN_LINTER_SH_FILES:-$PLUGIN_SH_FILES}"
    PLUGIN_SKIP_DOCKERFILE="${PLUGIN_LINTER_SKIP_DOCKERFILE:-$PLUGIN_SKIP_DOCKERFILE}"
    PLUGIN_DOCKERFILES="${PLUGIN_LINTER_DOCKERFILES:-$PLUGIN_DOCKERFILES}"
    PLUGIN_SKIP_PYTHON="${PLUGIN_LINTER_SKIP_PYTHON:-$PLUGIN_SKIP_PYTHON}"
    PLUGIN_PYTHON_FILES="${PLUGIN_LINTER_PYTHON_FILES:-$PLUGIN_PYTHON_FILES}"
    PLUGIN_SKIP_MARKDOWN="${PLUGIN_LINTER_SKIP_MARKDOWN:-$PLUGIN_SKIP_MARKDOWN}"
    PLUGIN_MARKDOWN_FILES="${PLUGIN_LINTER_MARKDOWN_FILES:-$PLUGIN_MARKDOWN_FILES}"
    PLUGIN_SKIP_JSON="${PLUGIN_LINTER_SKIP_JSON:-$PLUGIN_SKIP_JSON}"
    PLUGIN_JSON_FILES="${PLUGIN_LINTER_JSON_FILES:-$PLUGIN_JSON_FILES}"

    exclude_regex="${PLUGIN_EXCLUDE_REGEX:-^NO_EXCLUDE_FILES\$}"
    test -z "$PLUGIN_SKIP_YML" && yml_files="${PLUGIN_YML_FILES:-$(find_yml_files)}"
    test -z "$PLUGIN_SKIP_SH" && sh_files="${PLUGIN_SH_FILES:-$(find_shell_scripts)}"
    test -z "$PLUGIN_SKIP_DOCKERFILE" && dockerfiles="${PLUGIN_DOCKERFILES:-$(find_dockerfiles)}"
    test -z "$PLUGIN_SKIP_PYTHON" && python_files="${PLUGIN_PYTHON_FILES:-$(find_python_files)}"
    test -z "$PLUGIN_SKIP_MARKDOWN" && markdown_files="${PLUGIN_MARKDOWN_FILES:-$(find_markdown_files)}"
    test -z "$PLUGIN_SKIP_JSON" && json_files="${PLUGIN_JSON_FILES:-$(find_json_files)}"
}

# shellcheck disable=SC2078,SC2166
function prepare_linters() {
    [ -f ".yamllint" -o -f ".yamllint.yaml" -o -f ".yamllint.yml" ] && yamllint='yamllint' || yamllint='yamllint -c /etc/yamllint.yml'
    [ -f ".markdownlint.json" -o -f ".markdownlint.yaml" -o -f ".markdownlint.yml" ] && markdownlint='markdownlint' || markdownlint='markdownlint --config /etc/markdownlint.yml'
    [ -f ".flake8" ] && flake8='flake8' || flake8='flake8 --ignore=F401,E501'
    shellcheck='shellcheck'
    hadolint='hadolint'
    jsonlint='jsonlint -q'
}

prepare_vars
prepare_linters

linter "$yamllint" "$yml_files"
linter "$shellcheck" "$sh_files"
linter "$hadolint" "$dockerfiles"
linter "$markdownlint" "$markdown_files"
linter "$flake8" "$python_files"
linter "$jsonlint" "$json_files"

exit "${err}"
