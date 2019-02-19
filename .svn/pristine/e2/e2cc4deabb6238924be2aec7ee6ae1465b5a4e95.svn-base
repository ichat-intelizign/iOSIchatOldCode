//
//  MessageBubbleView.swift
//  MessageBubbleDemo
//
//  Created by Kyle Haptonstall on 9/6/17.
//  Copyright © 2017 Kyle Haptonstall. All rights reserved.
//

import UIKit

class MessageBubbleView: UIView {
    
    override func draw(_ rect: CGRect) {
        let bezierPath = UIBezierPath()
        //Draw main body
        bezierPath.move(to: CGPoint(x: rect.minX, y: rect.minY))
        bezierPath.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        bezierPath.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 10.0))
        bezierPath.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - 10.0))
        bezierPath.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        //Draw the tail
//        bezierPath.move(to: CGPoint(x: rect.maxX - 25.0, y: rect.maxY - 10.0))
//        bezierPath.addLine(to: CGPoint(x: rect.maxX - 10.0, y: rect.maxY))
//        bezierPath.addLine(to: CGPoint(x: rect.maxX - 10.0, y: rect.maxY - 10.0))
        // Draw the tail left
        bezierPath.move(to: CGPoint(x: rect.minX + 25.0, y: rect.maxY - 10.0))
        bezierPath.addLine(to: CGPoint(x: rect.minX + 10.0, y: rect.maxY))
        bezierPath.addLine(to: CGPoint(x: rect.minX + 10.0, y: rect.maxY - 10.0))
        UIColor(rgb: 0xE6E7E8, alphaVal: 1).setFill()
        //UIColor.lightGray.setFill()
        bezierPath.fill()
        bezierPath.close()
    }
    
}
