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
    static let identity = ViewState(zoom: 1, warp: 0, skew: NSPoint(x: 0, y: 0), mirror: false)
    static let zero = ViewState(zoom: 0, warp: 0, skew: NSPoint(x: 0, y: 0), mirror: false)
    
    init(zoom: CGFloat, warp: CGFloat, skew: NSPoint, mirror: Bool) {
        self.zoom = zoom
        self.warp = warp
        self.skew = skew
        self.mirror = mirror
    }
    
    let zoom: CGFloat
    let warp: CGFloat
    let skew: NSPoint
    let mirror: Bool
    
    func change(zoom: CGFloat? = nil, warp: CGFloat? = nil, skew: NSPoint? = nil, mirror: Bool? = nil) -> ViewState {
        return ViewState(zoom: zoom ?? self.zoom, warp: warp ?? self.warp, skew: skew ?? self.skew, mirror: mirror ?? self.mirror)
    }
    
    func transform(layer: CALayer) {
        let center = NSPoint(x: layer.frame.midX, y: layer.frame.midY)

        layer.anchorPoint = NSPoint(x: 0.5, y: 0.5)
        layer.position = center
        layer.transform = {
            let mr = CGFloat(1 - 2 * (mirror ? 1 : 0))
            var tr = CATransform3DIdentity
            tr.m21 = -warp * mr
            tr.m34 = CGFloat(-1.0/1000)
            tr = CATransform3DRotate(tr, toRadians(fromDegrees: skew.x), 0, 1, 0)
            tr = CATransform3DRotate(tr, toRadians(fromDegrees: skew.y), -1, 0, 0)
            tr = CATransform3DScale(tr, zoom, zoom, zoom)
            tr.m11 = tr.m11 * mr
            
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
        dict["mirror"] = mirror
        return dict
    }
    
    static func load(dictionary dict: [String: Any]) -> ViewState? {
        if
            let zoom = dict["zoom"] as? CGFloat,
            let warp = dict["warp"] as? CGFloat,
            let skewX = dict["skew.x"] as? CGFloat,
            let skewY = dict["skew.y"] as? CGFloat,
            let mirror = dict["mirror"] as? Bool
        {
            return ViewState(zoom: zoom, warp: warp, skew: NSPoint(x: skewX, y: skewY), mirror: mirror)
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
            skew: left.skew + right.skew,
            mirror: left.mirror != right.mirror)
    }
    
    static func -(left: ViewState, right: ViewState) -> ViewState {
        return ViewState(
            zoom: left.zoom - right.zoom,
            warp: left.warp - right.warp,
            skew: left.skew - right.skew,
            mirror: left.mirror != right.mirror)
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
