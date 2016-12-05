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
    
    var pdfScale: CGFloat {
        get {
            return detectScreenDPI().width / 72
        }
    }
    
    private var isPdf = false
    
    @IBOutlet weak var mtrixView: MtrixView!
    @IBOutlet weak var pdfView: PDFView!
    
    let app: AppDelegate = NSApplication.shared().delegate as! AppDelegate
    
    private var preState: ViewState?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pdfView.autoScales = false
        pdfView.scaleFactor = pdfScale
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
                pdfView.scaleFactor = pdfScale * currentState.zoom.width
                log.debug("PDF Scale: \(self.pdfView.scaleFactor)")
                currentState.transform(layer: newLayer, withZoom: false)
            } else {
                pdfLayer.isHidden = true
            }
        }
    }
    
    private func changeState(gesture: NSGestureRecognizer? = nil, offset: ViewState) {
        func update() {
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
        if let g = gesture {
            switch g.state {
            case .began: preState = currentState
            case .ended: preState = nil
            default: break
            }
            update()
        } else {
            if preState == nil {
                preState = currentState
                update()
                preState = nil
            }
        }
    }
    
    override func keyDown(with event: NSEvent) {
        if let c = KeyCode(rawValue: event.keyCode) {
            let withCtl = event.modifierFlags.contains(NSEventModifierFlags.control)
            let withCmd = event.modifierFlags.contains(NSEventModifierFlags.command)
            let withOpt = event.modifierFlags.contains(NSEventModifierFlags.option)
            let withSht = event.modifierFlags.contains(NSEventModifierFlags.shift)
            switch c {
            case .keyX where withCtl: switchView()
            case .keyC where withCtl: clear()
            case .keyM where withCtl: mirror()
            
            case .arrowRight where withCmd: warp(+0.001)
            case .arrowLeft where withCmd: warp(-0.001)
            
            case .arrowDown where withCmd && withSht: zoom(y: -0.001)
            case .arrowUp where withCmd && withSht: zoom(y: 0.001)
            case .arrowDown where withCmd: zoom(-0.001)
            case .arrowUp where withCmd: zoom(+0.001)
            
            case .arrowRight where withOpt: skew(x: -0.1)
            case .arrowLeft where withOpt: skew(x: +0.1)
            case .arrowDown where withOpt: skew(y: -0.1)
            case .arrowUp where withOpt: skew(y: +0.1)
            
            default: log.warning("Unsupported keyCode: \(c) with Flags(shift: \(withSht), ctl: \(withCtl), cmd: \(withCmd), opt: \(withOpt))")
            }
        } else {
            log.debug("Pressed key: \(event.keyCode)")
        }
    }
    
    private func clear() {
        if !isPdf && preState == nil {
            currentState = ViewState.identity
        }
    }
    
    private func mirror() {
        changeState(gesture: nil, offset: ViewState.zero.change(mirror: true))
    }
    
    private func skew(_ pos: NSPoint? = nil, x: CGFloat = 0, y: CGFloat = 0, gesture: NSGestureRecognizer? = nil) {
        changeState(gesture: gesture, offset: ViewState.zero.change(skew: pos ?? NSPoint(x: x, y: y)))
    }
    
    private func warp(_ v: CGFloat, gesture: NSGestureRecognizer? = nil) {
        changeState(gesture: gesture, offset: ViewState.zero.change(warp: v))
    }
    
    private func zoom(_ x: CGFloat = 0, y: CGFloat? = nil, gesture: NSGestureRecognizer? = nil) {
        changeState(gesture: gesture, offset: ViewState.zero.change(zoom: NSSize(width: x, height: y ?? x)))
    }
    
    @IBAction func panGesture(_ sender: Any) {
        if let g = sender as? NSPanGestureRecognizer {
            skew(g.translation(in: mtrixView) / 10, gesture: g)
        }
    }
    
    @IBAction func rotationGesture(_ sender: Any) {
        if let g = sender as? NSRotationGestureRecognizer {
            warp(g.rotation, gesture: g)
        }
    }
    
    @IBAction func zoomGesture(_ sender: Any) {
        if let g = sender as? NSMagnificationGestureRecognizer {
            zoom(g.magnification, gesture: g)
        }
    }
}

fileprivate enum KeyCode: UInt16 {
    case keyX = 7
    case keyC = 8
    case keyM = 46
    case arrowUp = 126
    case arrowDown = 125
    case arrowLeft = 124
    case arrowRight = 123
}

fileprivate extension NSPoint {
    static func /(left: NSPoint, right: CGFloat) -> NSPoint {
        return NSPoint(x: left.x / right, y: left.y / right)
    }
}
