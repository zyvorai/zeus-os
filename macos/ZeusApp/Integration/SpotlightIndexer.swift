import Foundation
@preconcurrency import CoreSpotlight
import ZeusKit

/// Makes machine names searchable from Spotlight. Only names and namespaces are indexed.
enum SpotlightIndexer {
    private static let domain = "dev.zyvor.zeus.machines"

    static func index(_ vms: [VM], server: String) {
        let items = vms.map { vm -> CSSearchableItem in
            let a = CSSearchableItemAttributeSet(contentType: .content)
            a.title = vm.name
            a.contentDescription = "Machine in \(vm.namespace) on \(server)"
            return CSSearchableItem(uniqueIdentifier: vm.id, domainIdentifier: domain, attributeSet: a)
        }
        let index = CSSearchableIndex.default()
        index.deleteSearchableItems(withDomainIdentifiers: [domain]) { _ in index.indexSearchableItems(items) { _ in } }
    }

    static func clear() {
        CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [domain]) { _ in }
    }
}
