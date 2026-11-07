import SwiftUI
import ZeusKit

extension Destination {
    /// Read-only screens for delivery, operators, catalog and platform add-ons. Mesh, the service registry
    /// list and service dependencies list live on "Mesh & Services"; the extra views of them are here.
    static let tailDelivery: [Destination] = [
        Destination("Operators", symbol: "puzzlepiece.extension", group: "Platform") {
            TailSectionsView(title: "Operators", client: $0, sections: [
                TailSection("Operators", "operators"),
                TailSection("Available operators", "operators", "available"),
                TailSection("Operator stats", "operators", "stats"),
                TailSection("Subscriptions", "subscriptions"),
                TailSection("Catalog sources", "catalogsources"),
                TailSection("Install plans", "installplans"),
                TailSection("Operator groups", "operatorgroups"),
            ])
        },
        Destination("Catalog", symbol: "books.vertical", group: "Platform") {
            TailSectionsView(title: "Catalog", client: $0, sections: [
                TailSection("Apps", "catalog", "apps"),
                TailSection("Categories", "catalog", "categories"),
                TailSection("Templates", "catalog", "templates"),
                TailSection("Helm repos", "catalog", "helm", "repos"),
                TailSection("Helm charts", "catalog", "helm", "charts"),
                TailSection("Helm releases", "catalog", "helm", "releases"),
                TailSection("Marketplace workspaces", "marketplace", "workspaces"),
                TailSection("Marketplace launches", "marketplace", "workspaces", "launches"),
                TailSection("Blueprints", "blueprints"),
                TailSection("Blueprint deployments", "blueprints", "deployments"),
                TailSection("Image factory pipelines", "image-factory", "pipelines"),
            ])
        },
        Destination("Rollouts", symbol: "arrow.triangle.branch", group: "Automation") {
            TailSectionsView(title: "Rollouts", client: $0, sections: [
                TailSection("Deployment strategies", "deployment-strategies", "strategies"),
                TailSection("Strategy deployments", "deployment-strategies", "deployments"),
                TailSection("Rollout history", "deployment-strategies", "rollout-history"),
                TailSection("Canary configs", "deployment-strategies", "canary-configs"),
                TailSection("Traffic splits", "deployment-strategies", "traffic-splits"),
                TailSection("Progressive rollouts", "progressive-delivery", "rollouts"),
                TailSection("Progressive canaries", "progressive-delivery", "canaries"),
                TailSection("Blue-green", "progressive-delivery", "blue-green"),
                TailSection("Experiments", "progressive-delivery", "experiments"),
                TailSection("Analysis templates", "progressive-delivery", "analysis-templates"),
                TailSection("Progressive metrics", "progressive-delivery", "metrics"),
                TailSection("Kustomize capabilities", "kustomize", "capabilities"),
                TailSection("Kustomize projects", "kustomize", "projects"),
                TailSection("Kustomize bases", "kustomize", "bases"),
                TailSection("Kustomize overlays", "kustomize", "overlays"),
                TailSection("Kustomize components", "kustomize", "components"),
                TailSection("Kustomize templates", "kustomize", "templates"),
                TailSection("IaC workspaces", "iac", "workspaces"),
                TailSection("IaC runs", "iac", "runs"),
                TailSection("IaC state", "iac", "state"),
                TailSection("IaC providers", "iac", "providers"),
                TailSection("IaC modules", "iac", "modules"),
                TailSection("IaC resources", "iac", "resources"),
                TailSection("IaC drift", "iac", "drift"),
                TailSection("IaC drift reports", "iac", "drift", "reports"),
            ])
        },
        Destination("Platform Add-ons", symbol: "square.stack.3d.up", group: "Platform") {
            TailSectionsView(title: "Platform Add-ons", client: $0, sections: [
                TailSection("NMState policies", "nmstate", "policies"),
                TailSection("NMState enactments", "nmstate", "enactments"),
                TailSection("Gateway classes", "gateway-api", "gateway-classes"),
                TailSection("Gateways", "gateway-api", "gateways"),
                TailSection("HTTP routes", "gateway-api", "http-routes"),
                TailSection("Netra status", "netra", "status"),
                TailSection("Netra drops", "netra", "drops"),
                TailSection("Netra DNS board", "netra", "dns", "board"),
                TailSection("Netra flows", "netra", "flows", "summary"),
                TailSection("Netra L7 sampled", "netra", "l7", "sampled"),
                TailSection("Netra L7 TLS", "netra", "l7", "tls"),
                TailSection("Netra emergency", "netra", "emergency"),
                TailSection("Kryton status", "kryton", "status"),
                TailSection("Kryton machines", "kryton", "machines"),
                TailSection("Kryton images", "kryton", "images"),
                TailSection("Kryton golden images", "kryton", "golden"),
                TailSection("Mesh stats", "mesh", "stats"),
                TailSection("Registry metrics", "service-registry", "metrics"),
                TailSection("Registry health checks", "service-registry", "health-checks"),
                TailSection("Registry DNS", "service-registry", "discovery", "dns"),
                TailSection("Registry load balancers", "service-registry", "load-balancers"),
                TailSection("Registry service graph", "service-registry", "service-graph"),
                TailSection("Dependency graph", "service-dependencies", "dependency-graph"),
                TailSection("Critical paths", "service-dependencies", "critical-path"),
                TailSection("Bottlenecks", "service-dependencies", "bottlenecks"),
                TailSection("Circular dependencies", "service-dependencies", "circular-dependencies"),
                TailSection("Communication patterns", "service-dependencies", "communication-patterns"),
                TailSection("Health propagation", "service-dependencies", "health-propagation"),
                TailSection("SLA dependencies", "service-dependencies", "sla-dependencies"),
                TailSection("Cluster dependencies", "dependencies"),
            ])
        },
        Destination("Lifecycle", symbol: "arrow.triangle.2.circlepath.circle", group: "Platform") {
            TailSectionsView(title: "Lifecycle", client: $0, sections: [
                TailSection("Patch center", "patch-center", "status"),
                TailSection("Patch capabilities", "patch", "capabilities"),
                TailSection("Patch policies", "patch", "policies"),
                TailSection("Node lifecycle compliance", "lifecycle", "compliance"),
                TailSection("Lifecycle rollout", "lifecycle", "rollout", "status"),
                TailSection("Customization profiles", "customization-profiles"),
                TailSection("Webhook subscriptions", "webhooks", "subscriptions"),
                TailSection("Webhooks", "webhooks"),
                TailSection("Alert webhooks", "alert-webhooks"),
                TailSection("Validating admission", "webhooks", "validating"),
                TailSection("Mutating admission", "webhooks", "mutating"),
                TailSection("Webhook stats", "webhooks", "stats"),
            ])
        },
    ]
}
