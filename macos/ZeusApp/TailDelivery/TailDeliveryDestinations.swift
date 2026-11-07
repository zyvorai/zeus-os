import SwiftUI
import ZeusKit

extension Destination {
    /// Read-only screens for delivery, operators, catalog and platform add-ons. Mesh, the service registry
    /// list and service dependencies list live on "Mesh & Services"; the extra views of them are here.
    static let tailDelivery: [Destination] = [
        Destination("Operators", symbol: "puzzlepiece.extension", group: "Platform") {
            DeliverySectionsView(title: "Operators", client: $0, sections: [
                DeliverySection("Operators", "operators"),
                DeliverySection("Available operators", "operators", "available"),
                DeliverySection("Operator stats", "operators", "stats"),
                DeliverySection("Subscriptions", "subscriptions"),
                DeliverySection("Catalog sources", "catalogsources"),
                DeliverySection("Install plans", "installplans"),
                DeliverySection("Operator groups", "operatorgroups"),
            ])
        },
        Destination("Catalog", symbol: "books.vertical", group: "Platform") {
            DeliverySectionsView(title: "Catalog", client: $0, sections: [
                DeliverySection("Apps", "catalog", "apps"),
                DeliverySection("Categories", "catalog", "categories"),
                DeliverySection("Templates", "catalog", "templates"),
                DeliverySection("Helm repos", "catalog", "helm", "repos"),
                DeliverySection("Helm charts", "catalog", "helm", "charts"),
                DeliverySection("Helm releases", "catalog", "helm", "releases"),
                DeliverySection("Marketplace workspaces", "marketplace", "workspaces"),
                DeliverySection("Marketplace launches", "marketplace", "workspaces", "launches"),
                DeliverySection("Blueprints", "blueprints"),
                DeliverySection("Blueprint deployments", "blueprints", "deployments"),
                DeliverySection("Image factory pipelines", "image-factory", "pipelines"),
            ])
        },
        Destination("Rollouts", symbol: "arrow.triangle.branch", group: "Automation") {
            DeliverySectionsView(title: "Rollouts", client: $0, sections: [
                DeliverySection("Deployment strategies", "deployment-strategies", "strategies"),
                DeliverySection("Strategy deployments", "deployment-strategies", "deployments"),
                DeliverySection("Rollout history", "deployment-strategies", "rollout-history"),
                DeliverySection("Canary configs", "deployment-strategies", "canary-configs"),
                DeliverySection("Traffic splits", "deployment-strategies", "traffic-splits"),
                DeliverySection("Progressive rollouts", "progressive-delivery", "rollouts"),
                DeliverySection("Progressive canaries", "progressive-delivery", "canaries"),
                DeliverySection("Blue-green", "progressive-delivery", "blue-green"),
                DeliverySection("Experiments", "progressive-delivery", "experiments"),
                DeliverySection("Analysis templates", "progressive-delivery", "analysis-templates"),
                DeliverySection("Progressive metrics", "progressive-delivery", "metrics"),
                DeliverySection("Kustomize capabilities", "kustomize", "capabilities"),
                DeliverySection("Kustomize projects", "kustomize", "projects"),
                DeliverySection("Kustomize bases", "kustomize", "bases"),
                DeliverySection("Kustomize overlays", "kustomize", "overlays"),
                DeliverySection("Kustomize components", "kustomize", "components"),
                DeliverySection("Kustomize templates", "kustomize", "templates"),
                DeliverySection("IaC workspaces", "iac", "workspaces"),
                DeliverySection("IaC runs", "iac", "runs"),
                DeliverySection("IaC state", "iac", "state"),
                DeliverySection("IaC providers", "iac", "providers"),
                DeliverySection("IaC modules", "iac", "modules"),
                DeliverySection("IaC resources", "iac", "resources"),
                DeliverySection("IaC drift", "iac", "drift"),
                DeliverySection("IaC drift reports", "iac", "drift", "reports"),
            ])
        },
        Destination("Platform Add-ons", symbol: "square.stack.3d.up", group: "Platform") {
            DeliverySectionsView(title: "Platform Add-ons", client: $0, sections: [
                DeliverySection("NMState policies", "nmstate", "policies"),
                DeliverySection("NMState enactments", "nmstate", "enactments"),
                DeliverySection("Gateway classes", "gateway-api", "gateway-classes"),
                DeliverySection("Gateways", "gateway-api", "gateways"),
                DeliverySection("HTTP routes", "gateway-api", "http-routes"),
                DeliverySection("Netra status", "netra", "status"),
                DeliverySection("Netra drops", "netra", "drops"),
                DeliverySection("Netra DNS board", "netra", "dns", "board"),
                DeliverySection("Netra flows", "netra", "flows", "summary"),
                DeliverySection("Netra L7 sampled", "netra", "l7", "sampled"),
                DeliverySection("Netra L7 TLS", "netra", "l7", "tls"),
                DeliverySection("Netra emergency", "netra", "emergency"),
                DeliverySection("Kryton status", "kryton", "status"),
                DeliverySection("Kryton machines", "kryton", "machines"),
                DeliverySection("Kryton images", "kryton", "images"),
                DeliverySection("Kryton golden images", "kryton", "golden"),
                DeliverySection("Mesh stats", "mesh", "stats"),
                DeliverySection("Registry metrics", "service-registry", "metrics"),
                DeliverySection("Registry health checks", "service-registry", "health-checks"),
                DeliverySection("Registry DNS", "service-registry", "discovery", "dns"),
                DeliverySection("Registry load balancers", "service-registry", "load-balancers"),
                DeliverySection("Registry service graph", "service-registry", "service-graph"),
                DeliverySection("Dependency graph", "service-dependencies", "dependency-graph"),
                DeliverySection("Critical paths", "service-dependencies", "critical-path"),
                DeliverySection("Bottlenecks", "service-dependencies", "bottlenecks"),
                DeliverySection("Circular dependencies", "service-dependencies", "circular-dependencies"),
                DeliverySection("Communication patterns", "service-dependencies", "communication-patterns"),
                DeliverySection("Health propagation", "service-dependencies", "health-propagation"),
                DeliverySection("SLA dependencies", "service-dependencies", "sla-dependencies"),
                DeliverySection("Cluster dependencies", "dependencies"),
            ])
        },
        Destination("Lifecycle", symbol: "arrow.triangle.2.circlepath.circle", group: "Platform") {
            DeliverySectionsView(title: "Lifecycle", client: $0, sections: [
                DeliverySection("Patch center", "patch-center", "status"),
                DeliverySection("Patch capabilities", "patch", "capabilities"),
                DeliverySection("Patch policies", "patch", "policies"),
                DeliverySection("Node lifecycle compliance", "lifecycle", "compliance"),
                DeliverySection("Lifecycle rollout", "lifecycle", "rollout", "status"),
                DeliverySection("Customization profiles", "customization-profiles"),
                DeliverySection("Webhook subscriptions", "webhooks", "subscriptions"),
                DeliverySection("Webhooks", "webhooks"),
                DeliverySection("Alert webhooks", "alert-webhooks"),
                DeliverySection("Validating admission", "webhooks", "validating"),
                DeliverySection("Mutating admission", "webhooks", "mutating"),
                DeliverySection("Webhook stats", "webhooks", "stats"),
            ])
        },
    ]
}
