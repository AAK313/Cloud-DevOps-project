output "vpc_id" {
  value = aws_vpc.myvpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_1_id" {
  value = aws_subnet.private_1.id
}

output "private_subnet_2_id" {
  value = aws_subnet.private_2.id
}

output "private_subnet_ids" {
  value = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}


output "subnet_ids" {
  value = [aws_subnet.public.id, aws_subnet.private_1.id, aws_subnet.private_2.id]
}

output "public_route_table_id" {
  value = aws_route_table.public.id
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}
