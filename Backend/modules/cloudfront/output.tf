output "cloudfront-id" {
    value = aws_cloudfront_distribution.static_web_cloudfront.id
    description = "Gives cloudfront distribution ID: "
}

output "domain-name" {
    value = aws_cloudfront_distribution.static_web_cloudfront.domain_name
    description = "Domain Name: "
}

output "web_url" {
    value = "https://${var.cname}.${var.domain}/"
}