# Accurics CI Tooling

This repo contains the accurics Infrastructure as Code (IaC) scan tooling for Vulnerability Management of various IaC components.

It can be used as the basis for scanning during CI in order to fail builds that have vulnerabilities that exceed some threshold or configuration.

The tools included in the image are `accurics` cli tool and `terrascan`. Using this is CI can be done by running something like:

```
./accurics_linux scan -mode=pipeline -appurl=https://cloud.tenable.com/cns -token=${ACCURICS_TOKEN}
```

# Usage in Gitlab

In a Gitlab CI workflow you can use this container within an IaC repository like so:

**.gitlab-ci.yml**
```

```
