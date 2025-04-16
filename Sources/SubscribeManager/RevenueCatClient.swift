//
//  RevenueCatClient.swift
//  SuperTuber
//
//  Created by mohamed abd elaleem on 05/04/2025.
//
import RevenueCat
import Foundation

// RevenueCat client class
public class RevenueCatClient {
    // Singleton instance
    public static let shared = RevenueCatClient()
    
    private init() {}
    
    // Get available offerings from RevenueCat
    public func getOfferings() async throws -> Offerings? {
        return try await Purchases.shared.offerings()
    }
    
    // Check if user has premium status
    public func checkPremiumStatus() async throws -> Bool {
        let customerInfo = try await Purchases.shared.customerInfo()
        return customerInfo.entitlements["premium"]?.isActive == true
    }
    
    // Purchase a product by ID
    public func purchase(_ productID: String) async throws -> Bool {
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
        } catch {
            throw error
        }
    }
    
    // Restore purchases
    public func restore() async throws -> Bool {
        // Restore purchases using async/await
        let customerInfo = try await Purchases.shared.restorePurchases()
        return customerInfo.entitlements["premium"]?.isActive == true
    }
}
