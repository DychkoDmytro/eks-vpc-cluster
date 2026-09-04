# Домашнее задание №5 — MLOps Train Automation

## Структура проекта

mlops-train-automation/
├── terraform/
│   ├── main.tf
│   ├── data.tf
│   ├── terraform.tf
│   ├── variables.tf
│   └── lambda/
│       ├── validate.py
│       ├── log_metrics.py
│       ├── validate.zip
│       └── log_metrics.zip
├── .gitlab-ci.yml
└── README.md

## Lambda-функции

В проекте используются две Lambda-функции: validate.py и log_metrics.py.

validate.py проверяет входные данные и возвращает статус validated.
log_metrics.py получает результат предыдущего шага и выводит информацию о workflow, source и commit.

ZIP-файлы создаются командами:

cd terraform/lambda
zip validate.zip validate.py
zip log_metrics.zip log_metrics.py

## Terraform

Terraform создаёт IAM-роли, две Lambda-функции и Step Function mlops-train-pipeline.

Основные команды:

cd terraform
terraform init
terraform validate
terraform plan
terraform apply

Для удаления инфраструктуры:

terraform destroy

## Step Functions

Workflow выполняется последовательно:

ValidateData → LogMetrics

Сначала запускается Lambda validate, затем её результат передаётся в Lambda log_metrics.

Пример входных данных:

{
  "source": "manual",
  "commit": "example123"
}

Step Function можно запустить вручную через AWS Console.

После запуска необходимо открыть execution и проверить результат.

Ожидаемый статус: Succeeded

## GitLab CI

Файл .gitlab-ci.yml содержит job train-model.

Job использует Docker image amazon/aws-cli:2.15.0.

Для запуска Step Function используется команда aws stepfunctions start-execution.

В GitLab CI/CD Variables необходимо добавить:

AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_DEFAULT_REGION
STEP_FUNCTION_ARN

Регион: eu-central-1

Пример STEP_FUNCTION_ARN:

arn:aws:states:eu-central-1:ACCOUNT_ID:stateMachine:mlops-train-pipeline

После push в GitLab запускается job train-model.

В Step Functions передаются source и commit из GitLab CI.

## Проверка результата

1. В AWS Lambda существуют обе функции.
2. В AWS Step Functions существует mlops-train-pipeline.
3. Workflow содержит два последовательных шага: ValidateData → LogMetrics.
4. Execution завершается со статусом Succeeded.
5. GitLab CI job train-model завершается успешно.

## Результат

Terraform создаёт инфраструктуру для автоматизированного запуска последовательности Lambda-функций через AWS Step Functions, а GitLab CI позволяет запускать этот workflow после изменения проекта.
