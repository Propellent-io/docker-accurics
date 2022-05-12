# Accurics CI Tooling

This repo contains the accurics Infrastructure as Code (IaC) scan tooling for Vulnerability Management of various IaC components.

It can be used as the basis for scanning during CI in order to fail builds that have vulnerabilities that exceed some threshold or configuration.

The tools included in the image are `accurics` cli tool and `terrascan`. Using this is CI can be done by running something like:

```shell
$ ./accurics_linux scan -mode=pipeline -appurl=https://cloud.tenable.com/cns -token=${ACCURICS_TOKEN} -project=xxxx-xxxx-xxxxxx-xxx-xxxx
```

## Usage in Gitlab

In a Gitlab CI workflow you can use this container within an IaC repository like so:

> **NOTE:** This example uses Gitlab CI/CD variables to hold the accurics credentials in a config file

### .gitlab-ci.yml

```yaml
variables:
  ACCURICS_CONFIG: ${ACCURICS_CONFIG}

  # Export the original git commit branch so we do not continuously add new "repos"
  # to the Tenable.CS project. This is because Gitlab's CICD detaches head and then
  # creates a new branch called pipelines/n and this causes a new branch to be
  # referenced by Tenable.CS - branches are treated as different repos because we
  #could have one repo with the branches development/test/staging/production, etc.
  GIT_BRANCH: ${CI_COMMIT_BRANCH}

stages:
  - scan
  - plan

default:
  image: ghcr.io/briansidebotham/accurics-terrascan:latest
  tags:
    - docker
  before_script:
    - 'echo "Accurics: $(accurics version)"'
    - 'echo "Terrascan: $(terrascan version)"'

scan-code:
  stage: scan
  artifacts:
    when: always
    paths:
      - accurics_report.html
      - accurics_report.json
  script:
    - cd ${CI_PROJECT_DIR} && echo "${ACCURICS_CONFIG}" > accurics.conf
    - accurics scan -mode=pipeline -config accurics.conf

plan-code:
  stage: plan
  script:
    - cd ${CI_PROJECT_DIR}
    - accurics init -config=accurics.conf
    - accurics plan -mode=pipeline -config=accurics.conf
```

Where accurics token will be the token value required to upload data.

## Use in GitHub Actions

In Github Actions we can make use of Github secrets with the environment variables or otherwise use the secrets replacement directly on the command line. This command line example shows a bit more use of the CLI in order to:

  - Perform a cloud scan after the IaC scan has taken place
  - Retrieve the tfstate file from any backend provider in Terraform
  - Use a planned output converted to JSON so the accurics tool doesn't have to do the actual plan

> **NOTE:** In the below example there is a Github checkout issue ([#760](https://github.com/actions/checkout/issues/760)) that we need to circumvent when using a docker container. There is a different command in that thread if the version of git in the container is too low to support this command.

### github-workflow.yaml

```yaml
name: Terraform Init and Plan on pull request

on:
  push:
    # Run on all pushes to the main branch
    branches: [ main ]
  pull_request:
    branches: [ main ]

env:
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

permissions:
  packages: read
  contents: read

jobs:
  terraform:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/propellent-io/docker-accurics:latest
      credentials:
        username: ${{ github.actor }}
        password: ${{ github.token }}
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Terraform Init
        run: |
          terraform --version && terraform init -var="environment=staging"
      - name: Terraform plan
        run: |
          terraform plan -var="environment=staging" -out=plan.out
          terraform show -json plan.out > plan.json
      # See https://github.com/actions/checkout/issues/760 for why this step is necessary
      - name: Accurics Plan
        run: |
          export TF_VAR_environment=staging
          git config --global --add safe.directory /__w/tenable-cs-remote-terraform-s3-state-cli/tenable-cs-remote-terraform-s3-state-cli
          accurics version
          accurics plan -mode=pipeline -project=5e580a6c-b35a-4325-90bb-7d085de5eca0 -appurl="https://cloud.tenable.com/cns" -token="${{ secrets.ACCURICS_API_KEY }}" -planjson=plan.json --pulltfstate -cloudscan
```
