data "aws_ami" "ubuntu" {
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20260610"]
  }
  most_recent = true
  owners = [ "099720109477" ]
}

resource "aws_instance" "web_server" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.instance_type
    key_name = var.key_pair
    tags = {
        "Name" = "Web Server"
    }
    vpc_security_group_ids = [ aws_security_group.ssh.id,
    aws_security_group.web.id,
    aws_security_group.egress.id,
    aws_security_group.mysql_out.id ]
    user_data = file("./scripts/web_server.sh")
    user_data_replace_on_change = true
  
}

resource "aws_instance" "db_server" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.instance_type
    key_name = var.key_pair
    tags = {
        "Name" = "DB Server"
    }
    vpc_security_group_ids = [ aws_security_group.ssh.id,
    aws_security_group.egress.id,
    aws_security_group.mysql_in.id ]
    user_data = file("./scripts/db_server.sh")
    user_data_replace_on_change = true
  
}


resource "aws_security_group" "ssh" {
    name = "SSH-IN-ANYWHERE"
    description = "Allows all SSH inbound traffic"
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
    security_group_id = aws_security_group.ssh.id
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 22
    to_port = 22
    ip_protocol = "TCP"

}

resource "aws_security_group" "web" {
        name = "WEB-IN-ANYWHERE"
    description = "Allows all HTTP and HTTPS inbound traffic"
  
}
resource "aws_vpc_security_group_ingress_rule" "http" {
    security_group_id = aws_security_group.web.id
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 80
    to_port = 80
    ip_protocol = "TCP"

}
resource "aws_vpc_security_group_ingress_rule" "https" {
    security_group_id = aws_security_group.web.id
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 443
    to_port = 443
    ip_protocol = "TCP"

}

resource "aws_security_group" "egress" {
    name = "ALL-OUT-ANYWHERE"
    description = "Allows all egress traffic"
  
}
resource "aws_vpc_security_group_egress_rule" "all" {
    security_group_id = aws_security_group.egress.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "-1"

}

resource "aws_security_group" "mysql_out" {
    name = "MYSQL-OUT-ANYWHERE"
    description = "Identifies instances to comunicate with MySQL server"
}

resource "aws_security_group" "mysql_in" {
    name = "MYSQL-IN-ANYWHERE"
    description = "Allows MySQL ingress traffic from some isntances"
}

resource "aws_vpc_security_group_ingress_rule" "mysql" {
    security_group_id = aws_security_group.mysql_in.id
    from_port = 3306
    to_port = 3306
    ip_protocol = "TCP"
    referenced_security_group_id = aws_security_group.mysql_out.id
  
}

