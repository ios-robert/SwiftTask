//: Playground - noun: a place where people can play

import Cocoa
import XCPlayground
import SwiftTask

typealias Progress = (bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
typealias Value = String
typealias Error = NSError

typealias URLSessionTask = Task<Progress, Value, Error>

// for async test
XCPSetExecutionShouldContinueIndefinitely()

//--------------------------------------------------
// Example: URLSession with progress tracking
//--------------------------------------------------

// define task using URLSession instead of Alamofire
let task = URLSessionTask { progress, fulfill, reject, configure in
    
    let url = NSURL(string: "http://httpbin.org/stream/100")!
    let request = NSURLRequest(URL: url)
    
    let session = NSURLSession.sharedSession()
    let downloadTask = session.downloadTaskWithRequest(request) { (location, response, error) in
        
        if let error = error {
            reject(error)
            return
        }
        
        fulfill("Download completed successfully")
    }
    
    // Configure pause/resume/cancel
    configure.pause = {
        downloadTask.suspend()
    }
    configure.resume = {
        downloadTask.resume()
    }
    configure.cancel = {
        downloadTask.cancel()
    }
    
    // Start the download
    downloadTask.resume()
}

task
    .progress { oldProgress, newProgress in
        // print progress
        print("Progress: \(newProgress.bytesWritten)/\(newProgress.totalBytesExpectedToWrite)")
    }
    .then { value, errorInfo -> String in
        if let errorInfo = errorInfo {
            return "ERROR: \(errorInfo.error!.localizedDescription)"
        }
        
        return "\(value!) - Task completed"
    }
    .success { value in
        print("Success: \(value)")
    }
    .failure { error, isCancelled in
        print("Failed: \(error?.localizedDescription ?? "Unknown error"), Cancelled: \(isCancelled)")
    }
