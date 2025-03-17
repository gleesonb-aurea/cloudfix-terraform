# CloudFix Terraform Configuration
# This terraform configuration replicates the CloudFormation stacks provided by CloudFix

provider "aws" {
  region = var.region
}

# Variables
variable "region" {
  description = "AWS region"
  default     = "us-east-1"  # CloudFix assumes this for CUR
}

variable "tenant_id" {
  description = "CloudFix TenantId"
  default     = ""
}

variable "external_id" {
  description = "CloudFix ExternalId"
  default     = ""
}

variable "resource_suffix" {
  description = "Suffix for resource names"
  default     = ""
}

variable "database_name" {
  description = "Athena Database Name"
  default     = "cloudfixdb"
}

variable "version" {
  description = "Stack Version"
  default     = "4.61.1"
}

locals {
  cloudfix_account          = "061081614506"
  cloudfix_sns_topic        = "cloudfix-stack-prod-cloudfixiamrolesprodBB1500ED-6MARQETT6Q9M"
  cloudfix_org_sns_topic    = "cloudfix-onboarding-listener-prod"
  creation_date             = formatdate("YYYY-MM-DD", timestamp())
  cur_bucket_name           = "cloudfix-cur-${data.aws_caller_identity.current.account_id}${var.resource_suffix}"
  account_id                = data.aws_caller_identity.current.account_id
}

# Get current account info
data "aws_caller_identity" "current" {}

# 1. IAM Roles and Policies

# Cloud Fix Finder Role
resource "aws_iam_role" "cloudfix_finder_role" {
  name                 = "cloudfix-finder-role${var.resource_suffix}"
  max_session_duration = 14400
  assume_role_policy   = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          AWS = [
            "arn:aws:iam::${local.cloudfix_account}:role/cloudfix-finder-role-assume${var.resource_suffix}",
            "arn:aws:iam::${local.cloudfix_account}:role/cloudfix-finder-cur-role-assume${var.resource_suffix}"
          ]
        },
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.external_id
          }
        }
      }
    ]
  })

  inline_policy {
    name = "core"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Action = [
            "application-autoscaling:DescribeScalableTargets",
            "autoscaling:DescribeAutoScalingGroups",
            "ce:GetReservationPurchaseRecommendation",
            "cloudfront:GetCachePolicy",
            "cloudfront:GetDistributionConfig",
            "cloudfront:ListTagsForResource",
            "cloudtrail:DescribeTrails",
            "cloudtrail:GetEventSelectors",
            "cloudtrail:GetInsightSelectors",
            "cloudtrail:GetTrailStatus",
            "cloudtrail:listTags",
            "cloudtrail:ListTrails",
            "cloudtrail:LookupEvents",
            "cloudwatch:GetMetricData",
            "cloudwatch:GetMetricStatistics",
            "cloudwatch:ListMetrics",
            "compute-optimizer:GetAutoScalingGroupRecommendations",
            "compute-optimizer:GetEBSVolumeRecommendations",
            "compute-optimizer:GetEC2InstanceRecommendations",
            "compute-optimizer:GetEC2RecommendationProjectedMetrics",
            "compute-optimizer:GetECSServiceRecommendations",
            "compute-optimizer:GetEnrollmentStatus",
            "compute-optimizer:GetLicenseRecommendations",
            "compute-optimizer:GetRDSRecommendationProjectedMetrics",
            "dms:DescribeReplicationInstances",
            "dms:DescribeReplicationTasks",
            "dms:ListTagsForResource",
            "dynamodb:DescribeTable",
            "dynamodb:ListTagsOfResource",
            "ebs:ListChangedBlocks",
            "ebs:ListSnapshotBlocks",
            "ec2:CreateTags",
            "ec2:DeleteTags",
            "ec2:DescribeAddresses",
            "ec2:DescribeAddressesAttribute",
            "ec2:DescribeFastSnapshotRestores",
            "ec2:DescribeImages",
            "ec2:DescribeInstanceAttribute",
            "ec2:DescribeInstances",
            "ec2:DescribeInstanceStatus",
            "ec2:DescribeInstanceTypes",
            "ec2:DescribeNatGateWays",
            "ec2:DescribeNatGateways",
            "ec2:DescribeRegions",
            "ec2:DescribeReservedInstances",
            "ec2:DescribeRouteTables",
            "ec2:DescribeSnapshotAttribute",
            "ec2:DescribeSnapshots",
            "ec2:DescribeSpotPriceHistory",
            "ec2:DescribeSubnets",
            "ec2:DescribeTags",
            "ec2:DescribeVolumes",
            "ec2:DescribeVpcAttribute",
            "ec2:DescribeVpcEndpoints",
            "ec2:DescribeVpcs",
            "ec2:GetLaunchTemplateData",
            "ecs:DescribeCapacityProviders",
            "ecs:DescribeClusters",
            "ecs:DescribeServices",
            "ecs:DescribeTaskDefinition",
            "ecs:DescribeTasks",
            "ecs:ListClusters",
            "ecs:ListContainerInstances",
            "ecs:ListServices",
            "ecs:ListTagsForResource",
            "ecs:ListTasks",
            "eks:DescribeCluster",
            "eks:DescribeInsight",
            "eks:ListClusters",
            "eks:ListInsights",
            "eks:ListTagsForResource",
            "elasticache:DescribeCacheClusters",
            "elasticache:ListTagsForResource",
            "elasticfilesystem:DescribeFileSystems",
            "elasticfilesystem:DescribeLifecycleConfiguration",
            "elasticfilesystem:ListTagsForResource",
            "elasticloadbalancing:DescribeLoadBalancers",
            "elasticloadbalancing:DescribeTags",
            "elasticloadbalancing:DescribeTargetGroups",
            "elasticmapreduce:DescribeCluster",
            "elasticmapreduce:GetManagedScalingPolicy",
            "elasticmapreduce:ListClusters",
            "elasticmapreduce:ListInstanceGroups",
            "elasticmapreduce:ListInstances",
            "emr:DescribeCluster",
            "es:DescribeDomain",
            "es:DescribeDomainChangeProgress",
            "es:DescribeDomains",
            "es:ListTags",
            "iam:GetInstanceProfile",
            "iam:ListAttachedRolePolicies",
            "iam:ListInstanceProfilesForRole",
            "kendra:DescribeDataSource",
            "kendra:DescribeIndex",
            "kendra:ListDataSources",
            "kendra:ListTagsForResource",
            "lambda:GetFunction",
            "logs:DescribeLogGroups",
            "logs:GetQueryResults",
            "logs:ListTagsForResource",
            "logs:StartQuery",
            "pricing:GetProducts",
            "quicksight:ListTagsForResource",
            "quicksight:ListUsers",
            "quicksight:SearchAnalyses",
            "quicksight:SearchDashboards",
            "quicksight:SearchDataSets",
            "quicksight:SearchDataSources",
            "rds:DescribeDBClusters",
            "rds:DescribeDBInstances",
            "rds:DescribeOrderableDBInstanceOptions",
            "rds:ListTagsForResource",
            "route53:ListHostedZones",
            "route53:ListResourceRecordSets",
            "s3:GetBucketTagging",
            "s3:GetLifecycleConfiguration",
            "s3:ListAllMyBuckets",
            "sagemaker:DescribeEndpoint",
            "sagemaker:DescribeEndpointConfig",
            "sagemaker:DescribeTransformJob",
            "sagemaker:ListApps",
            "sagemaker:ListEndpointConfigs",
            "sagemaker:ListEndpoints",
            "sagemaker:ListModels",
            "sagemaker:ListNotebookInstances",
            "sagemaker:ListProcessingJobs",
            "sagemaker:ListTrainingJobs",
            "sagemaker:ListTransformJobs",
            "servicequotas:GetServiceQuota",
            "ssm:DescribeAssociation",
            "ssm:ListAssociations",
            "ssm:ListTagsForResource",
            "tag:TagResources"
          ],
          Effect   = "Allow",
          Resource = "*"
        }
      ]
    ])
  }

  inline_policy {
    name = "organization-retrieval"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Action = [
            "iam:ListAccountAliases",
            "organizations:DescribeOrganization",
            "organizations:ListAccounts"
          ],
          Effect   = "Allow",
          Resource = "*"
        }
      ]
    })
  }

  tags = {
    "cloudfix:fixerId"         = "CloudFix Infrastructure${var.resource_suffix}"
    "cloudfix:originalResourceId" = "Role Stack"
    "cloudfix:executionDate"   = local.creation_date
  }
}

# Cloud Fix SSM Assumed Role
resource "aws_iam_role" "cloudfix_ssm_assumed_role" {
  name                 = "cloudfix-ssm-assumed-role${var.resource_suffix}"
  max_session_duration = 14400
  assume_role_policy   = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ssm.amazonaws.com",
          AWS = "arn:aws:iam::${local.account_id}:root"
        }
      },
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name = "s3-limited"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Action = "sts:AssumeRole",
          Effect = "Allow",
          Resource = "arn:aws:iam::${local.account_id}:role/cloudfix-ssm-assumed-role${var.resource_suffix}"
        },
        {
          Action = "iam:PassRole",
          Effect = "Allow",
          Resource = "arn:aws:iam::${local.account_id}:role/cloudfix-ssm-assumed-role${var.resource_suffix}"
        }
      ]
    })
  }

  inline_policy {
    name = "core"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Action = "sts:AssumeRole",
          Effect = "Allow",
          Resource = "arn:aws:iam::${local.account_id}:role/cloudfix-ssm-assumed-role${var.resource_suffix}"
        },
        {
          Action = [
            "cloudfront:CreateCachePolicy",
            "cloudfront:GetCachePolicy",
            "cloudfront:GetCachePolicyConfig",
            "cloudfront:GetDistributionConfig",
            "cloudfront:ListCachePolicies",
            "cloudfront:TagResource",
            "cloudfront:UpdateCachePolicy",
            "cloudfront:UpdateDistribution",
            "cloudtrail:GetEventSelectors",
            "cloudtrail:GetTrailStatus",
            "cloudtrail:LookupEvents",
            "cloudtrail:StopLogging",
            "cloudwatch:DeleteAlarms",
            "cloudwatch:DescribeAlarms",
            "cloudwatch:PutMetricAlarm",
            "compute-optimizer:GetRDSRecommendationProjectedMetrics",
            "compute-optimizer:UpdateEnrollmentStatus",
            "dms:CreateReplicationInstance",
            "dms:CreateReplicationTask",
            "dms:DeleteReplicationInstance",
            "dms:DeleteReplicationTask",
            "dms:DescribeReplicationInstances",
            "dynamodb:DescribeTable",
            "dynamodb:TagResource",
            "dynamodb:UpdateTable",
            "ec2:AssociateIamInstanceProfile",
            "ec2:CreateLaunchTemplate",
            "ec2:CreateNetworkInterface",
            "ec2:CreateSnapshot",
            "ec2:CreateSnapshots",
            "ec2:CreateTags",
            "ec2:CreateVpcEndpoint",
            "ec2:DeleteNatGateway",
            "ec2:DeleteNetworkInterface",
            "ec2:DeleteSnapshot",
            "ec2:DeleteVolume",
            "ec2:DeleteVpcEndpointServiceConfigurations",
            "ec2:DescribeAddresses",
            "ec2:DescribeIamInstanceProfileAssociations",
            "ec2:DescribeInstances",
            "ec2:DescribeInstanceStatus",
            "ec2:DescribeLaunchTemplates",
            "ec2:DescribeNatGateways",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DescribeRouteTables",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeSnapshots",
            "ec2:DescribeSubnets",
            "ec2:DescribeVolumes",
            "ec2:DescribeVolumesModifications",
            "ec2:DescribeVpcAttribute",
            "ec2:DescribeVpcEndpointServiceConfigurations",
            "ec2:DescribeVpcs",
            "ec2:DetachVolume",
            "ec2:ModifyInstanceAttribute",
            "ec2:ModifySnapshotTier",
            "ec2:ModifyVolume",
            "ec2:ModifyVpcAttribute",
            "ec2:ReleaseAddress",
            "ec2:RunInstances",
            "ec2:StartInstances",
            "ec2:StopInstances",
            "ecs:DeregisterTaskDefinition",
            "ecs:DescribeClusters",
            "ecs:DescribeServices",
            "ecs:DescribeTaskDefinition",
            "ecs:DescribeTasks",
            "ecs:ListServices",
            "ecs:ListTasks",
            "ecs:RegisterTaskDefinition",
            "ecs:TagResource",
            "ecs:UntagResource",
            "ecs:UpdateService",
            "elasticache:AddTagsToResource",
            "elasticache:CreateReplicationGroup",
            "elasticache:DeleteCacheCluster",
            "elasticache:DeleteReplicationGroup",
            "elasticache:DescribeCacheClusters",
            "elasticache:DescribeReplicationGroups",
            "elasticache:DescribeSnapshots",
            "elasticache:ModifyReplicationGroup",
            "elasticfilesystem:CreateTags",
            "elasticfilesystem:DescribeFileSystems",
            "elasticfilesystem:DescribeLifecycleConfiguration",
            "elasticfilesystem:PutLifecycleConfiguration",
            "elasticfilesystem:TagResource",
            "elasticfilesystem:UpdateFileSystem",
            "elasticloadbalancing:DeleteListener",
            "elasticloadbalancing:DeleteLoadBalancer",
            "elasticloadbalancing:DeleteTargetGroup",
            "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
            "elasticloadbalancing:DescribeListeners",
            "elasticloadbalancing:DescribeTargetGroups",
            "elasticloadbalancing:ModifyLoadBalancerAttributes",
            "es:AddTags",
            "es:DescribeDomain",
            "es:DescribeDomainChangeProgress",
            "es:ListTags",
            "es:UpdateDomainConfig",
            "iam:AddRoleToInstanceProfile",
            "iam:AttachRolePolicy",
            "iam:CreateInstanceProfile",
            "iam:CreateRole",
            "iam:CreateServiceLinkedRole",
            "iam:GetInstanceProfile",
            "iam:GetRole",
            "iam:ListInstanceProfilesForRole",
            "iam:PassRole",
            "iam:PutRolePolicy",
            "kendra:CreateDataSource",
            "kendra:CreateIndex",
            "kendra:DeleteIndex",
            "kms:DescribeKey",
            "quicksight:DeleteUserByPrincipalId",
            "quicksight:UpdateAnalysisPermissions",
            "quicksight:UpdateDashboardPermissions",
            "quicksight:UpdateDataSetPermissions",
            "quicksight:UpdateDataSourcePermissions",
            "rds:AddTagsToResource",
            "rds:CreateDBInstance",
            "rds:CreateDBSnapshot",
            "rds:DeleteDBCluster",
            "rds:DeleteDBInstance",
            "rds:DescribeDBClusters",
            "rds:DescribeDBClusterSnapshots",
            "rds:DescribeDBInstances",
            "rds:DescribeDBSnapshots",
            "rds:FailoverDBCluster",
            "rds:ListTagsForResource",
            "rds:ModifyDBCluster",
            "rds:ModifyDBInstance",
            "rds:RemoveTagsFromResource",
            "rds:RestoreDBClusterFromSnapshot",
            "s3:CreateBucket",
            "s3:GetBucketTagging",
            "s3:GetLifecycleConfiguration",
            "s3:ListBucket",
            "s3:PutBucketTagging",
            "s3:PutLifecycleConfiguration",
            "s3:PutObject",
            "sagemaker:AddTags",
            "sagemaker:CreateNotebookInstanceLifecycleConfig",
            "sagemaker:DescribeNotebookInstance",
            "sagemaker:ListNotebookInstanceLifecycleConfigs",
            "sagemaker:StartNotebookInstance",
            "sagemaker:StopNotebookInstance",
            "sagemaker:UpdateNotebookInstance",
            "sns:Publish",
            "ssm:CreateAssociation",
            "ssm:DeleteAssociation",
            "ssm:GetAutomationExecution",
            "ssm:PutParameter",
            "ssm:StartAutomationExecution",
            "ssm:UpdateAssociation"
          ],
          Effect   = "Allow",
          Resource = "*"
        }
      ]
    })
  }

  tags = {
    "cloudfix:fixerId"         = "CloudFix Infrastructure${var.resource_suffix}"
    "cloudfix:originalResourceId" = "Role Stack"
    "cloudfix:executionDate"   = local.creation_date
  }
}

# Cloud Fix Fixer Approver Role
resource "aws_iam_role" "cloudfix_fixer_approver_role" {
  name = "cloudfix-fixer-approver-role${var.resource_suffix}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${local.account_id}:root"
        }
      }
    ]
  })

  tags = {
    "cloudfix:fixerId"         = "CloudFix Infrastructure${var.resource_suffix}"
    "cloudfix:originalResourceId" = "Role Stack"
    "cloudfix:executionDate"   = local.creation_date
  }
}

# Cloud Fix Approver Group Policy
resource "aws_iam_policy" "cloudfix_approver_group_policy" {
  name = "cloudfix-approver-group-policy${var.resource_suffix}"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ssm:SendAutomationSignal",
          "ssm:GetOpsItem",
          "ssm:GetDocument",
          "ssm:GetServiceSetting",
          "ssm:ListDocuments",
          "ssm:ListDocumentVersions",
          "ssm:DescribeDocument",
          "ssm:UpdateDocumentMetadata"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudfix_approver_policy_attachment" {
  role       = aws_iam_role.cloudfix_fixer_approver_role.name
  policy_arn = aws_iam_policy.cloudfix_approver_group_policy.arn
}

# Cloud Fix SSM Update Role
resource "aws_iam_role" "cloudfix_ssm_update_role" {
  name                 = "cloudfix-ssm-update-role${var.resource_suffix}"
  max_session_duration = 14400
  assume_role_policy   = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          AWS = [
            "arn:aws:iam::${local.cloudfix_account}:role/cloudfix-finder-role-assume${var.resource_suffix}",
            "arn:aws:iam::${local.cloudfix_account}:role/cloudfix-finder-cur-role-assume${var.resource_suffix}",
            "arn:aws:iam::${local.cloudfix_account}:role/cloudfix-monitor-role-assume${var.resource_suffix}"
          ]
        },
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.external_id
          }
        }
      }
    ]
  })

  inline_policy {
    name = "core"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Action = "iam:PassRole",
          Effect = "Allow",
          Resource = "arn:aws:iam::${local.account_id}:role/cloudfix-ssm-assumed-role${var.resource_suffix}"
        },
        {
          Action = [
            "ssm:CreateDocument",
            "ssm:GetDocument",
            "ssm:UpdateDocument",
            "ssm:UpdateDocumentMetadata",
            "ssm:DescribeDocument",
            "ssm:ListDocumentVersions",
            "ssm:StartChangeRequestExecution",
            "ssm:DeleteDocument",
            "ssm:ListDocuments",
            "ssm:UpdateDocumentDefaultVersion",
            "ssm:GetAutomationExecution",
            "ssm:GetOpsItem",
            "ssm:DescribeOpsItems",
            "ssm:ListOpsItemEvents",
            "ssm:UpdateOpsItem",
            "ssm:StartAutomationExecution",
            "ssm:StopAutomationExecution",
            "ssm:SendAutomationSignal",
            "ssm:DescribeAutomationStepExecutions",
            "ssm:DescribeAutomationExecutions",
            "ssm:AddTagsToResource",
            "iam:ListRoles",
            "iam:ListUsers",
            "iam:ListGroups",
            "iam:GetGroup",
            "iam:CreateServiceLinkedRole",
            "ssm:GetOpsSummary",
            "ssm:GetOpsMetadata",
            "sns:CreateTopic",
            "sns:ConfirmSubscription",
            "ssm:UpdateServiceSetting",
            "ssm:GetServiceSetting",
            "autoscaling:CreateOrUpdateTags",
            "backup:TagResource",
            "cloudfront:TagResource",
            "dlm:TagResource",
            "dynamodb:TagResource",
            "ec2:CreateTags",
            "elasticfilesystem:CreateTags",
            "rds:AddTagsToResource",
            "elasticfilesystem:TagResource",
            "es:AddTags",
            "s3:PutBucketTagging",
            "tag:TagResources"
          ],
          Effect   = "Allow",
          Resource = "*"
        }
      ]
    })
  }

  inline_policy {
    name = "specific-fixers"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Action   = "s3:GetObject",
          Effect   = "Allow",
          Resource = "arn:aws:s3:::cloudfix-runbook-bucket-zip${var.resource_suffix}/*"
        }
      ]
    })
  }

  tags = {
    "cloudfix:fixerId"         = "CloudFix Infrastructure${var.resource_suffix}"
    "cloudfix:originalResourceId" = "Role Stack"
    "cloudfix:executionDate"   = local.creation_date
  }
}

# CloudFix Backup Job Role
resource "aws_iam_role" "cloudfix_backup_job_role" {
  name                 = "cloudfix-backup-job-role${var.resource_suffix}"
  max_session_duration = 14400
  assume_role_policy   = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "backup.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup",
    "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
  ]

  inline_policy {
    name = "core"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Action = [
            "backup:DescribeBackupVault",
            "backup:CopyIntoBackupVault",
            "backup:CopyFromBackupVault",
            "elasticfilesystem:Backup",
            "elasticfilesystem:DescribeTags"
          ],
          Effect   = "Allow",
          Resource = "*"
        },
        {
          Action = [
            "ec2:CreateSnapshot",
            "ec2:DeleteSnapshot",
            "ec2:DescribeVolumes"
          ],
          Effect   = "Allow",
          Resource = [
            "arn:aws:ec2:*::snapshot/*",
            "arn:aws:ec2:*:*:volume/*"
          ]
        },
        {
          Action = [
            "ec2:DescribeSnapshots",
            "ec2:DescribeTags"
          ],
          Effect   = "Allow",
          Resource = "*"
        },
        {
          Action = [
            "ec2:CopySnapshot",
            "ec2:CreateTags",
            "ec2:DeleteSnapshot"
          ],
          Effect   = "Allow",
          Resource = "arn:aws:ec2:*::snapshot/*"
        },
        {
          Action    = "ec2:ModifySnapshotAttribute",
          Effect    = "Allow",
          Condition = {
            "Null" = {
              "aws:ResourceTag/aws:backup:source-resource" = "false"
            }
          },
          Resource = "*"
        }
      ]
    })
  }

  tags = {
    "cloudfix:fixerId"         = "CloudFix Infrastructure${var.resource_suffix}"
    "cloudfix:originalResourceId" = "Role Stack"
    "cloudfix:executionDate"   = local.creation_date
  }
}

# CloudFix Athena Query Execution Role
resource "aws_iam_role" "cloudfix_athena_query_execution_role" {
  name                 = "cloudfix-athena-query-execution-role${var.resource_suffix}"
  max_session_duration = 14400
  assume_role_policy   = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          AWS = [
            "arn:aws:iam::${local.cloudfix_account}:role/cloudfix-finder-role-assume${var.resource_suffix}",
            "arn:aws:iam::${local.cloudfix_account}:role/cloudfix-finder-cur-role-assume${var.resource_suffix}",
            "arn:aws:iam::${local.cloudfix_account}:role/cloudfix-cur-role-assume${var.resource_suffix}",
            "arn:aws:iam::${local.cloudfix_account}:role/cloudfix-monitor-role-assume${var.resource_suffix}"
          ]
        },
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.external_id
          }
        }
      }
    ]
  })

  inline_policy {
    name = "core"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Action = "s3:*",
          Effect = "Allow",
          Resource = [
            "arn:aws:s3:::cloudfix-cur-${local.account_id}${var.resource_suffix}",
            "arn:aws:s3:::cloudfix-cur-${local.account_id}${var.resource_suffix}/*"
          ]
        },
        {
          Action = [
            "cloudformation:DescribeStacks",
            "organizations:DescribeAccount",
            "organizations:DescribeOrganization",
            "organizations:ListAccounts",
            "organizations:ListAccountsForParent",
            "organizations:ListRoots",
            "organizations:DescribeOrganizationalUnit",
            "organizations:ListChildren"
          ],
          Effect   = "Allow",
          Resource = "*"
        },
        {
          Action = [
            "athena:StartQueryExecution",
            "athena:GetQueryExecution",
            "athena:GetQueryResults"
          ],
          Effect   = "Allow",
          Resource = "arn:aws:athena:*:${local.account_id}:workgroup/CloudFixWorkspace${var.resource_suffix}"
        },
        {
          Action = [
            "cloudformation:CreateStackInstances",
            "cloudformation:DescribeStackSetOperation"
          ],
          Effect = "Allow",
          Resource = [
            "arn:aws:cloudformation:*:${local.account_id}:stackset-target/*CloudFixOrgStackSet*",
            "arn:aws:cloudformation:*:${local.account_id}:stackset/*CloudFixOrgStackSet*"
          ]
        },
        {
          Action = [
            "cloudformation:CreateStackInstances"
          ],
          Effect = "Allow",
          Resource = [
            "arn:aws:cloudformation:us-east-1::type/resource/AWS-IAM-Role",
            "arn:aws:cloudformation:us-east-1::type/resource/AWS-IAM-Group",
            "arn:aws:cloudformation:us-east-1::type/resource/AWS-IAM-Policy",
            "arn:aws:cloudformation:us-east-1::type/resource/AWS-CloudFormation-CustomResource",
            "arn:aws:cloudformation:us-east-1::type/resource/AWS-S3-Bucket",
            "arn:aws:cloudformation:us-east-1::type/resource/AWS-Lambda-Function"
          ]
        },
        {
          Action = "glue:*",
          Effect = "Allow",
          Resource = [
            "arn:aws:glue:${var.region}:${local.account_id}:catalog",
            "arn:aws:glue:${var.region}:${local.account_id}:database/${var.database_name}",
            "arn:aws:glue:${var.region}:${local.account_id}:table/${var.database_name}/*",
            "arn:aws:glue:${var.region}:${local.account_id}:userDefinedFunction/${var.database_name}/*"
          ]
        },
        {
          Action   = "ce:UpdateCostAllocationTagsStatus",
          Effect   = "Allow",
          Resource = "*"
        }
      ]
    })
  }

  tags = {
    "cloudfix:fixerId"         = "CloudFix Infrastructure${var.resource_suffix}"
    "cloudfix:originalResourceId" = "Role Stack" 
    "cloudfix:executionDate"   = local.creation_date
  }
}

# 2. S3 Bucket for CUR

resource "aws_s3_bucket" "cloudfix_cur_bucket" {
  bucket = local.cur_bucket_name
  force_destroy = true  # Allow terraform to delete the bucket even if it contains objects

  lifecycle_rule {
    id      = "Cloudfix-SIT"
    enabled = true

    transition {
      days          = 0
      storage_class = "INTELLIGENT_TIERING"
    }

    noncurrent_version_transition {
      days          = 0
      storage_class = "INTELLIGENT_TIERING"
    }

    expiration {
      days = 365
    }
  }

  tags = {
    "cloudfix:fixerId"         = "CloudFix Infrastructure${var.resource_suffix}"
    "cloudfix:originalResourceId" = "CUR Stack"
    "cloudfix:executionDate"   = local.creation_date
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudfix_cur_encryption" {
  bucket = aws_s3_bucket.cloudfix_cur_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cloudfix_cur_public_access" {
  bucket = aws_s3_bucket.cloudfix_cur_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "cloudfix_cur_bucket_policy" {
  bucket = aws_s3_bucket.cloudfix_cur_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "billingreports.amazonaws.com"
        },
        Action = [
          "s3:GetBucketAcl",
          "s3:GetBucketPolicy"
        ],
        Resource = "arn:aws:s3:::${local.cur_bucket_name}",
        Condition = {
          StringEquals = {
            "aws:SourceArn": "arn:aws:cur:us-east-1:${local.account_id}:definition/*",
            "aws:SourceAccount": local.account_id
          }
        }
      },
      {
        Effect = "Allow",
        Principal = {
          Service = "billingreports.amazonaws.com"
        },
        Action = "s3:PutObject",
        Resource = "arn:aws:s3:::${local.cur_bucket_name}/*",
        Condition = {
          StringEquals = {
            "aws:SourceArn": "arn:aws:cur:us-east-1:${local.account_id}:definition/*",
            "aws:SourceAccount": local.account_id
          }
        }
      },
      {
        Effect = "Deny",
        Principal = "*",
        Action = "s3:*",
        Resource = [
          "arn:aws:s3:::${local.cur_bucket_name}",
          "arn:aws:s3:::${local.cur_bucket_name}/*"
        ],
        Condition = {
          Bool = {
            "aws:SecureTransport": false
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket.cloudfix_cur_bucket]
}

# 3. CUR Report Definition

resource "aws_cur_report_definition" "cloudfix_cur" {
  report_name                = "CloudFix-CUR${var.resource_suffix}"
  time_unit                  = "HOURLY"
  format                     = "Parquet"
  compression                = "Parquet"
  additional_schema_elements = ["RESOURCES"]
  additional_artifacts       = ["ATHENA"]
  s3_bucket                  = aws_s3_bucket.cloudfix_cur_bucket.id
  s3_region                  = "us-east-1"
  s3_prefix                  = "cloudfix"
  report_versioning          = "OVERWRITE_REPORT"
  refresh_closed_reports     = true

  depends_on = [
    aws_s3_bucket_policy.cloudfix_cur_bucket_policy
  ]
}

# 4. Athena and Glue Configuration

resource "aws_athena_workgroup" "cloudfix_workspace" {
  name          = "CloudFixWorkspace${var.resource_suffix}"
  description   = "CloudFix Workspace"
  state         = "ENABLED"
  force_destroy = true

  configuration {
    bytes_scanned_cutoff_per_query     = 1099511627776
    enforce_workgroup_configuration    = false
    publish_cloudwatch_metrics_enabled = false
    result_configuration {
      output_location = "s3://${local.cur_bucket_name}/cloudfix/query-results/"
    }
  }

  tags = {
    "cloudfix:fixerId"         = "CloudFix Infrastructure${var.resource_suffix}"
    "cloudfix:originalResourceId" = "CUR Stack"
    "cloudfix:executionDate"   = local.creation_date
  }
}

resource "aws_glue_catalog_database" "cloudfix_database" {
  name = var.database_name
}

# IAM role for Glue
resource "aws_iam_role" "cloudfix_glue_role" {
  name = "AWSCURCrawlerComponentFunction${var.resource_suffix}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "AWSCURCrawlerGluePerms"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Action = "glue:*",
          Effect = "Allow",
          Resource = [
            "arn:aws:glue:${var.region}:${local.account_id}:database/${var.database_name}",
            "arn:aws:glue:${var.region}:${local.account_id}:table/${var.database_name}*",
            "arn:aws:glue:${var.region}:${local.account_id}:catalog"
          ]
        },
        {
          Action = [
            "s3:ListBucket",
            "s3:GetBucketAcl",
            "s3:GetBucketLocation"
          ],
          Effect = "Allow",
          Resource = "arn:aws:s3:::${local.cur_bucket_name}"
        },
        {
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          Effect = "Allow",
          Resource = "arn:aws:logs:*:*:/aws-glue/*"
        }
      ]
    })
  }

  inline_policy {
    name = "AWSCURCrawlerComponentFunction"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "s3:GetObject",
            "s3:PutObject"
          ],
          Resource = "arn:aws:s3:::${local.cur_bucket_name}/cloudfix/CloudFix-CUR${var.resource_suffix}/CloudFix-CUR${var.resource_suffix}*"
        }
      ]
    })
  }

  tags = {
    "cloudfix:fixerId"         = "CloudFix Infrastructure${var.resource_suffix}"
    "cloudfix:originalResourceId" = "CUR Stack"
    "cloudfix:executionDate"   = local.creation_date
  }
}

# Glue Crawler
resource "aws_glue_crawler" "cloudfix_cur_crawler" {
  name          = "AWSCURCrawler-CloudFix-CUR${var.resource_suffix}"
  description   = "A recurring crawler that keeps your CUR table in Athena up-to-date."
  database_name = aws_glue_catalog_database.cloudfix_database.name
  role          = aws_iam_role.cloudfix_glue_role.arn
  
  s3_target {
    path = "s3://${local.cur_bucket_name}/cloudfix/CloudFix-CUR${var.resource_suffix}/CloudFix-CUR${var.resource_suffix}"
    
    exclusions = [
      "**.json",
      "**.yml",
      "**.sql",
      "**.csv",
      "**.gz",
      "**.zip"
    ]
  }

  schema_change_policy {
    update_behavior = "UPDATE_IN_DATABASE"
    delete_behavior = "DELETE_FROM_DATABASE"
  }

  configuration = jsonencode({
    Version = 1.0,
    CrawlerOutput = {
      Tables = {
        AddOrUpdateBehavior = "MergeNewColumns"
      }
    }
  })

  tags = {
    "cloudfix:fixerId"         = "CloudFix Infrastructure${var.resource_suffix}"
    "cloudfix:originalResourceId" = "CUR Stack"
    "cloudfix:executionDate"   = local.creation_date
  }
}

# 5. Lambda Functions for Automation

# IAM role for Lambda to start Glue Crawler
resource "aws_iam_role" "cloudfix_lambda_crawler_role" {
  name = "AWSCURCrawlerLambdaExecutor${var.resource_suffix}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  inline_policy {
    name = "AWSCURCrawlerLambdaExecutor"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Action = "glue:StartCrawler",
          Resource = aws_glue_crawler.cloudfix_cur_crawler.arn
        }
      ]
    })
  }

  tags = {
    "cloudfix:fixerId"         = "CloudFix Infrastructure${var.resource_suffix}"
    "cloudfix:originalResourceId" = "CUR Stack"
    "cloudfix:executionDate"   = local.creation_date
  }
}

# Lambda function for S3 notifications
resource "aws_iam_role" "cloudfix_lambda_s3_notification_role" {
  name = "AWSS3CURLambdaExecutor${var.resource_suffix}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  inline_policy {
    name = "AWSS3CURLambdaExecutor"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Action = "s3:PutBucketNotification",
          Resource = "arn:aws:s3:::${local.cur_bucket_name}"
        },
        {
          Effect = "Allow",
          Action = "ce:UpdateCostAllocationTagsStatus",
          Resource = "*"
        },
        {
          Effect = "Allow",
          Action = "support:CreateCase",
          Resource = "*"
        }
      ]
    })
  }

  tags = {
    "cloudfix:fixerId"         = "CloudFix Infrastructure${var.resource_suffix}"
    "cloudfix:originalResourceId" = "CUR Stack"
    "cloudfix:executionDate"   = local.creation_date
  }
}

# Lambda function for S3 bucket cleanup
resource "aws_iam_role" "cloudfix_lambda_cleanup_role" {
  name = "cleanupBucketOnDeleteLambdaRole${var.resource_suffix}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "cleanupBucketOnDeleteLambdaPolicy"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Action = "s3:*",
          Resource = [
            "arn:aws:s3:::${local.cur_bucket_name}",
            "arn:aws:s3:::${local.cur_bucket_name}/*"
          ]
        }
      ]
    })
  }

  tags = {
    "cloudfix:fixerId"         = "CloudFix Infrastructure${var.resource_suffix}"
    "cloudfix:originalResourceId" = "CUR Stack"
    "cloudfix:executionDate"   = local.creation_date
  }
}

# Lambda function for crawler initialization
resource "aws_lambda_function" "cloudfix_crawler_initializer" {
  function_name = "AWSCURInitializer${var.resource_suffix}"
  role          = aws_iam_role.cloudfix_lambda_crawler_role.arn
  handler       = "index.handler"
  runtime       = "python3.10"
  timeout       = 30

  environment {
    variables = {
      CUR_CRAWLER_NAME = aws_glue_crawler.cloudfix_cur_crawler.name
    }
  }

  filename         = "lambda_function_payload.zip"
  source_code_hash = filebase64sha256("lambda_function_payload.zip")

  reserved_concurrent_executions = 1

  depends_on = [aws_glue_crawler.cloudfix_cur_crawler]
}

# Lambda functions are now managed as separate files in the lambda directory
resource "null_resource" "create_lambda_zip" {
  triggers = {
    # Trigger rebuild when any Lambda files change
    cur_initializer = filemd5("${path.module}/lambda/cur_initializer.py")
  }

  provisioner "local-exec" {
    command = "zip -j lambda_function_payload.zip ${path.module}/lambda/cur_initializer.py"
  }
}

# Lambda function for S3 notification setup
resource "aws_lambda_function" "cloudfix_s3_notification" {
  function_name = "AWSS3CURNotification${var.resource_suffix}"
  role          = aws_iam_role.cloudfix_lambda_s3_notification_role.arn
  handler       = "index.handler"
  runtime       = "python3.10"
  timeout       = 30

  filename         = "lambda_s3_notification.zip"
  source_code_hash = filebase64sha256("lambda_s3_notification.zip")

  reserved_concurrent_executions = 1

  depends_on = [aws_lambda_function.cloudfix_crawler_initializer]
}

# Lambda function for bucket cleanup
resource "aws_lambda_function" "cloudfix_bucket_cleanup" {
  function_name = "Clean_Up_Buckets${var.resource_suffix}"
  role          = aws_iam_role.cloudfix_lambda_cleanup_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.10"
  timeout       = 900

  filename         = "lambda_bucket_cleanup.zip"
  source_code_hash = filebase64sha256("lambda_bucket_cleanup.zip")
}

# 6. Lambda Permissions and Triggers

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cloudfix_crawler_initializer.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.cloudfix_cur_bucket.arn
  source_account = local.account_id
}

# 7. Glue Table for CUR Status
resource "aws_glue_catalog_table" "cloudfix_cur_status" {
  name          = "cost_and_usage_data_status"
  database_name = aws_glue_catalog_database.cloudfix_database.name
  
  table_type = "EXTERNAL_TABLE"
  
  storage_descriptor {
    location      = "s3://${local.cur_bucket_name}cloudfix/CloudFix-CUR${var.resource_suffix}/CloudFix-CUR${var.resource_suffix}/cost_and_usage_data_status/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"
    
    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }
    
    columns {
      name = "status"
      type = "string"
    }
  }
}

# 8. CloudFix SNS Notification
resource "aws_sns_topic" "cloudfix_notification" {
  name = "cloudfix-notification${var.resource_suffix}"
  
  tags = {
    "cloudfix:fixerId" = "CloudFix Infrastructure${var.resource_suffix}"
  }
}

resource "aws_sns_topic_policy" "cloudfix_notification" {
  arn = aws_sns_topic.cloudfix_notification.arn
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "CloudFixPublish"
        Effect = "Allow"
        Principal = {
          AWS = local.account_id
        }
        Action = "SNS:Publish"
        Resource = aws_sns_topic.cloudfix_notification.arn
      }
    ]
  })
}

resource "aws_lambda_function" "cloudfix_notification" {
  filename      = "lambda_notification.zip"
  function_name = "CloudFix_Notification${var.resource_suffix}"
  role          = aws_iam_role.cloudfix_lambda_notification_role.arn
  handler       = "notification.handler"
  runtime       = "python3.10"

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.cloudfix_notification.arn
      TENANT_ID     = var.tenant_id
      EXTERNAL_ID   = var.external_id
    }
  }

  tags = {
    "cloudfix:fixerId" = "CloudFix Infrastructure${var.resource_suffix}"
  }
}

resource "aws_iam_role" "cloudfix_lambda_notification_role" {
  name = "cloudfix-lambda-notification-role${var.resource_suffix}"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name = "sns-publish"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "sns:Publish"
          ]
          Resource = [
            aws_sns_topic.cloudfix_notification.arn
          ]
        }
      ]
    })
  }
}

# Notify CloudFix about created resources
resource "null_resource" "cloudfix_notification" {
  triggers = {
    finder_role_arn      = aws_iam_role.cloudfix_finder_role.arn
    athena_role_arn      = aws_iam_role.cloudfix_athena_query_execution_role.arn
    ssm_update_role_arn  = aws_iam_role.cloudfix_ssm_update_role.arn
    ssm_assumed_role_arn = aws_iam_role.cloudfix_ssm_assumed_role.arn
    approver_role_arn    = aws_iam_role.cloudfix_fixer_approver_role.arn
    backup_job_role_arn  = aws_iam_role.cloudfix_backup_job_role.arn
    account_id           = local.account_id
    tenant_id            = var.tenant_id
    external_id          = var.external_id
    version              = var.version
    stack_region         = var.region
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws lambda invoke \
        --function-name ${aws_lambda_function.cloudfix_notification.function_name} \
        --payload '{"roles": {
          "finder_role_arn": "${aws_iam_role.cloudfix_finder_role.arn}",
          "athena_role_arn": "${aws_iam_role.cloudfix_athena_query_execution_role.arn}",
          "ssm_update_role_arn": "${aws_iam_role.cloudfix_ssm_update_role.arn}",
          "ssm_assumed_role_arn": "${aws_iam_role.cloudfix_ssm_assumed_role.arn}",
          "approver_role_arn": "${aws_iam_role.cloudfix_fixer_approver_role.arn}",
          "backup_job_role_arn": "${aws_iam_role.cloudfix_backup_job_role.arn}"
        }}' \
        response.json
    EOT
  }

  depends_on = [
    aws_lambda_function.cloudfix_notification,
    aws_iam_role.cloudfix_finder_role,
    aws_iam_role.cloudfix_athena_query_execution_role,
    aws_iam_role.cloudfix_ssm_update_role,
    aws_iam_role.cloudfix_ssm_assumed_role,
    aws_iam_role.cloudfix_fixer_approver_role,
    aws_iam_role.cloudfix_backup_job_role,
    aws_cur_report_definition.cloudfix_cur,
    aws_glue_crawler.cloudfix_cur_crawler,
    aws_glue_catalog_database.cloudfix_database
  ]
}

# Output the important ARNs and other information
output "cloudfix_roles" {
  value = {
    finder_role_arn      = aws_iam_role.cloudfix_finder_role.arn
    athena_role_arn      = aws_iam_role.cloudfix_athena_query_execution_role.arn
    ssm_update_role_arn  = aws_iam_role.cloudfix_ssm_update_role.arn
    ssm_assumed_role_arn = aws_iam_role.cloudfix_ssm_assumed_role.arn
    approver_role_arn    = aws_iam_role.cloudfix_fixer_approver_role.arn
    backup_job_role_arn  = aws_iam_role.cloudfix_backup_job_role.arn
  }
  description = "ARNs of the IAM roles created for CloudFix"
}

output "cloudfix_cur_bucket" {
  value       = aws_s3_bucket.cloudfix_cur_bucket.bucket
  description = "Name of the S3 bucket created for CloudFix CUR"
}

output "cloudfix_cur_report" {
  value       = aws_cur_report_definition.cloudfix_cur.report_name
  description = "Name of the CUR report created for CloudFix"
}

output "cloudfix_database" {
  value       = aws_glue_catalog_database.cloudfix_database.name
  description = "Name of the Glue database created for CloudFix"
}

output "cloudfix_workgroup" {
  value       = aws_athena_workgroup.cloudfix_workspace.name
  description = "Name of the Athena workgroup created for CloudFix"
}