output "elb_url" {
    value = aws_elastic_beanstalk_environment.environment.cname
}