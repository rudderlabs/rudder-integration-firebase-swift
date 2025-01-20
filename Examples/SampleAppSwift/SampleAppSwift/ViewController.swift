//
//  ViewController.swift
//  ExampleSwift
//
//  Created by Arnab Pal on 09/05/20.
//  Copyright © 2020 RudderStack. All rights reserved.
//

import UIKit
import Rudder

struct Events {
    let name: String
    let properties: [String: Any]?
}

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let identify_events: [Events] = [Events(name: "User_id_1", properties: nil),
                                     Events(name: "test_user_id", properties: ["ios": "Display"]),
                                     Events(name: "Identity_Event_With_Hyphen_Name_Properties", properties: ["Hyphen-property": "value"])]
    
    let screen_events: [Events] = [Events(name: "Screen_1: _AppDelegate_1", properties: ["Custom_screen_property": "Custom_property_6"]), Events(name: "Screen-Event-With-Hyphen-Name-Properties", properties: ["Hyphen-property": "value"])]
    
    let track_events: [Events] = [Events(name: "Payment Info Entered", properties: [
        "payment_method": "payment_method_1",
        "coupon": "coupon_1",
        "currency": "INR",
        "revenue": 125,
        "value": 126,
        "total": 127,
        "Custom_1": "Custom_1_1",
        "Custom_2": 234.45
    ]), Events(name: "Product Added", properties: [
        "Custom_value_4": "Custom_Track_Call_4",
        "product_id": "product_id_4",
        "currency": "INR",
        "price": NSNumber(value: 4000),
        "quantity": NSNumber(value: 400),
        "category": "category_4",
        "extra": "extra_4",
        "value": NSNumber(value: 124),
        "total": NSNumber(value: 125)
    ]), Events(name: "Product Added to Wishlist", properties: [
        "Custom_value_4": "Custom_Track_Call_4",
        "product_id": "product_id_4",
        "currency": "INR",
        "price": NSNumber(value: 4000),
        "quantity": NSNumber(value: 400),
        "category": "category_4",
        "extra": "extra_4",
        "value": "124",
        "total": NSNumber(value: 125)
    ]), Events(name: "Checkout Started", properties: [
        "Custom_value_4": "Custom_Track_Call_4",
        "products": [[
            "product_id": "product_id_1_11",
            "name": "name_11",
            "price": NSNumber(value: 1000),
            "quantity": NSNumber(value: 100),
            "category": "category_1",
            "extra": "extra_1"
        ], [
            "product_id": "product_id_22",
            "name": "name_22",
            "price": "2000",
            "quantity": "200",
            "category": "category_2",
            "extra": "extra_2"
        ]],
        "value": NSNumber(value: 124.23),
        "total": NSNumber(value: 125),
        "coupon": "Off-100%"
    ]), Events(name: "Order Completed", properties: [
        "Custom_value_4": "Custom_Track_Call_4",
        "products": [[
            "product_id": "product_id_1",
            "name": "name_1",
            "price": NSNumber(value: 1000),
            "quantity": NSNumber(value: 100),
            "category": "category_1",
            "extra": "extra_1"
        ], [
            "product_id": "product_id_2",
            "name": "name_2",
            "price": NSNumber(value: 2000),
            "quantity": NSNumber(value: 200),
            "category": "category_2",
            "extra": "extra_2"
        ]],
        "revenue": "123.56",
        "value": NSNumber(value: 124),
        "total": NSNumber(value: 125),
        "coupon": "Off-100%",
        "affiliation": "affiliation_1",
        "shipping": NSNumber(value: 126),
        "tax": NSNumber(value: 127),
        "order_id": "order_id_1"
    ]), Events(name: "Order Refunded", properties: [
        "Custom_value_4": "Custom_Track_Call_4",
        "products": [[
            "product_id": "product_id_1",
            "name": "name_1",
            "price": NSNumber(value: 1000),
            "quantity": NSNumber(value: 100),
            "category": "category_1",
            "extra": "extra_1"
        ], [
            "product_id": "product_id_2",
            "name": "name_2",
            "price": NSNumber(value: 2000),
            "quantity": NSNumber(value: 200),
            "category": "category_2",
            "extra": "extra_2"
        ]],
        "revenue": "123",
        "value": NSNumber(value: 124),
        "total": NSNumber(value: 125),
        "coupon": NSNumber(value: 100),
        "affiliation": "affiliation_1",
        "shipping": NSNumber(value: 126),
        "tax": NSNumber(value: 127),
        "order_id": "transaction_1"
    ]), Events(name: "Products Searched", properties: [
        "Custom_value_4": "Custom_Track_Call_4",
        "query": "www.google.com",
        "extra": NSNumber(value: 567.67)
    ]), Events(name: "Cart Shared", properties: [
        "Custom_value_4": "Custom_Track_Call_4",
        "cart_id": "order_id_1",
        "share_via": "share_via_1",
        "extra": NSNumber(value: 567.67)
    ]), Events(name: "Product Shared", properties: [
        "Custom_value_4": "Custom_Track_Call_4",
        "share_via": "share_via_1",
        "cart_id": "order_id_1"
    ]), Events(name: "Product Viewed", properties: [
        "Custom_value_4": "Custom_Track_Call_4",
        "currency": "INR",
        "price": NSNumber(value: 4000),
        "quantity": NSNumber(value: 400),
        "category": "category_4",
        "extra": "extra_4",
        "revenue": "123",
        "value": NSNumber(value: 124),
        "total": NSNumber(value: 125)
    ]), Events(name: "Product List Viewed", properties: [
        "Custom_value_4": "Custom_Track_Call_4",
        "products": [[
            "product_id": "product_id_1",
            "name": "name_1",
            "price": NSNumber(value: 1000),
            "quantity": NSNumber(value: 100),
            "category": "category_1",
            "extra": "extra_1"
        ], [
            "product_id": "product_id_2",
            "name": "name_2",
            "price": NSNumber(value: 2000),
            "quantity": NSNumber(value: 200),
            "category": "category_2",
            "extra": "extra_2"
        ]],
        "list_id": "list_id_1"
    ]), Events(name: "Product Removed", properties: [
        "Custom_value_4": "Custom_Track_Call_4",
        "product_id": "product_id_4",
        "currency": "INR",
        "price": NSNumber(value: 4000),
        "quantity": NSNumber(value: 400),
        "category": "category_4",
        "extra": "extra_4",
        "revenue": "123",
        "value": NSNumber(value: 124),
        "total": NSNumber(value: 125)
    ]), Events(name: "Product Clicked", properties: [
        "Custom_value_4": "Custom_Track_Call_4",
        "product_id": "product_id_4"
    ]), Events(name: "Promotion Viewed", properties: [
        "Custom_value_4": "Custom_Track_Call_4",
        "creative": "creative_iOS",
        "promotion_id": "promotion_id_1",
        "name": "name_4"
    ]), Events(name: "Promotion Clicked", properties: [
        "Custom_value_4": "Custom_Track_Call_4",
        "promotion_id": "promotion_id_1",
        "creative": "creative_1",
        "name": "name_4"
    ]), Events(name: "Cart Viewed", properties: [
        "Custom_value_4": "Custom_Track_Call_4",
        "products": [[
            "product_id": "product_id_1",
            "name": "name_1",
            "price": NSNumber(value: 1000),
            "quantity": NSNumber(value: 100),
            "category": "category_1",
            "extra": "extra_1"
        ], [
            "product_id": "product_id_2",
            "name": "name_2",
            "price": NSNumber(value: 2000),
            "quantity": NSNumber(value: 200),
            "category": "category_2",
            "extra": "extra_2"
        ]],
        "revenue": "123",
        "value": NSNumber(value: 124),
        "total": NSNumber(value: 125)
    ]), Events(name: "Custom_Track_Call", properties: [
        "Custom_track_value_1_askasakjaldjladjaljdaljdajdaldjaljladjladjaljdaljdaljd": "Custom_Track_Call_6"
    ]), Events(name: "Track-Event-With-Hyphen", properties: nil), Events(name: "Track event with hyphen properties", properties: ["key1": "value1", "KEY_2": 127, "KEY_3": true])]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension ViewController {
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
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Identify"
        case 1:
            return "Screen"
        case 2:
            return "Track"
        default:
            return nil
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return identify_events.count
        case 1:
            return screen_events.count
        case 2:
            return track_events.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let section: Int = indexPath.section
        let item = section == 0 ? identify_events[indexPath.row] :
        (section == 1 ? screen_events[indexPath.row] : track_events[indexPath.row])
        
        cell.textLabel?.text = item.name
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let client: RSClient? = RSClient.sharedInstance()
        
        switch indexPath.section {
        case 0:
            let item = identify_events[indexPath.row]
            if let properties = item.properties {
                client?.identify(item.name, traits: properties)
            } else {
                client?.identify(item.name)
            }
            
        case 1:
            let item = screen_events[indexPath.row]
            if let properties = extractTraits(traits: item.properties) {
                client?.screen(item.name, properties: properties)
            } else {
                client?.screen(item.name)
            }
            
        case 2:
            let item = track_events[indexPath.row]
            if let properties = item.properties {
                client?.track(item.name, properties: properties)
            } else {
                client?.track(item.name)
            }
            
        default:
            break
        }
    }
}
