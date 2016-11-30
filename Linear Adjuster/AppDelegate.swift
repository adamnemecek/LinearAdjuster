//
//  AppDelegate.swift
//  Linear Adjuster
//
//  Created by 沢谷邦夫 on 11/28/16.
//  Copyright © 2016 沢谷邦夫. All rights reserved.
//

import Cocoa
import Quartz
import XCGLogger

let log: XCGLogger = {
    let log = XCGLogger.default
    #if DEBUG
        log.setup(level: .debug, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil, fileLevel: .debug)
    #else
        log.setup(level: .severe, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: false, writeToFile: nil, fileLevel: .debug)
    #endif
    return log
}()


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var pdfView: PDFView?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func openFile(_ sender: Any) {
        log.info("Opening Dialog...")
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = "Choose PDF"
        panel.allowedFileTypes = ["pdf"]
        panel.begin(completionHandler: { (status) in
            if status == NSModalResponseOK {
                if let url = panel.url {
                    log.debug("Choosed file: \(url)")
                    self.loadPdf(url)
                } else {
                    log.warning("No valid url")
                }
            } else {
                log.info("No file choosed")
            }
        })
    }
    
    private func loadPdf(_ url: URL) {
        print("Loading PDF: \(url)")
        if let view = pdfView {
            let pdf = PDFDocument(url: url)
            view.document = pdf
        }
    }
}
