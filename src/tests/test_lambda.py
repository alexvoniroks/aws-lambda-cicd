import json
import pytest
import sys
import os

# Add src directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from lambda_function import lambda_handler

class MockContext:
    def __init__(self):
        self.aws_request_id = "test-request-id"
        self.function_name = "test-function"
        self.function_version = "1"

def test_lambda_handler_success():
    """Test successful lambda handler execution"""
    event = {"test": "data"}
    context = MockContext()
    
    response = lambda_handler(event, context)
    
    assert response['statusCode'] == 200
    assert 'body' in response
    
    body = json.loads(response['body'])
    assert 'message' in body
    assert body['message'] == 'Hello from AWS Lambda!'

def test_lambda_handler_with_environment_vars():
    """Test lambda handler with environment variables"""
    os.environ['ENVIRONMENT'] = 'test'
    os.environ['PROJECT'] = 'test-project'
    
    event = {}
    context = MockContext()
    
    response = lambda_handler(event, context)
    body = json.loads(response['body'])
    
    assert body['environment'] == 'test'
    assert body['project'] == 'test-project'
