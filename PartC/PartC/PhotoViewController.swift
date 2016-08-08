//
//  PhotoViewController.swift
//  PartC
//
//  Created by Nam Nguyen on 5/10/2015.
//  Copyright © 2015 latrobe. All rights reserved.
//

import UIKit
import CloudKit

protocol PhotoDelegate {
    
}

class PhotoViewController: UIViewController {
    
    var image: UIImage?
    
    var photoRecord: CKRecord?

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let photoRecord = photoRecord {
            let imageAsset = photoRecord.valueForKey("photo") as! CKAsset
            let image = UIImage(contentsOfFile: imageAsset.fileURL.path!)
            imageView.image = image
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func deletePhoto(sender: AnyObject) {
        let alert = UIAlertController()
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive) { (action) -> Void in
            let container = CKContainer.defaultContainer()
            let privateDatabase = container.privateCloudDatabase
            
            if let recordID = self.photoRecord?.recordID {
                privateDatabase.deleteRecordWithID(recordID, completionHandler: { (recordID, error) -> Void in
                    if error != nil {
                        print(error)
                    } else {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                })
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}
