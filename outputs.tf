output "site_a_cluster_name" {
  value = aws_eks_cluster.site_a_cluster.name
}

output "site_b_cluster_name" {
  value = aws_eks_cluster.site_b_cluster.name
}

output "site_a_vpc_id" {
  value = aws_vpc.site_a_vpc.id
}

output "site_b_vpc_id" {
  value = aws_vpc.site_b_vpc.id
}