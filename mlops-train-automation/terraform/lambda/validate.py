def lambda_handler(event, context):
    print("Validating data...")

    return {
        "status": "validated",
        "source": event.get("source", "unknown"),
        "commit": event.get("commit", "unknown")
    }
