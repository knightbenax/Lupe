//
//  HomeViewController.swift
//  Lupe
//
//  Created by Bezaleel Ashefor on 06/02/2021.
//

import Foundation
import UIKit

class HomeViewController: BaseViewController {
    
    @IBOutlet weak var drawingsList: UICollectionView!
    let dashboardPadding : CGFloat = 12
    let interItemSpacing : CGFloat = 0
    var refreshControl = UIRefreshControl()
    let refreshTitle = "Refreshing your drawings"
    var drawingModels = [DrawingModel]()
    
    @IBOutlet weak var greetingLabel: UILabel!
    
    var deviceRotation : UIDeviceOrientation = UIDeviceOrientation.portrait
    
    override func viewDidLoad() {
        initializeEngine()
        setGreeting()
    }
    
    var morningGreetings = ["having an awesome morning?", "having a great morning?", "having a swell morning?", "having a productive morning?", "had a good night rest?"]
    var afternoonGreetings = ["having a great day?", "having a great afternoon?", "having a swell afternoon?", "having a productive day?", "having a fantastic afternoon?", "having a fantastic day?"]
    var eveningsGreetings = ["had a great day?", "having a great evening?", "having a good evening?", "had a productive day?", "had a fantastic day?", "having a fantastic evening?"]
    
    func setGreeting(){
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.locale = Locale(identifier: "en_US")
        dateFormatterPrint.timeZone = TimeZone.current
        dateFormatterPrint.dateFormat = "HH"
        let hourOfDay = Int(dateFormatterPrint.string(from: Date())) ?? 0
        
        let firstPart = "Hope you are "
        var finalGreeting = ""
        
        switch hourOfDay {
        case 0...11:
            let number = Int.random(in: 0..<morningGreetings.count)
            finalGreeting = firstPart + morningGreetings[number]
        case 12...16:
            let number = Int.random(in: 0..<afternoonGreetings.count)
            finalGreeting = firstPart + afternoonGreetings[number]
        case 16...24:
            let number = Int.random(in: 0..<eveningsGreetings.count)
            finalGreeting = firstPart + eveningsGreetings[number]
        default:
            break
        }
        
        greetingLabel.text = finalGreeting
    }
    
    func initializeEngine(){
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.font:UIFont(name: fontName, size: 14)!]
        
        drawingsList.contentInset = UIEdgeInsets(top: 12, left: dashboardPadding, bottom: 12, right: dashboardPadding)
        //drawingsList.backgroundColor = UIColor.clear
        drawingsList.dataSource = self
        drawingsList.delegate = self
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString.init(string: refreshTitle, attributes: [NSAttributedString.Key.font : UIFont.init(name: fontName, size: 12.0)!, NSAttributedString.Key.foregroundColor: UIColor.white])
        drawingsList.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        deviceRotation = UIDevice.current.orientation
        drawingsList.collectionViewLayout.invalidateLayout()
        drawingsList.reloadData()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        drawingsList.reloadData()
    }
   
    @objc func loadData(){
        drawingModels = storeHelper.getDrawings(delegate: delegate)
        drawingsList.reloadData()
        refreshControl.endRefreshing()
    }
    
    @IBAction func showNewPaper(_ sender: Any) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "DrawingViewController") as! DrawingViewController
        controller.new_canvas = true
        navigationController?.pushViewController(controller, animated: true)
        
    }
    
    func makeContextMenu(indexPath: IndexPath) -> UIMenu {
        let share = UIAction(title: NSLocalizedString("Share", comment: "Share this palette"), image: UIImage(systemName: "square.and.arrow.up")) { [self] action in
            let drawing = drawingModels[indexPath.row]
            let cell = self.drawingsList.cellForItem(at: indexPath)
            //self.shareColorImage(color: color, cell: cell!)
        }

        let delete = UIAction(title: NSLocalizedString("Delete", comment: "Delete this palette"), image: UIImage(systemName: "trash"), attributes: .destructive) { [self] action in
            let drawing = drawingModels[indexPath.row]
            self.deleteDrawing(drawing: drawing)
            self.drawingsList.deleteItems(at: [indexPath])
        }

        // Create our menu with both the edit menu and the share action
        return UIMenu(title: "", children: [share, delete])
    }
    
    func deleteDrawing(drawing: DrawingModel){
        storeHelper.deleteDrawing(delegate: delegate, drawing: drawing)
        loadData()
    }
}


extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return drawingModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            return self.makeContextMenu(indexPath: indexPath)
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let drawing = drawingModels[indexPath.row]
        let controller = storyboard?.instantiateViewController(withIdentifier: "DrawingViewController") as! DrawingViewController
        controller.new_canvas = false
        controller.editingDrawingModel = drawing
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let kWhateverHeightYouWant : CGFloat = 260
        
//        if (deviceRotation == .portrait || deviceRotation == .portraitUpsideDown){
//            var kWhateverWidthYouWant = (collectionView.bounds.width / 4)
//            kWhateverWidthYouWant = kWhateverWidthYouWant - (dashboardPadding / 2)
//            return CGSize(width: kWhateverWidthYouWant, height: kWhateverHeightYouWant)
//        } else {
//            var kWhateverWidthYouWant = (collectionView.bounds.width / 2)
//            kWhateverWidthYouWant = kWhateverWidthYouWant - (dashboardPadding - 2)
//            return CGSize(width: kWhateverWidthYouWant, height: kWhateverHeightYouWant)
//        }
        
        var kWhateverWidthYouWant = (collectionView.bounds.width / 4)
        kWhateverWidthYouWant = kWhateverWidthYouWant - (dashboardPadding / 2)
        return CGSize(width: kWhateverWidthYouWant, height: kWhateverHeightYouWant)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let drawing = drawingModels[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SingleDrawingCell", for: indexPath) as! SingleDrawingCell
        cell.setUp(drawingModel: drawing)
        return cell
    }
    
    
}
