import Foundation
import Combine
import StoreKit
import SwiftUI

@MainActor
final class PaywallViewModel: ObservableObject {
    @Published var selectedOption: SubscriptionOption = .year
    @Published private(set) var loadedProducts: [String: Product] = [:]
    @Published private(set) var isLoadingProducts = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var errorMessageKey: LocalizedStringKey?

    let options: [SubscriptionOption] = SubscriptionOption.all

    private let paywallService: PaywallServiceProtocol

    init(paywallService: PaywallServiceProtocol) {
        self.paywallService = paywallService
    }

    func select(_ option: SubscriptionOption) {
        selectedOption = option
    }

    func loadProducts() async {
        guard !isLoadingProducts else {
            print("[PaywallViewModel] loadProducts: already loading, skip")
            return
        }
        isLoadingProducts = true
        errorMessage = nil
        errorMessageKey = nil
        defer { isLoadingProducts = false }
        let identifiers = Set(options.map(\.productIdentifier))
        print("[PaywallViewModel] loadProducts: start, identifiers: \(identifiers)")
        do {
            let products = try await paywallService.loadProducts(identifiers: identifiers)
            var dict: [String: Product] = [:]
            for product in products {
                dict[product.id] = product
            }
            loadedProducts = dict
            print("[PaywallViewModel] loadProducts: success, loadedProducts keys: \(dict.keys.sorted())")
        } catch {
            print("[PaywallViewModel] loadProducts: error — \(error)")
            errorMessage = error.localizedDescription
        }
    }

    func priceString(for option: SubscriptionOption) -> String {
        if let price = loadedProducts[option.productIdentifier]?.displayPrice {
            return price
        }
        print("[PaywallViewModel] priceString(for: \(option.productIdentifier)): using fallback, loadedProducts has: \(loadedProducts.keys.sorted())")
        return "$\(option.priceValue)"
    }

    func purchase(completion: @escaping (Bool) -> Void) {
        guard let product = loadedProducts[selectedOption.productIdentifier] else {
            errorMessage = nil
            errorMessageKey = "paywall.error.not_available"
            completion(false)
            return
        }
        isLoading = true
        errorMessage = nil
        errorMessageKey = nil
        Task {
            do {
                let success = try await paywallService.purchase(product)
                await MainActor.run {
                    isLoading = false
                    if !success {
                        errorMessage = nil
                        errorMessageKey = "paywall.error.cancelled"
                    }
                    completion(success)
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    errorMessageKey = nil
                    completion(false)
                }
            }
        }
    }

    func restorePurchases(completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        errorMessageKey = nil
        Task {
            do {
                _ = try await paywallService.restorePurchases()
                let productIds = Set(options.map(\.productIdentifier))
                let hasEntitlement = await paywallService.checkCurrentEntitlements(productIds: productIds)
                await MainActor.run {
                    isLoading = false
                    if !hasEntitlement {
                        errorMessage = nil
                        errorMessageKey = "paywall.error.no_purchases"
                    }
                    completion(hasEntitlement)
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    errorMessageKey = nil
                    completion(false)
                }
            }
        }
    }
}
