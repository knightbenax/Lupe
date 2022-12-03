//
//  NewDrawingController.swift
//  Lupe
//
//  Created by Bezaleel Ashefor on 17/10/2021.
//

import Foundation
import UIKit
import PencilKit

class NewDrawingController: BaseViewController{
    
    @IBOutlet weak var canvas: PKCanvasView!
    @IBOutlet weak var canvasHolder: UIView!
    @IBOutlet weak var parentScroll: UIScrollView!
    
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    var toolPicker : PKToolPicker!
    var setBool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(canvasHolder.bounds.size)
//        parentScroll.contentSize = CGSize(width: 5000, height: 5000)
//        parentScroll.minimumZoomScale = 0.5
//        parentScroll.maximumZoomScale = 4.0
//        //parentScroll.zoomScale = 2.0
        if #available(iOS 14.0, *) {
            toolPicker = PKToolPicker()
        } else {
            // Fallback on earlier versions
            let window = parent?.view.window
            toolPicker = PKToolPicker.shared(for: window!)
        }
        canvas.tool = PKInkingTool(.pen, color: .black, width: 5)
        //canvas.backgroundColor = UIColor(patternImage: UIImage(named: "grid")!)
        parentScroll.delegate = self
        initToolPicker()
        showPicker()
    }
    
    func initToolPicker(){
        toolPicker.addObserver(canvas)
        toolPicker.setVisible(true, forFirstResponder: canvas)
//        toolPicker.setVisible(true, forFirstResponder: canvasParent)
//        toolPicker.setVisible(true, forFirstResponder: backButton)
//        toolPicker.setVisible(true, forFirstResponder: canvasLockButton)
        toolPicker.setVisible(true, forFirstResponder: view)
        toolPicker.selectedTool = PKInkingTool(.pen, color: .black, width: 5)
    }
    
    private func showPicker(){
        canvas.becomeFirstResponder()
    }
    
    func updateMinZoomScaleForSize(_ size: CGSize) {
      let widthScale = size.width / (canvasHolder.bounds.width + 500)
      let heightScale = size.height / (canvasHolder.bounds.height + 500)
      let minScale = min(widthScale, heightScale)
        
        parentScroll.minimumZoomScale = minScale
        parentScroll.zoomScale = minScale
    }
    
    override func viewWillLayoutSubviews() {
      super.viewWillLayoutSubviews()
      //updateMinZoomScaleForSize(view.bounds.size)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateMinZoomScaleForSize(view.bounds.size)
        if (setBool){
            parentScroll.contentInset = UIEdgeInsets(top: 125, left: 125, bottom: 125, right: 125)
            //parentScroll.contentOffset = CGPoint(x: 200, y: 100)
            setBool = false
            //print("yay")
        }
    }
    
    //2
    func updateConstraintsForSize(_ size: CGSize) {
      //3
        let yOffset = max(0, (size.height - canvasHolder.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
      
        //4
        let xOffset = max(0, (size.width - canvasHolder.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset
        
        view.layoutIfNeeded()
    }

    
}

extension NewDrawingController: UIScrollViewDelegate {
  
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return canvasHolder
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(view.bounds.size)
    }

    
}
