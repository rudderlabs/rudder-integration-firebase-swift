<p align="center">
  <a href="https://rudderstack.com/">
    <img src="https://user-images.githubusercontent.com/59817155/121357083-1c571300-c94f-11eb-8cc7-ce6df13855c9.png">
  </a>
</p>

<p align="center"><b>The Customer Data Platform for Developers</b></p>

<p align="center">
  <a href="https://cocoapods.org/pods/Rudder">
    <img src="https://img.shields.io/cocoapods/v/RudderStack.svg?style=flat">
    </a>
</p>

<p align="center">
  <b>
    <a href="https://rudderstack.com">Website</a>
    ·
    <a href="https://rudderstack.com/docs/stream-sources/rudderstack-sdk-integration-guides/rudderstack-swift-sdk/">Documentation</a>
    ·
    <a href="https://rudderstack.com/join-rudderstack-slack-community">Community Slack</a>
  </b>
</p>

---
# What is RudderStack?

[RudderStack](https://rudderstack.com/) is a **customer data pipeline tool** for collecting, routing and processing data from your websites, apps, cloud tools, and data warehouse.

With RudderStack, you can build customer data pipelines that connect your whole customer data stack and then make them smarter by triggering enrichment and activation in customer tools based on analysis in your data warehouse. Its easy-to-use SDKs and event source integrations, Cloud Extract integrations, transformations, and expansive library of destination and warehouse integrations makes building customer data pipelines for both event streaming and cloud-to-warehouse ELT simple. 

| Try **RudderStack Cloud Free** - a no time limit, no credit card required, completely free tier of [RudderStack Cloud](https://resources.rudderstack.com/rudderstack-cloud). Click [here](https://app.rudderlabs.com/signup?type=freetrial) to start building a smarter customer data pipeline today, with RudderStack Cloud Free. |
|:------|

Questions? Please join our [Slack channel](https://resources.rudderstack.com/join-rudderstack-slack) or read about us on [Product Hunt](https://www.producthunt.com/posts/rudderstack).

## Integrating Firebase with the RudderStack iOS SDK

1. Add [Firebase](http://firebase.google.com) as a destination in the [RudderStack dashboard](https://app.rudderstack.com/).

2. RudderFirebase is available through [CocoaPods](https://cocoapods.org). To install it, add the following line to your Podfile and followed by `pod install`:

```ruby
pod 'RudderFirebase'
```

3. Download the `GoogleService-Info.plist` from your Firebase console and put it in your project.

## Initializing ```RSClient```

Put this code in your ```AppDelegate``` under the method ```didFinishLaunchingWithOptions```
##### Objective C
```objective-c
RSConfig *config = [[RSConfig alloc] initWithWriteKey:WRITE_KEY];
[config dataPlaneURL:DATA_PLANE_URL];
[[RSClient sharedInstance] configureWith:config];
[[RSClient sharedInstance] addDestination:[[RudderFirebaseDestination alloc] init]];
```
##### Swift
```swift
let config: RSConfig = RSConfig(writeKey: WRITE_KEY)
            .dataPlaneURL(DATA_PLANE_URL)
RSClient.sharedInstance().configure(with: config)
RSClient.sharedInstance().addDestination(RudderFirebaseDestination())
```

## Sending Events

Follow the steps from the [RudderStack Swift SDK](https://github.com/rudderlabs/rudder-sdk-ios/tree/master-v2#sending-events) repo.

## Contact Us

If you come across any issues while configuring or using this integration, please feel free to start a conversation on our [Slack](https://resources.rudderstack.com/join-rudderstack-slack) channel. We will be happy to help you.
