//
//  QrReaderViewController.swift
//  QrReaderViewController
//
//  Created by u-pt on 2024/09/08.
//

import UIKit
import AVFoundation

class QrReaderViewController: UIViewController {
    @IBOutlet weak var cameraView: UIView!
    
    var previewLayer: AVCaptureVideoPreviewLayer!
    var captureSession: AVCaptureSession!
    var qrDatas: [String] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.qrDatas.removeAll()
        self.configureSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.captureSession.stopRunning()
    }
    
    @IBSegueAction func showDataListSegueAction(_ coder: NSCoder) -> UITableViewController? {
        return QrCodeDataListViewController(coder: coder, qrDatas: self.qrDatas)
    }
    
    private func configureSession() {
        // カメラの準備
        guard let captureDeviceVideo = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        self.captureSession = AVCaptureSession()
        var captureMetadataOutput: AVCaptureMetadataOutput
        do {
            let captureDeviceInputVideo = try AVCaptureDeviceInput(device: captureDeviceVideo)
            if (self.captureSession.canAddInput(captureDeviceInputVideo)) {
                self.captureSession.addInput(captureDeviceInputVideo)
            }
            
            captureMetadataOutput = AVCaptureMetadataOutput()
            if (self.captureSession.canAddOutput(captureMetadataOutput)) {
                self.captureSession.addOutput(captureMetadataOutput)
            }
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: .main)
            
            // 読み込み対象としてQRコードを指定
            captureMetadataOutput.metadataObjectTypes = [.qr]
        } catch {
            self.captureSession = nil
            return
        }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer.frame = self.cameraView.layer.bounds
        self.previewLayer.videoGravity = .resizeAspectFill
        self.cameraView.layer.addSublayer(self.previewLayer)
        
        self.captureSession.startRunning()
    }
    
    private func sohwTargetBox(data: String, metadataObject: AVMetadataObject) {
        guard let transformedMetadataObject = self.previewLayer.transformedMetadataObject(for: metadataObject) else {return}
        
        let targetBoxView = UIView()
        targetBoxView.layer.borderWidth = 3
        targetBoxView.layer.borderColor = UIColor.systemYellow.cgColor
        targetBoxView.frame = transformedMetadataObject.bounds
        
        self.cameraView.addSubview(targetBoxView)
    }
}

extension QrReaderViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        self.qrDatas.removeAll()
        self.cameraView.subviews.forEach { $0.removeFromSuperview() }
        
        for metadataObject in metadataObjects {
            guard let readableCodeObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                  let stringValue = readableCodeObject.stringValue,
                  !stringValue.isEmpty else {
                return
            }
            self.qrDatas.append(stringValue)
            self.sohwTargetBox(data: stringValue, metadataObject: metadataObject)
        }
    }
}

