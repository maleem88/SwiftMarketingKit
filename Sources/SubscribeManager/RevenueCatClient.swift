//
//  RevenueCatClient.swift
//  SuperTuber
//
//  Created by mohamed abd elaleem on 05/04/2025.
//
import ComposableArchitecture
import RevenueCat
import Foundation



// RevenueCat client dependency
struct RevenueCatClient {
    var getOfferings: @Sendable () async throws -> Offerings?
    var checkPremiumStatus: @Sendable () async throws -> Bool
    var purchase: @Sendable (String) async throws -> Bool
    var restore: @Sendable () async throws -> Bool
}

// Live implementation of RevenueCat client
extension RevenueCatClient {
    static let live = RevenueCatClient(
        getOfferings: {
            
            return try await Purchases.shared.offerings()
            
//            return try await withCheckedThrowingContinuation { continuation in
//                
//                Purchases.shared.getOfferings(fetchPolicy: .fetchCurrent) { offerings, error in
//                    if let error = error {
//                        continuation.resume(throwing: error)
//                        return
//                    }
//                    continuation.resume(returning: offerings)
//                }
//            }
        },
        checkPremiumStatus: {
            let customerInfo = try await Purchases.shared.customerInfo()
            return customerInfo.entitlements["premium"]?.isActive == true
        },
        purchase: { productID in
            do {
                // Get offerings using async/await
                let offerings = try await Purchases.shared.offerings()
                
                // Find the package with the matching product ID
                guard let offering = offerings.current,
                      let package = offering.availablePackages.first(where: { $0.storeProduct.productIdentifier == productID }) else {
                    throw NSError(domain: "com.supertuber", code: 1, userInfo: [NSLocalizedDescriptionKey: "Product not found"])
                }
                
                // Purchase the package using async/await
                let purchaseResult = try await Purchases.shared.purchase(package: package)
                
                // Check if premium is active
                return purchaseResult.customerInfo.entitlements["premium"]?.isActive == true
            } catch let error as NSError {
                // Handle user cancellation
//                if error.userCancelled {
//                    return false
//                } else {
                    throw error
//                }
            }
        },
        restore: {
            // Restore purchases using async/await
            let customerInfo = try await Purchases.shared.restorePurchases()
            return customerInfo.entitlements["premium"]?.isActive == true
        }
    )
}

// Register RevenueCat client with dependency system
extension DependencyValues {
    var revenueCat: RevenueCatClient {
        get { self[RevenueCatClient.self] }
        set { self[RevenueCatClient.self] = newValue }
    }
}

// Register the live implementation
extension RevenueCatClient: DependencyKey {
    static var liveValue = RevenueCatClient.live
}
