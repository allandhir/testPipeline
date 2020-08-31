// gcp details
project_id = "dev-range-287412"
sa_key = "test-sa.json"
region = "us-central1"
zone = "us-central1-a"

//private key for ssh 
private_key_path = "~/.ssh/terraform-ssh-key"

// IAM roles for cicd-server VM instance
iam_roles = {
  role1 = "roles/compute.storageAdmin"
  role2 = "roles/storage.admin"
}


