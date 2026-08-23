# EKS VPC Cluster with Terraform

## Description

This project creates AWS infrastructure for MLOps workloads using Terraform.

The infrastructure is separated into two independent Terraform configurations:

- `vpc/` - creates the VPC, public/private subnets and NAT Gateway.
- `eks/` - creates the Amazon EKS cluster and worker node groups.

The connection between the VPC and EKS configurations is implemented using `terraform_remote_state`.

## Project Structure

```text
eks-vpc-cluster/
├── vpc/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tf
│   └── backend.tf
├── eks/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tf
│   ├── backend.tf
│   └── data.tf
└── README.md

## Deployment

### 1. Create VPC

```bash
cd vpc
terraform init
terraform apply

### 2. Создание EKS-кластера

После успешного создания VPC переходим в каталог EKS:

```bash
cd ../eks
terraform init
terraform apply

### 3. Подключение к EKS через kubectl

После создания EKS-кластера выполняем:

    aws eks --region eu-central-1 update-kubeconfig --name mlops-eks-terraform

Проверяем worker nodes:

    kubectl get nodes

Ожидаемый результат: worker nodes находятся в статусе Ready.

Для отображения workload-меток:

    kubectl get nodes -L workload

### 4. Проверка workload node

Для отдельной workload node используется метка workload=gpu и taint workload=gpu:NoSchedule. Это позволяет изолировать ML/workload-нагрузку от обычных CPU-нагрузок.

Для проверки был создан тестовый Pod gpu-test с соответствующим nodeSelector и toleration.

Проверка Pod:

    kubectl get pod gpu-test -o wide

Pod должен находиться в состоянии Running и быть размещён на workload node.

### 5. Проверка terraform_remote_state

Связь между VPC и EKS реализована через terraform_remote_state.

Файл eks/data.tf получает данные из Terraform state VPC. Используются следующие outputs:

- vpc_id
- public_subnets
- private_subnets

Проверить outputs VPC можно командой:

    cd vpc
    terraform output

### 6. Удаление ресурсов

После проверки инфраструктуры ресурсы необходимо удалить, чтобы избежать дополнительных расходов AWS.

Сначала удаляется EKS:

    cd eks
    terraform destroy

После успешного удаления EKS удаляется VPC:

    cd ../vpc
    terraform destroy

Порядок удаления важен, поскольку EKS зависит от сетевой инфраструктуры VPC.

### 7. Итог

Проект содержит две независимые Terraform-конфигурации: vpc/ и eks/.

VPC создаётся с использованием официального модуля terraform-aws-modules/vpc/aws. EKS создаётся с использованием официального модуля terraform-aws-modules/eks/aws.

Связь между конфигурациями реализована через terraform_remote_state. EKS использует outputs VPC для получения VPC ID и subnet IDs.

Кластер содержит отдельные CPU и GPU/workload node groups. Workload node использует label workload=gpu и taint workload=gpu:NoSchedule для изоляции нагрузки.

После создания инфраструктуры доступ к EKS проверяется через aws eks update-kubeconfig и kubectl get nodes.
