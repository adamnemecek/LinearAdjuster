//
//  ViewController.swift
//  Linear Adjuster
//
//  Created by 沢谷邦夫 on 11/28/16.
//  Copyright © 2016 沢谷邦夫. All rights reserved.
//

import Cocoa
import Quartz

class ViewController: NSViewController {
    
    @IBOutlet weak var pdfView: PDFView!
    
    let app: AppDelegate = NSApplication.shared().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pdfView.autoScales = false
        pdfView.scaleFactor = 1.0
        pdfView.displaysPageBreaks = false

        app.pdfView = pdfView
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

