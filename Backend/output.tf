output "elb_url" {
    value = module.elasticbeanstalk.elb_url
}

output "id" {
    value = module.cloudfront.cloudfront-id
}

output "domain-name" {
    value = module.cloudfront.domain-name
}