//
//  GridView.swift
//  Lupe
//
//  Created by Bezaleel Ashefor on 12/02/2021.
//

import Foundation
import UIKit

class GridView: UIView {
    private var path = UIBezierPath()
    fileprivate var gridWidthMultiple: CGFloat
    {
        return 7
    }
    fileprivate var gridHeightMultiple : CGFloat
    {
        return 5
    }

    fileprivate var gridWidth: CGFloat
    {
        return bounds.width/CGFloat(gridWidthMultiple)
    }

    fileprivate var gridHeight: CGFloat
    {
        return bounds.height/CGFloat(gridHeightMultiple)
    }

    fileprivate var gridCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }

    fileprivate func drawGrid()
    {
        path = UIBezierPath()
        path.lineWidth = 5.0

        for index in 1...Int(gridWidthMultiple) - 1
        {
            let start = CGPoint(x: CGFloat(index) * gridWidth, y: 0)
            let end = CGPoint(x: CGFloat(index) * gridWidth, y:bounds.height)
            path.move(to: start)
            path.addLine(to: end)
        }

        /*for index in 1...Int(gridHeightMultiple) - 1 {
            let start = CGPoint(x: 0, y: CGFloat(index) * gridHeight)
            let end = CGPoint(x: bounds.width, y: CGFloat(index) * gridHeight)
            path.move(to: start)
            path.addLine(to: end)
        }*/
        
        self.backgroundColor = .systemBackground
        //Close the path.
        path.close()

    }

    override func draw(_ rect: CGRect)
    {
        drawGrid()
        
        self.layer.borderWidth = 5
        self.layer.borderColor = UIColor.white.cgColor
        
        // Specify a border (stroke) color.
        UIColor.white.setStroke()
        path.stroke()
    }
}
