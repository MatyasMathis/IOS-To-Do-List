//
//  StoreService.swift
//  Reps
//
//  Purpose: Manages StoreKit 2 in-app purchase for premium unlock
//

import Foundation
import StoreKit

@MainActor
@Observable
class StoreService {

    // MARK: - Constants

    static let premiumProductID = "com.mathis.reps.premium"

    // MARK: - State

    var isPremium: Bool = false
    var premiumProduct: Product?
    var isPurchasing: Bool = false
    var errorMessage: String?

    // MARK: - Private

    private var transactionListener: Task<Void, Never>?

    // MARK: - Initialization

    init() {
        transactionListener = listenForTransactions()
        Task {
            await checkCurrentEntitlements()
            await loadProduct()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Product Loading

    func loadProduct() async {
        do {
            let products = try await Product.products(for: [Self.premiumProductID])
            premiumProduct = products.first
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    // MARK: - Purchase

    func purchase() async {
        guard let product = premiumProduct else { return }
        isPurchasing = true
        errorMessage = nil

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                isPremium = true
                await transaction.finish()

            case .userCancelled:
                break

            case .pending:
                break

            @unknown default:
                break
            }
        } catch {
            errorMessage = "Purchase failed. Please try again."
            print("Purchase error: \(error)")
        }

        isPurchasing = false
    }

    // MARK: - Restore

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await checkCurrentEntitlements()
        } catch {
            errorMessage = "Restore failed. Please try again."
            print("Restore error: \(error)")
        }
    }

    // MARK: - Entitlement Check

    func checkCurrentEntitlements() async {
        var hasPremium = false

        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result),
               transaction.productID == Self.premiumProductID {
                hasPremium = true
            }
        }

        isPremium = hasPremium
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached {
            for await result in Transaction.updates {
                if let transaction = try? self.checkVerified(result) {
                    await MainActor.run {
                        if transaction.productID == Self.premiumProductID {
                            self.isPremium = transaction.revocationDate == nil
                        }
                    }
                    await transaction.finish()
                }
            }
        }
    }

    // MARK: - Verification

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let value):
            return value
        }
    }
}
