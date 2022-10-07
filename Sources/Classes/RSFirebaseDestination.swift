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
        if FirebaseApp.app() != nil {
            client?.log(message: "Firebase already configured.", logLevel: .debug)
        } else {
            FirebaseApp.configure()
        }
    }
    
    func identify(message: IdentifyMessage) -> IdentifyMessage? {
        if let userId = message.userId, !userId.isEmpty {
            FirebaseAnalytics.Analytics.setUserID(userId)
            client?.log(message: "Setting userId to firebase", logLevel: .debug)
        }
        if let traits = extractTraits(traits: message.traits) {
            for (key, value) in traits {
                if key == RSKeys.Identify.userId {
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
    
    func track(message: TrackMessage) -> TrackMessage? { // swiftlint:disable:this cyclomatic_complexity
        var firebaseEvent: String?
        var params: [String: Any]? = [String: Any]()
        if message.event == RSEvents.LifeCycle.applicationOpened {
            firebaseEvent = AnalyticsEventAppOpen
        } else if let event = getFirebaseECommerceEvent(from: message.event) {
            firebaseEvent = event
            var productsNeedToBeAdded = false
            switch firebaseEvent {
            case AnalyticsEventShare:
                if let cartId = message.properties?[RSKeys.Ecommerce.cartId] {
                    params?[AnalyticsParameterItemID] = cartId
                } else if let productId = message.properties?[RSKeys.Ecommerce.productId] {
                    params?[AnalyticsParameterItemID] = productId
                }
            case AnalyticsEventViewPromotion, AnalyticsEventSelectPromotion:
                if let name = message.properties?[RSKeys.Ecommerce.productName] {
                    params?[AnalyticsParameterPromotionName] = name
                }
            case AnalyticsEventSelectContent:
                if let productId = message.properties?[RSKeys.Ecommerce.productId] {
                    params?[AnalyticsParameterItemID] = productId
                }
                params?[AnalyticsParameterContentType] = "product"
            case AnalyticsEventAddToCart, AnalyticsEventAddToWishlist, AnalyticsEventViewItem, AnalyticsEventRemoveFromCart, AnalyticsEventBeginCheckout, AnalyticsEventPurchase, AnalyticsEventRefund, AnalyticsEventViewItemList, AnalyticsEventViewCart: // swiftlint:disable:this line_length
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
        if !message.name.isEmpty {
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
        return [RSKeys.Ecommerce.productId, RSKeys.Ecommerce.productName, RSKeys.Ecommerce.category, RSKeys.Ecommerce.quantity, RSKeys.Ecommerce.price, RSKeys.Ecommerce.currency, RSKeys.Ecommerce.value, RSKeys.Ecommerce.revenue, RSKeys.Ecommerce.total, RSKeys.Ecommerce.tax, RSKeys.Ecommerce.shipping, RSKeys.Ecommerce.coupon, RSKeys.Ecommerce.cartId, RSKeys.Ecommerce.paymentMethod, RSKeys.Ecommerce.query, RSKeys.Ecommerce.listId, RSKeys.Ecommerce.promotionId, RSKeys.Ecommerce.creative, RSKeys.Ecommerce.affiliation, RSKeys.Other.shareVia, RSKeys.Ecommerce.products, AnalyticsParameterScreenName] // swiftlint:disable:this line_length
    }
    
    var IDENTIFY_RESERVED_KEYWORDS: [String] {
        return [RSKeys.Identify.Traits.age, RSKeys.Identify.Traits.gender, RSKeys.Other.interest]
    }
        
    func getFirebaseECommerceEvent(from rudderEvent: String) -> String? { // swiftlint:disable:this cyclomatic_complexity
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
        case RSKeys.Ecommerce.paymentMethod: return AnalyticsParameterPaymentType
        case RSKeys.Ecommerce.coupon: return AnalyticsParameterCoupon
        case RSKeys.Ecommerce.query: return AnalyticsParameterSearchTerm
        case RSKeys.Ecommerce.listId: return AnalyticsParameterItemListID
        case RSKeys.Ecommerce.promotionId: return AnalyticsParameterPromotionID
        case RSKeys.Ecommerce.creative: return AnalyticsParameterCreativeName
        case RSKeys.Ecommerce.affiliation: return AnalyticsParameterAffiliation
        case RSKeys.Other.shareVia: return AnalyticsParameterMethod
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
        if let revenue = properties[RSKeys.Ecommerce.revenue] {
            params?[AnalyticsParameterValue] = Double("\(revenue)")
        } else if let value = properties[RSKeys.Ecommerce.value] {
            params?[AnalyticsParameterValue] = Double("\(value)")
        } else if let total = properties[RSKeys.Ecommerce.total] {
            params?[AnalyticsParameterValue] = Double("\(total)")
        }
        
        if let currency = properties[RSKeys.Ecommerce.currency] {
            params?[AnalyticsParameterCurrency] = "\(currency)"
        } else {
            params?[AnalyticsParameterCurrency] = "USD"
        }
        
        if let shipping = properties[RSKeys.Ecommerce.shipping] {
            params?[AnalyticsParameterShipping] = Double("\(shipping)")
        }
        
        if let tax = properties[RSKeys.Ecommerce.tax] {
            params?[AnalyticsParameterTax] = Double("\(tax)")
        }
        
        /// To have the backward compatibility, we'll not filter `order_id` and send it as a custom event. So we're expecting two fields `order_id` and `transaction_id` in the firebase dashboard for an `order_id` key.
        if let orderId = properties[RSKeys.Ecommerce.orderId] {
            params?[AnalyticsParameterTransactionID] = "\(orderId)"
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
                case RSKeys.Ecommerce.productId:
                    params[AnalyticsParameterItemID] = "\(value)"
                case RSKeys.Other.itemName:
                    params[AnalyticsParameterItemName] = "\(value)"
                case RSKeys.Ecommerce.category:
                    params[AnalyticsParameterItemCategory] = "\(value)"
                case RSKeys.Ecommerce.quantity:
                    params[AnalyticsParameterQuantity] = Int("\(value)")
                case RSKeys.Ecommerce.price:
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
        if let products = properties[RSKeys.Ecommerce.products] as? [[String: Any]] {
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
    
    @objc
    public override init() {
        super.init()
        plugin = RSFirebaseDestination()
    }
    
}
