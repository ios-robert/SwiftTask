import Foundation
import PlaygroundSupport
import Alamofire

// Enable indefinite execution for async operations
PlaygroundPage.current.needsIndefiniteExecution = true

print("Testing Alamofire 5.x in Playground...")

// Simple GET request test
AF.request("https://httpbin.org/get")
    .responseJSON { response in
        switch response.result {
        case .success(let value):
            print("✅ Success: \(value)")
        case .failure(let error):
            print("❌ Error: \(error)")
        }
        
        // Finish playground execution
        PlaygroundPage.current.finishExecution()
    }

print("Request sent, waiting for response...")
