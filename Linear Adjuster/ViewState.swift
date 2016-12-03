//
//  ViewState.swift
//  Linear Adjuster
//
//  Created by 沢谷邦夫 on 12/1/16.
//  Copyright © 2016 沢谷邦夫. All rights reserved.
//

import Foundation
import Cocoa

struct ViewState {
    static let identity = ViewState(zoom: 1, warp: 0, skew: NSPoint(x: 0, y: 0))
    static let zero = ViewState(zoom: 0, warp: 0, skew: NSPoint(x: 0, y: 0))
    
    init(zoom: CGFloat, warp: CGFloat, skew: NSPoint) {
        self.zoom = zoom
        self.warp = warp
        self.skew = skew
    }
    
    let zoom: CGFloat
    let warp: CGFloat
    let skew: NSPoint
    
    func change(zoom: CGFloat? = nil, warp: CGFloat? = nil, skew: NSPoint? = nil) -> ViewState {
        return ViewState(zoom: zoom ?? self.zoom, warp: warp ?? self.warp, skew: skew ?? self.skew)
    }
    
    func transform(layer: CALayer) {
        let center = NSPoint(x: layer.frame.midX, y: layer.frame.midY)

        layer.anchorPoint = NSPoint(x: 0.5, y: 0.5)
        layer.position = center
        layer.transform = {
            var tr = CATransform3DIdentity
            tr.m21 = -warp
            tr.m34 = CGFloat(-1.0/1000)
            tr = CATransform3DRotate(tr, toRadians(fromDegrees: skew.x), 0, 1, 0)
            tr = CATransform3DRotate(tr, toRadians(fromDegrees: skew.y), -1, 0, 0)
            tr = CATransform3DScale(tr, zoom, zoom, zoom)
            
            log.debug("Transforming: \(self) -> \(tr)")
            return tr
        }()
    }
    
    func asDictionary() -> [String: Any] {
        var dict = [String: Any]()
        dict["zoom"] = zoom
        dict["warp"] = warp
        dict["skew.x"] = skew.x
        dict["skew.y"] = skew.y
        return dict
    }
    
    static func load(dictionary dict: [String: Any]) -> ViewState? {
        if
            let zoom = dict["zoom"] as? CGFloat,
            let warp = dict["warp"] as? CGFloat,
            let skewX = dict["skew.x"] as? CGFloat,
            let skewY = dict["skew.y"] as? CGFloat
        {
            return ViewState(zoom: zoom, warp: warp, skew: NSPoint(x: skewX, y: skewY))
        } else {
            log.warning("Cannot load from dictionary: \(dict)")
            return nil
        }
    }
}

extension ViewState {
    static func +(left: ViewState, right: ViewState) -> ViewState {
        return ViewState(
            zoom: left.zoom + right.zoom,
            warp: left.warp + right.warp,
            skew: left.skew + right.skew)
    }
    
    static func -(left: ViewState, right: ViewState) -> ViewState {
        return ViewState(
            zoom: left.zoom - right.zoom,
            warp: left.warp - right.warp,
            skew: left.skew - right.skew)
    }
}

fileprivate extension NSPoint {
    static func +(left: NSPoint, right: NSPoint) -> NSPoint {
        return NSPoint(x: left.x + right.x, y: left.y + right.y)
    }
    static func -(left: NSPoint, right: NSPoint) -> NSPoint {
        return NSPoint(x: left.x - right.x, y: left.y - right.y)
    }
}

fileprivate let pi = CGFloat(M_PI)
fileprivate let p2 = pi * 2

fileprivate func toRadians(fromDegrees: CGFloat) -> CGFloat {
    return fromDegrees * pi / 180
}
