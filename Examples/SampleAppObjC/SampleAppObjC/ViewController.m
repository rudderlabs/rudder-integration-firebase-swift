//
//  ViewController.m
//  SampleAppObjC
//
//  Created by Pallab Maiti on 11/03/22.
//

#import "ViewController.h"
#import "Rudder/Rudder-Swift.h"

@interface ViewController ()

@end

@implementation ViewController

RSClient *client;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    client = [RSClient sharedInstance];
    [self identyfy];
    [self productListViewedEvent];
    
}

-(void)identyfy{
    NSMutableDictionary<NSString *,NSObject *> *traits = [[NSMutableDictionary alloc] init];
    [traits setValue:@"random@example.com" forKey:@"email"];
    [traits setValue:@"FirstName" forKey:@"fname"];
    [traits setValue:@"LastName" forKey:@"lname"];
    [traits setValue:@"1234567890" forKey:@"phone"];
    [client identify:@"i12345" traits:traits];
}

-(void)productListViewedEvent{
    NSMutableDictionary<NSString *,NSObject *> *properties = [[NSMutableDictionary alloc] initWithDictionary:[self getStandardAndCustomProperties]];
    [properties setValue:[self getMultipleProducts] forKey:@"products"];
    [client track:@"Product List Viewed" properties:properties];
}

-(NSMutableArray *) getMultipleProducts {
    NSMutableDictionary *product1 = [[NSMutableDictionary alloc] init];
    [product1 setObject:@"RSPro1" forKey:@"product_id"];
    [product1 setObject:@"RSMonopoly1" forKey:@"name"];
    [product1 setObject:@(1000.2) forKey:@"price"];
    [product1 setObject:@"100" forKey:@"quantity"];
    [product1 setObject:@"RSCat1" forKey:@"category"];
    
    NSMutableDictionary *product2 = [[NSMutableDictionary alloc] init];
    [product2 setObject:@"Pro2" forKey:@"product_id"];
    [product2 setObject:@"Games2" forKey:@"name"];
    [product2 setObject:@"2000.20" forKey:@"price"];
    [product2 setObject:@(200) forKey:@"quantity"];
    [product2 setObject:@"RSCat2" forKey:@"category"];
    
    NSMutableArray *products = [[NSMutableArray alloc] init];
    [products addObject:product1];
    [products addObject:product2];
    
    return products;
}

-(NSMutableDictionary<NSString *,NSObject *> *) getStandardAndCustomProperties {
    NSMutableDictionary<NSString *,NSObject *> *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:@(100.0) forKey:@"revenue"];
    [properties setValue:@"payment type 1" forKey:@"payment_method"];
    [properties setValue:@"100% off coupon" forKey:@"coupon"];
    [properties setValue:@"Search query" forKey:@"query"];
    [properties setValue:@"item list id 1" forKey:@"list_id"];
    [properties setValue:@"promotion id 1" forKey:@"promotion_id"];
    [properties setValue:@"creative name 1" forKey:@"creative"];
    [properties setValue:@"affiliation value 1" forKey:@"affiliation"];
    [properties setValue:@"method 1" forKey:@"share_via"];
    [properties setValue:@"INR" forKey:@"currency"];
    [properties setValue:@"500" forKey:@"shipping"];
    [properties setValue:@(15) forKey:@"tax"];
    [properties setValue:@"transaction id 1" forKey:@"order_id"];
    [properties setValue:@"value 1" forKey:@"key1"];
    [properties setValue:@(100) forKey:@"key2"];
    [properties setValue:@(200.25) forKey:@"key3"];
    
    return  properties;
}

@end
