provider "google" {
  credentials = file("${var.sa_key}")
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}

resource "google_container_cluster" "primary" {
  name     = "testcluster"
  location = "us-central1-a"

  remove_default_node_pool = true
  initial_node_count       = 1

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
  provisioner "local-exec" {
    command = "sudo gcloud container clusters get-credentials testcluster --zone=us-central1-a"
  }
}

resource "google_container_node_pool" "testcluster_nodes" {
  name       = "test-node-pool"
  location   = "us-central1-a"
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = false
    machine_type = "e2-medium"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
    ]
  }
}


