//
//  NKInputFormViewController.swift
//  NKInputFormKit
//
//  Created by Nam Kennic on 6/10/16.
//  Copyright © 2016 Nam Kennic. All rights reserved.
//

import UIKit

open class NKInputFormViewController: UIViewController, UIScrollViewDelegate {
	
	public var inputFormView : NKInputFormView? = nil {
		willSet {
			if newValue != inputFormView {
				if let oldValue = inputFormView, oldValue.superview == self.view {
					oldValue.delegate = nil
					oldValue.removeGestureRecognizer(tapGesture)
					oldValue.onSizeChangeRequested = nil
					oldValue.registerTextFieldDelegate(nil)
					oldValue.unregisterTouchEventForAllButtonsWithTarget(self, selector: #selector(onButtonSelected))
					oldValue.unregisterValueChangedEventForAllControlsWithTarget(self, selector: #selector(onControlValueChanged))
				}
			}
		}
		
		didSet {
			if let newValue = inputFormView {
				newValue.delegate = self
				newValue.addGestureRecognizer(tapGesture)
				newValue.onSizeChangeRequested = #selector(onSizeChangeRequested)
				newValue.registerTextFieldDelegate(self)
				newValue.registerTouchEventForAllButtonsWithTarget(self, selector: #selector(onButtonSelected))
				newValue.registerValueChangedEventForAllControlsWithTarget(self, selector: #selector(onControlValueChanged))
				self.view.addSubview(newValue)
				self.view.setNeedsLayout()
			}
		}
	}
	
	public var tapToDismissKeyboard : Bool {
		get {
			return tapGesture.isEnabled
		}
		set (value) {
			tapGesture.isEnabled = value
		}
	}
	
	public var animationWhenPoppingBack				: UIViewAnimationOptions! = .transitionFlipFromRight
	public var animationDuration					: TimeInterval = 0.4
	public var spaceBetweenLowestViewAndKeyboard	: CGFloat = 10.0
	public var keyboardFrame						: CGRect! = .zero
	public var autoPushUpWhenShowingKeyboard		: Bool = true
	
	internal var tapGesture : UITapGestureRecognizer!
	
	open var isLoading : Bool = false {
		didSet {
			inputFormView?.enabled = !isLoading
		}
	}
	
	convenience public init(formView: NKInputFormView) {
		self.init()
		self.inputFormView = formView
	}
	
	public init() {
		super.init(nibName: nil, bundle: nil)
		
		self.automaticallyAdjustsScrollViewInsets = false
		self.modalTransitionStyle = .coverVertical
		self.modalPresentationStyle = .overCurrentContext
		
		tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		tapGesture.cancelsTouchesInView = false
		tapGesture.delegate = self
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Public Methods
	
	open func submitAction() {
		if isLoading {
			return
		}
		
		dismissKeyboard()
		// Subclasses should override this to perform submit action
	}
	
	open func cancelAction() {
		dismiss(animated: true, completion: nil)
	}

	open override func dismiss(animated flag: Bool, completion: (() -> Void)?) {
		dismissKeyboard()
		dismissViewControllerAnimated(flag, completion: completion, forceDismissing: false)
	}
	
	open func dismissViewControllerAnimated(_ flag: Bool, completion: (() -> Void)?, forceDismissing forceDimissing: Bool) {
		if (self.navigationController != nil) && (self.navigationController!.viewControllers.count > 1) && !forceDimissing {
			self.navigationController!.popViewController(animated: flag)
			validateViewSize()
			completion?()
		}
		else {
			super.dismiss(animated: flag, completion: completion)
			
			/*
			let viewController: ModalViewController? = ModalViewManager.sharedInstance().modalViewControllerThatContains(self)
			if viewController != nil {
				viewController!.dismissWith(animated: flag, completion: completion)
			}
			else {
				super.dismiss(animated: flag, completion: completion)
			}
			*/
		}
	}
	
	open func popToRootViewControllerAnimated(_ flag: Bool, completion: (() -> Void)?) {
		if self.navigationController != nil && self.navigationController!.viewControllers.count > 1 {
			self.navigationController!.popToRootViewController(animated: flag)
			self.validateViewSize()
			completion?()
		}
	}
	
	open func validateViewSize() {
		// Subclasses should override this to handle size validation
	}
	
	// MARK: - UIViewController
	
	override open func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = .clear
	}
	
	override open func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		registerForKeyboardNotifications()
	}
	
	override open func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if visibleKeyboardHeight > 0 {
			self.updateInputFormViewContentOffsetAnimated(true)
		}
	}
	
	override open func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		inputFormView?.frame = self.view.bounds
	}
	
	override open var preferredContentSize: CGSize {
		get {
			if let inputFormView = inputFormView {
				var screenSize: CGSize = UIScreen.main.bounds.size
				screenSize.height = CGFloat(NSIntegerMax)
				return inputFormView.sizeThatFits(screenSize)
			}
			else {
				return .zero
			}
		}
		set (value) {
			super.preferredContentSize = value
		}
	}
	
	override open var prefersStatusBarHidden : Bool {
		return true
	}
	
	// MARK: - Events
	
	@objc open func onButtonSelected(_ sender: UIButton) {
		if let buttonTag = NKInputFormButtonTag(rawValue:sender.tag) {
			if buttonTag == .cancel {
				self.cancelAction()
			}
			else if buttonTag == .submit {
				self.submitAction()
			}
		}
	}
	
	@objc open func onControlValueChanged(_ sender: UIControl) {
		
	}
	
	@objc open func onSizeChangeRequested(_ sender: NKInputFormView) {
		self.validateViewSize()
	}
	
	// MARK: - Keyboard Handling
	
	@objc open func dismissKeyboard() {
		self.view!.endEditing(true)
	}
	
	open func registerForKeyboardNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	@objc open func keyboardWillShow(_ notification: Notification) {
		if autoPushUpWhenShowingKeyboard {
			var userInfo: [String: AnyObject] = (notification as NSNotification).userInfo! as! [String : AnyObject]
			let endFrame: CGRect = userInfo[UIKeyboardFrameEndUserInfoKey]!.cgRectValue
//			let duration: TimeInterval = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
	//		let curve: UIViewAnimationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! UIViewAnimationCurve

			keyboardFrame = self.view!.convert(endFrame, from: self.view.window)
			let visibleKeyboardHeight: CGFloat = self.view.bounds.maxY - keyboardFrame.minY
			self.visibleKeyboardHeight = visibleKeyboardHeight
		}
	}
	
	@objc open func keyboardWillHide(_ notification: Notification) {
//		var userInfo: [String: AnyObject] = (notification as NSNotification).userInfo! as! [String : AnyObject]
//		let duration: TimeInterval = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
//		let curve: UIViewAnimationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! UIViewAnimationCurve
		keyboardFrame = CGRect.zero
		self.visibleKeyboardHeight = 0.0
	}
	
	internal func updateInputFormViewContentOffsetAnimated(_ animated: Bool) {
		var contentOffset: CGPoint = CGPoint.zero
		
		if visibleKeyboardHeight > 0.0 {
			var offsetForScrollingTextFieldToTop: CGFloat = (self.currentFirstResponder != nil ? self.currentFirstResponder!.frame.minY : 0.0)
			offsetForScrollingTextFieldToTop -= spaceBetweenLowestViewAndKeyboard
			
			let lowestView: UIView? = inputFormView?.lowestView()
			var offsetForScrollingLowestViewToBottom: CGFloat = 0.0
			offsetForScrollingLowestViewToBottom += visibleKeyboardHeight
			offsetForScrollingLowestViewToBottom += lowestView?.frame.maxY ?? 0
			offsetForScrollingLowestViewToBottom -= inputFormView?.bounds.height ?? 0
			offsetForScrollingLowestViewToBottom += spaceBetweenLowestViewAndKeyboard
			
			let value: CGFloat = offsetForScrollingTextFieldToTop > 0 ? min(offsetForScrollingTextFieldToTop, offsetForScrollingLowestViewToBottom) : max(offsetForScrollingLowestViewToBottom, 0)
			if value < 0 {
				return
			}
			contentOffset = CGPoint(x: 0.0, y: value)
		}
		
		if let formView = inputFormView, formView.contentOffset.y != contentOffset.y {
			formView.setContentOffset(contentOffset, animated: animated)
		}
	}
	
	public var visibleKeyboardHeight : CGFloat = 0 {
		didSet {
			if visibleKeyboardHeight != oldValue {
				updateInputFormViewContentOffsetAnimated(false)
			}
		}
	}
	
	public var currentFirstResponder : UIView? {
		get {
			var result: UIView? = nil
			
			if inputFormView != nil {
				for textField: UITextField in inputFormView!.allTextFields {
					if textField.isFirstResponder {
						result = textField
					}
				}
				
				for control: UIControl in inputFormView!.allControls {
					if control.isFirstResponder {
						result = control
					}
				}
			}
			
			return result
		}
	}
	
	// MARK: - Rotation
	
	override open var shouldAutorotate : Bool {
		return true
	}
	
	override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
		return UIDevice.current.userInterfaceIdiom == .pad ? .all : .portrait
	}
	
	override open var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
		return UIDevice.current.userInterfaceIdiom == .pad ? UIApplication.shared.statusBarOrientation : .portrait
	}
	
	
	// MARK: -
	
	deinit {
		NotificationCenter.default.removeObserver(self)
		
		inputFormView?.registerTextFieldDelegate(nil)
		inputFormView?.unregisterTouchEventForAllButtonsWithTarget(self, selector: #selector(onButtonSelected))
		inputFormView?.unregisterValueChangedEventForAllControlsWithTarget(self, selector: #selector(onControlValueChanged))
	}
}

extension NKInputFormViewController: UIGestureRecognizerDelegate {
	
	open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
		return !(touch.view! is UIControl)
	}
	
}

extension NKInputFormViewController: UITextFieldDelegate {
	
	open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		return true
	}
	
	open func textFieldDidBeginEditing(_ textField: UITextField) {
//		if visibleKeyboardHeight > 0 {
//			updateInputFormViewContentOffsetAnimated(true)
//		}
	}
	
	open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		let nextResponder: UIResponder? = inputFormView?.nextResponderFromResponder(textField)
		if nextResponder != nil {
			nextResponder!.becomeFirstResponder()
			return true
		}
		
		submitAction()
		return true
	}
	
}

extension NKInputFormViewController: UINavigationControllerDelegate {
	
	open func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
		validateViewSize()
	}
	
}


// MARK: - NKInputFormView

public enum NKInputFormButtonTag : Int {
	case cancel = 100
	case submit = 101
}

open class NKInputFormView: UIScrollView {
	public var backgroundView : UIView? = nil {
		willSet {
			if let view = backgroundView, view.superview == self {
				view.removeFromSuperview()
			}
		}
		
		didSet {
			if let view = backgroundView {
				self.insertSubview(view, at: 0)
			}
		}
	}
	
	public var onSizeChangeRequested	: Selector?
	public var keyboardFrame			: CGRect = CGRect.zero
	
	internal var buttonArray	: [UIButton]!		= []
	internal var textFieldArray	: [UITextField]!	= []
	internal var controlArray	: [UIControl]!		= []
	internal var lastButton		: UIView? = nil
	
	internal var _enabled		: Bool = true // enable/disable all controls, including TextFields and Buttons
	internal var _editable		: Bool = true // enable/disable all TextFields, not effected to Buttons
	
	open var allTextFields : [UITextField]! {
		get {
			return textFieldArray
		}
	}
	
	open var allButtons : [UIButton]! {
		get {
			return buttonArray
		}
	}
	
	open var allControls : [UIControl]! {
		get {
			return controlArray
		}
	}
	
	open var enabled : Bool {
		get {
			return _enabled
		}
		set (newValue) {
			_enabled = newValue
			
			for button:UIButton in allButtons {
				button.isEnabled = _enabled
			}
			
			for control:UIControl in allControls {
				control.isEnabled = _enabled
			}
			
			for textField:UITextField in allTextFields {
				textField.isEnabled = _enabled
			}
		}
	}
	
	open var editable : Bool {
		get {
			return _editable
		}
		set (newValue) {
			_editable = newValue
			
			for textField:UITextField in allTextFields {
				textField.isEnabled = _editable
			}
		}
	}
	
	// MARK: -
	
	public init() {
		super.init(frame: CGRect.zero)
		
		self.backgroundColor		= .blue
		self.alwaysBounceVertical	= false
		self.alwaysBounceHorizontal = false
		self.bounces				= true
		self.delaysContentTouches	= false
		
		self.backgroundView = UIVisualEffectView.init(effect: UIBlurEffect(style: .light))
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	open override func addSubview(_ view: UIView) {
		super.addSubview(view)
		
		if (view is UIButton) {
			buttonArray.append(view as! UIButton)
			lastButton = view
		}
		else if (view is UITextField) {
			textFieldArray.append(view as! UITextField)
		}
		else if (view is UIControl) {
			controlArray.append(view as! UIControl)
		}
	}
	
	
	// MARK: -
	
	open func nextResponderFromResponder(_ textField: UIResponder) -> UIResponder? {
		let index: Int = textFieldArray.index(of: textField as! UITextField)!
		if index >= 0 && index < textFieldArray.count - 1 {
			return textFieldArray[index + 1]
		}
		return nil
	}
	
	open func lowestView() -> UIView? {
		return lastButton
	}
	
	open func registerTouchEventForAllButtonsWithTarget(_ target: AnyObject, selector: Selector) {
		for button: UIButton in buttonArray {
			button.addTarget(target, action: selector, for: .touchUpInside)
		}
	}
	
	open func unregisterTouchEventForAllButtonsWithTarget(_ target: AnyObject, selector: Selector) {
		for button: UIButton in buttonArray {
			button.removeTarget(target, action: selector, for: .touchUpInside)
		}
	}
	
	open func registerValueChangedEventForAllControlsWithTarget(_ target: AnyObject, selector: Selector) {
		for control: UIControl in controlArray {
			control.addTarget(target, action: selector, for: .valueChanged)
		}
	}
	
	open func unregisterValueChangedEventForAllControlsWithTarget(_ target: AnyObject, selector: Selector) {
		for control: UIControl in controlArray {
			control.removeTarget(target, action: selector, for: .valueChanged)
		}
	}
	
	open func registerTextFieldDelegate(_ delegate: UITextFieldDelegate?) {
		for textField: UITextField in textFieldArray {
			textField.delegate = delegate
		}
	}
}

