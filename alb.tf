resource "aws_alb" "ecs-alb" {
  name            = "helloworld-alb"
  subnets         = data.aws_subnet_ids.default.ids
  security_groups = [aws_security_group.ecs_tasks.id]
}

resource "aws_alb_target_group" "blue-sg" {
  name        = "helloworld-blue-tg"
  port        = "8080"
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"
}

resource "aws_alb_target_group" "green-sg" {
  name        = "helloworld-green-tg"
  port        = "8080"
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"
}

# Redirect all traffic from the ALB to the blue target group
resource "aws_alb_listener" "blue_deploy" {
  load_balancer_arn = aws_alb.ecs-alb.id
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.blue-sg.id
    type             = "forward"
  }
}

# Redirect all traffic from the ALB to the green target group
resource "aws_alb_listener" "green_deploy" {
  load_balancer_arn = aws_alb.ecs-alb.id
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.green-sg.id
    type             = "forward"
  }
}

