resource "aws_security_group" "this" {
  name        = "${var.environment}-${var.name}-sg"
  description = "Security group for ${var.name} instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name        = "${var.environment}-${var.name}-sg"
    Environment = var.environment
  })
}

resource "aws_instance" "this" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.this.id]
  associate_public_ip_address = var.associate_public_ip

  tags = merge(var.tags, {
    Name        = "${var.environment}-${var.name}"
    Environment = var.environment
  })
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.environment}-${var.name}-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Alert when CPU exceeds 70%"
  dimensions = {
    InstanceId = aws_instance.this.id
  }
  alarm_actions = var.cw_alarm_actions
  ok_actions    = var.cw_alarm_actions
}
