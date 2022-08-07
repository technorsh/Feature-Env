resource "aws_cloudfront_distribution" "static_web_cloudfront" {

    enabled = true
    default_cache_behavior {

        allowed_methods = [ 
            "DELETE",
            "GET", 
            "HEAD", 
            "OPTIONS", 
            "PATCH", 
            "POST", 
            "PUT" 
        ]

        cached_methods = [ 
            "GET", 
            "HEAD" 
        ]

        target_origin_id       = var.cname
        viewer_protocol_policy = "redirect-to-https"
        min_ttl                = 0
        default_ttl            = 86400
        max_ttl                = 31536000
        compress               = true

        forwarded_values {
            query_string = false
            cookies {
                forward = "none"
            }
        }
    }

    origin {
        # s3_origin_config {
        #     origin_access_identity = "origin-access-identity/cloudfront/${aws_cloudfront_origin_access_identity.origin_access_identity.id}"
        # }
        custom_origin_config {
            http_port = 80
            https_port = 443
            origin_protocol_policy = "http-only"
            origin_ssl_protocols = ["TLSv1.2"]
        }
        domain_name = var.domain-name
        origin_id = var.cname
    }

    # default_root_object = "index.html"

    # custom_error_response {
    #     error_code            = "403"
    #     response_code         = "200"
    #     response_page_path    = "/index.html"
    #     error_caching_min_ttl = 300
    # }

    # custom_error_response {
    #     error_code            = "404"
    #     response_code         = "200"
    #     response_page_path    = "/index.html"
    #     error_caching_min_ttl = 300
    # }

    # logging_config {
    #     include_cookies = false
    #     bucket          = var.logs_bucket_name_cloudfront
    #     prefix          = "myprefix"
    # }

    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }

    aliases       = [ "${var.cname}.${var.domain}" ]
    # web_acl_id    = var.web_acl_id

    viewer_certificate {
        acm_certificate_arn = var.cert_arn
        ssl_support_method  = "sni-only"
        minimum_protocol_version = "TLSv1.2_2021"
        cloudfront_default_certificate = false
    }
}

# resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
#     comment = "OAI"
# }

# data "aws_iam_policy_document" "s3_policy" {
#     statement {
#         actions   = ["s3:GetObject"]
#         resources = var.resource-bucket

#         principals {
#             type        = "AWS"
#             identifiers = [ aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn ]
#         }
#     }
# }

# resource "aws_s3_bucket_policy" "bucket-id" {
#     bucket = var.bucket-name
#     policy = data.aws_iam_policy_document.s3_policy.json
# }

# resource "aws_route53_record" "www" {
#     zone_id = var.zone_id
#     records = ["${aws_cloudfront_distribution.static_web_cloudfront.domain_name}"]
#     type    = "CNAME"
#     name    = "${var.cname}.${var.domain}"
#     ttl     = "5"
# }