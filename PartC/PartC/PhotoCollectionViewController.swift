//
//  PhotoCollectionViewController.swift
//  PartC
//
//  Created by Nam Nguyen on 4/10/2015.
//  Copyright © 2015 latrobe. All rights reserved.
//

import UIKit
import CloudKit

class PhotoCollectionViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imagePicker: UIImagePickerController!
    var photos: Array<CKRecord> = []
    
    @IBAction func pickPhoto(sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .Camera
            presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        print("Get the image")
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let resizedImage = resizeImage(image)
        // Save image locally)
        let imageData = UIImagePNGRepresentation(resizedImage)
        let imageURL = FileUtil.urlForFileName("Temporary", fileExtension: "photo")
        imageData?.writeToURL(imageURL, atomically: true)
        
        // Upload image to iCloud
        let timestampAsString = String(format: "%f", NSDate.timeIntervalSinceReferenceDate())
        let timestampParts = timestampAsString.componentsSeparatedByString(".")
        let photoID = CKRecordID(recordName: timestampParts[0])
        let photoRecord = CKRecord(recordType: "Photos", recordID: photoID)
        photoRecord.setObject(NSDate(), forKey: "photoTakenDate")
        let imageAsset = CKAsset(fileURL: imageURL)
        photoRecord.setObject(imageAsset, forKey: "photo")
        
        let container = CKContainer.defaultContainer()
        let privateDatabase = container.privateCloudDatabase
        print("Start uploading to iCloud")
        privateDatabase.saveRecord(photoRecord) { (record, error) -> Void in
            if error != nil {
                self.alertError((error?.localizedDescription)!)
            } else {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    print("Finish uploading")
                    self.imagePicker.dismissViewControllerAnimated(true, completion: { () -> Void in
                        self.fetchPhotos()
                    })
                })
            }
        }
    }
    
    func resizeImage(image: UIImage, sizeLimit: Int = 500) -> UIImage {
        var newWidth = 0
        var newHeight = 0
        
        let originalWidth = Int(image.size.width)
        let originalHeight = Int(image.size.height)
        
        // Get new size with max w/h = 700
        if originalWidth > originalHeight {
            // Max width
            newWidth = sizeLimit
            newHeight = (originalHeight * sizeLimit)/originalWidth
        } else {
            newWidth = (originalWidth * sizeLimit)/originalHeight
            newHeight = sizeLimit
        }
        let newSize = CGSizeMake(CGFloat(newWidth), CGFloat(newHeight))
        UIGraphicsBeginImageContext(newSize)
        image.drawInRect(CGRectMake(0, 0, CGFloat(newWidth), CGFloat(newHeight)))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    private let reuseIdentifier = Constant.Identifier.PhotoCell
    private let sectionInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)

    override func viewDidLoad() {
        super.viewDidLoad()


        fetchPhotos()
    }
    
    func fetchPhotos() {
        let activityIndicatorView = ActivityIndicatorView(title: "Loading...", center: self.view.center)
        self.view.addSubview(activityIndicatorView.getViewActivityIndicator())
        activityIndicatorView.startAnimating()
        
        
        let container = CKContainer.defaultContainer()
        let privateDatabase = container.privateCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Photos", predicate: predicate)
        
        
        privateDatabase.performQuery(query, inZoneWithID: nil) { (records, error) -> Void in
            if error != nil {
                self.alertError((error?.localizedDescription)!)
                activityIndicatorView.stopAnimating()
            } else {
                self.photos.removeAll() // Clear the photos array
                for record in records! {
                    self.photos.append(record)
                }
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.collectionView?.reloadData()
                    activityIndicatorView.stopAnimating()
                })
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        if segue.identifier == Constant.Identifier.CollectionToDetailSegue {
            let photoVC = segue.destinationViewController.contentViewController as! PhotoViewController
            
            let photoRecord = sender as! CKRecord
            photoVC.photoRecord = photoRecord
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return photos.count
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let photoRecord = photos[indexPath.row]
        performSegueWithIdentifier(Constant.Identifier.CollectionToDetailSegue, sender: photoRecord)
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoCollectionViewCell
    
        // Configure the cell
        
        cell.backgroundColor = UIColor.blackColor()
        
        let photoRecord = photos[indexPath.row]
        let imageAsset = photoRecord.valueForKey("photo") as! CKAsset
        cell.imageView.image = UIImage(contentsOfFile: imageAsset.fileURL.path!)
        cell.imageView.contentMode = UIViewContentMode.ScaleAspectFit
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    /*
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoCollectionViewCell
        performSegueWithIdentifier(Constant.Identifier.CollectionToDetailSegue, sender: cell)
        return true
    }*/

}

extension PhotoCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
}
