provider "google" {
  project     = "testjune13-462806"
  region      = "us-central1"
  credentials = file("/home/shruti/sec.json")
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
    bucket      = "tf-state-prod-byshrutier"
    prefix      = "ansibleterraform"
    credentials = "/home/shruti/sec.json"
   }
}


resource "google_compute_network" "vpc" {
  name                    = "centos9-vpc"
  auto_create_subnetworks = true
}

resource "google_compute_instance" "centos9_vm" {
  name         = "centos9-vm"
  machine_type = "e2-medium"
  zone = "us-central1-a"
  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-stream-9"
    }
  }

  network_interface {
    network       = google_compute_network.vpc.name
    access_config {}
  }

  metadata = {
    ssh-keys = "centos:${file("/home/shruti/.ssh/id_rsa.pub")}"
  }

  tags = ["centos9"]
}

output "instance_ip" {
  value = google_compute_instance.centos9_vm.network_interface[0].access_config[0].nat_ip
}
