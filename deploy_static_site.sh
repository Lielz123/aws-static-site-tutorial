#!/bin/bash

# Variables
BUCKET_NAME="lilamandal05-static-site-bucket-2025"                       # unique bucket name
REGION="us-east-1"
DIST_FOLDER="/C/Users/xxxx/Documents/AWS/Projects/my-static-site"     # local folder containing index.html, error.html, etc.

# ===============================
# Functions
# ===============================
function check_command() {
    command -v $1 >/dev/null 2>&1 || { echo >&2 "$1 is required but not installed. Aborting."; exit 1; }
}

# ===============================
# Prerequisites check
# ===============================
check_command aws
check_command date

if [ ! -d "$DIST_FOLDER" ]; then
    echo "❌ Error: Local folder $DIST_FOLDER does not exist."
    exit 1
fi

# ===============================
# Create S3 bucket
# ===============================
#echo "🚀 Creating S3 bucket: $BUCKET_NAME"

#if [ "$REGION" == "us-east-1" ]; then
#    aws s3api create-bucket --bucket $BUCKET_NAME --region $REGION
#else
#    aws s3api create-bucket \
#        --bucket $BUCKET_NAME \
#        --region $REGION \
#        --create-bucket-configuration LocationConstraint=$REGION
#fi

# Verify bucket creation
if ! aws s3api head-bucket --bucket $BUCKET_NAME 2>/dev/null; then
    echo "❌ Bucket creation failed. Exiting."
    exit 1
fi

# ===============================
# Disable Block Public Access temporarily
# ===============================
aws s3api put-public-access-block \
    --bucket $BUCKET_NAME \
    --public-access-block-configuration BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false

# ===============================
# Enable Block Public Access temporarily
# ===============================
aws s3api put-public-access-block \
    --bucket $BUCKET_NAME \
    --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

#====================================

# Apply public bucket policy (temporary for testing)

#Make sure BUCKET_NAME is defined
#BUCKET_NAME="lilamandal05-static-site-bucket-2025"

# Create the public bucket policy JSON
# Apply public bucket policy (temporary for testing)
#cat > bucket-policy.json <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Sid": "PublicReadGetObject",
#      "Effect": "Allow",
#      "Principal": "*",
#      "Action": "s3:GetObject",
#      "Resource": "arn:aws:s3:::lilamandal05-static-site-bucket-2025/*"
#    }
#  ]
#}
#EOF

# Apply policy

aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy file://C/Users/xxxx/Documents/AWS/Projects/createS3bucket/bucket-policy.json

# ===============================
# Enable static website hosting
aws s3 website "s3://$BUCKET_NAME" --index-document index.html --error-document error.html

# ===============================
# Upload website files
# ===============================
echo "📤 Uploading website files from $DIST_FOLDER ..."
aws s3 sync "$DIST_FOLDER" "s3://$BUCKET_NAME"

# ===============================
# Done

# ===============================
echo "✅ Your static website is live at:"
echo "http://$BUCKET_NAME.s3-website-$REGION.amazonaws.com"

aws s3 sync /C/Users/xxxx/Documents/AWS/Projects/my-static-site s3://lilamandal05-static-site-bucket-2025/


#Run it

#bash deploy_static_site.sh
