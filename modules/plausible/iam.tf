resource "aws_iam_role" "plausible_task_role" {
  assume_role_policy = data.aws_iam_policy_document.plausible_task_role_policy.json
  name               = "plausible-task-role"
}

resource "aws_iam_role_policy_attachment" "plausible_task_role" {
  role       = aws_iam_role.plausible_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "plausible_task_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "plausible_allow_create_log_groups" {
  statement {
    actions   = ["logs:CreateLogGroup"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "allow_create_log_groups" {
  policy = data.aws_iam_policy_document.plausible_allow_create_log_groups.json
  role   = aws_iam_role.plausible_task_role.id
}

resource "aws_iam_role" "plausible" {
  name = "plausible-task"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "ecs-tasks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs" {
  role       = aws_iam_role.plausible.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "plausible" {
  name = "plausible-task"
  role = aws_iam_role.plausible.name
}

resource "aws_iam_role_policy_attachment" "plausible_instance_ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.plausible.name
}
