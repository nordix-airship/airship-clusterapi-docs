# Keylime POC
<!-- cSpell:ignore keylime -->

WIP: NOTHING IS EXPECTED WORK HERE YET!

## Kubernetes

Make a Proof of Concept of Keylime in k8s.

This POC is needed as the concept of having Keylime Tenant/Verifier/Registrar
outside K8s cluster, but Keylime Agent in K8s cluster and being accessed via
Ingress/LoadBalancer IP, is something Keylime maintainers did not think
originally as a use-case. This has several issues with the current design, and
while there is a proposal/ study for changing from "pull model" to "push
model", it is miles away and this POC tries to find out the minimal changes
needed to make the current model work for this use case.

## POC requirements

Since Keylime is about using TPM and being secure, we have some requirements:

1. A machine/VM where we can setup a K8s cluster, and the pods can have access
   to TPM.
1. We need the TPM public certificates for said machine, EK CA etc.
1. Machine where we can run Keylime services/commands, Registrar, Verifier and
   Tenant. Preferably a second machine, so we can't "cheat".
1. There needs to be connectivity between these. Preferably different networks,
   again we don't want to "cheat".
1. Agents have unique UUID that are pre-set, generated or tied to TPM EK.
   There should be more than one machine in Cluster, so we have multiple Agents.

For test/reproducibility purposes, we must consider some shortcuts:

1. Use of single laptop, where the separation is happening either via
   - VM (does it expose TPM properly)
   - Containers (eventually all services, directly on Docker or in K8s cluster
      will run in the same container runtime)
1. Using TPM simulation software (might be good for reproducibility due
   different manufacturers having different certs etc)
1. Using only one machine in K8s cluster, and hence only one Agent (this may
   lead of incorrect configs as there is only one Agent as is always "correct"
   target)

We have some availability for infra:

1. Xerces (OpenStack) does not expose TPM to the VMs, so it is ruled out
1. BML (Bare Metal Lab) has real machines that certainly would work, but those
   are not for development (jump hosts) or run test payloads (actual servers).
   Also access to those is not readily available to persons outside the ESJ
   team.

## POC setup

As we're talking about POC, it is good to start with MVP, which here is:

1. Use laptop as hardware for TPM access
1. Use containers to make it reproducible
1. Make all hardware related things configurable (EK certs, networks, ...)

This leads to test setup looking like this.

### Registrar in Docker

1. Make Docker networking such it can be accessed by the K8s services (use
   host network if needed)
1. Run Keylime Registrar image in local Docker
1. Run Keylime Verifier image in local Docker
1. Run Keylime Tenant CLI in local Docker

### Agent in K8s

1. Run K8s cluster with Kind
1. Install Keylime Agent in Kind
1. Expose the Agent with LoadBalancer IP (if Kind supports that?)
1. Make Ingress rule for a fake hostname (uuid0-31.uuid32-64.cluster.local)

## POC plan

With POC setup in place, we aim to achieve following steps.

1. Agent registration to Registrar must work.

   - Connectivity from Agent -> Registrar
   - Agent must be configured with valid data (for later stages)
      - `contact_ip`
      - ...
   - See Keylime Rust Agent
      [contact_ip issue](https://github.com/keylime/rust-keylime/issues/848)

1. Tenant will add Agent to Verifier with data from Registrar/command line.

   - With use of Tenant CLI command, we add Agent to Verifier to be polled
   - Verifier will query Registrar about Agent details, when it is supplied
      with Agent UUID. This needs Tenant -> Verifier -> Registrar connectivity
      and configuration to work.

1. Verifier will query Agent for data

   - Verifier now has all needed data to poll Agent. This is the tricky part as
      it will use data input by Agent to Registrar, but needs to also travel
      through LoadBalancer IP and Ingress rules to the correct Agent. Data must
      only go to the Agent with matching UUID.
   - NOTE: In the POC setup we have only one Agent, leading to the risk of
      sending all Agent queries to this single Agent, allowing "cheating" in
      K8s configurations as the sole Agent is the only target and UUID based rules
      might "cheat".

1. Agent sends data back

   - Agent gets data from TPM and sends it to Verifier.
   - Agent EK certs and Verifier EK certs need to match at this point.

1. ...

1. Profit!

   There might be some additional steps, but this is how far we've come right now.
   Stay tuned!

## POC steps

Actual steps to take to achieve [POC plan](#poc-plan). For this, a
[Makefile](./makefile) and [helper scripts](./scripts/) are implemented in this
repository.

1. `make e2e` to run e2e, ie. `run` + `verify`
1. `make run` to just setup everything, ie. `docker` + `kind`
1. `make docker` to setup Verifier/Registrar correctly
1. `make kind` to setup Agent in K8s cluster
1. `make verify` to have Tenant sign up the Agent and trigger the verification
1. `make clean` to clean everything up
1. `make realclean` to clean everything up + remove any temporary files + images

Whole POC e2e can be executed with `make e2e` and cleaned away with
`make realclean`.

For anything else, use `docker` and `kubectl` commands for digging into details,
and when everything is running, use [scripts/run_tenant.sh](./scripts/run_tenant.sh)
to issue Tenant commands.

### Verifier and Registrar installation

Running `make docker` sets up Verifier first, which generates certificates for
mTLS in the shared directory `/tmp/keylime/cv_ca`, which needs to be mounted as
`/var/lib/keylime/cv_ca` in all containers.

See [scripts/run_docker.sh](./scripts/run_docker.sh) for the code.

### Agent installation

Running `make kind` sets up Kind cluster, then applies K8s manifests from `k8s`
subdirectory to run Keylime Agent as DaemonSet.

For nitty gritty details of the K8s installation of the agent, see
[manifest generation details](#manifest-generation).

See [scripts/run_kind.sh](./scripts/run_kind.sh) for the code.

#### Manifest generation

This K8s installation is created based on the
[attestation-operator](https://github.com/keylime/attestation-operator) templates
via following process (no need to repeat, resulting files are stored in this
POC):

1. Clone attestation-operator repo
1. Run `make helm-keylime`
1. Run `kind create cluster` to have something to deploy into
1. Run `make helm-keylime-deploy` run deploy all components from the Helm chart
1. Run `kubectl -n keylime get daemonset hhkl-keylime-agent -o yaml` to get a
   manifest for Agent.
1. Add some adaptation, especially around mTLS and cert mounts. Certs generated
   by the Docker container must be made secrets etc

### Verification with Tenant

tbd

## Issues found during POC

1. [Agent contact_ip issue](https://github.com/keylime/rust-keylime/issues/848)

## POC shortcomings

As mentioned in [POC requirements](#poc-requirements) section, this POC for
sake of simplicity has its limits. Following items could be implemented for
more completeness, if time is not an issue.

1. Two or mode nodes
1. Two or more machines
1. Adding TPM simulation (or removal of it)
1. tbc

## Extras

Some extra more or less useful notes related to this POC.

### Ubuntu 24.04 tools

Per [Keylime documentation on TPM2 tools](https://keylime-docs.readthedocs.io/en/latest/installation.html#tpm-2-0-support)
we need to install some tools manually.

- `tpm2-tools` and `tpm2-tss-engine-tools` need to be installed (at least for
   convenience)
   - `sudo apt install tpm2-tools tpm2-tss-engine-tools`

## References

Collection of referenced docs, issues etc.

1. [Keylime documentation](https://keylime-docs.readthedocs.io/en/latest/)
1. [Attestation Operator](https://github.com/keylime/attestation-operator)
   aka Keylime in K8s
1. [Push model proxy doc](https://github.com/keylime/attestation-operator/blob/main/docs/push-model-proxy.md)
1. [Agent contact_ip issue](https://github.com/keylime/rust-keylime/issues/848)
1. [Slack discussion](https://cloud-native.slack.com/archives/C01ARE2QUTZ/p1727792733885549)
1. [RedHat's Keylime docs](https://docs.redhat.com/de/documentation/red_hat_enterprise_linux/9/html/security_hardening/assembly_ensuring-system-integrity-with-keylime_security-hardening#configuring-keylime-agent_assembly_ensuring-system-integrity-with-keylime)
