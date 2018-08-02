//
//  ViewController.swift
//  NKInputFormKit
//
//  Created by kennic on 07/06/2017.
//  Copyright (c) 2017 kennic. All rights reserved.
//

import UIKit
import NKButton
import NKModalViewManager

class ViewController: UIViewController {
	let presentButton = NKButton()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		presentButton.title = "Present Login Form"
		presentButton.isRoundedButton = true
		presentButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
		presentButton.setTitleColor(.black, for: .normal)
		presentButton.setTitleColor(.white, for: .highlighted)
		presentButton.setBorderColor(.black, for: .normal)
		presentButton.setBackgroundColor(.black, for: .highlighted)
		presentButton.borderSize = 1.0
		presentButton.extendSize = CGSize(width: 20, height: 20)
		presentButton.addTarget(self, action: #selector(presentLogin), for: .touchUpInside)
		
		self.view.addSubview(presentButton)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		let viewSize = self.view.bounds.size
		let buttonSize = presentButton.sizeThatFits(viewSize)
		presentButton.frame = CGRect(x: (viewSize.width - buttonSize.width)/2, y: (viewSize.height - buttonSize.height)/2, width: buttonSize.width, height: buttonSize.height)
	}
	
	@objc func presentLogin() {
		let viewController = LoginViewController()
		NKModalViewManager.sharedInstance().presentModalViewController(viewController)
	}

}

