# Injecting Secrets into Kubernetes Pods via Vault Agent and Read These Secrets in .NET Applications
Example how use Vault Agent for inject secrets in pods before starting, and how a dotnet application can be reading these secrets. Source: https://learn.hashicorp.com/tutorials/vault/kubernetes-sidecar?in=vault/kubernetes

# Getting started
First, install make CLI for test this project
##### Windows
```shell
$ choco install make
```
##### Linux
```shell
$ apt-get install -y make
```
Run the project (*Ensure you have kubectl and helm cli installed*)
```shell
$ make
```
Test if the application can read the secret
```shell
$ curl "http://<expose-url>:<available-port>/secret"
{"secretValue":"vault"} # <- Expected output
```
