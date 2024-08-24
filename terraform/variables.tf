
variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "Cluster_name" {
  description = "Cluster Name"
  type        = string
  default     = "Bruvio"
}

variable "VPC_name" {
  description = "VPC Name"
  type        = string
  default     = "VPC_bruvio"

}
variable "folder1_path" {
  type    = string
  default = "../simple"
}

variable "folder2_path" {
  type    = string
  default = "../helloHttpd"
}
variable "versioning" {
  type    = bool
  default = false
}

variable "key-name" {
  default = "deployer-key"
}
