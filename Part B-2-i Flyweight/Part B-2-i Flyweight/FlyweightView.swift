//
//  FlyweightView.swift
//  Part B-2-i Flyweight
//
//  Created by Junqi Li on 4/10/2015.
//  Copyright © 2015 Junqi Li. All rights reserved.
//

import UIKit

class FlyweightView: UIView {
    
    var currentShapeType: Int = 0
    let drawFactory = RectFactory()
    var shapeColor = [UIColor.blackColor(), UIColor.blueColor(),    UIColor.brownColor(),
                      UIColor.redColor(),   UIColor.purpleColor(),  UIColor.greenColor(),
                      UIColor.yellowColor(),UIColor.magentaColor(), UIColor.cyanColor()]
    
    
    init(frame: CGRect, shape: Int) {
        super.init(frame: frame)
        self.currentShapeType = shape
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        switch currentShapeType {
        case 0: drawUseFlyweight(10000)
        case 1: drawUseFlyweight(500000)
        case 2: drawUseFlyweight(1000000)
        case 3: drawUseFlyweight(1500000)
        case 4: drawUseFlyweight(2000000)
        case 5: drawNotUseFlyweight(10000)
        case 6: drawNotUseFlyweight(500000)
        case 7: drawNotUseFlyweight(1000000)
        case 8: drawNotUseFlyweight(1500000)
        case 9: drawNotUseFlyweight(2000000)
        default: print("default")
        }
    }
    
    func drawUseFlyweight(looptimes: Int){
        let ctx = UIGraphicsGetCurrentContext()
        let before = CFAbsoluteTimeGetCurrent();

        for _ in 0...looptimes{
            let tColor = getRandColor()
            let rectD = drawFactory.getRect(tColor)
            let xi = getRandX()
            let yi = getRandY()
            rectD.draw(ctx!,x: xi,y: yi,width: Int(self.frame.width)-xi,height: Int(self.frame.size.height)-yi)
        }
        let after = CFAbsoluteTimeGetCurrent();
        print("\(after - before)")
    
    }
    
    func drawNotUseFlyweight(looptimes: Int){
        let context = UIGraphicsGetCurrentContext()
        let before = CFAbsoluteTimeGetCurrent();
        for _ in 0...looptimes{
            let tColor = getRandColor()
            let xi = getRandX()
            let yi = getRandY()
 
            CGContextAddRect(context, CGRectMake(CGFloat(xi),CGFloat(yi),self.frame.width - CGFloat(xi),self.frame.size.height - CGFloat(yi)))
            CGContextSetLineWidth(context, 1.0)
            CGContextSetStrokeColorWithColor(context,tColor.CGColor)
            CGContextStrokePath(context)
            
            CGContextSetFillColorWithColor(context,tColor.CGColor);
            CGContextFillPath(context)
        }
        let after = CFAbsoluteTimeGetCurrent();
        print("\(after - before)")
        
    }
    
    func getRandColor()->UIColor{
        let randInt = Int(arc4random_uniform(9))
        return shapeColor[randInt]
    }
    
    func getRandX()->Int{
        return Int(arc4random_uniform(UInt32(self.frame.width)))
    }
    
    func getRandY()->Int{
        return Int(arc4random_uniform(UInt32(self.frame.size.height)))
    }

    class MyRect{
        var color = UIColor.blackColor()
        
        init(color: UIColor){
            self.color = color;
        }
        
        func draw(context:CGContext, x:Int,y:Int,width:Int,height:Int){
            CGContextAddRect(context, CGRectMake(CGFloat(x),CGFloat(y),CGFloat(width),CGFloat(height)))
            CGContextSetLineWidth(context, 1.0)
            CGContextSetStrokeColorWithColor(context,self.color.CGColor)
            CGContextStrokePath(context)
            
            CGContextSetFillColorWithColor(context,self.color.CGColor);
            CGContextFillPath(context)
        }
    }
    
    class RectFactory{
        
        var rectsByColor = Dictionary<UIColor, MyRect>()
        
        func getRect(color: UIColor)->MyRect{
            var rect = rectsByColor[color];
            
            if(rect === nil){
                rect = MyRect(color: color)
                rectsByColor[color] = rect;
            }
            return rect!
        }
    }
}
