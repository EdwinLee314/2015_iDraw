//
//  ViewController.swift
//  PartC
//
//  Created by Nam Nguyen on 25/09/2015.
//  Copyright © 2015 latrobe. All rights reserved.
//

import UIKit
import CloudKit

protocol DrawingDelegate {
    func updateFiles()
}

class DrawingViewController: UIViewController {
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    
    var delegate: DrawingDelegate?
    
    //var delegate: DrawingViewDelegate?
    
    var fileName: String?
    
    // The last drawn point on the canvas
    var lastPoint = CGPoint.zero
    
    // Brush stroke width
    var brushWidth: CGFloat = 3.0
    
    // Identify if the brush stroke is continuous
    var swiped = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if fileName != nil {
            self.title = fileName
            let updateButton = UIBarButtonItem(title: "Update", style: .Done, target: self, action: "updateDrawing")
            navigationItem.rightBarButtonItem = updateButton
            let imageURL = FileUtil.urlForFileName(fileName!)
            if let data = NSData(contentsOfURL: imageURL) {
                mainImageView.image = UIImage(data: data)
            }
        } else {
            let addButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "createDrawing")
            navigationItem.rightBarButtonItem = addButton
        }
    }
    
    
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        
        // Draw a line between two points.
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        
        // Get the current touch point and then draw a line
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        
        // Drawing parameters: brush size and brush stroke color
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, brushWidth)
        CGContextSetRGBStrokeColor(context, 0, 0, 0, 1)
        CGContextSetBlendMode(context, CGBlendMode.Normal)
        
        // Actually draw the path
        CGContextStrokePath(context)
        
        // Wrap up the drawing context to render the new line into the temporary image view
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        swiped = false
        if let touch = touches.first {
            lastPoint = touch.locationInView(self.view)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // There is a swipe in progress
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.locationInView(view)
            drawLineFrom(lastPoint, toPoint: currentPoint)
            
            // Update the lastPoint so the next touch event will continue where we just left off
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !swiped {
            // Draw a single point
            drawLineFrom(lastPoint, toPoint: lastPoint)
        }
        
        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tempImageView.image = nil
        
    }

    
    @IBAction func cancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func createDrawing() {
        let alert = UIAlertController(title: "", message: "Enter a description for new drawing", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler(nil)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save on the device", style: .Default) { (action) -> Void in
            let prefs = NSUserDefaults.standardUserDefaults()
            prefs.setInteger(0, forKey: "selectedStorage")
            prefs.synchronize()
            
            let textField = alert.textFields![0]
            self.saveFile(textField.text!)
        }
        let saveOnCloud = UIAlertAction(title: "Save on the iCloud", style: .Default) { (action) -> Void in
            let prefs = NSUserDefaults.standardUserDefaults()
            prefs.setInteger(1, forKey: "selectedStorage")
            prefs.synchronize()
            
            let textField = alert.textFields![0]
            self.saveFile(textField.text!)
        }
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        alert.addAction(saveOnCloud)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func updateDrawing() {
        if fileName != nil {
            saveFile(fileName!)
        }
    }
    
    private func saveFile(fileName: String) {
        let trimmedFileName = fileName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if !trimmedFileName.isEmpty {
            let imageData = UIImagePNGRepresentation(mainImageView.image!)
            let saveURL = FileUtil.urlForFileName(trimmedFileName)
            imageData?.writeToURL(saveURL, atomically: true)
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                self.delegate?.updateFiles()
            })
        }
    }
    
}

