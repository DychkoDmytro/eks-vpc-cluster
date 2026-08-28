output "argocd_namespace" {
  description = "Namespace where Argo CD is installed"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "argocd_release_name" {
  description = "Argo CD Helm release name"
  value       = helm_release.argocd.name
}

output "argocd_ui_port_forward" {
  description = "Command to access Argo CD UI locally"
  value       = "kubectl -n ${var.argocd_namespace} port-forward svc/argocd-server 8080:80"
}

output "argocd_cluster_name" {
  description = "EKS cluster used for Argo CD"
  value       = var.cluster_name
}
