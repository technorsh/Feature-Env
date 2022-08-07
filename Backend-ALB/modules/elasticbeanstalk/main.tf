# resource "aws_elastic_beanstalk_application" "application" {
#   name        = var.elastic_beanstalk_application_name
# }

resource "aws_elastic_beanstalk_environment" "environment" {
    name                = "${var.elastic_beanstalk_environment_name}"
    application         = var.elastic_beanstalk_application_name
    solution_stack_name = var.solution_stack_name

    cname_prefix = "${var.name}"

    setting {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "IamInstanceProfile"
      value     = "aws-elasticbeanstalk-ec2-role"
    }

    # setting {
    #   namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    #   name = "StreamLogs"
    #   value = "true"
    # }

    # setting {
    #     namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    #     name = "DeleteOnTerminate"
    #     value = "true"
    # }

    # setting {
    #     namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    #     name = "RetentionInDays"
    #     value = "1"
    # }

    # setting {
    #     namespace = "aws:elbv2:loadbalancer"
    #     name = "AccessLogsS3Enabled"
    #     value = "true"
    # }

    # setting {
    #     namespace = "aws:elbv2:loadbalancer"
    #     name = "AccessLogsS3Bucket"
    #     value = aws_s3_bucket.eb_log_bucket.bucket
    # }

    setting {
        namespace = "aws:elasticbeanstalk:environment"
        name = "LoadBalancerType"
        value = var.loadbalancer_type
    }

    # setting {
    #     namespace = "aws:elasticbeanstalk:application"
    #     name = "Application Healthcheck URL"
    #     value = "/"
    # }

    setting {
        namespace = "aws:autoscaling:asg"
        name = "Availability Zones"
        value = "Any 2"
    }

    setting {
        namespace = "aws:autoscaling:trigger"
        name = "MeasureName"
        value = "CPUUtilization"
    }

    setting {
        namespace = "aws:autoscaling:trigger"
        name = "LowerThreshold"
        value = "20"
    }

    setting {
        namespace = "aws:autoscaling:trigger"
        name = "UpperThreshold"
        value = "80"
    }
    
    setting {
        namespace = "aws:autoscaling:trigger"
        name = "Unit"
        value = "Percent"
    }

    setting {
        namespace = "aws:autoscaling:launchconfiguration"
        name = "RootVolumeType"
        value = "gp2"
    }

    setting {
        namespace = "aws:autoscaling:launchconfiguration"
        name = "RootVolumeSize"
        value = "8"
    }

    setting {
        namespace = "aws:autoscaling:updatepolicy:rollingupdate"
        name = "RollingUpdateEnabled"
        value = "true"
    }

    setting {
        namespace = "aws:autoscaling:updatepolicy:rollingupdate"
        name = "RollingUpdateType"
        value = "Time"
    }

    # Manage Action - Rollback Updates

    setting {
        namespace = "aws:elasticbeanstalk:command"
        name = "DeploymentPolicy"
        value = "Rolling"
    }

    # setting {
    #     namespace = "aws:elasticbeanstalk:managedactions"
    #     name = "ManagedActionsEnabled"
    #     value = "true"
    # }

    setting {
        namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
        name = "UpdateLevel"
        value = "minor"
    }

    setting {
        namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
        name = "InstanceRefreshEnabled"
        value = "true"
    }

    setting {
        namespace = "aws:elasticbeanstalk:managedactions"
        name = "PreferredStartTime"
        value = "Sun:10:00"
    }

    setting {
        namespace = "aws:elasticbeanstalk:managedactions"
        name = "ServiceRoleForManagedUpdates"
        value = "AWSServiceRoleForElasticBeanstalkManagedUpdates"
    }

    setting {
        namespace = "aws:ec2:vpc"
        name = "VPCId"
        value = var.vpc_id
    }

    setting {
        namespace = "aws:ec2:vpc"
        name = "Subnets"
        value = var.subnets
    }

    # setting {
    #     name = "EnableSpot"
    #     namespace = "aws:ec2:instances"
    #     value = "true"
    # }

    setting {
        name = "InstanceType"
        namespace = "aws:autoscaling:launchconfiguration"
        value = var.instance_type
    }

    setting {
        name = "EnableCapacityRebalancing"
        namespace = "aws:autoscaling:asg"
        value = "true"
    }

    setting {
        namespace = "aws:ec2:vpc"
        name = "ELBSubnets"
        value = var.application_subnets
    }

    setting {
        namespace = "aws:ec2:vpc"
        name = "AssociatePublicIpAddress"
        value = "true"
    }

    setting {
        namespace = "aws:autoscaling:launchconfiguration"
        name = "EC2KeyName"
        value = var.keypair
    }

    setting {
        namespace = "aws:elbv2:listener:443"
        name = "Protocol"
        value = "HTTPS"
    }

    setting {
        namespace = "aws:elbv2:listener:443"
        name = "SSLPolicy"
        value = var.loadbalancer_ssl_policy
    }

    setting {
        namespace = "aws:elbv2:listener:443"
        name = "SSLCertificateArns"
        value = var.loadbalancer_certificate_arn
    }

    setting {
        namespace = "aws:autoscaling:launchconfiguration"
        name = "InstanceType"
        value = var.instance_type
    }

    # Single Instance 

    # setting {
    #     namespace = "aws:elasticbeanstalk:environment"
    #     name = "EnvironmentType"
    #     value = "SingleInstance"
    # }

    # Environment Process 

    setting {
        namespace = "aws:elasticbeanstalk:environment:process:default"
        name = "Port"
        value = 5000
    }
    setting {
        namespace = "aws:elasticbeanstalk:environment:process:default"
        name = "HealthCheckPath"
        value = "/"
    }

    setting {
        namespace = "aws:autoscaling:launchconfiguration"   
        name = "SecurityGroups"
        value = var.security_group
    }

    setting {
        name = "MatcherHTTPCode"
        namespace = "aws:elasticbeanstalk:environment:process:default"
        value = "200,401"
    }

    setting {
       name = "EnvironmentVariables"
       namespace = "aws:cloudformation:template:parameter"
       value = "SERVER_PORT=5000,M2=/usr/local/apache-maven/bin,M2_HOME=/usr/local/apache-maven,GRADLE_HOME=/usr/local/gradle"
    }

    tags = {
        Project = "DTD-DEVELOPERS"
        Environment = "DTD-DEVELOPERS"
    }
}

resource "aws_route53_record" "www" {
    zone_id = var.zone_id
    records = [ aws_elastic_beanstalk_environment.environment.endpoint_url ]
    type    = "CNAME"
    name    = "${var.cname}.${var.domain}"
    ttl     = "5"
}

# resource "aws_s3_bucket" "eb_log_bucket" {
#     bucket = "${var.name}-eb-loadbalancer-log"
#     force_destroy = true
#     tags = {
#         Name        = "${var.name}-eb-loadbalancer-log"
#         Environment = "Dev"
#     }
# }

# data "aws_region" "current" {}
# data "aws_caller_identity" "current" {}
# data "aws_elb_service_account" "main" {}

# resource "aws_s3_bucket_policy" "lb-bucket-policy" {
#     bucket = aws_s3_bucket.eb_log_bucket.id
        
#     policy = <<POLICY
# {
#     "Id": "Policy",
#     "Version": "2012-10-17",
#     "Statement": [{
#             "Effect": "Allow",
#             "Principal": {
#                 "AWS": [
#                     "${data.aws_elb_service_account.main.arn}"
#                 ]
#             },
#             "Action": [
#                 "s3:PutObject"
#             ],
#             "Resource": "${aws_s3_bucket.eb_log_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
#         },
#         {
#             "Effect": "Allow",
#             "Principal": {
#                 "Service": "delivery.logs.amazonaws.com"
#             },
#             "Action": [
#                 "s3:PutObject"
#             ],
#             "Resource": "${aws_s3_bucket.eb_log_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
#             "Condition": {
#                 "StringEquals": {
#                     "s3:x-amz-acl": "bucket-owner-full-control"
#                 }
#             }
#         },
#         {
#             "Effect": "Allow",
#             "Principal": {
#                 "Service": "delivery.logs.amazonaws.com"
#             },
#             "Action": [
#                 "s3:GetBucketAcl"
#             ],
#             "Resource": "${aws_s3_bucket.eb_log_bucket.arn}"
#         }
#     ]
# }
# POLICY
# }