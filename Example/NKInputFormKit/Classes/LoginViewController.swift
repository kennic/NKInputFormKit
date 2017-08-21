//
//  LoginViewController.swift
//  NKInputFormKit_Example
//
//  Created by Nam Kennic on 8/21/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import NKInputFormKit

class LoginViewController: NKInputFormViewController {
	var formView : LoginFormView!
	
	convenience init () {
		self.init(inputFormViewInstance: LoginFormView())
		formView = inputFormView as! LoginFormView
	}
	
	// MARK: -
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}


// MARK: - LoginFormView

internal class LoginFormView : NKInputFormView {
	
	override init () {
		super.init()
		
		self.backgroundColor = .white
	}
	
	required internal init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}

