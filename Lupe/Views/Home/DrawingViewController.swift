//
//  ViewController.swift
//  Lupe
//
//  Created by Bezaleel Ashefor on 05/02/2021.
//

import UIKit
import PencilKit
import PDFGenerator

class DrawingViewController: BaseViewController {
    
    fileprivate let maxContentEdge = CGFloat(500000)
    var new_canvas = true
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var canvasParent: UIView!
    var toolPicker = PKToolPicker()
    var canvas : PKCanvasView!
    var editingDrawingModel : DrawingModel!
    @IBOutlet weak var tagLabel: UIButton!
    
    let gridView = GridView()
    var exportingCanvas = false
    
    override func viewDidLoad() {
        hideKeyboard = false
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addPKCanvasView()
    }

    func addPKCanvasView(){
        canvas = PKCanvasView(frame: canvasParent.frame)
        canvas.delegate = self
        canvas.showsVerticalScrollIndicator = false
        canvas.showsHorizontalScrollIndicator = false
        canvas.minimumZoomScale = 0.4
        canvas.maximumZoomScale = 8
        canvas.zoomScale = 1
        canvasParent.addSubview(canvas)
        print("Count")
        print(canvasParent.subviews.count)
        print(canvas.subviews.count)
        print(canvas.subviews)
        canvas.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            canvas.topAnchor.constraint(equalTo: canvasParent.topAnchor),
            canvas.leadingAnchor.constraint(equalTo: canvasParent.leadingAnchor),
            canvas.bottomAnchor.constraint(equalTo: canvasParent.bottomAnchor),
            canvas.trailingAnchor.constraint(equalTo: canvasParent.trailingAnchor)
        ])
        
        canvas.contentInsetAdjustmentBehavior = .never
        canvas.contentSize = CGSize(width: maxContentEdge, height: maxContentEdge)
        canvas.tool = PKInkingTool(.pen, color: .black, width: 1)
        
    }
    
    func formatDateToBeauty(thisDate: Date) -> String{
        let dateFormatterPrint = DateFormatter()
        //dateFormatterPrint.locale = Locale(identifier: "en_US")
        dateFormatterPrint.timeZone = TimeZone.current
        dateFormatterPrint.dateFormat = "MMddyy_hh_mm"
        return dateFormatterPrint.string(from: thisDate)
    }
    
    var canvasToPrint : PKCanvasView!

    @IBAction func shareSaveDrawing(_ sender: Any) {
        let drawing = canvas.drawing.bounds
        
        let drawingWidth = drawing.width + 40
        let drawingHeight = drawing.height + 40
        canvasToPrint = PKCanvasView(frame: CGRect(x: drawing.origin.x, y: drawing.origin.y, width: drawingWidth, height: drawingHeight))
        canvasToPrint.delegate = self
        canvasToPrint.contentSize = CGSize(width: drawingWidth, height: drawingHeight)
        canvasToPrint.drawing = canvas.drawing
        canvasToPrint.drawing.transform(using: CGAffineTransform(translationX: -drawing.origin.x + 30, y: -drawing.origin.y + 30))
        canvasToPrint.backgroundColor = .white
        print("bounds")
        print(canvasToPrint.drawing.bounds)
        print(canvasToPrint.bounds)
        exportingCanvas = true
    }
    
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
    
    func setZoomScale(){
        let zoomScale = min(canvas.frame.size.width / canvas.drawing.bounds.size.width, canvas.frame.size.height / canvas.drawing.bounds.size.height)

        if (zoomScale < canvas.minimumZoomScale){
            canvas.zoomScale = canvas.minimumZoomScale
        } else {
            canvas.zoomScale = 1
        }
    }
    
    func loadCanvasData(){
        if (!new_canvas){
            tagLabel.setTitle(editingDrawingModel.tag, for: .normal)
            let drawingObject = Data(base64Encoded: editingDrawingModel.drawingEntity)
            do {
                try canvas.drawing = PKDrawing(data: drawingObject!)
               setZoomScale()
            } catch let error as NSError {
                print("Couldn't load shit \(error), \(error.userInfo)")
            }
        } else {
            canvas.zoomScale = 1
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
        
        showPicker()
    }
    
    private var haveScrolledToInitialOffset = false
    
    private func scrollToInitialContentOffsetIfNecessary() {
        if !haveScrolledToInitialOffset {
            let canvasView = canvas!
            let centerOffsetX = (canvasView.contentSize.width - canvasView.frame.width) / 2
            let centerOffsetY = (canvasView.contentSize.height - canvasView.frame.height) / 2
            canvasView.contentOffset = CGPoint(x: centerOffsetX, y: centerOffsetY)
            haveScrolledToInitialOffset = true
        }
    }
    
    @IBAction func goBackHome(_ sender: Any) {
        saveDrawing()
        navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveDrawing()
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
        let viewportBounds = canvas.bounds

                // no drawing
                if canvas.drawing.bounds.size == .zero {
                    let leftInset = (canvas.contentSize.width - viewportBounds.width)/2
                    let topInset = (canvas.contentSize.height - viewportBounds.height)/2
                    canvas.contentOffset = CGPoint(x: leftInset, y: topInset)
                } else {
                    //let realContentBounds = canvas.drawing.bounds.inset(by: margin)
                    let realContentBounds = CGRect(x: canvas.drawing.bounds.origin.x,
                                                   y: canvas.drawing.bounds.origin.y,
                                                   width: canvas.drawing.bounds.width,
                                                   height: canvas.drawing.bounds.height)

                    // consider the useful content as the (drawing + margins) + the viewport, so that the drawing is not
                    // scrolled upon updating the content insets, while the user draws something
                    let finalContentBounds = realContentBounds.union(viewportBounds)
                    canvas.contentOffset = CGPoint(x: finalContentBounds.origin.x, y: finalContentBounds.origin.y)
                }
                return
    }
    
}

extension DrawingViewController: PKCanvasViewDelegate{
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        //updateCanvasContentSize()
    }
    
    func canvasViewDidFinishRendering(_ canvasView: PKCanvasView) {
        if (exportingCanvas){
            DispatchQueue.main.async { [self] in
                let dateInString = formatDateToBeauty(thisDate: Date()).replacingOccurrences(of: " ", with: "_")
                var name = (tagLabel.currentTitle?.stringByRemovingEmoji())!
                name = name.replacingOccurrences(of: " ", with: "_") + dateInString
                name = name.lowercased()
                
                let dst = URL(fileURLWithPath: NSTemporaryDirectory().appending("lupe_" + name + ".pdf"))
                    // outputs as Data
                    do {
                        let data = try PDFGenerator.generated(by: canvasToPrint)
                        try data.write(to: dst, options: .atomic)
                        let av = UIActivityViewController(activityItems: [dst], applicationActivities: nil)
                        av.popoverPresentationController?.sourceView = shareButton
                        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
                        exportingCanvas = false
                    } catch (let error) {
                        print(error)
                    }
            }
        }
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }

    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return false
    }
    
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        return canvas
//    }
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
