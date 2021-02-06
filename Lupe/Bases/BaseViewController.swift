//
//  BaseViewController.swift
//  Lupe
//
//  Created by Bezaleel Ashefor on 05/02/2021.
//

import Foundation
import UIKit

class BaseViewController: UIViewController {
    
    var fontName = "Rubik"
    var storeHelper = StoreHelper()
    let selectionGenerator = UISelectionFeedbackGenerator()
    let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .medium)
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.hideKeyboardWhenTappedArround()
        // Do any additional setup after loading the view.
    }
    
    //we dismiss the keyboard when user touches view while editing
    func hideKeyboardWhenTappedArround(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }

    
}

extension BaseViewController: UIGestureRecognizerDelegate{
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer is UIScreenEdgePanGestureRecognizer
    }

}
