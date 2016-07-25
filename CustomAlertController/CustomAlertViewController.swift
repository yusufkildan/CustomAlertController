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
            return UIColor(red: 252/255, green: 201/255, blue: 0/255, alpha: 1.0)
        case CustomAlertActionStyle.Cancel:
            return UIColor(red: 60/255, green: 60/255, blue: 60/255, alpha: 1.0)
        case CustomAlertActionStyle.Destructive:
            return UIColor(red: 220/255, green: 56/255, blue: 56/255, alpha: 1.0)
        }
    }
}

enum CustomAlertControllerStyle: Int {
    case ActionSheet
    case Alert
}

// MARK - CustomAlertAnimation

class CustomAlertAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    let isPresenting: Bool
    
    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        if (isPresenting) {
            return 0.5
        } else {
            return 0.5
        }
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if (isPresenting) {
            self.presentAnimateTransition(transitionContext)
        } else {
            self.dismissAnimateTransition(transitionContext)
        }
    }
    
    func presentAnimateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let alertController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! CustomAlertViewController
        let containerView = transitionContext.containerView()
        
        alertController.overlayView.alpha = 0.0
        alertController.alertView.transform = CGAffineTransformMakeTranslation(0, alertController.alertView.frame.height)
        
        containerView!.addSubview(alertController.view)
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                alertController.overlayView.alpha = 1.0
                alertController.alertView.transform = CGAffineTransformMakeTranslation(0, 0)
            }) { (finished) in
                if (finished) {
                    transitionContext.completeTransition(true)
                }
        }
    }
    
    func dismissAnimateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let alertController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! CustomAlertViewController
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            alertController.overlayView.alpha = 0.0
            alertController.alertView.transform = CGAffineTransformMakeTranslation(0, alertController.alertView.frame.height)
        }) { (finished) in
            if (finished) {
                transitionContext.completeTransition(true)
            }
        }
    }
}

// MARK: CustomAlertAction

class CustomAlertAction : NSObject{
    var title: String
    var style: CustomAlertActionStyle
    var handler: ((CustomAlertAction!) -> Void)?
    
    var enabled: Bool
    
    required init(title: String, style: CustomAlertActionStyle, handler: ((CustomAlertAction!) -> Void)?) {
        self.title = title
        self.style = style
        self.handler = handler
        self.enabled = true
    }
    
}

// MARK: CustomAlertViewController

class CustomAlertViewController: UIViewController, UIViewControllerTransitioningDelegate {
    var preferredStyle: CustomAlertControllerStyle?
    
    //Overlay View
    var overlayView = UIView()
    var overlayColor = UIColor(red:0, green:0, blue:0, alpha:0.5)
    
    //Alert View
    var alertView = UIView()
    var alertViewBgColor = UIColor.whiteColor()
    var alertViewWidth: CGFloat = 0
    var alertViewHeightConstraint: NSLayoutConstraint!
    var alertViewHeight: CGFloat = 0.0

    
    var buttonHeight: CGFloat = 60.0
    
    var actions = [AnyObject]()
    
    var buttons = [UIButton]()
    
    let buttonFont = UIFont(name: "Lato-Semibold", size: 16)
    let buttonBackgroundHighlightedColor = UIColor(red: 227/255, green: 227/255, blue: 227/255, alpha: 1.0)
    
    convenience init(preferredStyle: CustomAlertControllerStyle) {
        self.init(nibName: nil, bundle: nil)
        self.preferredStyle = preferredStyle
        self.transitioningDelegate = self

        self.modalPresentationStyle = UIModalPresentationStyle.Custom

        
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
        alertViewHeightConstraint = alertView.autoSetDimension(ALDimension.Height, toSize:0)

    }
  
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        setupView()
        
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        overlayView.backgroundColor = overlayColor
        alertView.backgroundColor = alertViewBgColor
        
        for i in 0..<buttons.count {
            let action = actions[buttons[i].tag - 1] as! CustomAlertAction
            buttons[i].titleLabel?.font = buttonFont
            buttons[i].setTitleColor(action.style.textColor, forState: .Normal)
            buttons[i].setBackgroundImage(createImageFromUIColor(buttonBackgroundHighlightedColor), forState: UIControlState.Highlighted)
            
            
            buttons[i].autoPinEdgeToSuperviewEdge(ALEdge.Left)
            buttons[i].autoPinEdgeToSuperviewEdge(ALEdge.Right)
            buttons[i].autoSetDimension(ALDimension.Height, toSize: buttonHeight)
            
            if i == 0 {
                buttons[i].autoPinEdge(ALEdge.Top, toEdge: ALEdge.Top, ofView: alertView)
                
            }else  {
                buttons[i].autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: buttons[i-1])
            }
        }
        
        alertViewHeight = CGFloat(buttons.count) * buttonHeight
        alertViewHeightConstraint.constant = alertViewHeight
        alertView.frame.size = CGSizeMake(alertViewWidth, alertViewHeightConstraint.constant)
    }
    

    
    func buttonTapped(sender: UIButton) {
        let action = actions[sender.tag - 1] as! CustomAlertAction
        if (action.handler != nil) {
            action.handler!(action)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addAction(action: CustomAlertAction) {
        
        actions.append(action)

        let button = UIButton(type: UIButtonType.Custom)
        button.setTitle(action.title, forState: .Normal)
        button.enabled = action.enabled
        button.addTarget(self, action: #selector(CustomAlertViewController.buttonTapped(_:)), forControlEvents: .TouchUpInside)
        button.tag = buttons.count + 1
        buttons.append(button)
        alertView.addSubview(button)
        
        //Create bottom border
        let border = CALayer()
        border.backgroundColor = UIColor(red: 227/255, green: 227/255, blue: 227/255, alpha: 1.0).CGColor
        border.frame = CGRectMake(0, button.frame.height, alertViewWidth, 1)
        button.layer.addSublayer(border)
        
    }
    
 
    
    func createImageFromUIColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0, 0, 1, 1)
        UIGraphicsBeginImageContext(rect.size)
        let contextRef: CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextSetFillColorWithColor(contextRef, color.CGColor)
        CGContextFillRect(contextRef, rect)
        let img: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomAlertAnimation(isPresenting: true)
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomAlertAnimation(isPresenting: false)
    }
}