//
//  ViewController.swift
//  SelfionAlertController
//
//  Created by yusuf_kildan on 23/07/2016.
//  Copyright © 2016 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        
        let button = UIButton.newAutoLayoutView()
        button.addTarget(self, action: #selector(ViewController.open), forControlEvents: .TouchUpInside)
        button.backgroundColor = UIColor.redColor()
        
        view.addSubview(button)
        
        button.autoSetDimensionsToSize(CGSize(width: 55, height: 55))
        button.autoCenterInSuperview()

    }
    
  

    func open() {
    
        let alertController = CustomAlertViewController()
        alertController.addAction(CustomAlertAction(title: "Change Location", style: CustomAlertActionStyle.Default, handler: { (_) in
            print("Deneme1")
        }))
        alertController.addAction(CustomAlertAction(title: "Remove Location", style: CustomAlertActionStyle.Destructive, handler: { (_) in
            print("Deneme2")
        }))
        alertController.addAction(CustomAlertAction(title: "Cancel", style: CustomAlertActionStyle.Cancel, handler: { (_) in
            print("Deneme3")
        }))
        
        presentViewController(alertController, animated: true, completion: nil)
    }

}

