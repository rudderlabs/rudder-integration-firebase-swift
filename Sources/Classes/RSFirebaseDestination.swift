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
        if let traits = message.traits {
            for key in traits.keys {
                if key == "userId" {
                    continue
                }
                let firebaseKey = RSFirebaseDestination.getTrimKey(key)
                client?.log(message: "Setting userProperty to Firebase: \(firebaseKey)", logLevel: .debug)
                FirebaseAnalytics.Analytics.setUserProperty(traits[key], forName: firebaseKey)
            }
        }
        return message
    }
    
    func track(message: TrackMessage) -> TrackMessage? {
        var firebaseEvent: String?
        var params: [String: Any]?
        if let rudderEvent = message.event {
            if rudderEvent == "Application Opened" {
                firebaseEvent = AnalyticsEventAppOpen
            } else if let event = RSFirebaseDestination.getFirebaseECommerceEvent(from: rudderEvent) {
                firebaseEvent = event
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
                case RSECommerceConstants.ECommProductShared:
                    params?[AnalyticsParameterContentType] = "product"
                case RSECommerceConstants.ECommCartShared:
                    params?[AnalyticsParameterContentType] = "cart"
                case AnalyticsEventSelectContent:
                    if let productId = message.properties?["product_id"] {
                        params?[AnalyticsParameterItemID] = productId
                    }
                    params?[AnalyticsParameterContentType] = "product"
                default:
                    break
                }
            } else {
                firebaseEvent = RSFirebaseDestination.getTrimKey(rudderEvent)
            }
            if let event = firebaseEvent {
                if let properties = message.properties {
                    params?.merge(dict: RSFirebaseDestination.configure(properties: properties))
                }
                FirebaseAnalytics.Analytics.logEvent(event, parameters: params)
            }
        }
        return message
    }
    
    func screen(message: ScreenMessage) -> ScreenMessage? {
        if let event = message.name, event.count > 0 {
            var params: [String: Any] = [AnalyticsParameterScreenName: event]
            if let properties = message.properties {
                params.merge(dict: RSFirebaseDestination.configure(properties: properties))
            }
            FirebaseAnalytics.Analytics.logEvent(AnalyticsEventScreenView, parameters: params)
        }
        return message
    }
}

// MARK: - Support methods

extension Dictionary {
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}

extension RSFirebaseDestination {
    static let TRACK_RESERVED_KEYWORDS = ["product_id", "name", "category", "quantity", "price", "currency", "value", "revenue", "total", "tax", "shipping", "coupon", "cart_id", "payment_method", "query", "list_id", "promotion_id", "creative", "affiliation", "share_via", "products", AnalyticsParameterScreenName]
    
    static func getTrimKey(_ key: String) -> String {
        return key.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).replacingOccurrences(of: " ", with: "_")
    }
    
    static func configure(properties: [String: Any]) -> [String: Any] {
        var params: [String: Any] = [:]
        for key in properties.keys {
            let firebaseKey = getTrimKey(key)
            if TRACK_RESERVED_KEYWORDS.contains(firebaseKey) {
                continue
            }
            params[firebaseKey] = properties[key]
        }
        return params
    }
    
    static func getFirebaseECommerceEvent(from rudderEvent: String) -> String? {
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
}

@objc
public class RudderFirebaseDestination: RudderDestination {
    
    public override init() {
        super.init()
        plugin = RSFirebaseDestination()
    }
    
}
