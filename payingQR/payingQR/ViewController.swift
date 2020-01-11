//
//  ViewController.swift
//  payingQR
//
//  Created by alejandro david perez morales on 1/11/20.
//  Copyright © 2020 alejandro david perez morales. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var generatedQR: UIImageView!
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    let manager = QRManager()
    
    let cadena = "{\"email\":\"scanf16@hotmail.com\",\"reservacion\":\"0000\"}"
    self.generatedQR.image = manager.generateQRCode(from: cadena)
  }

  @IBAction func readQR(_ sender: Any) {
    print("rearQR")
    let qrmanager = QRManager()
    self.present(qrmanager, animated: true, completion: nil)
  }
  
}

