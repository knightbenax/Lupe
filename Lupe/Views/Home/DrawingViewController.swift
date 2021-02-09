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
    var maxScaleFromMinScale: CGFloat = 3.0

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
        canvas.minimumZoomScale = 1
        canvas.maximumZoomScale = 100
        canvas.contentInsetAdjustmentBehavior = .never
        //canvas.drawingPolicy = .anyInput
        //canvas.maximumZoomScale = 100
        canvasParent.addSubview(canvas)
        canvas.tool = PKInkingTool(.pen, color: .black, width: 1)
    }
    
//    func listenForPencilTaps(){
//        let interaction = UIPencilInteraction()
//        interaction.delegate = self
//        view.addInteraction(interaction)
//    }
    @IBAction func showDrawingTagForm(_ sender: Any) {
        displayForm(message: "Tag this drawing e.g Ideas💡")
    }
    
    var drawingTagField : UITextField!
    
    func displayForm(message:String){
        //create alert
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        //create cancel button
        let cancelAction = UIAlertAction(title: "Cancel" , style: .cancel)
        //create save button
        let saveAction = UIAlertAction(title: "Save", style: .default) { [self] (action) -> Void in
            if (drawingTagField.text != ""){
                tagLabel.setTitle(drawingTagField.text, for: .normal)
            }
            //validation logic goes here
        }
            
            //add button to alert
            alert.addAction(cancelAction)
            alert.addAction(saveAction)
            
            //create first name textfield
        alert.addTextField(configurationHandler: { [self](textField: UITextField!) in
                textField.placeholder = "Write the tag here"
                textField.text = tagLabel.currentTitle
                self.drawingTagField = textField
            })
            
        alert.popoverPresentationController?.sourceView = tagLabel
        alert.popoverPresentationController?.sourceRect = tagLabel.bounds
        alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        
            self.present(alert, animated: true, completion: nil)
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
            initToolPicker()
        }
        
        //setMaxMinZoomScalesForCurrentBounds()
        print("Values")
        print(canvas.minimumZoomScale)
        print(canvas.maximumZoomScale)
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
                                                                                  tag: tagLabel.currentTitle ?? "unsorted"))
            } else {
                editingDrawingModel.dateModified = Date()
                let drawing = canvas.drawing.dataRepresentation()
                let drawingString = drawing.base64EncodedString()
                editingDrawingModel.drawingEntity = drawingString
                editingDrawingModel.tag = tagLabel.currentTitle ?? "unsorted"
                storeHelper.editDrawing(delegate: delegate, drawing: editingDrawingModel)
            }
        }
    }
    
    func initToolPicker(){
        toolPicker.addObserver(canvas)
        toolPicker.setVisible(true, forFirstResponder: canvas)
        toolPicker.setVisible(true, forFirstResponder: canvasParent)
        toolPicker.setVisible(true, forFirstResponder: backButton)
        toolPicker.setVisible(true, forFirstResponder: canvasLockButton)
        toolPicker.setVisible(true, forFirstResponder: view)
        toolPicker.selectedTool = PKInkingTool(.pen, color: .black, width: 1)
    }
    
    func showPicker(){
        canvas.becomeFirstResponder()
        
    }
    
    @IBOutlet weak var canvasLockButton: UIButton!
    
    @IBAction func lockAndUnlockCanvas(_ sender: Any) {
        if (canvas.isScrollEnabled){
            canvas.isScrollEnabled = false
            canvasLockButton.setImage(UIImage(systemName: "lock"), for: .normal)
        } else {
            canvas.isScrollEnabled = true
            canvasLockButton.setImage(UIImage(systemName: "lock.open"), for: .normal)
        }
    }
    
    
    func updateCanvasContentSize(){
        print("yas")
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
    
    private func setMaxMinZoomScalesForCurrentBounds() {
        // calculate min/max zoomscale
        let xScale = canvas.bounds.width / canvas.contentSize.width    // the scale needed to perfectly fit the image width-wise
        let yScale = canvas.bounds.height / canvas.contentSize.height   // the scale needed to perfectly fit the image height-wise
    
        var minScale: CGFloat = 1
        minScale = max(xScale, yScale)
        
        
        let maxScale = maxScaleFromMinScale*minScale
        
        // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
        if minScale > maxScale {
            minScale = maxScale
        }
        
        canvas.maximumZoomScale = maxScale
        canvas.minimumZoomScale = minScale * 0.999 // the multiply factor to prevent user cannot scroll page while they use this control in UIPageViewController
    }
}

extension DrawingViewController: PKCanvasViewDelegate{
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        updateCanvasContentSize()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return canvas
    }
}


//extension DrawingViewController: UIPencilInteractionDelegate{
//    func pencilInteractionDidTap(_ interaction: UIPencilInteraction) {
//        print("yes, did double tap")
//    }
//}


//let context = LAContext()
//    var error: NSError?
//
//    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
//        let reason = "Identify yourself!"
//
//        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
//            [weak self] success, authenticationError in
//
//            DispatchQueue.main.async {
//                if success {
//                    self?.unlockSecretMessage()
//                } else {
//                    // error
//                }
//            }
//        }
//    } else {
//        // no biometry
//    }
