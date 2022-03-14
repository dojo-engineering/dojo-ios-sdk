//
//  ApplePayPlaceholderViewController.swift
//  dojo-ios-sdk
//
//  Created by Deniss Kaibagarovs on 07/03/2022.
//

import UIKit

class ApplePayPlaceholderViewController: UIViewController {
    
    private var completion: ((NSError?) -> Void)?
    
    convenience init(completion: ((NSError?) -> Void)?) {
        self.init()
        self.completion = completion
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        createView()
    }
    
    private func createView() {
        let centeredView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 300, width: UIScreen.main.bounds.width, height: 300))
        centeredView.backgroundColor = .lightGray
        
        let buttonSuccess = UIButton(frame: CGRect(x: 50, y: 100, width: 80, height: 50))
        buttonSuccess.setTitle("Success", for: .normal)
        buttonSuccess.addTarget(self, action: #selector(onSuccessPress), for: .touchUpInside)
        let buttonFail = UIButton(frame: CGRect(x: 140, y: 100, width: 60, height: 50))
        buttonFail.setTitle("Fail", for: .normal)
        buttonFail.addTarget(self, action: #selector(onFailPress), for: .touchUpInside)
        let buttonCancel = UIButton(frame: CGRect(x: 220, y: 100, width: 60, height: 50))
        buttonCancel.setTitle("Cancel", for: .normal)
        buttonCancel.addTarget(self, action: #selector(onCancelPress), for: .touchUpInside)
        
        centeredView.addSubview(buttonSuccess)
        centeredView.addSubview(buttonFail)
        centeredView.addSubview(buttonCancel)
        self.view.addSubview(centeredView)
    }
    
    @objc func onSuccessPress() {
        completion?(nil)
    }
    
    @objc func onFailPress() {
        completion?(ErrorBuilder.serverError(.applePayError))
    }
    
    @objc func onCancelPress() {
        completion?(ErrorBuilder.internalError(.cancel))
    }
}
