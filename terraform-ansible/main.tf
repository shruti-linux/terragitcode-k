provider "google" {
  project     = "testjune13-462806"
  region      = "us-central1"
  credentials = file("~/sec.json")
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
  name                    = "centos9-vpc1"
  auto_create_subnetworks = true
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "8080", "1000-2000"]
  }

  direction = "INGRESS"
  source_ranges = ["0.0.0.0/0"]

  target_tags = ["centos9"]
  priority    = 1000
  description = "Allow SSH from anywhere"
}



resource "google_compute_instance" "centos9_vm" {
  depends_on = [google_compute_firewall.allow_ssh]
  name         = "centos9-vm2"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

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
    ssh-keys = "centos:${file("~/.ssh/id_rsa.pub")}"
    startup-script = <<-EOT
      #!/bin/bash
      useradd -m -s /bin/bash devops
      mkdir -p /home/devops/.ssh
      echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC21Iqhz/VCClxNEKjn6GvDINqhpzuKEwmxfZPZyZbuDyw0ZEvsdmLAPsm/Kw6UNAFHJf1bKr/tsjWBwWu4iv8m4xH53s+AqNTqAIjqtLxmU6v8nknd0SXsoXx+2smO7J3aL8o9yigV/kjIUNIHVXxtCikLvSMaXIu20GWB8AHrLrKC/RQ1SNzFiU6rNJQQJ8jqWS/YGtP9pF8CS8P3RJaA4FU++VhOnrsBwwXPniz4L0yP5bxwt3vRpdjvmXbjXseqOPP6L7IPbbs3BCl7KrtbNHbMI6j+FungazgZtXRrQwlCmmX90vuNmTEVv79uHt2dKC0hk/RinknJ4wC6Y+C5n6jId0e/6Po+iFKmn1ednFFSARjujeegEci4PD7YMbnVZKRFG0KU1qUv0o2pLFioESSN8EpibukiN/kYRhu1YFluo/XvRoxpx3MZTmoD1EVcHVV6ENLP+YxJRYFniIxcWsv4sImVuExR1+i4w1jy2+Zmft+sIpHp3yUAV3PFBds= shruti@master"  > /home/devops/.ssh/authorized_keys
      chown -R devops:devops /home/devops/.ssh
      chmod 700 /home/devops/.ssh
      chmod 600 /home/devops/.ssh/authorized_keys
    EOT
  }

  tags = ["centos9"]
}


output "instance_ip" {
  value = google_compute_instance.centos9_vm.network_interface[0].access_config[0].nat_ip
}


