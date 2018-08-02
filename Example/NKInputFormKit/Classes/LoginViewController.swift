//
//  LoginViewController.swift
//  NKInputFormKit_Example
//
//  Created by Nam Kennic on 8/21/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import NKInputFormKit
import NKModalViewManager

class LoginViewController: NKInputFormViewController {
	var formView : LoginFormView!
	
	override func dismiss(animated flag: Bool, completion: (() -> Void)?) {
		if let modalViewController = NKModalViewManager.sharedInstance().modalViewControllerThatContains(self) {
			modalViewController.dismissWith(animated: flag, completion: completion)
		}
		else {
			super.dismiss(animated: flag, completion: completion)
		}
	}
	
	override var preferredContentSize: CGSize {
		get {
			var screenSize = UIScreen.main.bounds.size
			screenSize.width = screenSize.width * 0.8
			var contentSize = formView.sizeThatFits(screenSize)
			contentSize.width = screenSize.width
			
			return contentSize
		}
		set {
			super.preferredContentSize = newValue
		}
	}
	
	override func submitAction() {
		self.isLoading = true
		formView.submitButton.isLoading = true
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
			self.dismiss(animated: true, completion: nil)
		}
	}
	
	// MARK: -
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		formView = LoginFormView()
		self.inputFormView = formView
	}
}


// MARK: - LoginFormView
import NKButton
import FrameLayoutKit

internal class LoginFormView : NKInputFormView {
	let titleLabel = UILabel()
	let usernameField = UITextField()
	let passwordField = UITextField()
	let cancelButton = NKButton()
	let submitButton = NKButton()
	let frameLayout = StackFrameLayout(direction: .vertical)
	
	override init () {
		super.init()
		
		self.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
		
		titleLabel.text = "Login Form"
		titleLabel.textAlignment = .center
		titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
		
		usernameField.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
		passwordField.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
		
		usernameField.placeholder = "Username"
		passwordField.placeholder = "Password"
		
		cancelButton.title = "Cancel"
		cancelButton.isRoundedButton = true
		cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
		cancelButton.setTitleColor(.black, for: .normal)
		cancelButton.setTitleColor(.white, for: .highlighted)
		cancelButton.setBorderColor(.black, for: .normal)
		cancelButton.setBackgroundColor(.black, for: .highlighted)
		cancelButton.borderSize = 1.0
		cancelButton.tag = NKInputFormButtonTag.cancel.rawValue
		
		submitButton.title = "Submit"
		submitButton.isRoundedButton = true
		submitButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
		submitButton.setTitleColor(.black, for: .normal)
		submitButton.setTitleColor(.white, for: .highlighted)
		submitButton.setBorderColor(.black, for: .normal)
		submitButton.setBackgroundColor(.black, for: .highlighted)
		submitButton.borderSize = 1.0
		submitButton.tag = NKInputFormButtonTag.submit.rawValue
		
		let textFieldSize = CGSize(width: 0, height: 40)
		let buttonSize = CGSize(width: 0, height: 40)
		frameLayout.append(view: titleLabel)
		frameLayout.appendEmptySpace(size: CGSize(width: 0, height: 10))
		frameLayout.append(view: usernameField).minSize = textFieldSize
		frameLayout.append(view: passwordField).minSize = textFieldSize
		frameLayout.appendEmptySpace(size: CGSize(width: 0, height: 10))
		frameLayout.append(view: cancelButton).minSize = buttonSize
		frameLayout.append(view: submitButton).minSize = buttonSize
		frameLayout.spacing = 5
		frameLayout.edgeInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
		
		self.addSubview(titleLabel)
		self.addSubview(usernameField)
		self.addSubview(passwordField)
		self.addSubview(cancelButton)
		self.addSubview(submitButton)
		self.addSubview(frameLayout)
	}
	
	required internal init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func sizeThatFits(_ size: CGSize) -> CGSize {
		return frameLayout.sizeThatFits(size)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		frameLayout.frame = self.bounds
	}
	
}

