# drone-linter

[![Build Status](https://drone.osshelp.ru/api/badges/drone/drone-linter/status.svg?ref=refs/heads/master)](https://drone.osshelp.ru/drone/drone-linter)

## About

The image is used in Drone CI builds for lint tests.

## Usage examples

### Find and lint files automatically

``` yaml
steps:
  - name: lint
    image: osshelp/drone-linter
```

### Specific files to check

``` yaml
steps:
  - name: lint
    image: osshelp/drone-linter
    settings:
      yml_files:
        - file1.yml
        - dir/file2.yml
      sh_files:
        - entrypoint.sh
      dockerfiles:
        - Dockerfile
      markdown_files:
        - README.md
      python_files:
        - test.py
      json_files:
        - file.json
```

### Skip checks

``` yaml
steps:
  - name: lint
    image: osshelp/drone-linter
    settings:
      skip_yml: true
      skip_sh: true
      skip_dockerfile: true
      skip_markdown: true
      skip_python: true
      skip_json: true
```

### Exclude files by exclude_regex

``` yaml
steps:
  - name: lint
    image: osshelp/drone-linter
    settings:
      exclude_regex: '(regex1|regex2)'
```

### Internal usage

For internal purposes and OSSHelp customers we have an alternative image url:

``` yaml
  image: oss.help/drone/linter
```

There is no difference between the DockerHub image and the oss.help/drone image.

## Linters documentations

- [hadolint](https://github.com/hadolint/hadolint)
- [shellcheck](https://github.com/koalaman/shellcheck)
- [yamllint](https://yamllint.readthedocs.io/en/stable/)
- [flake8](http://flake8.pycqa.org/en/latest/user/error-codes.html)
- [markdownlint](https://github.com/DavidAnson/markdownlint)
- [jsonlint](https://github.com/zaach/jsonlint)

## TODO

- add warnings for disabled linters (skip_ options)
