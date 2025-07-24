provider "google" {
  credentials = file("/home/shruti/sec.json")
  project     = var.project_id
  region      = var.region
}

#tf-state-prod-bykumar need to create manully
terraform {
  required_version = ">= 0.13"

  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }

  backend "gcs" {
    bucket      = "tf-state-prod-bykumar"
    prefix      = "dev"
    credentials = "home/shruti/sec.json"
   }
}
