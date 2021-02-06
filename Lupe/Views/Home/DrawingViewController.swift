//
//  ViewController.swift
//  Lupe
//
//  Created by Bezaleel Ashefor on 05/02/2021.
//

import UIKit
import PencilKit

class DrawingViewController: BaseViewController {
    
    fileprivate let maxContentEdge = CGFloat(500000)
    var new_canvas = true

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var canvasParent: UIView!
    var toolPicker = PKToolPicker.init()
    var canvas : PKCanvasView!
    var editingDrawingModel : DrawingModel!
    @IBOutlet weak var tagLabel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addPKCanvasView()
    }

    func addPKCanvasView(){
        canvas = PKCanvasView(frame: canvasParent.frame)
        canvas.delegate = self
        canvas.showsVerticalScrollIndicator = false
        canvas.showsHorizontalScrollIndicator = false
        canvas.contentSize = CGSize(width: maxContentEdge, height: maxContentEdge)
        canvas.contentInsetAdjustmentBehavior = .never
        //canvas.maximumZoomScale = 100
        canvasParent.addSubview(canvas)
        canvas.tool = PKInkingTool(.pen, color: .black, width: 1)
    }
    
    func loadCanvasData(){
        if (!new_canvas){
            tagLabel.setTitle(editingDrawingModel.tag, for: .normal)
            let drawingObject = Data(base64Encoded: editingDrawingModel.drawingEntity)
            do {
                try canvas.drawing = PKDrawing(data: drawingObject!)
                print(canvas.drawing)
            } catch let error as NSError {
                print("Couldn't load shit \(error), \(error.userInfo)")
            }
        } else {
            tagLabel.setTitle("unsorted", for: .normal)
        }
    }
    
    var first_time_load = false
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCanvasContentSize()
        if (!first_time_load){
            loadCanvasData()
            first_time_load = true
        }
        showPicker()
    }
    
    @IBAction func goBackHome(_ sender: Any) {
        saveDrawing()
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func clearDrawing(_ sender: Any) {
        canvas.drawing = PKDrawing()
    }
    
    //save the drawing if there is one. And check whether to save a new drawing or edit an old one
    func saveDrawing(){
        if(canvas.drawing.bounds != .zero){
            if (new_canvas){
                let drawing = canvas.drawing.dataRepresentation()
                let drawingString = drawing.base64EncodedString()
                storeHelper.saveDrawing(delegate: delegate, drawing: DrawingModel(dateModified: Date(),
                                                                                  dateCreated: Date(),
                                                                                  drawingEntity: drawingString,
                                                                                  tag: "unsorted"))
            } else {
                editingDrawingModel.dateModified = Date()
                let drawing = canvas.drawing.dataRepresentation()
                let drawingString = drawing.base64EncodedString()
                editingDrawingModel.drawingEntity = drawingString
                storeHelper.editDrawing(delegate: delegate, drawing: editingDrawingModel)
            }
        }
    }
    
    func showPicker(){
        toolPicker.addObserver(canvas)
        toolPicker.setVisible(true, forFirstResponder: canvas)
        toolPicker.setVisible(true, forFirstResponder: backButton)
        toolPicker.selectedTool = PKInkingTool(.pen, color: .black, width: 1)
        canvas.becomeFirstResponder()
    }
    
    func updateCanvasContentSize(){
        let viewportBounds = canvas.bounds
        let margin = UIEdgeInsets(top: -viewportBounds.height, left: -viewportBounds.width, bottom: -viewportBounds.height, right: -viewportBounds.width)
        
        //no drawing
        if (canvas.drawing.bounds.size == .zero){
            let leftInset = (canvas.contentSize.width - viewportBounds.width)/2
            let topInset = (canvas.contentSize.height - viewportBounds.height)/2
            canvas.contentInset = UIEdgeInsets(top: -topInset, left: -leftInset, bottom: -topInset, right: -leftInset)
        } else {
            let realContentBounds = canvas.drawing.bounds.inset(by: margin)
            // consider the useful content as the (drawing + margins) + the viewport, so that the drawing is not
            // scrolled upon updating the content insets, while the user draws something
            let finalContentBounds = realContentBounds.union(viewportBounds)
            // set the insets such a way that you can only scroll the useful content area
            canvas.contentInset = UIEdgeInsets(top: -finalContentBounds.origin.y,
                                               left: -finalContentBounds.origin.x,
                                               bottom: -(canvas.contentSize.height - finalContentBounds.maxY),
                                               right: -(canvas.contentSize.width - finalContentBounds.maxX))
        }
        return
    }
}

extension DrawingViewController: PKCanvasViewDelegate{
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        updateCanvasContentSize()
    }
}

