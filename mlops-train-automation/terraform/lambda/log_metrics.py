def lambda_handler(event, context):
    print("Logging metrics...")

    print(f"Workflow status: {event.get('status', 'unknown')}")
    print(f"Source: {event.get('source', 'unknown')}")
    print(f"Commit: {event.get('commit', 'unknown')}")

    return {
        "status": "metrics_logged",
        "source": event.get("source", "unknown"),
        "commit": event.get("commit", "unknown")
    }
