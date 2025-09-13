import json
import logging
import os

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    AWS Lambda function handler
    """
    try:
        # Log the incoming event
        logger.info(f"Received event: {json.dumps(event)}")
        
        # Get environment variables
        environment = os.environ.get('ENVIRONMENT', 'unknown')
        project = os.environ.get('PROJECT', 'unknown')
        
        # Create response
        response_body = {
            'message': 'Hello from AWS Lambda!',
            'environment': environment,
            'project': project,
            'timestamp': context.aws_request_id,
            'function_name': context.function_name,
            'function_version': context.function_version
        }
        
        # Return successful response
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps(response_body)
        }
        
    except Exception as e:
        logger.error(f"Error processing request: {str(e)}")
        
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': 'Internal server error',
                'message': str(e)
            })
        }
