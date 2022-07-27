//
//  ViewController.m
//  dojo-ios-sdk-Example-Objc
//
//  Created by Deniss Kaibagarovs on 08/03/2022.
//

#import "ViewController.h"
#import <dojo_ios_sdk/dojo_ios_sdk-Swift.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment to test
//    [self executeCardPayment];
//    [self executeApplePayPayment];
}

- (void)executeCardPayment {
    DojoCardPaymentPayload* cardPaymentPayload = [[DojoCardPaymentPayload alloc]
                                                  initWithCardDetails: [[DojoCardDetails alloc]
                                                                        initWithCardNumber:@"4456530000001096"
                                                                        cardName:@"Card Holder Name"
                                                                        expiryDate:@"12/24"
                                                                        cv2:@"020"]
                                                  userEmailAddress: NULL
                                                  userPhoneNumber: NULL
                                                  billingAddress: NULL
                                                  shippingDetails: NULL
                                                  metaData: NULL
                                                  isSandbox: NO];
    NSString *token = @"Token from Payment Intent (connecteToken)";
    [DojoSDK executeCardPaymentWithToken: token payload: cardPaymentPayload fromViewController: self completion:^(NSInteger result) {
        NSLog(@"%ld", (long)result);
    }];
}

- (void)executeApplePayPayment {
    DojoApplePayConfig *applePayConfig = [[DojoApplePayConfig alloc] initWithMerchantIdentifier: @"merchant.uk.co.paymentsense.sdk.demo.app"
                                                                          collectBillingAddress: FALSE
                                                                         collectShippingAddress: FALSE
                                                                                   collectEmail: FALSE];
    DojoApplePayPayload *applePayPayload = [[DojoApplePayPayload alloc] initWithApplePayConfig: applePayConfig email: NULL metaData: NULL isSandbox: NO];
    DojoPaymentIntent *paymentIntent = [[DojoPaymentIntent alloc] initWithConnecteToken: @"Token from Payment Intent (connecteToken)" totalAmount: [[DojoPaymentIntentAmount alloc] initWithValue: 120 currencyCode:@"GBP"]];  // TODO move to Swift as well
    
    [DojoSDK executeApplePayPaymentWithPaymentIntent: paymentIntent payload: applePayPayload fromViewController:self completion: ^(NSInteger result) {
        NSLog(@"%ld", (long)result);
    }];
}

@end
