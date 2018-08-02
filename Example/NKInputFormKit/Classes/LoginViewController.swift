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
	
	// MARK: -
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		formView = LoginFormView()
		self.inputFormView = formView
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
	
	override func sizeThatFits(_ size: CGSize) -> CGSize {
		return CGSize(width: size.width * 0.8, height: 320)
	}
	
}

