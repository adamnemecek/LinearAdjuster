//
//  AppDelegate.swift
//  Linear Adjuster
//
//  Created by 沢谷邦夫 on 11/28/16.
//  Copyright © 2016 沢谷邦夫. All rights reserved.
//

import Cocoa
import Quartz

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
        print("Opening Dialog...")
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = "Choose PDF"
        panel.allowedFileTypes = ["pdf"]
        panel.begin(completionHandler: { (status) in
            if status == NSModalResponseOK {
                if let url = panel.url {
                    print("Choosed file: \(url)")
                    self.loadPdf(url)
                } else {
                    print("No valid url")
                }
            } else {
                print("No file choosed")
            }
        })
    }
    
    private func loadPdf(_ url: URL) {
        print("Loading PDF: \(url)")
        let pdf = PDFDocument(url: url)
        if let view = pdfView {
            view.document = pdf
        }
    }
}
