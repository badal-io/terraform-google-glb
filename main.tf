// Provides information on GCP provider config
data "google_client_config" "default" {}

locals {
    project-id   = "${length(var.project) > 0 ? var.project : data.google_client_config.default.project}"
    # backend    = "${var.backend == null ? [] : list(var.backend)}"
    # cdn_policy = "${var.cdn_policy == null ? [] : list(var.cdn_policy)}"
}
# Managed SSL Certificate
resource "google_compute_managed_ssl_certificate" "default" {
    # provider hack until workaround is established
    provider = "google-beta"

    project     = "${local.project-id}"
    name        = "${var.name}-ssl"
    description = "${var.ssl_description}"

    managed {
        domains = ["${var.domain}"]
    }
}


# Health Check
resource "google_compute_http_health_check" "default" {
    project      = "${local.project-id}"
    name         = "${var.name}-health-check"
    description  = "${var.hc_description}"

    healthy_threshold   = "${var.hc_healthy_threshold}"
    check_interval_sec  = "${var.hc_check_interval}"
    timeout_sec         = "${var.hc_timeout}"
    unhealthy_threshold = "${var.hc_unhealthy_threshold}"

    request_path        = "${var.hc_request_path}"
    host                = "${var.hc_host_header}"
    port                = "${var.hc_port}"
}

resource "google_compute_backend_service" "default" {
    project       = "${local.project-id}"
    name          = "${var.name}-bs"
    description   = "${var.bs_description}"

    health_checks = ["${google_compute_http_health_check.default.self_link}"]

    affinity_cookie_ttl_sec = "${var.affinity_cookie_ttl}"

    load_balancing_scheme = "${var.lb_scheme}"
    port_name   = "${var.port_name}"
    protocol    = "${var.protocol}"
    security_policy = "${var.security_policy}"
    session_affinity = "${var.session_affinity}"
    timeout_sec = "${var.timeout_sec}"

    enable_cdn = "${var.enable_cdn}"
    connection_draining_timeout_sec = "${var.connection_draining_timeout_sec}"

    dynamic "backend" {
        for_each = var.backend == null ? [] : list(var.backend)

        content {
            balancing_mode  = backend.value.balancing_mode
            capacity_scaler = backend.value.capacity_scaler
            description     = backend.value.description
            group           = backend.value.group

            max_connections              = backend.value.max_connections
            max_connections_per_instance = backend.value.max_connections_per_instance
            max_connections_per_endpoint = backend.value.max_connections_per_endpoint

            max_rate              = backend.value.max_rate
            max_rate_per_instance = backend.value.max_rate_per_instance
            max_rate_per_endpoint = backend.value.max_rate_per_endpoint

            max_utilization = backend.value.max_utilization
        }
    }

    dynamic "cdn_policy" {
        for_each = var.cdn_policy == null ? [] : list(var.cdn_policy)

        content {
            dynamic "cache_key_policy" {
                for_each = cdn_policy.value.cache_key_policy == null ? [] : list(cdn_policy.value.cache_key_policy)

                content {
                    include_host           = cache_key_policy.value.include_host
                    include_protocol       = cache_key_policy.value.include_protocol
                    include_query_string   = cache_key_policy.value.include_query_string
                    query_string_blacklist = cache_key_policy.value.query_string_blacklist
                    query_string_whitelist = cache_key_policy.value.query_string_whitelist
                }
            }
            signed_url_cache_max_age_sec = cdn_policy.value.signed_url_cache_max_age_sec
        }
    }

    dynamic "iap" {
        for_each = var.iap == null ? [] : list(var.iap)

        content {
            oauth2_client_id            = cache_key_policy.value.oauth2_client_id
            oauth2_client_secret        = cache_key_policy.value.oauth2_client_secret
            oauth2_client_secret_sha256 = cache_key_policy.value.oauth2_client_secret_sha256
        }
    }
}

resource "google_compute_url_map" "default" {
    project       = "${local.project-id}"
    name          = "${var.name}-bs"
    description   = "${var.um_description}"

    default_service = "${google_compute_backend_service.default.self_link}"

    # This has been temporarily disabled
    # We will reimplement this logic once we have a for_each that supports generating multiple backends.
    # As of Version 0.12 of TF, below doesn't make sense for this module

    # dynamic "host_rule" {
    #     for_each = var.host_rule == null ? [] : list(var.host_rule)

    #     content {
    #         description  = host_rule.value.description
    #         hosts        = host_rule.value.hosts
    #         path_matcher = host_rule.value.path_matcher_name
    #     }
    # }

    # dynamic "path_matcher" {
    #     for_each = var.path_matcher == null ? [] : list(var.path_matcher)

    #     content {
    #         default_service = google_compute_backend_service.default.self_link
    #         description     = path_matcher.value.description
    #         name            = path_matcher.value.name

    #         dynamic "path_rule" {
    #             for_each = [for p in path_matcher.value.paths: {
    #                 paths = p
    #             }]

    #             content {
    #                 paths   = path_rule.value.paths
    #                 service = google_compute_backend_service.default.self_link
    #             }
    #         } 
    #     }
    # }

    # dynamic "test" {
    #     for_each = var.test == null ? [] : list(var.test)

    #     content {
    #         description  = test.value.description
    #         host         = test.value.host
    #         path         = test.value.path
    #         service      = google_compute_backend_service.default.self_link
    #     }
    # }
}

resource "google_compute_target_https_proxy" "default" {
    project       = "${local.project-id}"
    name          = "${var.name}-https-tp"
    description   = "${var.tp_description}"

    url_map          = "${google_compute_url_map.default.self_link}"
    ssl_certificates = ["${google_compute_managed_ssl_certificate.default.self_link}"]
}

resource "google_compute_global_forwarding_rule" "default" {
    project       = "${local.project-id}"
    name          = "${var.name}-fr"
    description   = "${var.fr_description}"

    target  = "${google_compute_target_https_proxy.default.self_link}"
    ip_address = "${var.load_balancer_ip}"

    ip_protocol = "${var.load_balancer_protocol}"

    load_balancing_scheme = "${var.lb_scheme}"

    # ommiting port_range as we are forcing SSL in this module for now
    # add future support for port 80 target proxy
    port_range = 443
}