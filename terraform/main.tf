# resource "aws_instance" "this" {
#   ami           = "ami-01811d4912b4ccb26" # Ubuntu AMI
#   instance_type = "t2.small"
#   key_name      = "khainh-ssh-key"
#   security_groups = ["sg-0c867e733dbc75384"]
#   subnet_id     = "subnet-0cdcc944d88340d52"

#   tags = {
#     Name = "Terraform-Khainh"
#   }
# }

resource "aws_vpc" "khainh-vpc" {
  cidr_block = var.cidrvpc
  tags = var.tags
}

#Create public subnet
resource "aws_subnet" "public" {
    count = var.az_count
    cidr_block = cidrsubnet(aws_vpc.khainh-vpc.cidr_block, 8, count.index)
    availability_zone = data.aws_availability_zones.available.names[count.index]
    vpc_id = aws_vpc.khainh-vpc.id
    tags = merge({
        Name = "${var.vpc_name}-public-subnet"
    },
    var.tags)
}

#Create private subnet
resource "aws_subnet" "private" {
    count = 3
    cidr_block = cidrsubnet(aws_vpc.khainh-vpc.cidr_block, 8, count.index + var.az_count)
    availability_zone = data.aws_availability_zones.available.names[count.index]
    vpc_id = aws_vpc.khainh-vpc.id
    tags = merge({
        Name = "${var.vpc_name}-private-subnet"
    },
    var.tags)
}



#associate the private subnets to private route tables
resource "aws_route_table_association" "private-subnet-rtb" {
    count = var.az_count
    subnet_id = element(aws_subnet.private.*.id, count.index)
    route_table_id = element(aws_route_table.private_rtb.*.id, count.index)
}

#Create internet gateway
resource "aws_internet_gateway" "main-igw" {
    vpc_id = aws_vpc.khainh-vpc.id
    tags = merge({
        Name = "${var.vpc_name}-igw"
    }, var.tags)
}

resource "aws_route" "main-route" {
  route_table_id = aws_vpc.khainh-vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main-igw.id
}

#associate the public subnet to main route table with igw
resource "aws_route_table_association" "public-subnet-rtb" {
    count = var.az_count
    subnet_id = element(aws_subnet.public.*.id, count.index)
    route_table_id = aws_vpc.khainh-vpc.main_route_table_id
}

#create natgate way
resource "aws_eip" "ngweip" {
 count = var.az_count
 tags = merge(
    {
        ext-name = "${var.vpc_name}-ngw-eip-${count.index}"
    },
    var.tags
 )  
}

resource "aws_nat_gateway" "ngw" {
 count = var.az_count
 subnet_id = element(aws_subnet.private.*.id, count.index)
 allocation_id = element(aws_eip.ngweip.*.id, count.index)
 tags = merge(
    { ext-name = "${var.vpc_name}-ngw-eip-${count.index}" },
    var.tags
 )
}

#Create the route table for private subnet
resource "aws_route_table" "private_rtb" {
    count = var.az_count
    vpc_id = aws_vpc.khainh-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = element(aws_nat_gateway.ngw.*.id, count.index)
    }
    tags = merge(
        {
            ext-name = "${var.vpc_name}-private-rtb-${count.index}"
        },
        var.tags
    )
}