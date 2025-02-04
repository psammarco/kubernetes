# Upload files recursively from both folders
resource "aws_s3_bucket_object" "folder1" {
  for_each = fileset(var.folder1_path, "**/*")

  bucket = aws_s3_bucket.this.id
  key    = each.key
  source = "${var.folder1_path}/${each.key}"
  acl    = "private"
  etag   = filemd5("${var.folder1_path}/${each.key}")
}

resource "aws_s3_bucket_object" "folder2" {
  for_each = fileset(var.folder2_path, "**/*")

  bucket = aws_s3_bucket.this.id
  key    = each.key
  source = "${var.folder2_path}/${each.key}"
  acl    = "private"
  etag   = filemd5("${var.folder2_path}/${each.key}")
}

resource "aws_s3_bucket_object" "setup" {


  bucket = aws_s3_bucket.this.id
  key    = "setup_ks8.sh"   # The destination path in S3
  source = "./setup_ks8.sh" # The path to the file on your local machine

  acl  = "private"
  etag = filemd5("./setup_ks8.sh")
}

# resource "aws_s3_bucket_object" "dashboard" {


#   bucket = aws_s3_bucket.this.id
#   key    = "setup_dashboard.sh"   # The destination path in S3
#   source = "./setup_dashboard.sh" # The path to the file on your local machine

#   acl  = "private"
#   etag = filemd5("./setup_dashboard.sh")
# }
