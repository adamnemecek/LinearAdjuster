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
    static let identity = ViewState(zoom: 1, rotation: 0, skew: NSPoint(x: 0, y: 0))
    
    init(zoom: CGFloat = 0, rotation: CGFloat = 0, skew: NSPoint = NSPoint(x: 0, y: 0)) {
        self.zoom = zoom
        self.rotation = rotation
        self.skew = (h: skew.x, v: skew.y)
    }
    
    let zoom: CGFloat
    let rotation: CGFloat
    let skew: (h: CGFloat, v: CGFloat)
    
    func transform(layer: CALayer) {
        log.debug("Transforming: \(self)")

        func setAffine() {
            var affine = CGAffineTransform()
            affine = affine.scaledBy(x: zoom, y: zoom)
            layer.setAffineTransform(affine)
        }
        func setTransform() {
            var tr = CATransform3DIdentity
            tr.m34 = CGFloat(-1.0/2000)
            tr = CATransform3DRotate(tr, -rotation, 0, 0, 1)
            tr = CATransform3DRotate(tr, toRadians(fromDegrees: skew.h), 0, 1, 0)
            tr = CATransform3DRotate(tr, -toRadians(fromDegrees: skew.v), 1, 0, 0)
            log.debug("Transform3D: \(tr)")
            layer.transform = tr
        }
        setTransform()
        setAffine()
    }
}

extension ViewState {
    static func +(left: ViewState, right: ViewState) -> ViewState {
        return ViewState(
            zoom: left.zoom + right.zoom,
            rotation: normalize(radians: left.rotation + right.rotation),
            skew: NSPoint(x: left.skew.h + right.skew.h, y: left.skew.v + right.skew.v))
    }
    
    static func -(left: ViewState, right: ViewState) -> ViewState {
        return ViewState(
            zoom: left.zoom - right.zoom,
            rotation: normalize(radians: left.rotation - right.rotation),
            skew: NSPoint(x: left.skew.h - right.skew.h, y: left.skew.v - right.skew.v))
    }
}

fileprivate let pi = CGFloat(M_PI)
fileprivate let p2 = pi * 2

fileprivate func normalize(radians: CGFloat) -> CGFloat {
    let v = (radians + p2).truncatingRemainder(dividingBy: p2)
    if pi < v {
        return v - p2
    } else {
        return v
    }
}

fileprivate func toRadians(fromDegrees: CGFloat) -> CGFloat {
    return fromDegrees * pi / 180
}
