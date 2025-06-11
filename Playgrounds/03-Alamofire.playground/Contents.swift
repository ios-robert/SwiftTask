//: Playground - noun: a place where people can play

import Foundation
import PlaygroundSupport

//
// NOTE: custom framework needs to be built first (and restart Xcode if needed)
//
// Importing Custom Frameworks Into a Playground
// https://developer.apple.com/library/prerelease/ios/recipes/Playground_Help/Chapters/ImportingaFrameworkIntoaPlayground.html
//
import SwiftTask
import Alamofire

typealias Progress = (bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
typealias Value = String
typealias Error = NSError

typealias AlamofireTask = Task<Progress, Value, Error>

let myError = NSError(domain: "MyErrorDomain", code: 0, userInfo: nil)

// for async test - Updated for modern PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

//--------------------------------------------------
// Example 1: Alamofire progress (Updated for Alamofire 5.x)
//--------------------------------------------------

// define task
let task = AlamofireTask { progress, fulfill, reject, configure in
    
    // Updated for Alamofire 5.x API
    let destination: DownloadRequest.Destination = { _, _ in
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("stream.txt")
        return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
    }
    
    let request = AF.download("https://httpbin.org/stream/100", to: destination)
        
    request
        .downloadProgress { downloadProgress in
            let progressTuple = (
                bytesWritten: downloadProgress.completedUnitCount,
                totalBytesWritten: downloadProgress.completedUnitCount,
                totalBytesExpectedToWrite: downloadProgress.totalUnitCount
            )
            progress(progressTuple as Progress)
        }
        .response { response in
            
            // print
            print("Response: \(response)")
            
            if let error = response.error {
                print("Error: \(error.localizedDescription)")
                reject(error as NSError)
                return
            }
            
            fulfill("OK")
        }
    
    // Configure pause/resume/cancel for the request
    configure.pause = {
        request.suspend()
    }
    configure.resume = {
        request.resume()
    }
    configure.cancel = {
        request.cancel()
    }
}

task
    .progress { oldProgress, newProgress in
        // print progress
        print("Progress: \(newProgress.totalBytesWritten)/\(newProgress.totalBytesExpectedToWrite)")
    }
    .then { value, errorInfo -> String in
        if let errorInfo = errorInfo {
            return "ERROR: \(errorInfo.error!.domain)"
        }
        
        return "\(value!) World"
    }
    .success { result in
        print("Final result: \(result)")
        PlaygroundPage.current.finishExecution()
    }
    .failure { error, isCancelled in
        print("Task failed: \(error?.localizedDescription ?? "Unknown error"), cancelled: \(isCancelled)")
        PlaygroundPage.current.finishExecution()
    }
