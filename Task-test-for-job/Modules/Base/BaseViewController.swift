//
//  BaseViewControler.swift
//  Task-test-for-job
//
//  Created by Apple on 31.7.2024.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func showAlert(title: String, massage: String){
        let alert = UIAlertController(title: title,
                                      message: massage,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .destructive))
        self.present(alert, animated: true)
    }
    
    
}
