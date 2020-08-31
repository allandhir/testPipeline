provider "google" {
  credentials = file("${var.sa_key}")
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}


resource "google_project_service" "crm_api" {
  service = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_service_account" "cicd-sa" {
  account_id   = "cicd-sa"
  display_name = "Service Account for cicd-server"
}

resource "google_service_account_key" "mykey" {
  service_account_id = google_service_account.cicd-sa.name
}

resource "local_file" "cicd-sa-private-key-file" {
  content  = base64decode(google_service_account_key.mykey.private_key)
  filename = "cicd-sa.json"
}

resource "google_project_iam_member" "k8s-member" {
  count   = length(var.iam_roles)
  project = var.project_id
  role    = element(values(var.iam_roles), count.index)
  member  = "serviceAccount:${google_service_account.cicd-sa.email}"
}

resource "google_compute_instance" "default" {
    name = "cicd-server"
    zone = var.zone
    machine_type = "e2-medium"
    
    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-10"
        }
    }
    scheduling {
        preemptible = "false"
        automatic_restart = "true"
    }

    network_interface {
        network = "default"
        access_config {
        }
    }

    service_account {
        email = google_service_account.cicd-sa.email
        scopes = ["cloud-platform"] //access to all cloud API's but restricted to the permissions the service account has.
    }
    metadata = {
      ssh-keys = "allandhir:${file("~/.ssh/terraform-ssh-key.pub")}"
    }
    connection {
      type        = "ssh"
      user        = "allandhir"
      private_key = file(var.private_key_path)
      host        = google_compute_instance.default.network_interface.0.access_config.0.nat_ip
      agent       = true
    }
    provisioner "file" {
        source = "./scripts/setup.sh"
        destination = "/tmp/setup.sh"
    }
    provisioner "file" {
        source = "./scripts/plugins.txt"
        destination = "/tmp/plugins.txt"
    }

    provisioner "remote-exec" {
        inline = [
            "chmod +x /tmp/setup.sh",
            "sudo /tmp/setup.sh"
        ]
    }

    provisioner "file" {
        source = "~/.kube/config"
        destination = "/tmp/config"
    }
    
    tags = ["cicd"]
}

resource "google_compute_firewall" "allow-jenkins" {
  name = "allow-jenkins-port"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
    source_ranges = ["0.0.0.0/0"]
    target_tags = ["cicd"]
    #target_service_accounts = ["jenkins"]
}




