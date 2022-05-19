//
//  RSFirebaseDestination.swift
//  RudderFirebase
//
//  Created by Pallab Maiti on 04/03/22.
//

import Foundation
import Rudder
import FirebaseAnalytics
import FirebaseCore

class RSFirebaseDestination: RSDestinationPlugin {
    let type = PluginType.destination
    let key = "Firebase"
    var client: RSClient?
    var controller = RSController()
        
    func update(serverConfig: RSServerConfig, type: UpdateType) {
        guard type == .initial else { return }
        if (FirebaseApp.app() != nil) {
            client?.log(message: "Firebase already configured.", logLevel: .debug)
        } else {
            FirebaseApp.configure()
        }
    }
    
    func identify(message: IdentifyMessage) -> IdentifyMessage? {
        if let userId = message.userId, userId.count > 0 {
            FirebaseAnalytics.Analytics.setUserID(userId)
        }
        if let traits = extractTraits(traits: message.traits) {
            for (key, value) in traits {
                if key == "userId" {
                    continue
                }
                let firebaseKey = key.firebaseEvent
                if !IDENTIFY_RESERVED_KEYWORDS.contains(firebaseKey) {                                        
                    client?.log(message: "Setting userProperty to Firebase: \(firebaseKey)", logLevel: .debug)
                    FirebaseAnalytics.Analytics.setUserProperty(value, forName: firebaseKey)
                }
            }
        }
        return message
    }
    
    func track(message: TrackMessage) -> TrackMessage? {
        var firebaseEvent: String?
        var params: [String: Any]? = [String: Any]()
        if message.event == "Application Opened" {
            firebaseEvent = AnalyticsEventAppOpen
        } else if let event = getFirebaseECommerceEvent(from: message.event) {
            firebaseEvent = event
            var productsNeedToBeAdded = false
            switch firebaseEvent {
            case AnalyticsEventShare:
                if let cartId = message.properties?["cart_id"] {
                    params?[AnalyticsParameterItemID] = cartId
                } else if let productId = message.properties?["product_id"] {
                    params?[AnalyticsParameterItemID] = productId
                }
            case AnalyticsEventViewPromotion, AnalyticsEventSelectPromotion:
                if let name = message.properties?["name"] {
                    params?[AnalyticsParameterPromotionName] = name
                }
            case AnalyticsEventSelectContent:
                if let productId = message.properties?["product_id"] {
                    params?[AnalyticsParameterItemID] = productId
                }
                params?[AnalyticsParameterContentType] = "product"
            case AnalyticsEventAddToCart, AnalyticsEventAddToWishlist, AnalyticsEventViewItem, AnalyticsEventRemoveFromCart, AnalyticsEventBeginCheckout, AnalyticsEventPurchase, AnalyticsEventRefund, AnalyticsEventViewItemList, AnalyticsEventViewCart:
                productsNeedToBeAdded = true
            default:
                switch message.event {
                case RSEvents.Ecommerce.productShared:
                    params?[AnalyticsParameterContentType] = "product"
                case RSEvents.Ecommerce.cartShared:
                    params?[AnalyticsParameterContentType] = "cart"
                default: break
                }
            }
            if let properties = message.properties {
                insertECommerceData(params: &params, properties: properties)
                if productsNeedToBeAdded {
                    insertECommerceProductData(params: &params, properties: properties)
                }
            }
        } else {
            firebaseEvent = message.event.firebaseEvent
        }
        if let event = firebaseEvent {
            if let properties = message.properties {
                insertCustomPropertiesData(params: &params, properties: properties)
            }
            FirebaseAnalytics.Analytics.logEvent(event, parameters: params)
        }
        return message
    }
    
    func screen(message: ScreenMessage) -> ScreenMessage? {
        if message.name.count > 0 {
            var params: [String: Any]? = [AnalyticsParameterScreenName: message.name]
            if let properties = message.properties {
                insertCustomPropertiesData(params: &params, properties: properties)
            }
            FirebaseAnalytics.Analytics.logEvent(AnalyticsEventScreenView, parameters: params)
        }
        return message
    }
    
    func reset() {
        FirebaseAnalytics.Analytics.setUserID(nil)        
    }
}

// MARK: - Support methods

extension String {
    var firebaseEvent: String {
        var string = lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).replacingOccurrences(of: " ", with: "_")
        if string.count > 40 {
            string = String(string.prefix(40))
        }
        return string
    }
    
    var firebaseValue: String {
        var string = self
        if string.count > 100 {
            string = String(string.prefix(100))
        }
        return string
    }
}

extension RSFirebaseDestination {
    var TRACK_RESERVED_KEYWORDS: [String] {
        return ["product_id", "name", "category", "quantity", "price", "currency", "value", "revenue", "total", "tax", "shipping", "coupon", "cart_id", "payment_method", "query", "list_id", "promotion_id", "creative", "affiliation", "share_via", "products", AnalyticsParameterScreenName]
    }
    
    var IDENTIFY_RESERVED_KEYWORDS: [String] {
        return ["age", "gender", "interest"]
    }
        
    func getFirebaseECommerceEvent(from rudderEvent: String) -> String? {
        switch rudderEvent {
        case RSEvents.Ecommerce.paymentInfoEntered: return AnalyticsEventAddPaymentInfo
        case RSEvents.Ecommerce.productAdded: return AnalyticsEventAddToCart
        case RSEvents.Ecommerce.productAddedToWishList: return AnalyticsEventAddToWishlist
        case RSEvents.Ecommerce.checkoutStarted: return AnalyticsEventBeginCheckout
        case RSEvents.Ecommerce.orderCompleted: return AnalyticsEventPurchase
        case RSEvents.Ecommerce.orderRefunded: return AnalyticsEventRefund
        case RSEvents.Ecommerce.productsSearched: return AnalyticsEventSearch
        case RSEvents.Ecommerce.cartShared: return AnalyticsEventShare
        case RSEvents.Ecommerce.productShared: return AnalyticsEventShare
        case RSEvents.Ecommerce.productViewed: return AnalyticsEventViewItem
        case RSEvents.Ecommerce.productListViewed: return AnalyticsEventViewItemList
        case RSEvents.Ecommerce.productRemoved: return AnalyticsEventRemoveFromCart
        case RSEvents.Ecommerce.productClicked: return AnalyticsEventSelectContent
        case RSEvents.Ecommerce.promotionViewed: return AnalyticsEventViewPromotion
        case RSEvents.Ecommerce.promotionClicked: return AnalyticsEventSelectPromotion
        case RSEvents.Ecommerce.cartViewed: return AnalyticsEventViewCart
        default: return nil
        }
    }
    
    func getFirebaseECommerceParameter(from rudderEvent: String) -> String? {
        switch rudderEvent {
        case "payment_method": return AnalyticsParameterPaymentType
        case "coupon": return AnalyticsParameterCoupon
        case "query": return AnalyticsParameterSearchTerm
        case "list_id": return AnalyticsParameterItemListID
        case "promotion_id": return AnalyticsParameterPromotionID
        case "creative": return AnalyticsParameterCreativeName
        case "affiliation": return AnalyticsParameterAffiliation
        case "share_via": return AnalyticsParameterMethod
        default: return nil
        }
    }
        
    func extractTraits(traits: [String: Any]?) -> [String: String]? {
        var params: [String: String]?
        if let traits = traits {
            params = [String: String]()
            for (key, value) in traits {
                switch value {
                case let v as String:
                    params?[key] = v
                case let v as NSNumber:
                    params?[key] = "\(v)"
                case let v as Bool:
                    params?[key] = "\(v)"
                default:
                    break
                }
            }
        }
        return params
    }
    
    func insertECommerceData(params: inout [String: Any]?, properties: [String: Any]) {
        if let revenue = properties["revenue"] {
            params?[AnalyticsParameterValue] = Double("\(revenue)")
        } else if let value = properties["value"] {
            params?[AnalyticsParameterValue] = Double("\(value)")
        } else if let total = properties["total"] {
            params?[AnalyticsParameterValue] = Double("\(total)")
        }
        
        if let currency = properties["currency"] {
            params?[AnalyticsParameterCurrency] = "\(currency)"
        } else {
            params?[AnalyticsParameterCurrency] = "USD"
        }
        
        if let shipping = properties["shipping"] {
            params?[AnalyticsParameterShipping] = Double("\(shipping)")
        }
        
        if let tax = properties["tax"] {
            params?[AnalyticsParameterTax] = Double("\(tax)")
        }
        
        for (key, value) in properties {
            if let key = getFirebaseECommerceParameter(from: key) {
                params?[key] = "\(value)"
            }
        }
    }
    
    func insertECommerceProductData(params: inout [String: Any]?, properties: [String: Any]) {
        
        func handleProductData(productList: inout [[String: Any]], product: [String: Any]) {
            var params = [String: Any]()
            for (key, value) in product {
                switch key {
                case "product_id":
                    params[AnalyticsParameterItemID] = "\(value)"
                case "name":
                    params[AnalyticsParameterItemName] = "\(value)"
                case "category":
                    params[AnalyticsParameterItemCategory] = "\(value)"
                case "quantity":
                    params[AnalyticsParameterQuantity] = Int("\(value)")
                case "price":
                    params[AnalyticsParameterPrice] = Double("\(value)")
                default:
                    break
                }
            }
            if !params.isEmpty {
                productList.append(params)
            }
        }
        var productList = [[String: Any]]()
        if let products = properties["products"] as? [[String: Any]] {
            for product in products {
                handleProductData(productList: &productList, product: product)
            }
        } else {
            handleProductData(productList: &productList, product: properties)
        }
        if !productList.isEmpty {
            params?[AnalyticsParameterItems] = productList
        }
    }
    
    func insertCustomPropertiesData(params: inout [String: Any]?, properties: [String: Any]) {
        for (key, value) in properties {
            let firebaseKey = key.firebaseEvent
            if TRACK_RESERVED_KEYWORDS.contains(firebaseKey) {
                continue
            }
            switch value {
            case let v as String:
                params?[firebaseKey] = v.firebaseValue
            case let v as Int:
                params?[firebaseKey] = Double(v)
            case let v as Double:
                params?[firebaseKey] = v
            default:
                params?[firebaseKey] = "\(value)".firebaseValue
            }
        }
    }
}

@objc
public class RudderFirebaseDestination: RudderDestination {
    
    public override init() {
        super.init()
        plugin = RSFirebaseDestination()
    }
    
}
