# MLOps Experiments

## Description

This project demonstrates ML experiment tracking using MLflow, PostgreSQL, MinIO, Prometheus PushGateway, Grafana and Argo CD.

The experiment uses the Iris dataset and trains several Logistic Regression models with different hyperparameters.

## Project structure

```text
mlops-experiments/
├── argocd/
│   └── applications/
│       ├── mlflow.yaml
│       ├── minio.yaml
│       ├── postgres.yaml
│       └── pushgateway.yaml
├── experiments/
│   ├── train_and_push.py
│   └── requirements.txt
├── best_model/
│   └── best_model.joblib
└── README.md
