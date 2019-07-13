# compute URL map output
output "url_map_selflink" {
    description = "The URI for Compute URL Map"
    value       = "${google_compute_url_map.default.self_link}"
}

output "url_map_id" {
    description = "unique identifier for the resource."
    value       = "${google_compute_url_map.default.map_id}"
}

# Managed SSL Certificate outputs
output "ssl_selflink" {
    description = "The URI for Managed SSL Certificate"
    value       = "${google_compute_managed_ssl_certificate.default.self_link}"
}

output "ssl_id" {
    description = "The unique identifier for Managed SSL Certificate"
    value       = "${google_compute_managed_ssl_certificate.default.certificate_id}"
}

output "ssl_san" {
    description = "Domains associated with the certificate via Subject Alternative Name"
    value       = "${google_compute_managed_ssl_certificate.default.subject_alternative_names}"
}

#Forwarding Rule
output "fr_selflink" {
    description = "URI for Forwarding Rule"
    value = "${google_compute_global_forwarding_rule.default.self_link}"
}