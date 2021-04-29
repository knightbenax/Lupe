//
//  GridView.swift
//  Lupe
//
//  Created by Bezaleel Ashefor on 12/02/2021.
//

import Foundation
import UIKit
import PencilKit

class GridOldView: UIView {
    
    private var path = UIBezierPath()
    fileprivate var gridWidthMultiple: CGFloat
    {
        return 7
    }
    fileprivate var gridHeightMultiple : CGFloat
    {
        return 15
    }

    fileprivate var gridWidth: CGFloat
    {
        return frame.width/CGFloat(gridWidthMultiple)
    }

    fileprivate var gridHeight: CGFloat
    {
        return frame.height/CGFloat(gridHeightMultiple)
    }

    fileprivate var gridCenter: CGPoint {
        return CGPoint(x: frame.midX, y: frame.midY)
    }

    fileprivate func drawGrid()
    {
        path = UIBezierPath()
        path.lineWidth = 2.0

//        for index in 1...Int(gridWidthMultiple) - 1
//        {
//            let start = CGPoint(x: CGFloat(index) * gridWidth, y: 0)
//            let end = CGPoint(x: CGFloat(index) * gridWidth, y:bounds.height)
//            path.move(to: start)
//            path.addLine(to: end)
//        }

        for index in 1...Int(gridHeightMultiple) - 1 {
            let start = CGPoint(x: 0, y: CGFloat(index) * gridHeight)
            let end = CGPoint(x: frame.width, y: CGFloat(index) * gridHeight)
            path.move(to: start)
            path.addLine(to: end)
        }
        
        print("Width")
        print(frame.width)
        print(gridHeight)
        self.backgroundColor = .clear
        path.close()

    }

    override func draw(_ rect: CGRect)
    {
        drawGrid()
        UIColor.white.setStroke()
        path.stroke()
    }
}
