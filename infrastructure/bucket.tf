resource "aws_s3_bucket" "ads-storage" {
  bucket        = "emoti-ai-ads-store"
  force_destroy = true
  tags = {
    Name = "Emoti AI Ads Storage"
    #Environment = "Dev"
  }
}

resource "aws_vpc_endpoint" "ads-storage-endpoint" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${aws_s3_bucket.ads-storage.region}.s3"
  vpc_endpoint_type = "Interface"
  # subnet_ids         = [aws_subnet.private.id, aws_subnet.public.id]
  security_group_ids = [aws_security_group.endpoint_group.id]
  # private_dns_enabled = true
}
