import Foundation
import PlaygroundSupport
import Alamofire

// Enable indefinite execution for async operations
PlaygroundPage.current.needsIndefiniteExecution = true

print("Testing Alamofire 5.x with Download Progress...")

// Create a simple Task-like structure for demonstration
class SimpleTask<Progress, Value, Error> {
    typealias ProgressHandler = (Progress?, Progress) -> Void
    typealias SuccessHandler = (Value) -> Void
    typealias FailureHandler = (Error?, Bool) -> Void
    
    private var progressHandlers: [ProgressHandler] = []
    private var successHandlers: [SuccessHandler] = []
    private var failureHandlers: [FailureHandler] = []
    
    func progress(_ handler: @escaping ProgressHandler) -> SimpleTask {
        progressHandlers.append(handler)
        return self
    }
    
    func success(_ handler: @escaping SuccessHandler) -> SimpleTask {
        successHandlers.append(handler)
        return self
    }
    
    func failure(_ handler: @escaping FailureHandler) -> SimpleTask {
        failureHandlers.append(handler)
        return self
    }
    
    func notifyProgress(_ oldProgress: Progress?, _ newProgress: Progress) {
        progressHandlers.forEach { $0(oldProgress, newProgress) }
    }
    
    func notifySuccess(_ value: Value) {
        successHandlers.forEach { $0(value) }
    }
    
    func notifyFailure(_ error: Error?, _ isCancelled: Bool) {
        failureHandlers.forEach { $0(error, isCancelled) }
    }
}

// Define progress type similar to original
typealias Progress = (bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
typealias AlamofireTask = SimpleTask<Progress, String, NSError>

// Create the task
let task = AlamofireTask()

// Set up handlers
task
    .progress { oldProgress, newProgress in
        let percentage = newProgress.totalBytesExpectedToWrite > 0 
            ? Double(newProgress.totalBytesWritten) / Double(newProgress.totalBytesExpectedToWrite) * 100 
            : 0
        print("📊 Progress: \(newProgress.totalBytesWritten)/\(newProgress.totalBytesExpectedToWrite) bytes (\(String(format: "%.1f", percentage))%)")
    }
    .success { result in
        print("✅ Task completed successfully: \(result)")
        PlaygroundPage.current.finishExecution()
    }
    .failure { error, isCancelled in
        print("❌ Task failed: \(error?.localizedDescription ?? "Unknown error"), cancelled: \(isCancelled)")
        PlaygroundPage.current.finishExecution()
    }

// Perform the actual Alamofire download
print("🚀 Starting download with Alamofire 5.x...")

let destination: DownloadRequest.Destination = { _, _ in
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileURL = documentsURL.appendingPathComponent("test_download.json")
    return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
}

var lastProgress: Progress?

AF.download("https://httpbin.org/json", to: destination)
    .downloadProgress { downloadProgress in
        let currentProgress = (
            bytesWritten: downloadProgress.completedUnitCount,
            totalBytesWritten: downloadProgress.completedUnitCount,
            totalBytesExpectedToWrite: downloadProgress.totalUnitCount
        )
        
        task.notifyProgress(lastProgress, currentProgress)
        lastProgress = currentProgress
    }
    .response { response in
        if let error = response.error {
            task.notifyFailure(error as NSError, false)
        } else {
            task.notifySuccess("Download completed successfully!")
        }
    }

print("⏳ Download request sent, waiting for completion...")
