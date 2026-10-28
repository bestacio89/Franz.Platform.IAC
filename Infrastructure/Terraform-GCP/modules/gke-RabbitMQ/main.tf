# Example GKE cluster (if you don’t already have one)
module "gke" {
  source        = "terraform-google-modules/kubernetes-engine/google"
  project_id    = var.project_id
  name          = "franz-gke"
  region        = var.region
  network       = var.network
  subnetwork    = var.subnetwork
  ip_range_pods = "pods"
}

# RabbitMQ Namespace
resource "kubernetes_namespace" "rabbitmq" {
  metadata {
    name = "rabbitmq"
  }
}

# RabbitMQ StatefulSet
resource "kubernetes_manifest" "rabbitmq_statefulset" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "StatefulSet"
    metadata = {
      name      = "rabbitmq"
      namespace = kubernetes_namespace.rabbitmq.metadata[0].name
    }
    spec = {
      serviceName = "rabbitmq"
      replicas    = 1
      selector = {
        matchLabels = {
          app = "rabbitmq"
        }
      }
      template = {
        metadata = {
          labels = {
            app = "rabbitmq"
          }
        }
        spec = {
          containers = [{
            name  = "rabbitmq"
            image = "rabbitmq:3-management" # includes mgmt UI
            ports = [
              { name = "amqp", containerPort = 5672 },
              { name = "management", containerPort = 15672 }
            ]
            env = [
              {
                name  = "RABBITMQ_DEFAULT_USER"
                value = var.rabbitmq_user
              },
              {
                name  = "RABBITMQ_DEFAULT_PASS"
                value = var.rabbitmq_password
              }
            ]
          }]
        }
      }
    }
  }
}

# RabbitMQ Service
resource "kubernetes_service" "rabbitmq" {
  metadata {
    name      = "rabbitmq"
    namespace = kubernetes_namespace.rabbitmq.metadata[0].name
  }
  spec {
    selector = {
      app = "rabbitmq"
    }
    port {
      name        = "amqp"
      port        = 5672
      target_port = 5672
    }
    port {
      name        = "management"
      port        = 15672
      target_port = 15672
    }
    type = "LoadBalancer"
  }
}
