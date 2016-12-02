//
//  MtrixView.swift
//  Linear Adjuster
//
//  Created by 沢谷邦夫 on 12/1/16.
//  Copyright © 2016 沢谷邦夫. All rights reserved.
//

import Cocoa

fileprivate let dpi: CGFloat = 120
fileprivate let unit = dpi / 2.54
fileprivate let canvasSize = NSSize(width: unit * 30, height: unit * 30)

class MtrixView: NSView {
    private let mtrix = Mtrix()

    override func awakeFromNib() {
        update(viewState: ViewState.identity)
    }
    
    func update(viewState: ViewState) {
        log.debug("Updating \(viewState)")
        if let layer = self.layer {
            let sub = CALayer()
            sub.bounds = NSRect(origin: NSPoint.zero, size: canvasSize)
            sub.backgroundColor = NSColor.white.cgColor
            sub.delegate = mtrix
            
            viewState.transform(layer: sub)
            
            layer.sublayers = nil
            layer.addSublayer(sub)
            
            needsDisplay = true
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        log.debug("Drawing \(self)")
        
        if let sub = layer?.sublayers?.first {
            sub.position = NSPoint(x: frame.midX, y: frame.midY)
            log.debug("Set layer position: \(sub.position)")
            
            sub.setNeedsDisplay()
        }
    }
}

fileprivate class Mtrix: NSObject, CALayerDelegate {
    
    func draw(_ layer: CALayer, in ctx: CGContext) {
        log.debug("Drawing Mtrix \(self)")
        
        let rect = ctx.boundingBoxOfClipPath
        
        let start = NSPoint(x: rect.minX, y: rect.minY)
        let end = NSPoint(x: rect.maxX, y: rect.maxY)
        
        ctx.setLineWidth(1)
        
        for i in 0...Int(rect.width / unit) {
            let x = CGFloat(i) * unit
            ctx.move(to: NSPoint(x: x, y: start.y))
            ctx.addLine(to: NSPoint(x: x, y: end.y))
        }
        for i in 0...Int(rect.height / unit) {
            let y = CGFloat(i) * unit
            ctx.move(to: NSPoint(x: start.x, y: y))
            ctx.addLine(to: NSPoint(x: end.x, y: y))
        }
        ctx.strokePath()
    }
}
