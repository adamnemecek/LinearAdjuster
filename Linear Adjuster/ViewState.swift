//
//  ViewState.swift
//  Linear Adjuster
//
//  Created by 沢谷邦夫 on 12/1/16.
//  Copyright © 2016 沢谷邦夫. All rights reserved.
//

import Foundation

struct ViewState {
    static let neutral = ViewState(zoom: 1, rotationInDegrees: 0, skew: NSPoint(x: 0, y: 0))
    
    init(zoom: CGFloat = 0, rotationInDegrees: CGFloat = 0, skew: NSPoint = NSPoint(x: 0, y: 0)) {
        self.zoom = zoom
        self.rotationInDegrees = rotationInDegrees
        self.skew = skew
    }
    
    let zoom: CGFloat
    let rotationInDegrees: CGFloat
    let skew: NSPoint
}

extension ViewState {
    static func +(left: ViewState, right: ViewState) -> ViewState {
        return ViewState(
            zoom: left.zoom + right.zoom,
            rotationInDegrees: normalize(degrees: left.rotationInDegrees + right.rotationInDegrees),
            skew: left.skew + right.skew)
    }
    
    static func -(left: ViewState, right: ViewState) -> ViewState {
        return ViewState(
            zoom: left.zoom - right.zoom,
            rotationInDegrees: normalize(degrees: left.rotationInDegrees - right.rotationInDegrees),
            skew: left.skew - right.skew)
    }
}

fileprivate func normalize(degrees: CGFloat) -> CGFloat {
    let v = (degrees + 360).truncatingRemainder(dividingBy: 360)
    if 180 < v {
        return v - 360
    } else {
        return v
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
