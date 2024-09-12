variable "vpc_name" {
  default = "khainh-tf-vpc"
}

variable "cidrvpc" {
  default = "10.0.0.0/16"
}

variable "tags" {
  default = {
    Name = "khainh-tf-vpc"
    Owner = "khainh"
  }
}

variable "az_count" {
    default = 3
}