#
# Be sure to run `pod lib lint dojo-ios-sdk.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'dojo-ios-sdk'
  s.version          = '1.4.3'
  s.summary          = 'Dojo Payment SDK'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

Minimum iOS version: 11.0

## Installation

dojo-ios-sdk is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'dojo-ios-sdk', :git => 'git@github.com:Dojo-Engineering/dojo-ios-sdk.git', :tag => '1.0.0'
```
## How to use
SDK functionality can be accessed via DojoSdk object.

## Swift

### Card payment
```swift
import dojo_ios_sdk

let cardPaymentPayload = DojoCardPaymentPayload(cardDetails: DojoCardDetails(cardNumber: "4456530000001096", cardName: "Card Holder Name", expiryDate: "12 / 24", cv2: "020"))
let token = "Token from Payment Intent (connecteToken)"
DojoSDK.executeCardPayment(token: token,
                            payload: cardPaymentPayload,
                            fromViewController: self) { [weak self] result in
    print(result)
}
```
This example includes only required fields, you can find additional fields that can be passed in the API reference.

### ApplePay Payment
```swift
import dojo_ios_sdk

let applePayConfig = DojoApplePayConfig(merchantIdentifier:"merchant.uk.co.paymentsense.sdk.demo.app",  supportedCards: ["visa","mastercard", "amex", "maestro"])
let applePayPayload = DojoApplePayPayload(applePayConfig: applePayConfig)
let paymentIntent = DojoPaymentIntent(id: "Payment intent ID", totalAmount: DojoPaymentIntentAmount(value: 120, currencyCode: "GBP"))
DojoSDK.executeApplePayPayment(paymentIntent: paymentIntent, payload: applePayPayload, fromViewController: self) { [weak self] result in
    print(result)
}
```
This example includes only required fields, you can find additional fields that can be passed in the API reference.

## Objective-C

### Card payment

```
#import <dojo_ios_sdk/dojo_ios_sdk-Swift.h>

DojoCardPaymentPayload* cardPaymentPayload = [[DojoCardPaymentPayload alloc]
                                                initWithCardDetails: [[DojoCardDetails alloc]
                                                                    initWithCardNumber:@"4456530000001096"
                                                                    cardName:@"Card Holder Name"
                                                                    expiryDate:@"12 / 24"
                                                                    cv2:@"020"]
                                                userEmailAddress: NULL
                                                userPhoneNumber: NULL
                                                billingAddress: NULL
                                                shippingDetails: NULL
                                                metaData: NULL
                                                savePaymentMethod: FALSE];
NSString *token = @"Token from Payment Intent";
[DojoSDK executeCardPaymentWithToken: token payload: cardPaymentPayload fromViewController: self completion:^(NSInteger result) {
    NSLog(@"%ld", (long)result);
}];
```

### ApplePay Payment

```
#import <dojo_ios_sdk/dojo_ios_sdk-Swift.h>

DojoApplePayConfig *applePayConfig = [[DojoApplePayConfig alloc] initWithMerchantIdentifier: @"merchant.uk.co.paymentsense.sdk.demo.app"
                                                                            supportedCards: [NSArray arrayWithObjects: @"visa", @"mastercard", nil]
                                                                        collectBillingAddress: FALSE
                                                                        collectShippingAddress: FALSE
                                                                                collectEmail: FALSE];
DojoApplePayPayload *applePayPayload = [[DojoApplePayPayload alloc] initWithApplePayConfig: applePayConfig userEmailAddress: NULL metaData: NULL];
DojoPaymentIntent *paymentIntent = [[DojoPaymentIntent alloc]  initWithId: @"PaymentIntent ID" clientSessionSecret: @"Token from Payment Intent" totalAmount: [[DojoPaymentIntentAmount alloc] initWithValue: 120 currencyCode:@"GBP"]];
    
[DojoSDK executeApplePayPaymentWithPaymentIntent: paymentIntent payload: applePayPayload fromViewController:self completion: ^(NSInteger result) {
    NSLog(@"%ld", (long)result);
}];
```

This example includes only required fields, you can find additional fields that can be passed in the API reference.


## Result codes

```
successful = 0
authorizing = 3
referred = 4
declined = 5
duplicateTransaction = 20
failed = 30
waitingPreExecute = 99
invalidRequest = 400
issueWithAccessToken = 401
noAccessTokenSupplied = 404
internalServerError = 500
            
sdkInternalError = 7770
```

## License

dojo-ios-sdk is available under the MIT license. See the LICENSE file for more info.
                       DESC

  s.homepage         = 'https://github.com/dojo-engineering/dojo-ios-sdk'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Dojo' => 'deniss.kaibagarovs@paymentsense.com' }
  s.source           = { :git => 'https://github.com/dojo-engineering/dojo-ios-sdk.git', :tag => s.version }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'

  s.source_files = 'Sources/dojo-ios-sdk/Classes/**/*'
  s.public_header_files = 'Sources/dojo-ios-sdk/Classes/**/*.h'
  
  s.test_spec 'dojo-ios-sdk-tests' do |test_spec|
      test_spec.source_files = 'Sources/dojo-ios-sdk/Tests/**/*'
  end
  # s.ios.vendored_frameworks = 'dojo-ios-sdk/Libs/**/*'
  
  # s.resource_bundles = {
  #   'dojo-ios-sdk' => ['dojo-ios-sdk/Assets/*.png']
  # }

   
  s.ios.vendored_frameworks = 'Sources/dojo-ios-sdk/Libs/CardinalMobile.xcframework'
end
