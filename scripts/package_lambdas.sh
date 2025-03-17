#!/bin/bash
# Script to package Lambda functions for CloudFix Terraform implementation

echo "Creating Lambda function packages..."

# Create clean_up_buckets Lambda package
echo "Packaging clean_up_buckets Lambda..."
cd lambda
zip -j ../lambda_bucket_cleanup.zip clean_up_buckets.py
cd ..

# Create cur_initializer Lambda package
echo "Packaging cur_initializer Lambda..."
cd lambda
zip -j ../lambda_function_payload.zip cur_initializer.py
cd ..

# Create s3_notification Lambda package
echo "Packaging s3_notification Lambda..."
cd lambda
zip -j ../lambda_s3_notification.zip s3_notification.py
cd ..

# Create notification Lambda package
echo "Packaging notification Lambda..."
cd lambda
zip -j ../lambda_notification.zip notification.py
cd ..

echo "Lambda packages created successfully!"
echo "- lambda_bucket_cleanup.zip"
echo "- lambda_function_payload.zip"
echo "- lambda_s3_notification.zip"
echo "- lambda_notification.zip"