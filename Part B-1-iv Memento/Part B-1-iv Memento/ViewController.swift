//
//  ViewController.swift
//  Part B-1-iv Memento
//
//  Created by Junqi Li on 17/09/2015.
//  Copyright © 2015 Junqi Li. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UITextViewDelegate{
    //MARK: Properties
    @IBOutlet weak var ArticleTextView: UITextView!
    let originator = Originator();
    let caretaker = Caretaker();
    var saveFiles = 0;
    var currentArticle = 0;
    
    @IBOutlet weak var UndoBtn: UIButton!
    @IBOutlet weak var RedoBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ArticleTextView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Actions
    
    @IBAction func saveButton(sender: UIButton) {
        let textValue = ArticleTextView.text
        originator.set(textValue)
        caretaker.addMemento(originator.storeINMemento())
        saveFiles++
        currentArticle++
        print("Save Files: \(saveFiles)");
        RedoBtn.userInteractionEnabled = true
        RedoBtn.backgroundColor = UIColor.whiteColor()
        
    }
    
    @IBAction func undoButton(sender: UIButton) {
        if currentArticle >= 1{
            currentArticle--;
            let textBoxStringA = originator.restoreFromMemento(caretaker.getMemento(currentArticle))
            ArticleTextView.text = textBoxStringA;
            RedoBtn.userInteractionEnabled = true
        }else{
            UndoBtn.userInteractionEnabled = false
            UndoBtn.backgroundColor = UIColor.redColor()
        }
        
    }
    
    @IBAction func redoButton(sender: UIButton) {
        if((saveFiles - 1) > currentArticle){
            currentArticle++;
            let textBoxStringB = originator.restoreFromMemento(caretaker.getMemento(currentArticle))
            ArticleTextView.text = textBoxStringB
            UndoBtn.userInteractionEnabled = true
            UndoBtn.backgroundColor = UIColor.whiteColor()
        }else{
            RedoBtn.userInteractionEnabled = false
            RedoBtn.backgroundColor = UIColor.redColor()
        }
    }
    
    
}

