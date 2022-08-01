//
//  ViewController.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 03/06/2022.
//  Copyright (c) 2022 Deniss Kaibagarovs. All rights reserved.
//

import UIKit
import dojo_ios_sdk
import PassKit

class ViewController: UIViewController {
    
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var switchIsSandbox: UISwitch!
    @IBOutlet weak var buttonApplePay: PKPaymentButton!
    private let tableViewItems: [InputTableViewCellType] = [.token, .cardholderName, .cardNumber, .expiry, .cvv, .collectBillingForApplePay, .collectShippingForApplePay, .collectEmailForApplePay]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        InputTableViewCell.register(tableView: mainTableView)
        setupApplePayButton()
    }
    
    func setupApplePayButton() {
        buttonApplePay.setTitle("", for: .normal)
        buttonApplePay.addTarget(self, action: #selector(onApplePayPaymentPress), for: .touchUpInside)
    }
    
    @IBAction func onStartCardPaymentPress(_ sender: Any) {
        let cardPaymentPayload = DojoCardPaymentPayload(cardDetails: getCardDetails(), isSandbox: switchIsSandbox.isOn)
        showLoadingIndicator()
        requestPaymentToken { token in
            DojoSDK.executeCardPayment(token: token,
                                     payload: cardPaymentPayload,
                                     fromViewController: self) { [weak self] result in
                self?.hideLoadingIndicator()
                self?.showAlert(result)
            }
        }
    }
    
    @IBAction func onAutofillPress(_ sender: UIButton) {
        autofill(AutofillType(rawValue:  sender.tag)!)
    }
    
    @IBAction func onApplePayPaymentPress(_ sender: Any) {
        print("startApplePay")
        
        let token = getToken()
//        let token = ""
        let paymentIntent = DojoPaymentIntent(connecteToken: token,
                                              totalAmount: DojoPaymentIntentAmount(value: 10, currencyCode: "GBP"))
        guard DojoSDK.isApplePayAvailable(paymentIntent: paymentIntent) else {
            let alert = UIAlertController(title: "", message: "ApplePay is not available for this device or supported card schemes are not present", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let applePayConfig = DojoApplePayConfig(merchantIdentifier:"merchant.uk.co.paymentsense.sdk.demo.app",
                                                collectBillingAddress: getBillingAddressSelectionForApplePay(),
                                                collectShippingAddress: getShippingAddressSelectionForApplePay(),
                                                collectEmail: getEmailAddressSelectionForApplePay())
        let applePayPayload = DojoApplePayPayload(applePayConfig: applePayConfig, isSandbox: switchIsSandbox.isOn)
        
        DojoSDK.executeApplePayPayment(paymentIntent: paymentIntent, payload: applePayPayload, fromViewController: self) { [weak self] result in
            print("finished with result:")
            self?.showAlert(result)
        }
    }
    
    private func showAlert(_ resultCode: Int) {
        var title = ""
        switch resultCode {
        case 0:
            title = "Success"
        default:
            title = "Other Error"
        }
        let alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDataSource {
    
    func getCardDetails() -> DojoCardDetails {
        var cardNumber: String = ""
        var cardholderName: String = ""
        var expiryDate: String = ""
        var cvv: String = ""
        
        mainTableView.visibleCells.forEach({ cell in
            if let cell = cell as? InputTableViewCell {
                switch cell.inputType {
                case .cardholderName:
                    cardholderName = cell.getValue()
                case .cardNumber:
                    cardNumber = cell.getValue()
                case .expiry:
                    expiryDate = cell.getValue()
                case .cvv:
                    cvv = cell.getValue()
                default:
                    break
                }
            }
        })
        
        return DojoCardDetails(cardNumber: cardNumber,
                               cardName: cardholderName,
                               expiryDate: expiryDate,
                               cv2: cvv)
    }
    
    func getToken() -> String {
        (mainTableView.visibleCells.first(where: { ($0 as? InputTableViewCell)?.inputType == .token}) as? InputTableViewCell)?.getValue() ?? ""
    }
    
    func getShippingAddressSelectionForApplePay() -> Bool {
        (mainTableView.visibleCells.first(where: { ($0 as? InputTableViewCell)?.inputType == .collectShippingForApplePay}) as? InputTableViewCell)?.getSwitchValue() ?? false
    }
    
    func getBillingAddressSelectionForApplePay() -> Bool {
        (mainTableView.visibleCells.first(where: { ($0 as? InputTableViewCell)?.inputType == .collectBillingForApplePay}) as? InputTableViewCell)?.getSwitchValue() ?? false
    }
    
    func getEmailAddressSelectionForApplePay() -> Bool {
        (mainTableView.visibleCells.first(where: { ($0 as? InputTableViewCell)?.inputType == .collectEmailForApplePay}) as? InputTableViewCell)?.getSwitchValue() ?? false
    }
    
    func autofill(_ type: AutofillType) {
        mainTableView.visibleCells.forEach({ cell in
            if let cell = cell as? InputTableViewCell {
                switch cell.inputType {
                case .cardholderName:
                    cell.setValue(type.getCardHolderName())
                case .cardNumber:
                    cell.setValue(type.getCardNumber())
                case .expiry:
                    cell.setValue(type.getExpiry())
                case .cvv:
                    cell.setValue(type.getCVV())
                default:
                    break
                }
            }
        })
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableViewItems.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: InputTableViewCell.identifier, for: indexPath) as? InputTableViewCell {
            cell.setup(tableViewItems[indexPath.row])
            return cell
        } else {
            return UITableViewCell.init(style: .default, reuseIdentifier: "") // Shouldn't happen
        }
    }
}

extension UIViewController {
    func showLoadingIndicator() {
        let spinnerView = UIView.init(frame: view.bounds)
        spinnerView.tag = 1984
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            self.view.addSubview(spinnerView)
        }
    }
    
    func hideLoadingIndicator() {
        DispatchQueue.main.async {
            if let loadingView = self.view.subviews.first(where: {$0.tag  == 1984}) {
                loadingView.removeFromSuperview()
            }
        }
    }
}

enum AutofillType: Int {
    case threeDS2 = 0
    case threeDS1 = 1
    case noneThreeDS = 2
    case decline = 3
    
    func getCardNumber() -> String {
        switch self {
        case .threeDS2:
            return "4456530000001096"
        case .threeDS1:
            return "4456530000000007"
        case .noneThreeDS:
            return "5200000000000056"
        case .decline:
            return "4456530000001013"
        }
    }
    
    func getCardHolderName() -> String {
        "Card holder"
    }
    
    func getExpiry() -> String {
        "12 / 24"
    }
    
    func getCVV() -> String {
        switch self {
        case .threeDS2:
            return "020"
        case .threeDS1:
            return "020"
        case .noneThreeDS:
            return "341"
        case .decline:
            return "341"
        }
    }
}

extension UIViewController {
    
    func requestPaymentToken(completion: ((String) -> Void)?) {
        let url = URL(string: "http://localhost:3000/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let token = String(decoding: data, as: UTF8.self)
                completion?(token)
            } else if let error = error {
                print("HTTP Request Failed \(error)")
            }
        }
        
        task.resume()
    }
}

