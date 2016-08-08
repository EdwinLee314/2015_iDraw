//
//  Memento.swift
//  Part B-1-iv Memento
//
//  Created by Junqi Li on 19/09/2015.
//  Copyright © 2015 Junqi Li. All rights reserved.
//

import Foundation

class Memento{
    var article:String = "";
    
    init(articleSave:String){
        article = articleSave;
    }
    
    func getSavedArticle() -> String{
        return article;
    }
}

class Originator{
    var article:String = " ";
    
    init(){
        
    }
    
    func set(newArticle:String){
        print("From Originator:Current Version of Article\n" + newArticle + "\n");
        article = newArticle;
    }
    
    func storeINMemento() -> Memento{
        print("From Originator:Saving to Memento");
        return Memento(articleSave: article);
    }
    
    func restoreFromMemento( memento: Memento)->String{
        article = memento.getSavedArticle();
        print("From Originator: Previous Article Saved in Memento\n" + article + "\n");
        return article;
    }
}

class Caretaker{
    var savedArticles = [Memento]()
    init(){
        
    }
    
    func addMemento( newMemento:Memento){
        savedArticles.append(newMemento)
    }
    
    func getMemento(indexOfWant: Int)->Memento{
        return savedArticles[indexOfWant];
    }
}