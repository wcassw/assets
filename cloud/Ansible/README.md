# Ansible

[![Ansible Playbook Syntax Check](https://github.com/wcassw/assets/cloud/Ansible/actions/workflows/ansible-playbook-syntax.yaml/badge.svg)](https://github.com/wcassw/assets/cloud/Ansible/actions/workflows/ansible-playbook-syntax.yaml)
[![Validation](https://github.com/wcassw/assets/cloud/Ansible/actions/workflows/validate.yaml/badge.svg)](https://github.com/wcassw/assets/cloud/Ansible/actions/workflows/validate.yaml)
[![Kics](https://github.com/wcassw/assets/cloud/Ansible/actions/workflows/kics.yaml/badge.svg)](https://github.com/wcassw/assets/cloud/wcassw/assets/cloud/actions/workflows/kics.yaml)
[![Grype](https://github.com/wcassw/assets/cloud/Ansible/actions/workflows/grype.yaml/badge.svg)](https://github.com/wcassw/assets/cloud/Ansible/actions/workflows/grype.yaml)
[![Semgrep](https://github.com/wcassw/assets/cloud/Ansible/actions/workflows/semgrep.yaml/badge.svg)](https://github.com/wcassw/assets/cloud/Ansible/actions/workflows/semgrep.yaml)
[![Semgrep Cloud](https://github.com/wcassw/assets/cloud/Ansible/actions/workflows/semgrep-cloud.yaml/badge.svg)](https://github.com/wcassw/assets/cloud/Ansible/actions/workflows/semgrep-cloud.yaml)
[![SonarCloud](https://github.com/wcassw/assets/cloud/Ansible/actions/workflows/sonarcloud.yaml/badge.svg)](https://github.com/wcassw/assets/cloud/Ansible/actions/workflows/sonarcloud.yaml)
[![Systemd-Analyze Verify](https://github.com/wcassw/assets/cloud/Ansible/actions/workflows/systemd-analyze.yaml/badge.svg)](https://github.com/wcassw/assets/cloud/Ansible/actions/workflows/systemd-analyze.yaml)
[![Trivy](https://github.com/wcassw/assets/cloud/Ansible/actions/workflows/trivy.yaml/badge.svg)](https://github.com/wcassw/assets/cloud/Ansible/actions/workflows/trivy.yaml)
[![YAML](https://github.com/wcassw/assets/cloud/Ansible/actions/workflows/yaml.yaml/badge.svg)](https://github.com/wcassw/assets/cloud/Ansible/actions/workflows/yaml.yaml)

<!-- INDEX_START -->

- [Quick Ansible Doc](#quick-ansible-doc)
- [Ansible Inventory](#ansible-inventory)
- [Ansible Playbooks](#ansible-playbooks)
  - [Check Diff, Then Run](#check-diff-then-run)
  - [Install Prometheus](#install-prometheus)
  - [Install Node Exporter](#install-node-exporter)
- [More Core Repos](#more-core-repos)
  - [Knowledge](#knowledge)
  - [DevOps Code](#devops-code)
  - [Containerization](#containerization)
  - [CI/CD](#cicd)
  - [DBA - SQL](#dba---sql)
  - [DevOps Reloaded](#devops-reloaded)
  - [Templates](#templates)
  - [Misc](#misc)

<!-- INDEX_END -->

## Quick Ansible Doc

See the [Ansible](https://github.com/wcassw/assets/Knowledge-Base/blob/main/ansible.md) page in
the [HariSekhon/Knowledge-Base](https://github.com/wcassw/assets/Knowledge-Base) repo.

## Ansible Inventory

A template of a quick easy static Ansible inventory is here:

[inventory.ini](inventory.ini)

More advanced dynamic inventories that populate by querying things like cloud providers can be used via
[plugins](https://docs.ansible.com/ansible/latest/plugins/inventory.html).

## Ansible Playbooks

Quickly install to a given host using `-i <hostname>,` with the trailing comma
to let Ansible know it is an inline host list not an [inventory.ini](inventory.ini) file.

### Check Diff, Then Run

Find a playbook you want, then run a dry run `--check --diff` to see what it would do,
check your SSH config is set up with the right AWS pem keys etc:

```shell
ansible-playbook -i inventory.ini path/to/playbook.yml --check --diff
```

If it look ok, then run it:

```shell
ansible-playbook -i inventory.ini path/to/playbook.yml
```

### Install Prometheus

```shell
ansible-playbook -i localhost, prometheus/playbook.yml
```

### Install Node Exporter

```shell
ansible-playbook -i localhost, prometheus_node_exporter/playbook.yml
```
