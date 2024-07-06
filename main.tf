# Create an S3 bucket
resource "aws_s3_bucket" "mybucket" {
  bucket = var.bucketname
  acl    = "public-read" # Ensuring the bucket is accessible
}

# Ensure that objects in the bucket are owned by the bucket owner
resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.mybucket.bucket

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Enable public access to the bucket
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.mybucket.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Set the bucket ACL to public-read
resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.mybucket.bucket
  acl    = "public-read"

  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]
}

# Upload index.html file
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.mybucket.bucket
  key          = "index.html"
  source       = "index.html"
  acl          = "public-read"
  content_type = "text/html"

  depends_on = [aws_s3_bucket_acl.example]
}

# Upload error.html file
resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.mybucket.bucket
  key          = "error.html"
  source       = "error.html"
  acl          = "public-read"
  content_type = "text/html"

  depends_on = [aws_s3_bucket_acl.example]
}

# Configure the bucket as a website
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.mybucket.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  depends_on = [aws_s3_bucket_acl.example]
}
