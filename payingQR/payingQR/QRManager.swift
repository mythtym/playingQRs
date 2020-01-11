//
//  QRManager.swift
//  payingQR
//
//  Created by alejandro david perez morales on 1/11/20.
//  Copyright © 2020 alejandro david perez morales. All rights reserved.
//

import UIKit
import AVFoundation // para la camara QR

@objc protocol QRManagerProtocol {
  func successRead(data:String!) -> Void
  func errorRead(description:String!) -> Void
}

class QRManager: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
  private var previewBackground = UIView();
  private var previewQR = UIView()
  
  var captureSession: AVCaptureSession!
  var previewLayer: AVCaptureVideoPreviewLayer!
  let metadataOutput = AVCaptureMetadataOutput()
  
  private let photoOutput = AVCapturePhotoOutput()

  weak var delegate:QRManagerProtocol?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setPreview()
    
    self.view.backgroundColor = .blue
    self.previewBackground.backgroundColor = UIColor.white
    captureSession = AVCaptureSession()
    
    guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
    var videoInput: AVCaptureDeviceInput
    
    do {
      videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
    } catch {
      return
    }
    
    if (captureSession.canAddInput(videoInput)) {
      captureSession.addInput(videoInput)
      
    } else {
      failed()
      return
    }
    
    if (captureSession.canAddOutput(metadataOutput)) {
      captureSession.addOutput(metadataOutput)
      
      metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
      metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
      
    } else {
      failed()
      return
    }

    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    previewLayer.frame = CGRect(x: 2, y: 2, width: 190 - 4, height: 190 - 4 )
    previewLayer.videoGravity = .resizeAspectFill
    self.previewQR.layer.addSublayer(previewLayer)
   
    captureSession.startRunning()
    
  }
  
  func failed() {
    let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .default))
    present(ac, animated: true)
    captureSession = nil
  }
  
  func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    
    if let metadataObject = metadataObjects.first {
      guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
      guard let stringValue = readableObject.stringValue else { return }
      AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
      found(code: stringValue)
    }
    captureSession.stopRunning()
    
  }
 
  
  func reactivateCam(_ sender: Any) {
    captureSession.startRunning()
  }

  
  func found(code: String) {
    print(code)
    self.delegate?.successRead(data: code)
    self.dismiss(animated: true, completion: nil)
  }
  
  
  func setPreview() {
    self.previewQR.translatesAutoresizingMaskIntoConstraints = false
    self.previewBackground.addSubview(self.previewQR)
    self.previewBackground.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[vistaP]-5-|", options: [], metrics: nil, views: ["vistaP":previewQR]))
    self.previewBackground.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[vistaP]-5-|", options: [], metrics: nil, views: ["vistaP":previewQR]))
    
    
    self.previewBackground.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(self.previewBackground)
    self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[vistaB(200)]", options: [], metrics: nil, views: ["vistaB":previewBackground]))
    self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[vistaB(200)]", options: [], metrics: nil, views: ["vistaB":previewBackground]))
    self.view.addConstraint(NSLayoutConstraint.init(item: self.previewBackground, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
    self.view.addConstraint(NSLayoutConstraint.init(item: self.previewBackground, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0))
    
    
    
  }
  
  
  
  func changeStringToDic(str:String) -> [String:Any]! {
   
    let data = str.data(using: .utf8)!
    do {
      if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as?  [String:Any]
      {
        print(jsonArray) // use the json here
        return jsonArray
      } else {
        print("bad json")
        return nil
      }
    } catch let error as NSError {
      print(error)
      return nil
    }
    
  }
  
  // MARK: - class method to generate QR's
 
  public func generateQRCode(from string: String) -> UIImage? {
    let data = string.data(using: String.Encoding.ascii)
    if let filter = CIFilter(name: "CIQRCodeGenerator") {
      filter.setValue(data, forKey: "inputMessage")
      let transform = CGAffineTransform(scaleX: 3, y: 3)
      if let output = filter.outputImage?.transformed(by: transform) {
        return UIImage(ciImage: output)
      }
    }
    return nil
  }
 
  
//  let image = generateQRCode(from: "Hacking with Swift is the best iOS coding tutorial I've ever read!")

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
