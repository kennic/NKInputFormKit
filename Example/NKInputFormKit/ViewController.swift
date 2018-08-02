//
//  ViewController.swift
//  NKInputFormKit
//
//  Created by kennic on 07/06/2017.
//  Copyright (c) 2017 kennic. All rights reserved.
//

import UIKit
import NKModalViewManager

class ViewController: UIViewController {
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
			self.presentLogin()
		}
	}
	
	func presentLogin() {
		let viewController = LoginViewController()
		NKModalViewManager.sharedInstance().presentModalViewController(viewController)
	}

}

