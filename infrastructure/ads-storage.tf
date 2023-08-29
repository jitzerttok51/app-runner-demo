resource "aws_s3_bucket" "ads-storage" {
  bucket        = "emoti-ai-ads-store"
  force_destroy = true
  tags = {
    Name = "Emoti AI Ads Storage"
    #Environment = "Dev"
  }
}

resource "aws_s3_bucket_public_access_block" "ads-storage-acl" {
  bucket = aws_s3_bucket.ads-storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_vpc_endpoint" "ads-storage-endpoint" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${aws_s3_bucket.ads-storage.region}.s3"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [aws_subnet.primary.id]
  security_group_ids = [aws_security_group.primary_default.id]
}

resource "aws_s3_object" "ads-folder" {
  bucket = aws_s3_bucket.ads-storage.id
  key    = "ads/"
}