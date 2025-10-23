terraform {
  backend "s3" {
    bucket         = "s3-lmk-tf-state"
    key            = "prac_tf/learn/terraform.tfstate"
    region         = "us-east-2"
  }
}
