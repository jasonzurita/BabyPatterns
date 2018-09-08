import Foundation
import StoreKit

public final class IAPCheckout: NSObject {
    public var onSuccess: (() -> Void)?
    public var onFailure: (() -> Void)?

    public override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }

    deinit {
        SKPaymentQueue.default().remove(self)
    }

    public func purchase(_ product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
}

extension IAPCheckout: SKPaymentTransactionObserver {
    public func paymentQueue(_: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                onSuccess?()
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                if let transactionError = transaction.error {
                    if (transactionError as NSError).code != SKError.paymentCancelled.rawValue {
                        print("Transaction Error: \(transactionError.localizedDescription)")
                    }
                }
                onFailure?()
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
            case .deferred, .purchasing:
                break
            }
        }
    }
}
