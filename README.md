# EKS VPC Cluster — Terraform

## Опис

Проєкт демонструє створення базової AWS-інфраструктури для майбутніх ML/MLOps-сервісів за допомогою Terraform.

Інфраструктура складається з двох незалежних Terraform-конфігурацій:

- `vpc/` — створення VPC та мережевої інфраструктури;
- `eks/` — створення EKS-кластера та node groups.

Зв'язок між VPC та EKS реалізований через `terraform_remote_state`.

---

## Структура проєкту

```text
eks-vpc-cluster/
├── vpc/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tf
│   ├── backend.tf
│   └── .terraform.lock.hcl
├── eks/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tf
│   ├── backend.tf
│   ├── data.tf
│   └── .terraform.lock.hcl
└── README.md
