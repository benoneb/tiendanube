# *******************
# scale up alarm +1
# *******************


resource "aws_autoscaling_policy" "web-servers-cpu-policy" {
  name                   = "web-servers-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.web-server-asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"


  # cooldown: no utilization can happen!!!
  cooldown = "300"

  policy_type = "SimpleScaling"
}




# *******************
# scale down alarm -1
# *******************


resource "aws_autoscaling_policy" "web-servers-cpu-policy-scaledown" {
  name                   = "web-servers-cpu-policy-scaledown"
  autoscaling_group_name = aws_autoscaling_group.web-server-asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"

  # cooldown: no utilization can happen!!!
  cooldown = "300"

  policy_type = "SimpleScaling"
}




# *************************************
# cloudwatch CPU utilization condition + 1
#
# notice that we used: "web-servers-cpu-policy"
# which is basically very first definition
# within this configuration file. It means
# that if CPU utilization has the average
# of two checks utilization.
# It will increase in 85% compared to the average
# CPU utilization and check period between
# this two checks which is 120 seconds please add
# one more instance (server)
#
# *************************************


resource "aws_cloudwatch_metric_alarm" "example-cpu-alarm" {
  depends_on          = [aws_autoscaling_group.web-server-asg]
  alarm_name          = "example-cpu-alarm"
  alarm_description   = "example-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "85"

  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.web-server-asg.name
  }

  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.web-servers-cpu-policy.arn]
}



# *************************************
# cloudwatch CPU utilization condition - 1
#
# notice that we used: "web-servers-cpu-policy-scaledown"
# which is basically very first definition
# within this configuration file. It means
# that we if CPU utilization as the average
# of two checks CPU utilization
# will decrease in 5% compared to the average
# CPU utilization and check perion between
# this two checks is 120 seconds please remove
# one more instance (server)
#
# *************************************



resource "aws_cloudwatch_metric_alarm" "example-cpu-alarm-scaledown" {
  depends_on          = [aws_autoscaling_group.web-server-asg]
  alarm_name          = "example-cpu-alarm-scaledown"
  alarm_description   = "example-cpu-alarm-scaledown"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "15"

  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.web-server-asg.name
  }

  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.web-servers-cpu-policy-scaledown.arn]
}

# Uncomment if you want to have autoscaling notifications

resource "aws_sns_topic" "web-server-asg-sns" {
  name         = "sg-sns"
  display_name = "Web Server ASG SNS topic"
} # email subscription is currently unsupported in terraform and can be done using the AWS Web Console

resource "aws_autoscaling_notification" "web-servers-asg-notify" {
  group_names = [aws_autoscaling_group.web-server-asg.name]
  topic_arn   = aws_sns_topic.web-server-asg-sns.arn
  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR"
  ]
}

# *********************************************************
# TODO!!! SNS TOPIC NOTIFICATIONS BY EMAIL !Do NOT uncomment!, if you don't intend to fix it
# *********************************************************

# variable "sns_subscription_email_address_list" {
#    type = list(string)
#    description = "List of email addresses"
#  }

#  variable "sns_subscription_protocol" {
#    type = string
#    default = "email"
#    description = "SNS subscription protocal"
#  }

#  variable "sns_topic_name" {
#    type = string
#    description = "SNS topic name"
#  }

#  variable "sns_topic_display_name" {
#    type = string
#    description = "SNS topic display name"
#  }

#  data "template_file" "aws_cf_sns_stack" {
#    template = file("${path.module}/templates/cf_aws_sns_email_stack.json.tpl")
#    vars = {
#      sns_topic_name        = var.sns_topic_name
#      sns_display_name      = var.sns_topic_display_name
#      sns_subscription_list = join(",", formatlist("{\"Endpoint\": \"%s\",\"Protocol\": \"%s\"}",
#      var.sns_subscription_email_address_list,
#      var.sns_subscription_protocol))
#    }
#  }

## Use template_body in resources
#  resource "aws_cloudformation_stack" "tf_sns_topic" {
#    name = "snsStack"
#    template_body = data.template_file.aws_cf_sns_stack.rendered
#    tags = {
#      name = "snsStack"
#    }
#  }
