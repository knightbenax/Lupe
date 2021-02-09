//
//  SingleDrawingCell.swift
//  Lupe
//
//  Created by Bezaleel Ashefor on 06/02/2021.
//

import Foundation
import UIKit
import PencilKit

class  SingleDrawingCell: UICollectionViewCell {
    
    @IBOutlet weak var snippet: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    
    func setUp(drawingModel : DrawingModel){
        dateLabel.text = formatDateToBeauty(thisDate: drawingModel.dateCreated)
        tagLabel.text = drawingModel.tag
        let drawingObject = Data(base64Encoded: drawingModel.drawingEntity)
        
        do {
            let drawing = try PKDrawing(data: drawingObject!)
            let image = drawing.image(from: drawing.bounds, scale: CGFloat(1.0))
            snippet.image = image
        } catch let error as NSError {
            print("Couldn't load image \(error), \(error.userInfo)")
        }
    }
    
    func formatDateToBeauty(thisDate: Date) -> String{
        let dateFormatterPrint = DateFormatter()
        //dateFormatterPrint.locale = Locale(identifier: "en_US")
        dateFormatterPrint.timeZone = TimeZone.current
        dateFormatterPrint.dateFormat = "EEE, MMM d yyyy - h:mma"
        return dateFormatterPrint.string(from: thisDate)
    }
    
}
