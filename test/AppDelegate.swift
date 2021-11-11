//
//  AppDelegate.swift
//  test
//
//  Created by Ricardo on 10/11/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, URLSessionDownloadDelegate {
  
    let defaultUrl = "https://brgweb.com.br/simple_counter.php"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Logger.log("app started")
        initializeFetchUrlMethodChannel()
        return true
    }
    
    func initializeFetchUrlMethodChannel(){
        fetchUrl(url: defaultUrl)
    }

    func fetchUrl(url: String) -> Void{
        let id = url+String(format: "%f", NSDate().timeIntervalSince1970)
       Logger.log("call "+id)
        lazy var urlSession: URLSession = {
                    let configuration = URLSessionConfiguration.background(withIdentifier: id)
                    configuration.sessionSendsLaunchEvents = true
                    configuration.isDiscretionary = false
                    configuration.waitsForConnectivity = true
                  return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
                }()
        let backgroundTask = urlSession.downloadTask(with: URL.init(string: url)!)
        Logger.log("fetch " + url);
        backgroundTask.resume()
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL){
        Logger.log("didFinishDownloadingTo " + location.path);
        fetchUrl(url: defaultUrl)
        
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?){
        Logger.log("didBecomeInvalidWithError " + error.debugDescription);
        fetchUrl(url: defaultUrl)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?){
        Logger.log("didCompleteWithError " + error.debugDescription)
        fetchUrl(url: defaultUrl)
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        Logger.log("urlSessionDidFinishEvents")
        fetchUrl(url: defaultUrl)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if totalBytesExpectedToWrite > 0 {
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            let progressPercentage = progress * 100
            Logger.log("Download with task identifier: \(downloadTask.taskIdentifier) is \(progressPercentage)% complete...")
        }
    }
}

class Logger {

    static var logFile: URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        print(documentsDirectory)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let dateString = formatter.string(from: Date())
        let fileName = "\(dateString).log"
        return documentsDirectory.appendingPathComponent(fileName)
    }

    static func log(_ message: String) {
        guard let logFile = logFile else {
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let timestamp = formatter.string(from: Date())
        guard let data = (timestamp + ": " + message + "\n").data(using: String.Encoding.utf8) else { return }

        if FileManager.default.fileExists(atPath: logFile.path) {
            if let fileHandle = try? FileHandle(forWritingTo: logFile) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
                print(data)
            }
        } else {
            try? data.write(to: logFile, options: .atomicWrite)
        }
    }
}
