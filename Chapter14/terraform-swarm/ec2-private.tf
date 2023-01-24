resource "aws_instance" "private-db1" {
    ami           = var.ami_id
    instance_type = "t2.medium" // var.instance_type
    subnet_id     = aws_subnet.private1.id
    key_name      = var.key_pair
    vpc_security_group_ids = [ aws_security_group.ec2-private-sg.id ]
    associate_public_ip_address = false

    root_block_device {
        volume_size = 50
    }

    tags = {
        Name = "${var.project_name}-ec2-private-db1"
    }

    depends_on = [ aws_vpc.notes, aws_internet_gateway.igw  ]
    user_data = join("\n", [
        "#!/bin/sh",
        file("sh/docker_install.sh"),
        "mkdir -p /data/notes /data/users",
        "sudo hostname ${var.project_name}-private-db1"
    ]) 
}

/* resource "aws_instance" "private-db2" {
    ami           = var.ami_id
    instance_type = var.instance_type
    subnet_id     = aws_subnet.private1.id
    key_name      = var.key_pair
    vpc_security_group_ids = [ aws_security_group.ec2-private-sg.id ]
    associate_public_ip_address = false

    tags = {
        Name = "${var.project_name}-ec2-private-db2"
    }

    depends_on = [ aws_vpc.notes, aws_internet_gateway.igw  ]
    user_data = join("\n", [
        "#!/bin/sh",
        file("sh/docker_install.sh"),
        "sudo hostname ${var.project_name}-private-db2"
    ]) 
} */

resource "aws_instance" "private-svc1" {
    ami           = var.ami_id
    instance_type = var.instance_type
    subnet_id     = aws_subnet.private1.id
    key_name      = var.key_pair
    vpc_security_group_ids = [ aws_security_group.ec2-private-sg.id ]
    associate_public_ip_address = false

    tags = {
        Name = "${var.project_name}-ec2-private-svc1"
    }

    depends_on = [ aws_vpc.notes, aws_internet_gateway.igw  ]
    user_data = join("\n", [
        "#!/bin/sh",
        file("sh/docker_install.sh"),
        "sudo hostname ${var.project_name}-private-svc1"
    ]) 
}

resource "aws_security_group" "ec2-private-sg" {
    name        = "${var.project_name}-private-sg"
    description = "allow inbound access to the EC2 instance"
    vpc_id      = aws_vpc.notes.id


    ingress {
        description = "SSH"
        protocol    = "TCP"
        from_port   = 22
        to_port     = 22
        cidr_blocks = [ aws_vpc.notes.cidr_block ]
    }

    ingress {
        description = "HTTP"
        protocol    = "TCP"
        from_port   = 80
        to_port     = 80
        cidr_blocks = [ aws_vpc.notes.cidr_block ]
    }

    ingress {
        description = "MySQL"
        protocol    = "TCP"
        from_port   = 3306
        to_port     = 3306
        cidr_blocks = [ aws_vpc.notes.cidr_block ]
    }

    ingress {
        description = "Redis"
        protocol    = "TCP"
        from_port   = 6379
        to_port     = 6379
        cidr_blocks = [ aws_vpc.notes.cidr_block ]
    }

    ingress {
        description = "Docker swarm management"
        from_port   = 2377
        to_port     = 2377
        protocol    = "tcp"
        cidr_blocks = [ aws_vpc.notes.cidr_block ]
    }

    ingress {
        description = "Docker container network discovery"
        from_port   = 7946
        to_port     = 7946
        protocol    = "tcp"
        cidr_blocks = [ aws_vpc.notes.cidr_block ]
    }

    ingress {
        description = "Docker container network discovery"
        from_port   = 7946
        to_port     = 7946
        protocol    = "udp"
        cidr_blocks = [ aws_vpc.notes.cidr_block ]
    }

    ingress {
        description = "Docker overlay network"
        from_port   = 4789
        to_port     = 4789
        protocol    = "udp"
        cidr_blocks = [ aws_vpc.notes.cidr_block ]
    }

    egress {
        description = "Docker swarm (udp)"
        from_port   = 0
        to_port     = 0
        protocol    = "udp"
        cidr_blocks = [ aws_vpc.notes.cidr_block ]
    }

    egress {
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        cidr_blocks = [ "0.0.0.0/0" ]
    }
}

output "ec2-private-db1-arn" { value = aws_instance.private-db1.arn }

output "ec2-private-db1-dns" { value = aws_instance.private-db1.private_dns }
output "ec2-private-db1-ip"  { value = aws_instance.private-db1.private_ip }

output "ec2-private-svc1-arn" { value = aws_instance.private-svc1.arn }

output "ec2-private-svc1-dns" { value = aws_instance.private-svc1.private_dns }
output "ec2-private-svc1-ip"  { value = aws_instance.private-svc1.private_ip }
