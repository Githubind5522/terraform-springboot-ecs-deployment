### ECS

resource "aws_ecs_cluster" "ecs-cluster" {
  name = "hello-world"
}

resource "aws_ecs_task_definition" "task-definition" {
  family                   = "hellworld-blue-task-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = <<DEFINITION
[
  {
    "cpu": 1,
    "image": "653308993752.dkr.ecr.us-west-1.amazonaws.com/springboot-ecr:v_8",
    "memory": 2048,
    "name": "helloworld-application",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "protocol"	: "tcp",
        "containerPort"	: 8080,
        "hostPort"	: 8080
      }
    ]
  }
]
DEFINITION
}

resource "aws_ecs_service" "ecs-service" {
  name            = "helloworld-service"
  cluster         = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.task-definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  scheduling_strategy = "REPLICA"

  network_configuration {
    security_groups = [aws_security_group.ecs_tasks.id]
    subnets         = data.aws_subnet_ids.default.ids
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.blue-sg.arn
    container_name   = "helloworld-application"
    container_port   = 8080
  }

  depends_on = [aws_alb_listener.blue_deploy]
}
