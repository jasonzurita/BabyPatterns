import Foundation
import StoreKit
import Library

// TODO: implement canMakePayments ?
public final class IAPAvailability: NSObject, Loggable {
    public let shouldPrintDebugLog = true

    public typealias ProductIdentifier = String
    public typealias ProductsRequestCompletionHandler = (Bool) -> Void

    private var availableProducts: [SKProduct] = []
    private var _productsRequest: SKProductsRequest
    private var _productsRequestCompletionHandler: ProductsRequestCompletionHandler?

    public init(productId: ProductIdentifier,
                productRequestCompletionHandler: ProductsRequestCompletionHandler? = nil) {
        _productsRequest = SKProductsRequest(productIdentifiers: [productId])
        _productsRequestCompletionHandler = productRequestCompletionHandler
        super.init()
        _productsRequest.delegate = self
        _productsRequest.start()
    }

    deinit {
        _productsRequest.cancel()
    }
}

extension IAPAvailability: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        availableProducts = response.products
        _productsRequestCompletionHandler?(true)

        print("Total IAPs found : \(response.products.count)")
        availableProducts.forEach {
            let msg = "\($0.productIdentifier) \($0.localizedTitle) \($0.price.floatValue)"
            log(msg, object: self, type: .info)
        }
    }

    public func request(_ request: SKRequest, didFailWithError error: Error) {
        let msg = "Failed to load list of IAP products: \(error.localizedDescription)"
        log(msg, object: self, type: .error)
        _productsRequestCompletionHandler?(false)
    }
}
