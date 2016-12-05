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
    
    private var isPdf = false
    
    @IBOutlet weak var mtrixView: MtrixView!
    @IBOutlet weak var pdfView: PDFView!
    
    let app: AppDelegate = NSApplication.shared().delegate as! AppDelegate
    
    private var preState: ViewState?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pdfView.layer?.isHidden = !isPdf

        app.pdfView = pdfView
        app.view = self
        log.debug("App view set.")
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    private func switchView() {
        log.info("Switching view...")
        if let mtrixLayer = mtrixView.layer, let pdfLayer = pdfView.layer {
            isPdf = !isPdf
            mtrixLayer.isHidden = isPdf
            if isPdf {
                let newLayer = CALayer()
                pdfView.layer = newLayer
                currentState.transform(layer: newLayer)
            } else {
                pdfLayer.isHidden = true
            }
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
    
    private func changeState(_ offset: ViewState) {
        if preState == nil {
            preState = currentState
            update(offset)
            preState = nil
        }
    }
    
    private func update(_ offset: ViewState) {
        if !isPdf, let pre = preState {
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
        let c = Int(event.keyCode)
        let withCtl = event.modifierFlags.contains(NSEventModifierFlags.control)
        let withCmd = event.modifierFlags.contains(NSEventModifierFlags.command)
        switch c {
        case 7 where withCtl: switchView()
        case 46 where withCtl: mirror()
        case 123 where withCmd: warp(+0.001)
        case 124 where withCmd: warp(-0.001)
        case 125 where withCmd: zoom(-0.001)
        case 126 where withCmd: zoom(+0.001)
        case 123: skew(x: -0.1)
        case 124: skew(x: +0.1)
        case 125: skew(y: -0.1)
        case 126: skew(y: +0.1)
        default: log.debug("Pressed key: \(c)")
        }
    }
    
    private func mirror() {
        changeState(ViewState.zero.change(mirror: true))
    }
    
    private func skew(x: CGFloat = 0, y: CGFloat = 0) {
        changeState(ViewState.zero.change(skew: NSPoint(x: x, y: y)))
    }
    
    private func warp(_ v: CGFloat) {
        changeState(ViewState.zero.change(warp: v))
    }
    
    private func zoom(_ v: CGFloat) {
        changeState(ViewState.zero.change(zoom: v))
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
