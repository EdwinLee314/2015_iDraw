//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"




protocol Visitable{
    func accept(visitor:Visitor )->Double;
}

class Liquor: Visitable {
    var price:Double;
    init(price:Double){
        self.price = price;
    }
    
    func accept( visitor:Visitor ) -> Double {
        return visitor.visit(self);
    }
    
    func getPrice() -> Double{
        return price;
    }
}

class Tobacco: Visitable{
    var price:Double;
    init(price:Double){
        self.price = price;
    }
    
    func accept( visitor: Visitor) -> Double {
        return visitor.visit(self);
    }
    
    func getPrice() -> Double{
        return price;
    }
}

class Necessity: Visitable {
    var price:Double;
    init(price:Double){
        self.price = price;
    }
    
    func accept(visitor:Visitor ) -> Double {
        return visitor.visit(self);
    }
    
    func getPrice() -> Double{
        return price;
    }
}

protocol Visitor{
    func visit(liquorItem :Liquor )->Double
    func visit(tobaccoItem :Tobacco )->Double
    func visit(necessityItem :Necessity )->Double
}

class TaxVisitor: Visitor {
    func visit(liquorItem:Liquor ) -> Double{
        print("Liquor Item:Price with Tax");
        return liquorItem.getPrice() * 0.18 + liquorItem.getPrice();
    }
    func visit( tobaccoItem:Tobacco) -> Double{
        print("Tobacco Item:Price with Tax");
        return tobaccoItem.getPrice() * 0.32 + tobaccoItem.getPrice();
    }
    func visit( necessityItem :Necessity) -> Double{
        print("Necessity Item:Price with Tax");
        return necessityItem.getPrice();
    }
}


let taxCalc = TaxVisitor();
var milk = Necessity(price:3.47);
var vodka = Liquor(price:11.99);
var cigars = Tobacco(price:19.99);

var i1 = milk.accept(taxCalc)
var milkTax = NSString(format:"%.2f",i1)
print("\(milkTax)")

var i2 = vodka.accept(taxCalc)
var vodkaTax = NSString(format:"%.2f",i2)
print("\(vodkaTax)")

var i3 = cigars.accept(taxCalc)
var cigarsTax = NSString(format:"%.2f",i3)
print("\(cigarsTax)")
