terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = "testjune13-462806"
  region  = "us-central1"
}

resource "google_compute_instance" "vm" {
  count        = 3  # Creates 3 identical VMs
  name         = "vm-instance-${count.index}"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {}  # Assigns a public IP
  }

  metadata = {
    ssh-keys = "ansible-user:${file("~/.ssh/id_rsa.pub")}"  # SSH key for Ansible access
  }
}

# Generate Ansible inventory file
resource "local_file" "ansible_inventory" {
  filename = "./ansible/inventory.ini"
  content  = <<-EOT
    [gcp_vms]
    %{for vm in google_compute_instance.vm.*}
    ${vm.name} ansible_host=${vm.network_interface.0.access_config.0.nat_ip}
    %{endfor}
  EOT
}
