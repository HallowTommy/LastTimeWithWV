import Foundation
import Combine
import StoreKit

protocol PaywallServiceProtocol {
    func loadProducts(identifiers: Set<String>) async throws -> [Product]
    func purchase(_ product: Product) async throws -> Bool
    func restorePurchases() async throws -> Bool
    func checkCurrentEntitlements(productIds: Set<String>) async -> Bool
}

@MainActor
final class PaywallService: PaywallServiceProtocol, ObservableObject {
    private var transactionUpdatesTask: Task<Void, Never>?
    private var hasStartedTransactionListener = false

    /// Call at launch so purchases are not missed. Optionally pass a closure to run when entitlement may have changed (e.g. update PremiumService).
    func startTransactionUpdatesListener(onEntitlementMaybeChanged: (() async -> Void)? = nil) {
        guard !hasStartedTransactionListener else { return }
        hasStartedTransactionListener = true
        let productIds = Set(SubscriptionOption.all.map(\.productIdentifier))
        transactionUpdatesTask = Task { [productIds] in
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else { continue }
                await transaction.finish()
                if productIds.contains(transaction.productID) {
                    await onEntitlementMaybeChanged?()
                }
            }
        }
    }

    func loadProducts(identifiers: Set<String>) async throws -> [Product] {
        guard !identifiers.isEmpty else {
            print("[PaywallService] loadProducts: identifiers empty, skipping")
            return []
        }
        print("[PaywallService] loadProducts: requesting product IDs: \(identifiers)")
        do {
            let products = try await Task.detached {
                try await Product.products(for: identifiers)
            }.value
            print("[PaywallService] loadProducts: received \(products.count) product(s)")
            for p in products {
                print("[PaywallService]   - id: \(p.id), displayPrice: \(p.displayPrice), displayName: \(p.displayName)")
            }
            if products.isEmpty {
                print("[PaywallService] loadProducts: WARNING — empty array. Check StoreKit config is selected (Edit Scheme → Run → Options → StoreKit Configuration) or App Store Connect product IDs match.")
            }
            return products
        } catch {
            print("[PaywallService] loadProducts: FAILED — \(error)")
            throw error
        }
    }

    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            switch verification {
            case .verified(let transaction):
                await transaction.finish()
                return true
            case .unverified:
                return false
            }
        case .userCancelled:
            return false
        case .pending:
            return false
        @unknown default:
            return false
        }
    }

    func restorePurchases() async throws -> Bool {
        try await AppStore.sync()
        return true
    }

    func checkCurrentEntitlements(productIds: Set<String>) async -> Bool {
        guard !productIds.isEmpty else { return false }
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if productIds.contains(transaction.productID) {
                return true
            }
        }
        return false
    }
}
