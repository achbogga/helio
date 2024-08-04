//
//  BodyMovementDetectorViewController.swift
//  Visuo
//
//  Created by Michelle Rueda on 7/20/24.
//


import UIKit
import AVFoundation
import Vision

class BodyMovementDetectorViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let captureSession = AVCaptureSession()
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    private let videoDataOutput = AVCaptureVideoDataOutput()
    
    private var detectionOverlay: CALayer! = nil
    
    private let bodyMovementDetector = BodyMovementDetector()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupDetectionOverlay()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
    }

  private func setupCamera() {
    captureSession.sessionPreset = .high
    
    guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
      return
    }
    
    do {
      if let input = try? AVCaptureDeviceInput(device: captureDevice) {
        captureSession.addInput(input)
        
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(videoDataOutput)
        
        videoDataOutput.connection(with: .video)?.videoOrientation = .portrait
        
        DispatchQueue.global(qos: .background).async { [weak self] in
          self?.captureSession.startRunning()
        }
      }
      
    }
    catch {
      print("what's the error")
      return
    }
  }
    
    private func setupDetectionOverlay() {
        detectionOverlay = CALayer()
        detectionOverlay.frame = view.bounds
        detectionOverlay.name = "DetectionOverlay"
        view.layer.addSublayer(detectionOverlay)
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return
        }
        
        bodyMovementDetector.detectPose(in: cgImage) { poses in
            DispatchQueue.main.async {
                self.drawPoses(poses)
            }
        }
    }
    
    private func drawPoses(_ poses: [VNHumanBodyPoseObservation]) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        detectionOverlay.sublayers = nil // remove all previous drawings
        
        for pose in poses {
            guard let recognizedPoints = try? pose.recognizedPoints(.all) else { continue }
            
            for (_, point) in recognizedPoints where point.confidence > 0.1 {
                let normalizedPoint = point.location
                let displayPoint = previewLayer.layerPointConverted(fromCaptureDevicePoint: normalizedPoint)
                
                let dot = CALayer()
                dot.frame = CGRect(x: displayPoint.x, y: displayPoint.y, width: 10, height: 10)
                dot.cornerRadius = 5
                dot.backgroundColor = UIColor.green.cgColor
                detectionOverlay.addSublayer(dot)
            }
        }
        
        CATransaction.commit()
    }
}

class BodyMovementDetector {
    private let sequenceHandler = VNSequenceRequestHandler()
    private var lastObservation: VNHumanBodyPoseObservation?
    
    func detectPose(in image: CGImage, completion: @escaping ([VNHumanBodyPoseObservation]) -> Void) {
        let request = VNDetectHumanBodyPoseRequest { request, error in
            guard let observations = request.results as? [VNHumanBodyPoseObservation] else { return }
            
            // Analyze the body pose here
            self.analyzePose(observations: observations)
            
            completion(observations)
        }
        
        try? sequenceHandler.perform([request], on: image, orientation: .up)
    }
    
    private func analyzePose(observations: [VNHumanBodyPoseObservation]) {
        guard let observation = observations.first else { return }
        
        // Implement your movement detection logic here
        // You can compare current observation with lastObservation to detect movement
        if let lastObservation = lastObservation {
            // Example: Detect if the right hand has moved significantly
            let rightHandLastPosition = try? lastObservation.recognizedPoint(.rightWrist)
            let rightHandCurrentPosition = try? observation.recognizedPoint(.rightWrist)
            
            if let last = rightHandLastPosition, let current = rightHandCurrentPosition {
                let distance = hypot(last.location.x - current.location.x, last.location.y - current.location.y)
                if distance > 0.1 { // Threshold for significant movement
                    print("Right hand moved significantly")
                }
            }
        }
        
        lastObservation = observation
    }
}
