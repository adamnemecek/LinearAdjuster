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
    
    @IBOutlet weak var mtrixView: MtrixView!
    @IBOutlet weak var pdfView: PDFView!
    
    let app: AppDelegate = NSApplication.shared().delegate as! AppDelegate
    
    private var state = ViewState.neutral
    private var preState: ViewState?
    
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
    
    private func changeState(gesture: NSGestureRecognizer, offset: ViewState) {
        switch gesture.state {
        case .began: preState = state
        case .ended: preState = nil
        default: break
        }
        if let pre = preState {
            state = pre + offset
            mtrixView.update(viewState: state)
        }
    }
    
    @IBAction func panGesture(_ sender: Any) {
        if let g = sender as? NSPanGestureRecognizer {
            changeState(gesture: g, offset: ViewState(skew: g.translation(in: mtrixView)))
        }
    }
    
    @IBAction func rotationGesture(_ sender: Any) {
        if let g = sender as? NSRotationGestureRecognizer {
            changeState(gesture: g, offset: ViewState(rotationInDegrees: g.rotationInDegrees))
        }
    }
    
    @IBAction func zoomGesture(_ sender: Any) {
        if let g = sender as? NSMagnificationGestureRecognizer {
            changeState(gesture: g, offset: ViewState(zoom: g.magnification))
        }
    }
}
