#s3

resource "aws_s3_bucket" "infra_bucket" {
        bucket = "aws-autoscaling-infra-bucket"

        tags = {
            Name = "aws-autoscaling-infra-bucket"
        }
}

#dynamodb

resource "aws_dynamodb_table" "infra_lock_table" {
        name         = "aws-autoscaling-infra-lock-table"
        billing_mode = "PAY_PER_REQUEST"
        hash_key     = "LockID"

        attribute {
                name = "LockID"
                type = "S"
        }

        tags = {
            Name = "aws-autoscaling-infra-lock-table"
        }
}