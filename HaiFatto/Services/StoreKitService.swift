// Hai fatto? — StoreKitService
import Foundation
import StoreKit

@Observable
public class StoreKitService {
    public var products: [Product] = []
    public var purchasedProductIDs: Set<String> = []
    
    public var isPremium: Bool {
        return !purchasedProductIDs.isDisjoint(with: StoreKitService.allProductIDs)
    }
    
    public var isLoading: Bool = false
    public var errorMessage: String?
    
    public static let monthlyID = "com.haifatto.premium.monthly"
    public static let yearlyID = "com.haifatto.premium.yearly"
    public static let lifetimeID = "com.haifatto.premium.lifetime"
    
    public static let allProductIDs: Set<String> = [monthlyID, yearlyID, lifetimeID]
    
    private var transactionListener: Task<Void, Never>?
    
    public init() {
        transactionListener = listenForTransactions()
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    @MainActor
    public func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedProducts = try await Product.products(for: StoreKitService.allProductIDs)
            self.products = fetchedProducts.sorted(by: { $0.price < $1.price })
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    public func purchase(_ product: Product) async throws -> Transaction? {
        isLoading = true
        defer { isLoading = false }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            if let transaction = verifyTransaction(verification) {
                await transaction.finish()
                await updatePurchasedProducts()
                return transaction
            } else {
                return nil
            }
        case .userCancelled, .pending:
            return nil
        @unknown default:
            return nil
        }
    }
    
    @MainActor
    public func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    public func updatePurchasedProducts() async {
        var purchasedIDs: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            if let transaction = verifyTransaction(result) {
                purchasedIDs.insert(transaction.productID)
            }
        }
        
        self.purchasedProductIDs = purchasedIDs
    }
    
    public func listenForTransactions() -> Task<Void, Never> {
        return Task.detached {
            for await result in Transaction.updates {
                if let transaction = self.verifyTransaction(result) {
                    await transaction.finish()
                    await self.updatePurchasedProducts()
                }
            }
        }
    }
    
    private func verifyTransaction(_ verificationResult: VerificationResult<Transaction>) -> Transaction? {
        switch verificationResult {
        case .unverified(_, _):
            return nil
        case .verified(let transaction):
            return transaction
        }
    }
}
