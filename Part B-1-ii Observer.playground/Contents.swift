//: Playground - noun: a place where people can play

import Cocoa


protocol ChangeSubject{
    func addObserver(o:ChangeObserver)
    
    func removeObserver(o:ChangeObserver)
    
    func notifyObserver()
    
}

protocol ChangeObserver{
    var id:Int{get set}
    func refresh(s: ChangeSubject)
}

class Point : ChangeSubject{
    var observers = Dictionary<Int, ChangeObserver>()
    var x:Int
    var y:Int
    
    var color:String
    
    init(x:Int ,y:Int, color:String){
        self.x = x
        self.y = y
        self.color = color
    }
    
    func getX() ->Int{
        return x;
    }
    
    func getY() ->Int{
        return y;
    }
    
    func setX(x:Int){
        self.x = x
        notifyObserver()
    }
    
    func setY(y:Int){
        self.y = y
        notifyObserver()
    }
    
    func setColor(color:String){
        self.color = color
        notifyObserver()
    }
    
    func addObserver(o: ChangeObserver) {
        self.observers[o.id] = o
    }
    
    func removeObserver(o: ChangeObserver) {
        self.observers.removeValueForKey(o.id);
    }
    
    func notifyObserver() {
        
        for observer in observers.values {
            observer.refresh(self)
        }
    }
}


class Screen : ChangeSubject,ChangeObserver{
    var observers = Dictionary<Int, ChangeObserver>()
    var name:String;
    var id:Int;
    init(s:String, id:Int){
        self.name = s;
        self.id = id;
    }
    
    func display(s:String){
        print("\(name) : \(s)");
        notifyObserver();
    }
    
    func addObserver(o: ChangeObserver) {
        self.observers[o.id] = o
    }
    
    func removeObserver(o: ChangeObserver) {
        self.observers.removeValueForKey(o.id);
    }
    
    func notifyObserver() {
        
        for observer in observers.values {
            observer.refresh(self)
        }
    }

    func refresh(s: ChangeSubject) {
        display("update received from a \(s.self) object")
    }
    
}

var p = Point(x: 5,y: 5,color: "Blue")
print("Create Screen s1,s2,s3,s4,s5 and Point p")

var s1 = Screen(s: "S1", id: 1)
var s2 = Screen(s: "S2", id: 2)
var s3 = Screen(s: "S3", id: 3)
var s4 = Screen(s: "S4", id: 4)
var s5 = Screen(s: "S5", id: 5)

print("Create observing relationship");
print("- s1 and s2 observer color changes to p")
print("- s3 and s4 observer coordinate changes to p")
print("- s5 observers s2's and s4's display() method")

p.addObserver(s1)
p.addObserver(s2)

p.addObserver(s3)
p.addObserver(s4)

s2.addObserver(s5)
s4.addObserver(s5)

print("Changing p's color")
p.setColor("Red")

print("Changing p's x-coordinate")
p.setX(4)

print("done")


