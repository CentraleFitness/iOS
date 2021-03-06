
//
//  ViewQRCode.swift
//  Centrale_Fitness_1
//
//  Created by Fabien Santoni on 23/05/2018.
//  Copyright © 2018 Fabien Santoni. All rights reserved.
//

import Alamofire
import AVFoundation
import UIKit

class ViewQRCode: UIViewController, QRCodeReaderViewControllerDelegate {
    var token: String = ""
    
    @IBOutlet weak var previewView: QRCodeReaderView! {
        didSet {
            previewView.setupComponents(showCancelButton: false, showSwitchCameraButton: false, showTorchButton: false, showOverlayView: true, reader: reader)
        }
    }
    lazy var reader: QRCodeReader = QRCodeReader()
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader                  = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
            $0.showTorchButton         = true
            $0.preferredStatusBarStyle = .lightContent
            
            $0.reader.stopScanningWhenCodeIsFound = false
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    // MARK: - Actions
    
    private func checkScanPermissions() -> Bool {
        do {
            return try QRCodeReader.supportsMetadataObjectTypes()
        } catch let error as NSError {
            let alert: UIAlertController
            
            switch error.code {
            case -11852:
                alert = UIAlertController(title: "Error", message: "This app is not authorized to use Back Camera.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (_) in
                    DispatchQueue.main.async {
                        if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
                            UIApplication.shared.openURL(settingsURL)
                        }
                    }
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            default:
                alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            }
            
            present(alert, animated: true, completion: nil)
            
            return false
        }
    }
    
    @IBAction func scanInModalAction(_ sender: AnyObject) {
        guard checkScanPermissions() else { return }
        
        readerVC.modalPresentationStyle = .formSheet
        readerVC.delegate               = self
        
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            if let result = result {
                print("Completion with result: \(result.value) of type \(result.metadataType)")
            }
        }
        
        present(readerVC, animated: true, completion: nil)
    }
    
    @IBAction func scanInPreviewAction(_ sender: Any) {
        guard checkScanPermissions(), !reader.isRunning else { return }
        
        reader.didFindCode = { result in
         //   print("Completion with result: \(result.value) of type \(result.metadataType)")
            self.affiliate(_token: self.token, _affiliation_token: result.value)
        }
        reader.startScanning()
    }
    
    // MARK: - QRCodeReader Delegate Methods
    
    func affiliate(_token: String, _affiliation_token: String)
    {
        print("Start affiliate")
        let parameters: Parameters = [
            "token": _token,
            "affiliation token": _affiliation_token
        ]
        
        Alamofire.request("\(network.ipAdress.rawValue)/affiliate", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                if let json = response.result.value as? [String: Any] {
                    let error = json["error"] as? String
                    print(error!)
                    if (error == "true")
                    {
                        print("Mauvais code")
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let exo = storyboard.instantiateViewController(withIdentifier: "home_NO") as! ViewAffiliateNO
                        exo.token = self.token;
                        self.present(exo, animated: true, completion: nil)
                    }
                    else
                    {
                        print("Bon code")
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let exo = storyboard.instantiateViewController(withIdentifier: "home_OK") as! ViewAffiliateOK
                        exo.token = self.token;
                        self.present(exo, animated: true, completion: nil)
                    }
                }
                else
                {
                    print("Bad")
                }
        }
    }
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        
        dismiss(animated: true) { [weak self] in
            let alert = UIAlertController(
                title: "QRCodeReader",
                message: String (format:"%@ (of type %@)", result.value, result.metadataType),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        print("Switching capturing to: \(newCaptureDevice.device.localizedName)")
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
    }
}
