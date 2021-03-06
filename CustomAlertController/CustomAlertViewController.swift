//
//  CustomAlertViewController.swift
//  SelfionAlertController
//
//  Created by yusuf_kildan on 23/07/2016.
//  Copyright © 2016 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

enum CustomAlertActionStyle: Int {
    case Default
    case Cancel
    case Destructive
    
    var textColor: UIColor {
        switch self {
        case CustomAlertActionStyle.Default:
            return UIColor(red: 252/255.0, green: 201/255.0, blue: 0/255.0, alpha: 1.0)
        case CustomAlertActionStyle.Cancel:
            return UIColor(red: 60/255.0, green: 60/255.0, blue: 60/255.0, alpha: 1.0)
        case CustomAlertActionStyle.Destructive:
            return UIColor(red: 220/255.0, green: 56/255.0, blue: 56/255.0, alpha: 1.0)
        }
    }
}

// MARK - CustomAlertAnimation

private class CustomAlertAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let isPresenting: Bool
    
    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
    }
    
    @objc private func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        if isPresenting {
            return 0.8
        } else {
            return 0.5
        }
    }
    
    @objc private func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            self.presentAnimateTransition(transitionContext)
        } else {
            self.dismissAnimateTransition(transitionContext)
        }
    }
    
    @objc private func presentAnimateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let alertController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! CustomAlertViewController
        let containerView = transitionContext.containerView()
        
        alertController.alertView.layoutIfNeeded()
        alertController.alertView.frame.size = CGSizeMake(alertController.alertViewWidth,alertController.alertView.frame.height)
        alertController.overlayView.alpha = 0.0
        alertController.alertView.transform = CGAffineTransformMakeTranslation(0, alertController.alertView.frame.height)
        
        containerView!.addSubview(alertController.view)
        
        UIView.animateWithDuration(0.8, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                alertController.overlayView.alpha = 1.0
                alertController.alertView.transform = CGAffineTransformMakeTranslation(0.0, 0.0)
            }) { (finished) in
                if (finished) {
                    transitionContext.completeTransition(true)
                }
        }
    }
    
    @objc private func dismissAnimateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let alertController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! CustomAlertViewController
        
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            alertController.overlayView.alpha = 0.0
            alertController.alertView.transform = CGAffineTransformMakeTranslation(0.0, alertController.alertView.frame.height)
        }) { (finished) in
            if (finished) {
                transitionContext.completeTransition(true)
            }
        }
    }
}

// MARK: CustomAlertAction

class CustomAlertAction: NSObject {
    private var title: String
    private var style: CustomAlertActionStyle
    private var handler: ((CustomAlertAction!) -> Void)?
    
    private var enabled: Bool
    
    required init(title: String, style: CustomAlertActionStyle, handler: ((CustomAlertAction!) -> Void)?) {
        self.title = title
        self.style = style
        self.handler = handler
        self.enabled = true
    }
}

// MARK: CustomAlertViewController

class CustomAlertViewController: UIViewController, UIViewControllerTransitioningDelegate {

    private var overlayView = UIView()
    
    private var alertView = UIView()
    private var alertViewWidth: CGFloat = 0.0

    private var buttonHeight: CGFloat = 60.0
    
    private var buttonBgAndBorderColor = UIColor(red: 227/255.0, green: 227/255.0, blue: 227/255.0, alpha: 1.0)
    
    private var actions: Dictionary<UIButton,CustomAlertAction> = [:]
    private var buttons = [UIButton]()
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        self.transitioningDelegate = self

        self.modalPresentationStyle = UIModalPresentationStyle.Custom
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        overlayView.backgroundColor = UIColor(red:0.0, green:0.0, blue:0.0, alpha:0.5)
        
        alertView.backgroundColor = UIColor.whiteColor()
        alertViewWidth = view.frame.width
        
        self.view.addSubview(overlayView)
        self.view.addSubview(alertView)
        
        //Autolayout Constraints
        overlayView.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Top, ofView: self.view)
        overlayView.autoPinEdge(ALEdge.Bottom, toEdge: ALEdge.Bottom, ofView: self.view)
        overlayView.autoPinEdge(ALEdge.Left, toEdge: ALEdge.Left, ofView: self.view)
        overlayView.autoPinEdge(ALEdge.Right, toEdge: ALEdge.Right, ofView: self.view)
        
        alertView.autoAlignAxis(ALAxis.Vertical, toSameAxisOfView: self.view)
        alertView.autoPinEdge(ALEdge.Bottom, toEdge: ALEdge.Bottom, ofView: self.view)
        alertView.autoSetDimension(ALDimension.Width, toSize: alertViewWidth)
     
        for (index,button) in buttons.enumerate() {
            button.titleLabel?.font = UIFont(name: "Lato-Semibold", size: 16.0)
            button.setTitleColor(actions[button]!.style.textColor, forState: .Normal)
            button.setBackgroundImage(createImageFromUIColor(buttonBgAndBorderColor), forState: UIControlState.Highlighted)
            
            button.autoPinEdgeToSuperviewEdge(ALEdge.Left)
            button.autoPinEdgeToSuperviewEdge(ALEdge.Right)
            button.autoSetDimension(ALDimension.Height, toSize: buttonHeight)
            
            if button  == buttons.first {
                button.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Top, ofView: alertView)
            }else {
                button.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: buttons[index-1])
            }
            if let lastButton = buttons.last {
                lastButton.autoPinEdge(ALEdge.Bottom, toEdge: ALEdge.Bottom, ofView: alertView)
            }
            
            //Create bottom border
            let border = CALayer()
            border.backgroundColor = buttonBgAndBorderColor.CGColor
            border.frame = CGRectMake(0.0, buttonHeight, alertViewWidth, 1.0)
            button.layer.addSublayer(border)
    
        }

    }

    @objc private func buttonTapped(sender: UIButton) {
        let action = actions[sender]
        if (action!.handler != nil) {
            action!.handler!(action)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addAction(action: CustomAlertAction) {
        let button = UIButton(type: UIButtonType.Custom)
        actions[button] = action
        button.setTitle(action.title, forState: .Normal)
        button.enabled = action.enabled
        button.addTarget(self, action: #selector(CustomAlertViewController.buttonTapped(_:)), forControlEvents: .TouchUpInside)
        buttons.append(button)
        alertView.addSubview(button)
    }
    
    private func createImageFromUIColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let contextRef: CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextSetFillColorWithColor(contextRef, color.CGColor)
        CGContextFillRect(contextRef, rect)
        let img: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img
    }
    
   @objc internal func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
        return CustomAlertAnimation(isPresenting: true)
    }
    
   @objc internal func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
        return CustomAlertAnimation(isPresenting: false)
    }
}