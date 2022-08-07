module "elasticbeanstalk" {
  source = "./modules/elasticbeanstalk"

  name = var.name # Will use it for cname
  
  # Elastic Beanstalk Details 

  elastic_beanstalk_application_name = var.elastic_beanstalk_application_name
  elastic_beanstalk_environment_name = var.elastic_beanstalk_environment_name
  solution_stack_name = var.solution_stack_name

  # VPC Details 

  vpc_id = var.vpc_id
  subnets = var.subnets # Private Subnets
  security_group = aws_security_group.allow_traffic.id

  # Instance Details 

  instance_type = var.instance_type
  keypair = var.keypair
}

# module "codepipeline" {
#   source = "./modules/codepipeline"

#   # Codepipeline Details

#   pipeline_name = var.name

#   # Codestar Connection

#   codestarConnection = var.codestarConnection

#   # Github Details

#   github_branch = var.github_branch
#   github_repo = var.github_repo
#   github_username = var.github_username

#   # buildspec.yml file

#   buildspec = var.buildspec

#   # Elastic beanstalk Details

#   elastic_beanstalk_application_name = var.elastic_beanstalk_application_name
#   elastic_beanstalk_environment_name = var.elastic_beanstalk_environment_name

#   # Cloudfront Details
#   cdn_id = module.cloudfront.cloudfront-id
# }

module "cloudfront" {
  source = "./modules/cloudfront"

  region = var.region
  cert_arn = var.cert_arn
  # web_acl_id = var.web_acl_id

  # Route 53 Details

  domain = var.domain
  cname = var.name
  domain-name = module.elasticbeanstalk.elb_url
  zone_id = var.zone_id
}

resource "aws_security_group" "allow_traffic" {
  name        = "${var.elastic_beanstalk_environment_name}-ebs-sg"
  description = "Feature Env Security Group"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Allow HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["172.0.0.0/16"]
  }

  ingress {
    description      = "Allow HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["172.0.0.0/16"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}