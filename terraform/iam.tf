# ECS Execution Role (pulls images, pushes logs, reads secrets)
resource "aws_iam_role" "ecs_execution" {
    name = "${local.name}-ecs-execution"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow",
            Action = "sts:AssumeRole",
            Principal = {
                Service = "ecs-tasks.amazonaws.com"
            }
        }]
    })
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
    role = aws_iam_role.ecs_execution.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_execution_secrets" {
    name = "${local.name}-secrets-access"
    role = aws_iam_role.ecs_execution.id
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = ["secretsmanager:GetSecretValue"]
            Effect = "Allow"
            Resource = [aws_secretsmanager_secret.db_credentials.arn]
        }]
    })
}

# ECS Task Role (application runtime permissions)
resource "aws_iam_role" "ecs_task" {
    name = "${local.name}-ecs-task"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow",
            Action = "sts:AssumeRole",
            Principal = {
                Service = "ecs-tasks.amazonaws.com"
            }
        }]
    })
}

resource "aws_iam_role_policy" "ecs_task" {
    name = "${local.name}-task-policy"
    role = aws_iam_role.ecs_task.id
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Action = ["logs:CreateLogStream", "logs:PutLogEvents"]
            Resource = "*"
        },
        {
            Effect = "Allow"
            Action = ["ssmmessages:CreateControlChannel", "ssmmessages:CreateDataChannel", "ssmmessages:OpenControlChannel"]
            Resource = "*"
        }]
    })
}

# CodeDeploy Role
resource "aws_iam_role" "codedeploy" {
    name = "${local.name}-codedeploy"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Action = "sts:AssumeRole"
            Principal = {
                Service = "codedeploy.amazonaws.com"
            }
        }]
    })
    
}

resource "aws_iam_role_policy_attachment" "codedeploy" {
  role = aws_iam_role.codedeploy.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

# GitHub Actions OIDC Role
resource "aws_iam_role" "github_actions" {
    name = "${local.name}-github_actions"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow",
            Action = "sts:AssumeRoleWithWebIdentity",
            Principal = {
                Federated = "arn:aws:iam::${local.account_id}:oidc-provider/token.actions.githubusercontent.com"
            }
        }]
    })
}

resource "aws_iam_role_policy" "github_actions" {
  name = "${local.name}-github-actions-policy"
  role = aws_iam_role.github_actions.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
        Effect = "Allow",
        Action = ["ecr:GetAuthorizationToken", "ecr:BatchCheckLayerAvailability", "ecr:GetDownloadUrlForLayer", "ecr:BatchGetImage", "ecr:PutImage", "ecr:InitiateLayerUpload", "ecr:UploadLayerPart", "ecr:CompleteLayerUpload"],
        Resource = "*" 
    },
    { 
        Effect = "Allow",
        Action = ["ecs:DescribeServices", "ecs:DescribeTaskDefinition", "ecs:RegisterTaskDefinition", "ecs:UpdateService"],
        Resource = "*"
    },
    {
        Effect = "Allow",
        Action = ["codedeploy:CreateDeployment", "codedeploy:GetDeployment", "codedeploy:GetDeploymentConfig", "codedeploy:GetApplicationRevision", "codedeploy:RegisterApplicationRevision"],
        Resource = "*"
    },
    { 
        Effect = "Allow",
        Action = ["iam:PassRole"],
        Resource = [aws_iam_role.ecs_execution.arn, aws_iam_role.ecs_task.arn]
    }]
  })
}