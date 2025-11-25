This repository provides playbooks, roles, and helper scripts to automate installation, configuration, and lifecycle management of GitHub runners on your own infrastructure.

🚀 **Features**
* Automated installation of GitHub Actions self‑hosted runners  
* Playbook‑driven setup for reproducible deployments  
* Role‑based structure for clean and maintainable configuration  
* Helper script (create-github-runner.sh) for quick runner creation  
* Works with repository‑level, organization‑level, or enterprise‑level runners  

📁 **Repository Structure**
```
playbooks/              # Ansible playbooks for provisioning runners
roles/                  # Ansible roles (tasks, templates, variables)
create-github-runner.sh # Shell script to bootstrap a runner
```

🛠 **Requirements**
* Ansible installed on your control machine  
* A target machine (Linux) reachable over SSH  
* A GitHub Personal Access Token (PAT) with appropriate permissions:
* repo (repository runners)
* admin:org (organization runners)
* Download & install roles

⚠️ **Security**: store tokens in Ansible Vault or environment variables ⚠️
