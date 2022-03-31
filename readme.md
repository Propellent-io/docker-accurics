# Accurics CI Tooling

This repo contains the accurics Infrastructure as Code (IaC) scan tooling for Vulnerability Management of various IaC components.

It can be used as the basis for scanning and planning during CI in order to fail builds that have vulnerabilities that exceed some threshold or configuration.

The tools included in the image are `accurics` cli tool and `terrascan`. Using this is CI can be done by running something like:

```
./accurics_linux scan -mode=pipeline -appurl=https://cloud.tenable.com/cns -token=${ACCURICS_TOKEN}
```

# Usage in Gitlab

In a Gitlab CI workflow you can use this container within an IaC repository like so:

**.gitlab-ci.yml**
```

stages:
  - test

default:
  image: ghcr.io/propellent-io/accurics-terrascan:ac-1.0.34-ts-1.13.1-tf-1.1.7
  tags:
    - docker
  before_script:
    - 'echo "Accurics: $(accurics version)"'
    - 'echo "Terrascan: $(terrascan version)"'
    - 'echo "Terraform: $(terraform version)"'

scan-code:
  stage: test
  artifacts:
    when: always
    paths:
      - accurics_report.html
      - accurics_report.json
  script:
    - cd ${CI_PROJECT_DIR}
    - accurics scan -mode=pipeline -appurl=https://cloud.tenable.com/cns -token=${ACCURICS_TOKEN}
    - terraform init
    - accurics plan -mode=pipeline -appurl=https://cloud.tenable.com/cns -token=${ACCURICS_TOKEN}
```

Where accurics token will be the token value required to upload data.
