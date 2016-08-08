//
//  ViewController.swift
//  Part B-2-i Flyweight
//
//  Created by Junqi Li on 4/10/2015.
//  Copyright © 2015 Junqi Li. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func buttonPressed(sender: UIButton) {
       
        let myView = FlyweightView(frame: CGRectMake(50, 200, 280, 250), shape: sender.tag)
        myView.backgroundColor = UIColor.grayColor()
        view.addSubview(myView)


        
    }
}

