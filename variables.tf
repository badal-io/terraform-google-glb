variable "project" {
  description = "The project in which the resource belongs. If it is not provided, the provider project is used."
  type        = string
  default     = ""
}

variable "name" {
    description = "Name of the resource. Provided by the client when the resource is created. The name must be 1-63 characters long, and comply with RFC1035. Specifically, the name must be 1-63 characters long and match the regular expression [a-z]([-a-z0-9]*[a-z0-9])? which means the first character must be a lowercase letter, and all following characters must be a dash, lowercase letter, or digit, except the last character, which cannot be a dash."
    type        = string
}

# SSL Certificate
variable "ssl_description" {
  description = "description of the SSL Resource"
  type        = string
  default     = "Managed SSL Certificate - Provisioned by Terraform"
}

variable "domain" {
    description = "Domains for which a managed SSL certificate will be valid."
    type = string
}

# Health Checks
variable "hc_check_interval" {
  description = "How often (in seconds) to send a health check"
  type        = number
  default     = 5
}

variable "hc_description" {
  description = "Descripton for health check"
  type        = string
  default     = "Health Check - Provisioned by Terraform"
}

variable "hc_healthy_threshold" {
  description = "A so-far unhealthy instance will be marked healthy after this many consecutive successes"
  type        = number
  default     = 2
}

variable "hc_host_header" {
    description = "The value of the host header in the HTTP health check request. If left empty (default value), the public IP on behalf of which this health check is performed will be used."
    type        = string
    default     = null
}

variable "hc_request_path" {
    description = "The request path of the HTTP health check request."
    type        = string
    default     = "/"
}

variable "hc_timeout" {
  description = "How long (in seconds) to wait before claiming failure. The default value is 5 seconds. It is invalid for timeoutSec to have greater value than checkIntervalSec"
  type        = number
  default     = 5
}

variable "hc_unhealthy_threshold" {
  description = "A so-far healthy instance will be marked unhealthy after this many consecutive failures"
  type        = number
  default     = 2
}

variable "hc_port" {
  description = "The TCP port number for the HTTP health check request."
  type        = number
  default     = 80
}

# backend services
variable "bs_description" {
    description = "backend description"
    type        = string
    default     = "Backend Service - Provisioned by Terraform"
}

variable "affinity_cookie_ttl" {
    description = "Lifetime of cookies in seconds if session_affinity is GENERATED_COOKIE. If set to 0, the cookie is non-persistent and lasts only until the end of the browser session (or equivalent). The maximum allowed value for TTL is one day. When the load balancing scheme is INTERNAL, this field is not used."
    type        = number
    default     = null
}

variable "enable_cdn" {
    description = "enable CDN"
    type        = bool
    default     = false
}

variable "connection_draining_timeout_sec" {
    description = "Time for which instance will be drained (not accept new connections, but still work to finish started)"
    type        = number
    default     = null
}


variable "backend" {
    description = "Please refer to README to see the structure of backend block. More details can be found at https://www.terraform.io/docs/providers/google/r/compute_backend_service.html#max_rate_per_endpoint"
    type        = object({
        balancing_mode               = string
        capacity_scaler              = number
        description                  = string
        group                        = string
        max_connections              = number
        max_connections_per_instance = number
        max_connections_per_endpoint = number
        max_rate                     = number
        max_rate_per_instance        = number
        max_rate_per_endpoint        = number
        max_utilization              = number
    })
    default = null
}

variable "cdn_policy" {
    description = "Please refer to README to see the structure of cdn_policy block. More details can be found at https://www.terraform.io/docs/providers/google/r/compute_backend_service.html#max_rate_per_endpoint"
    type        = object({
        cache_key_policy = object({
            include_host = bool
            include_protocol = bool
            include_query_string = bool
            query_string_blacklist = list(string)
            query_string_whitelist = list(string)
        })
        signed_url_cache_max_age_sec = number
    })
    default     = null
}

variable "iap" {
    description = " Settings for enabling Cloud Identity Aware Proxy Structure"
    type        = object({
        oauth2_client_id            = string
        oauth2_client_secret        = string
        oauth2_client_secret_sha256 = string
    })
    default     = null
}

variable "lb_scheme" {
    description = "Indicates whether the backend service will be used with internal or external load balancing. A backend service created for one type of load balancing cannot be used with the other. Must be EXTERNAL or INTERNAL_SELF_MANAGED for a global backend service"
    type        = string
    default = "EXTERNAL"
}

variable "port_name" {
    description = "Name of backend port. The same name should appear in the instance groups referenced by this service. Required when the load balancing scheme is EXTERNAL."
    type        = string
    default     = null
}

variable "protocol" {
    description = "The protocol this BackendService uses to communicate with backends. Possible values are HTTP, HTTPS, HTTP2, TCP, and SSL. The default is HTTP. NOTE: HTTP2 is only valid for beta HTTP/2 load balancer types and may result in errors if used with the GA API."
    type        = string
    default     = "HTTP"
}

variable "security_policy" {
    description = "The security policy associated with this backend service."
    type        = string
    default     = null
}

variable "session_affinity" {
    description = "Type of session affinity to use. The default is NONE. When the load balancing scheme is EXTERNAL, can be NONE, CLIENT_IP, or GENERATED_COOKIE. When the protocol is UDP, this field is not used."
    type        = string
    default     = "NONE"
}

variable "timeout_sec" {
    description = "How many seconds to wait for the backend before considering it a failed request. Default is 30 seconds."
    type        = number
    default     = 30
}

# Compute URL MAP
variable "um_description" {
  description = "An optional description of this resource. Provide this property when you create the resource."
  type        = string
  default     = "Compute URL Map - Provisioned by Terraform"
}

variable "host_rule" {
  description = "An optional description of this resource. Provide this property when you create the resource."
  type        = object({
      description       = string
      hosts             = list(string)
      path_matcher_name = string
  })
  default     = null
}

variable "path_matcher" {
  description = "The list of named PathMatchers to use against the URL."
  type        = object({
      description = string
      name        = string
      paths        = list(string)
  })
  default     = null
}

variable "test" {
  description = "he list of expected URL mappings. Requests to update this UrlMap will succeed only if all of the test cases pass."
  type        = object({
      description = string
      host        = string
      path        = string
  })
  default     = null
}

# Forwarding Rule
variable "tp_description" {
    description = "Description for Target Proxy"
    type        = string
    default     = "HTTPS Target Proxy - Provisioned by Terraform"
}

variable "fr_description" {
    description = "Description for Global Forwarding Rule"
    type        = string
    default     = "Global Forwarding Rule - Provisioned by Terraform"
}

variable "load_balancer_ip" {
    description = "The IP address that this forwarding rule is serving on behalf of. Addresses are restricted based on the forwarding rule's load balancing scheme (external or internal) and scope (global or regional). The address must be a global IP for external global forwarding rules. If this field is empty, an ephemeral IPv4 address from the same scope (global) is closen."
    type        = string
    default     = null
}

variable "load_balancer_protocol" {
    description = "The IP protocol to which this rule applies. Valid options are TCP, UDP, ESP, AH, SCTP or ICMP. When the load balancing scheme is INTERNAL_SELF_MANAGED, only TCP is valid."
    type        = string
    default     = "TCP"
}

variable "ip_version" {
    description = "The IP Version that will be used by this global forwarding rule. Valid options are IPV4 or IPV6."
    type        = string
    default     = "IPV4"
}