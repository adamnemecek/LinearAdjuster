//
//  MtrixView.swift
//  Linear Adjuster
//
//  Created by 沢谷邦夫 on 12/1/16.
//  Copyright © 2016 沢谷邦夫. All rights reserved.
//

import Cocoa

fileprivate let unit = CGFloat(100.0)

class MtrixView: NSView, CALayerDelegate {

    override func awakeFromNib() {
        update(viewState: ViewState.identity)
    }

    func update(viewState: ViewState) {
        log.debug("Updating \(viewState)")
        if let layer = self.layer {
            let sub = CALayer()
            sub.bounds = NSRect(x: 0, y: 0, width: 1000, height: 1000)
            sub.backgroundColor = NSColor.white.cgColor
            sub.position = NSPoint(x: 500, y: 500)
            sub.delegate = self
            
            viewState.transform(layer: sub)
            sub.setNeedsDisplay()
            
            layer.sublayers = nil
            layer.addSublayer(sub)
        }
    }

    func draw(_ layer: CALayer, in ctx: CGContext) {
        log.info("Drawing Layer \(layer)")
        
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
