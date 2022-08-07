# CodePipeline Resources

resource "aws_s3_bucket" "build_artifact_bucket" {
    bucket          =   "${var.pipeline_name}-build-artifact"
    force_destroy   =   true
}

resource "aws_s3_bucket_acl" "build_artifact_bucket_acl" {
    bucket = aws_s3_bucket.build_artifact_bucket.id
    acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "server_side_encryption_build_artifact_bucket" {
    bucket = aws_s3_bucket.build_artifact_bucket.bucket

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm     = "AES256"
        }
    }
}

data "aws_iam_policy_document" "codepipeline_assume_policy" {
    statement {
        effect  = "Allow"
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = ["codepipeline.amazonaws.com"]
        }
    }
}

resource "aws_iam_role" "codepipeline_role" {
    name               = "${var.pipeline_name}-role"
    assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_policy.json
}

# CodePipeline policy needed to use CodeCommit and CodeBuild
resource "aws_iam_role_policy" "attach_codepipeline_policy" {

    name = "${var.pipeline_name}-policy"
    role = aws_iam_role.codepipeline_role.id

    policy = <<POLICY
{
        "Statement": [
            {
                "Action": [
                    "s3:GetObject",
                    "s3:GetObjectVersion",
                    "s3:GetBucketVersioning",
                    "s3:PutObject",
                    "s3:PutObjectAcl",
                    "lambda:InvokeFunction"
                ],
                "Resource": "*",
                "Effect": "Allow"
            },
            {
                "Action": [
                    "cloudwatch:*",
                    "sns:*",
                    "sqs:*",
                    "elasticbeanstalk:*",
                    "iam:PassRole",
                    "s3:*",
                    "logs:CreateLogGroup",
                    "rds:*",
                    "logs:PutRetentionPolicy",
                    "elasticloadbalancing:*",
                    "ecs:*",
                    "ec2:*",
                    "cloudformation:*",
                    "autoscaling:*"
                ],
                "Resource": "*",
                "Effect": "Allow"
            },
            {
                "Effect": "Allow",
                "Action": [
                    "codestar-connections:UseConnection"
                ],
                "Resource": "${var.codestarConnection}"
            },
            {
                "Action": [
                    "codebuild:BatchGetBuilds",
                    "codebuild:StartBuild",
                    "logs:CreateLogStream"
                ],
                "Resource": "*",
                "Effect": "Allow"
            }
        ],
        "Version": "2012-10-17"
    }
    POLICY
}

# CodeBuild IAM Permissions
resource "aws_iam_role" "codebuild_assume_role" {
    name = "${var.pipeline_name}-build-role"

    assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "codebuild.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy" "codebuild_policy" {
    name = "${var.pipeline_name}-build-policy"
    role = aws_iam_role.codebuild_assume_role.id

    policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketVersioning",
                "s3:PutBucketAcl"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Effect": "Allow",
            "Resource": [
                "${aws_codebuild_project.build_project.id}"
            ],
            "Action": [
                "codebuild:*"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "*"
            ],
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:CreateLogStream"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "*"
            ],
            "Action": [
                "cloudfront:*"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "*"
            ],
            "Action": [
                "ssm:*"
            ]
        }
    ]
}
POLICY
}

# CodeBuild Section for the Package stage
resource "aws_codebuild_project" "build_project" {
    name          = var.pipeline_name
    description   = "The CodeBuild project for ${var.pipeline_name}"
    service_role  = aws_iam_role.codebuild_assume_role.arn
    build_timeout = "60"

    artifacts {
        type = "CODEPIPELINE"
    }

    environment {
        compute_type = "BUILD_GENERAL1_MEDIUM"
        image        = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
        type         = "LINUX_CONTAINER"

        environment_variable {
            name  = "branch"
            value = var.github_branch
        }
    }

    source {
        type      = "CODEPIPELINE"
        buildspec = var.buildspec
    }

    # logs_config {
    #     cloudwatch_logs {
    #         status = "DISABLED"
    #     }
    #     s3_logs {
    #         status = "ENABLED"
    #         location = "feature-env-logs/${var.pipeline_name}"
    #     }
    # }

    tags = {
        Project = "DTD-DEVELOPERS"
        Environment = "DTD-DEVELOPERS"
    }
}

# CodeStar Connection
# resource "aws_codestarconnections_connection" "github_connection" {
#     name          = "${var.pipeline_name}-connection" # GitHub Connection Name
#     provider_type = "GitHub"
# }

# Full CodePipeline
resource "aws_codepipeline" "codepipeline" {
    name     = "${var.pipeline_name}-pipeline"
    role_arn = aws_iam_role.codepipeline_role.arn

    artifact_store {
        location = aws_s3_bucket.build_artifact_bucket.bucket
        type     = "S3"
    }

    stage {
        name = "Source"

        action {
            name             = "Source"
            category         = "Source"
            owner            = "AWS"
            provider         = "CodeStarSourceConnection"
            version          = "1"
            run_order        = 1
            output_artifacts = [
                "code"
            ]
            configuration = {
                ConnectionArn  = var.codestarConnection # aws_codestarconnections_connection.github_connection.arn
                FullRepositoryId = "${var.github_username}/${var.github_repo}"
                OutputArtifactFormat = "CODE_ZIP"
                BranchName = var.github_branch
            }
        }
    }

    stage {
        name = "CodeBuild"

        action {
            name             = "CodeBuild"
            category         = "Test"
            owner            = "AWS"
            provider         = "CodeBuild"
            input_artifacts  = ["code"]
            output_artifacts = ["codebuild"]
            version          = "1"
            run_order        = 1

            configuration = {
                ProjectName  = aws_codebuild_project.build_project.name
            }
        }
    }

    stage {
        name = "Deploy"

        action {
            name            = "Deploy"
            category        = "Deploy"
            owner           = "AWS"
            provider        = "ElasticBeanstalk"
            input_artifacts = ["codebuild"]
            version         = "1"

            configuration = {
                ApplicationName = var.elastic_beanstalk_application_name
                EnvironmentName = "${var.elastic_beanstalk_environment_name}"
            }
        }
    }

    # stage {
    #     name = "Cloudfront_Invalidation"

    #     action {
    #         name            = "Cloudfront_Invalidation"
    #         category        = "Invoke"
    #         owner           = "AWS"
    #         provider        = "Lambda"
    #         version         = "1"

    #         configuration = {
    #             FunctionName = "Invalidate-Cloudfront"
    #             UserParameters = var.cdn_id
    #         }
    #     }
    # }
}
