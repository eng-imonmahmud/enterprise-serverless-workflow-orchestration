import uuid
import datetime
import os

def lambda_handler(event, context):
    workflow_id = str(uuid.uuid4())
    order_id = f"ORD-{uuid.uuid4().hex[:8].upper()}"
    customer_id = f"CUST-{uuid.uuid4().hex[:6].upper()}"
    timestamp = datetime.datetime.utcnow().isoformat()
    region = os.environ.get('REGION', 'eu-central-1')

    # Allow simulating failure by passing simulate_failure in the event
    simulate_failure = event.get('simulate_failure', False)
    priority = "HIGH" if simulate_failure else "NORMAL"
    status = "PENDING"
    
    return {
        "workflow_id": workflow_id,
        "order_id": order_id,
        "customer_id": customer_id,
        "timestamp": timestamp,
        "status": status,
        "priority": priority,
        "region": region,
        "simulate_failure": simulate_failure
    }
