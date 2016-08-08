//
//  DrawingTableViewController.swift
//  PartC
//
//  Created by Nam Nguyen on 30/09/2015.
//  Copyright © 2015 latrobe. All rights reserved.
//

import UIKit

class DrawingTableViewController: UITableViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // Switch Storage type
    @IBAction func indexChanged(sender: UISegmentedControl) {
        
        // Update User Defaults
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setInteger(segmentedControl.selectedSegmentIndex, forKey: Constant.DataKey.StorageType)
        prefs.synchronize()
        
        // Update to iCloud
        NSUbiquitousKeyValueStore.defaultStore().setLongLong(Int64(segmentedControl.selectedSegmentIndex), forKey: Constant.DataKey.StorageType)
        NSUbiquitousKeyValueStore.defaultStore().synchronize()
    }
    
    
    private var query: NSMetadataQuery!
    private var drawingURLs: [NSURL] = []
    private var drawingFileNames: [String] = []
    private var deleteIndexPath: NSIndexPath? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadFiles()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onStorageChanged:", name: NSUserDefaultsDidChangeNotification, object: nil)
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    func onStorageChanged(notification: NSNotification) {
        print("Storage type changed")
        reloadFiles()
    }
    
    private func reloadFiles() {
        let prefs = NSUserDefaults.standardUserDefaults()
        let storageType = prefs.integerForKey(Constant.DataKey.StorageType)
        segmentedControl.selectedSegmentIndex = storageType
        if storageType == 0 {
            reloadFilesOnLocal()
        } else if storageType == 1 {
            reloadFilesOnCloud()
        }
    }
    
    private func reloadFilesOnLocal() {
        print("Get files on local")
        drawingFileNames = FileUtil.getFilesOnLocal()
        tableView.reloadData()
    }
    
    private func reloadFilesOnCloud() {
        let fm = NSFileManager.defaultManager()
        let cloudURL = fm.URLForUbiquityContainerIdentifier(nil)
        print("Got cloudURL \(cloudURL)")
        if cloudURL != nil {
            query = NSMetadataQuery()
            query.predicate = NSPredicate(format: "%K like '*.drawing'", NSMetadataItemFSNameKey)
            query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUbiquitousDocuments:", name: NSMetadataQueryDidFinishGatheringNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUbiquitousDocuments:", name: NSMetadataQueryDidUpdateNotification, object: nil)
            query.startQuery()
        }
    }
    
    func updateUbiquitousDocuments(notification: NSNotification) {
        drawingURLs = []
        drawingFileNames = []
        let results = query.results
        print("updateUbiquitousDocuments, results = \(results)")
        for item in results as! [NSMetadataItem] {
            let url = item.valueForAttribute(NSMetadataItemURLKey) as! NSURL
            drawingURLs.append(url)
            let fileName = NSString(string: url.lastPathComponent!)
            drawingFileNames.append(fileName.stringByDeletingPathExtension)
        }
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return drawingFileNames.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DrawingCell")!
        // Configure the cell...
        let fileName = drawingFileNames[indexPath.row]
        cell.textLabel?.text = fileName
        
        return cell
    }
    
    // Remove indent cell bottom line
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if cell.respondsToSelector("setSeparatorInset:") {
            cell.separatorInset = UIEdgeInsetsZero
        }
        if cell.respondsToSelector("setLayoutMargins:") {
            cell.layoutMargins = UIEdgeInsetsZero
        }
        cell.preservesSuperviewLayoutMargins = false
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            deleteIndexPath = indexPath
            let fileToDelete = drawingFileNames[indexPath.row]
            confirmDelete(fileToDelete)
        }
    }
    
    func confirmDelete(fileName: String) {
        let alert = UIAlertController()
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: deleteFile)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: cancelDelete)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func deleteFile(alertAction: UIAlertAction!) -> Void {
        if let indexPath = deleteIndexPath {
            tableView.beginUpdates()
            
            let fileName = drawingFileNames[indexPath.row]
            let fileURL = FileUtil.urlForFileName(fileName)
            print(fileURL)
            let fm = NSFileManager.defaultManager()
            do {
                try fm.removeItemAtURL(fileURL)
            } catch _ { }
            
            drawingFileNames.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            deleteIndexPath = nil
            tableView.endUpdates()
        }
    }
    
    func cancelDelete(alertAction: UIAlertAction!) {
        deleteIndexPath = nil
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let drawingVC = segue.destinationViewController.contentViewController as! DrawingViewController
        drawingVC.delegate = self
        
        if let indexPath = tableView.indexPathForSelectedRow {
            let fileName = drawingFileNames[indexPath.row]
            drawingVC.fileName = fileName
        }
        
    }

}

extension DrawingTableViewController: DrawingDelegate {
    func updateFiles() {
        reloadFiles()
    }
}