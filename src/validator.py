def lambda_handler(event, context):
    job = event.get('job', {})
    
    simulate_failure = job.get('simulate_failure', False)
    
    if simulate_failure:
        return {
            "status": "FAILED",
            "reason": "Simulated failure requested"
        }
    
    # Example validation logic
    if not job.get('workflow_id'):
        return {
            "status": "FAILED",
            "reason": "Missing workflow_id"
        }
        
    if not job.get('order_id'):
        return {
            "status": "FAILED",
            "reason": "Missing order_id"
        }

    return {
        "status": "SUCCESS",
        "reason": "Job is valid"
    }
