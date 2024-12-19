# Keylime POC
<!-- cSpell:ignore keylime -->

## Docker Compose

First part of POC is deploying Keylime services in
[Docker Compose](compose/README.md). Setup is verified by a single Agent, backed
by software TPM, also in Docker.

## Kubernetes

Second part of POC is deploying [Agent in k8s](k8s/README.md), fronted by
Ingress/LoadBalancer, while the Verifier and Registrar sit in Docker Compose.
This simulates the use-case of using existing non-K8s Keylime installation to
measure nodes in K8s cluster.
