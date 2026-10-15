import Combine
import StoreKit

/// Product IDs must match the in-app purchases created in App Store Connect
/// (and `KittyEscape.storekit` for local testing).
enum StoreProduct {
    static let removeAds = "com.example.kittyescape.removeads"
    static let coinsSmall = "com.example.kittyescape.coins500"
    static let coinsLarge = "com.example.kittyescape.coins3000"

    static let all = [removeAds, coinsSmall, coinsLarge]
    static let coinAmounts = [coinsSmall: 500, coinsLarge: 3000]
}

@MainActor
final class Store: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var isPurchasing = false
    @Published var message: String?

    private let progress: PlayerProgress
    private var updatesTask: Task<Void, Never>?

    init(progress: PlayerProgress) {
        self.progress = progress
        // Purchases made outside the app or left unfinished arrive here.
        updatesTask = Task { [weak self] in
            for await result in Transaction.updates {
                await self?.handle(result)
            }
        }
        Task {
            await loadProducts()
            await refreshEntitlements()
        }
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: StoreProduct.all).sorted { $0.price < $1.price }
        } catch {
            products = []
        }
    }

    func purchase(_ product: Product) async {
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            switch try await product.purchase() {
            case .success(let verification):
                await handle(verification)
                Analytics.log("purchase", ["product": product.id])
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            message = "The purchase didn't go through. Please try again."
        }
    }

    func restore() async {
        try? await AppStore.sync()
        await refreshEntitlements()
        message = progress.removeAds ? "Purchases restored." : "No purchases to restore."
    }

    private func refreshEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == StoreProduct.removeAds,
               transaction.revocationDate == nil {
                progress.removeAds = true
            }
        }
    }

    private func handle(_ result: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = result else { return }
        if transaction.revocationDate == nil {
            if transaction.productID == StoreProduct.removeAds {
                progress.removeAds = true
            } else if let amount = StoreProduct.coinAmounts[transaction.productID] {
                progress.coins += amount
            }
        }
        await transaction.finish()
    }
}
