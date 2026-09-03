import os
import shutil
import tempfile

import joblib
import mlflow
import mlflow.sklearn
from prometheus_client import CollectorRegistry, Gauge, push_to_gateway
from sklearn.datasets import load_iris
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, log_loss
from sklearn.model_selection import train_test_split


MLFLOW_TRACKING_URI = os.getenv(
    "MLFLOW_TRACKING_URI",
    "http://localhost:5000",
)

PUSHGATEWAY_URL = os.getenv(
    "PUSHGATEWAY_URL",
    "http://pushgateway.monitoring.svc.cluster.local:9091",
)

EXPERIMENT_NAME = os.getenv(
    "MLFLOW_EXPERIMENT_NAME",
    "iris-logistic-regression",
)

BEST_MODEL_DIR = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    "best_model",
)


def push_metrics(accuracy, loss, run_id):
    registry = CollectorRegistry()

    accuracy_gauge = Gauge(
        "mlflow_accuracy",
        "MLflow run accuracy",
        ["run_id"],
        registry=registry,
    )

    loss_gauge = Gauge(
        "mlflow_loss",
        "MLflow run log loss",
        ["run_id"],
        registry=registry,
    )

    accuracy_gauge.labels(run_id=run_id).set(accuracy)
    loss_gauge.labels(run_id=run_id).set(loss)

    push_to_gateway(
        PUSHGATEWAY_URL,
        job="mlflow_iris",
        registry=registry,
    )


def main():
    print(f"MLflow Tracking URI: {MLFLOW_TRACKING_URI}")
    print(f"PushGateway URL: {PUSHGATEWAY_URL}")

    mlflow.set_tracking_uri(MLFLOW_TRACKING_URI)
    mlflow.set_experiment(EXPERIMENT_NAME)

    data = load_iris()

    X_train, X_test, y_train, y_test = train_test_split(
        data.data,
        data.target,
        test_size=0.2,
        random_state=42,
        stratify=data.target,
    )

    parameter_grid = [
        {"C": 0.1, "max_iter": 100},
        {"C": 1.0, "max_iter": 100},
        {"C": 10.0, "max_iter": 100},
        {"C": 1.0, "max_iter": 200},
        {"C": 10.0, "max_iter": 200},
    ]

    best_accuracy = -1.0
    best_model_path = None
    best_run_id = None

    for params in parameter_grid:
        with mlflow.start_run() as run:
            model = LogisticRegression(
                C=params["C"],
                max_iter=params["max_iter"],
                random_state=42,
            )

            model.fit(X_train, y_train)

            predictions = model.predict(X_test)
            probabilities = model.predict_proba(X_test)

            accuracy = accuracy_score(y_test, predictions)
            loss = log_loss(y_test, probabilities)

            mlflow.log_params(params)
            mlflow.log_metric("accuracy", accuracy)
            mlflow.log_metric("loss", loss)

            with tempfile.TemporaryDirectory() as temp_dir:
                model_file = os.path.join(temp_dir, "model.joblib")
                joblib.dump(model, model_file)

                mlflow.log_artifact(
                    model_file,
                    artifact_path="model",
                )

                if accuracy > best_accuracy:
                    best_accuracy = accuracy
                    best_run_id = run.info.run_id
                    best_model_path = model_file

                push_metrics(
                    accuracy=accuracy,
                    loss=loss,
                    run_id=run.info.run_id,
                )

            print(
                f"run_id={run.info.run_id} "
                f"C={params['C']} "
                f"max_iter={params['max_iter']} "
                f"accuracy={accuracy:.4f} "
                f"loss={loss:.4f}"
            )

    if best_model_path is not None:
        os.makedirs(BEST_MODEL_DIR, exist_ok=True)

        destination = os.path.join(
            BEST_MODEL_DIR,
            "best_model.joblib",
        )

        shutil.copy2(best_model_path, destination)

        print()
        print("Best model:")
        print(f"  run_id: {best_run_id}")
        print(f"  accuracy: {best_accuracy:.4f}")
        print(f"  saved to: {destination}")


if __name__ == "__main__":
    main()
