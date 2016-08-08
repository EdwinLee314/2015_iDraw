//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

protocol Writer{
    func write(s:String)
}

class SystemOutNewPrinter{
    func newPrintToSystemOut(s:String){
        print(s)
    }
}

class SystemOutPrinter{
    func printToSystemOut(s:String){
        print(s)
    }
}
class PrinterAdapter : Writer{
    var adaptee:SystemOutPrinter
    init(adaptee:SystemOutPrinter){
        self.adaptee = adaptee
    }
    
    func write(s: String) {
        adaptee.printToSystemOut(s);
    }
}
class NewPrinterAdapter : Writer{
    var adaptee:SystemOutNewPrinter
    init(adaptee:SystemOutNewPrinter){
        self.adaptee = adaptee
    }
    
    func write(s: String) {
        adaptee.newPrintToSystemOut(s);
    }
}

print("Creating the Adaptees...")
let adaptee = SystemOutPrinter();
let newAdaptee = SystemOutNewPrinter();

print("issuing the request to the Adaptees")
adaptee.printToSystemOut("Test successful")
newAdaptee.newPrintToSystemOut("Test successful")

print("Now generate the same output, but using Adapters...")
print("Creating the Adapers...")
let myTarget = PrinterAdapter(adaptee: adaptee)
let myNewTarget = NewPrinterAdapter(adaptee: newAdaptee)

print("Each pair of Adapter and Adaptee are the same object?")
print(myTarget === adaptee)
print(myNewTarget === newAdaptee)

print("issuing the request to the Adapters...")
myTarget.write("Test successful")
myNewTarget.write("Test successful")


