//
//  FileUtil.swift
//  PartC
//
//  Created by Nam Nguyen on 2/10/2015.
//  Copyright © 2015 latrobe. All rights reserved.
//

import Foundation

class FileUtil {
    
    // Convert file name to file url on local device/iCloud
    class func urlForFileName(fileName: String, fileExtension: String = "drawing") -> NSURL {
        let fullFileName = "\(fileName).\(fileExtension)"
        
        let fm = NSFileManager.defaultManager()
        let prefs = NSUserDefaults.standardUserDefaults()
        let storageType = prefs.integerForKey(Constant.DataKey.StorageType)
        if storageType == 1 {
            // iCloud
            let baseURL = fm.URLForUbiquityContainerIdentifier(nil)
            let pathURL = baseURL?.URLByAppendingPathComponent("Documents")
            let destinationURL = pathURL?.URLByAppendingPathComponent(fullFileName)
            return destinationURL!
        } else {
            // Local
            let urls = fm.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
            let directoryURL = urls[0]
            let fileURL = directoryURL.URLByAppendingPathComponent(fullFileName)
            return fileURL
        }
    }
    
    // Get all file names of local device
    class func getFilesOnLocal() -> [String] {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let path = paths[0]
        let fm = NSFileManager.defaultManager()
        
        var files = [String]()
        do {
            files = try fm.contentsOfDirectoryAtPath(path)
        } catch _ { }
        
        var fileNames = [String]()
        
        for fileName in files {
            let f = NSString(string: fileName)
            fileNames.append(f.stringByDeletingPathExtension)
        }
        
        return fileNames
    }
    
}