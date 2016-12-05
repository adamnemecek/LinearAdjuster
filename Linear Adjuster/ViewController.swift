//
//  ViewController.swift
//  Linear Adjuster
//
//  Created by 沢谷邦夫 on 11/28/16.
//  Copyright © 2016 沢谷邦夫. All rights reserved.
//

import Cocoa
import Quartz

protocol ViewStateKeeper {
    var currentState: ViewState { get set }
}

class ViewController: NSViewController, ViewStateKeeper {
    private var _currentState = ViewState.identity
    var currentState: ViewState {
        get {
            return _currentState
        }
        set {
            _currentState = newValue
            mtrixView.update(viewState: newValue)
        }
    }
    
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
        app.view = self
        log.debug("App view set.")
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    private func changeState(gesture: NSGestureRecognizer, offset: ViewState) {
        switch gesture.state {
        case .began: preState = currentState
        case .ended: preState = nil
        default: break
        }
        update(offset)
    }
    
    private func update(_ offset: ViewState) {
        if let pre = preState {
            let state = pre + offset
            
            func limit<N: FloatingPoint>(_ v: N, _ l: N) -> N {
                return min(max(v, -l), l)
            }
            currentState = state.change(skew: NSPoint(
                x: limit(state.skew.x, 45),
                y: limit(state.skew.y, 45)))
        }
    }
    
    override func keyDown(with event: NSEvent) {
        let u: CGFloat = 0.1
        let c = Int(event.keyCode)
        switch c {
        case 123: skew(x: -u)
        case 124: skew(x: +u)
        case 125: skew(y: -u)
        case 126: skew(y: +u)
        case 46 where event.modifierFlags.contains(NSEventModifierFlags.control): mirror()
        default: log.debug("Pressed key: \(c)")
        }
    }
    
    private func mirror() {
        if preState == nil {
            preState = currentState
            update(ViewState.zero.change(mirror: true))
            preState = nil
        }
    }
    
    private func skew(x: CGFloat = 0, y: CGFloat = 0) {
        if preState == nil {
            preState = currentState
            update(ViewState.zero.change(skew: NSPoint(x: x, y: y)))
            preState = nil
        }
    }
    
    @IBAction func panGesture(_ sender: Any) {
        if let g = sender as? NSPanGestureRecognizer {
            changeState(gesture: g, offset: ViewState.zero.change(skew: g.translation(in: mtrixView) / 10))
        }
    }
    
    @IBAction func rotationGesture(_ sender: Any) {
        if let g = sender as? NSRotationGestureRecognizer {
            changeState(gesture: g, offset: ViewState.zero.change(warp: g.rotation))
        }
    }
    
    @IBAction func zoomGesture(_ sender: Any) {
        if let g = sender as? NSMagnificationGestureRecognizer {
            changeState(gesture: g, offset: ViewState.zero.change(zoom: g.magnification))
        }
    }
}

fileprivate extension NSPoint {
    static func /(left: NSPoint, right: CGFloat) -> NSPoint {
        return NSPoint(x: left.x / right, y: left.y / right)
    }
}
