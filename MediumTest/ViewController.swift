//
//  ViewController.swift
//  MediumTest
//
//  Created by 黃建程 on 2019/8/23.
//  Copyright © 2019 Spark. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var gettoken = GetTokenAPI()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        gettoken.delegate = self
        
        gettoken.getToken()
        
        
    }


}

extension ViewController: GetTokenAPIDelegate {
    func didGetToken() {
        print("ok")
    }
    
    
}
