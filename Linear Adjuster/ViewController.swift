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
        case .began: preState = app.viewState
        case .ended: preState = nil
        default: break
        }
        if let pre = preState {
            let state = pre + offset
            
            func limit<N: FloatingPoint>(_ v: N, _ l: N) -> N {
                return min(max(v, -l), l)
            }
            app.viewState = state.change(skew: NSPoint(
                x: limit(state.skew.x, 45),
                y: limit(state.skew.y, 45)))
            mtrixView.update(viewState: app.viewState)
        }
    }
    
    @IBAction func panGesture(_ sender: Any) {
        if let g = sender as? NSPanGestureRecognizer {
            changeState(gesture: g, offset: ViewState.zero.change(skew: g.translation(in: mtrixView)))
        }
    }
    
    @IBAction func rotationGesture(_ sender: Any) {
        if let g = sender as? NSRotationGestureRecognizer {
            changeState(gesture: g, offset: ViewState.zero.change(rotation: g.rotation))
        }
    }
    
    @IBAction func zoomGesture(_ sender: Any) {
        if let g = sender as? NSMagnificationGestureRecognizer {
            changeState(gesture: g, offset: ViewState.zero.change(zoom: g.magnification))
        }
    }
}
