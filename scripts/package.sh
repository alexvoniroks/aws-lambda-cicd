#!/bin/bash
set -e

rm -f lambda.zip
cd lambda_app
zip -r ../lambda.zip .
cd ..
