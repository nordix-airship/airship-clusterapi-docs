# Deploy fake ipa testbed

## Requirements

Machine: `4c / 16gb / 100gb`
OS: `CentOS9-20220330`

## Test fake ipa

1. clone the env scripts and `cd metal3-clusterapi-docs/Support/Multitenancy/ironic-env`
2. check configs in config.py
3. run init `./Init-environment.sh`
4. to just rebuild fake-ipa from the local repo run `./rebuild-fipa.sh`
5. to clean the env `./clean.sh`
