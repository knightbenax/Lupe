//
//  LupeCanvasView.swift
//  Lupe
//
//  Created by Bezaleel Ashefor on 28/04/2021.
//

import Foundation
import UIKit
import PencilKit

class LupeCanvasView: PKCanvasView {
    
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        //feedbackGenerator.prepare()
        //feedbackGenerator.impactOccurred()
        touches.forEach { (touch) in
            print("touch location \(touch.location(in: self))")
        }
    }
}
