resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  values = [
    file("${path.module}/values/argocd-values.yaml")
  ]

  wait          = true
  wait_for_jobs = true
  atomic        = true
  timeout       = 600

  depends_on = [
    kubernetes_namespace.argocd
  ]
}

resource "kubernetes_manifest" "demo_app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"

    metadata = {
      name      = "demo-app"
      namespace = var.argocd_namespace
    }

    spec = {
      project = "default"

      source = {
        repoURL        = "https://github.com/DychkoDmytro/eks-vpc-cluster.git"
        targetRevision = "lesson-7"
        path           = "k8s/demo-app"
      }

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "default"
      }

      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }
    }
  }

  depends_on = [
    helm_release.argocd
  ]
}
