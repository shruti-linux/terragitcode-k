resource "google_storage_bucket" "example" {
  name     = "${var.project_id}-tf-bucket"
  location = var.region
  force_destroy = true
}
