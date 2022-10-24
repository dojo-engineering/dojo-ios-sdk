//
//  InputTableViewCell.swift
//  dojo-ios-sdk_Example
//
//  Created by Deniss Kaibagarovs on 29/03/2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit


enum InputTableViewCellType {
    case cardholderName
    case cardNumber
    case cvv
    case expiry
    case savedCardToken
    
    case token
    case collectBillingForApplePay
    case collectShippingForApplePay
    case collectEmailForApplePay
    case fetchPaymentIntent
    case refreshPaymentIntent
    case fetchCustomerPaymentMethods
    case customerSecret
}

protocol InputTableViewCellDelegate {
    func onActionButtonPress(cell: InputTableViewCell)
}

class InputTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var textFieldInput: UITextField!
    @IBOutlet weak var selectionSwitch: UISwitch!
    @IBOutlet weak var buttonAction: UIButton!
    
    @IBOutlet weak var constraintLabelTrailing: NSLayoutConstraint!
    public static let identifier: String = "InputTableViewCell"
    public static let nib: String = "InputTableViewCell"
    
    public var inputType: InputTableViewCellType! = .token
    public var delegate: InputTableViewCellDelegate?
    
    public static func register(tableView: UITableView) {
        tableView.register(UINib(nibName: InputTableViewCell.nib,
                                 bundle: nil),
                           forCellReuseIdentifier: InputTableViewCell.identifier)
    }
    
    func setValue(_ value: String) {
        self.textFieldInput.text = value
    }
    
    func getValue() -> String {
        textFieldInput.text ?? ""
    }
    
    func getSwitchValue() -> Bool {
        selectionSwitch.isOn
    }
    
    func setup(_ type: InputTableViewCellType, delegate: InputTableViewCellDelegate?) {
        self.inputType = type
        self.delegate = delegate
        textFieldInput.delegate = self
        selectionSwitch.isHidden = true
        selectionSwitch.isOn = false
        textFieldInput.isHidden = true
        buttonAction.isHidden = true
        constraintLabelTrailing.constant = 7
        textFieldInput.placeholder = ""
        switch type {
        case .cardholderName:
            labelTitle.text = "Cardholder name"
            textFieldInput.keyboardType = .default
            textFieldInput.isHidden = false
        case .cardNumber:
            labelTitle.text = "Card number"
            textFieldInput.keyboardType = .numberPad
            textFieldInput.isHidden = false
        case .cvv:
            labelTitle.text = "CVV"
            textFieldInput.keyboardType = .numberPad
            textFieldInput.isHidden = false
        case .expiry:
            labelTitle.text = "Expiry (MM / YY)"
            textFieldInput.keyboardType = .default
            textFieldInput.isHidden = false
        case .token:
            labelTitle.text = "Token"
            textFieldInput.keyboardType = .default
            textFieldInput.isHidden = false
        case .customerSecret:
            labelTitle.text = "Customer Secret"
            textFieldInput.keyboardType = .default
            textFieldInput.isHidden = false
        case .collectBillingForApplePay:
            labelTitle.text = "Collect Billing Address for ApplePay"
            selectionSwitch.isHidden = false
        case .collectShippingForApplePay:
            labelTitle.text = "Collect Shipping Address for ApplePay"
            selectionSwitch.isHidden = false
        case .collectEmailForApplePay:
            labelTitle.text = "Collect Email for ApplePay"
            selectionSwitch.isHidden = false
        case .savedCardToken:
            labelTitle.text = "Saved Card Token"
            textFieldInput.keyboardType = .default
            textFieldInput.isHidden = false
        case .fetchPaymentIntent:
            labelTitle.text = "Fetch Payment Intent"
            constraintLabelTrailing.constant = 80
            buttonAction.isHidden = false
            textFieldInput.isHidden = false
            textFieldInput.placeholder = "Payment Intent ID"
            buttonAction.setTitle("Fetch", for: .normal)
        case .refreshPaymentIntent:
            labelTitle.text = "Refresh Payment Intent"
            constraintLabelTrailing.constant = 90
            buttonAction.isHidden = false
            textFieldInput.isHidden = false
            textFieldInput.placeholder = "Payment Intent ID"
            buttonAction.setTitle("Refresh", for: .normal)
        case .fetchCustomerPaymentMethods:
            labelTitle.text = "Fetch Customer Payment Methods"
            constraintLabelTrailing.constant = 90
            buttonAction.isHidden = false
            textFieldInput.isHidden = false
            textFieldInput.placeholder = "Customer ID"
            buttonAction.setTitle("Fetch", for: .normal)
        }
    }
    
    @IBAction func onActionButtonPress(_ sender: Any) {
        delegate?.onActionButtonPress(cell: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension InputTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.contentView.endEditing(true)
        return false
    }
}
