//
//  CameraViewController.swift
//  Helio
//
//  Created by Michelle Rueda on 7/20/24.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
  
    var captureSession: AVCaptureSession?
    var videoOutput: AVCaptureMovieFileOutput?
  var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      checkPermissions()
    }
  
  func checkPermissions() {
          switch AVCaptureDevice.authorizationStatus(for: .video) {
          case .authorized:
              // The user has previously granted access to the camera.
              self.setupCaptureSession()
          case .notDetermined:
              // The user has not yet been asked for camera access.
              AVCaptureDevice.requestAccess(for: .video) { granted in
                  if granted {
                      DispatchQueue.main.async {
                          self.setupCaptureSession()
                      }
                  }
              }
          case .denied:
              // The user has previously denied access.
              return
          case .restricted:
              // The user can't grant access due to restrictions.
              return
          @unknown default:
              return
          }
      }
    
    func setupCaptureSession() {
      
//      captureSession = AVCaptureSession()
//      
//      guard let captureSession = captureSession else {
//        return
//      }
//      captureSession.sessionPreset = .high
//
//      guard let videoDevice = AVCaptureDevice.default(for: .video) else { return }
//      guard let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
//
//      if captureSession.canAddInput(videoInput) {
//          captureSession.addInput(videoInput)
//      }
//
//      let audioDevice = AVCaptureDevice.default(for: .audio)
//      let audioInput = try? AVCaptureDeviceInput(device: audioDevice!)
//
//      if captureSession.canAddInput(audioInput!) {
//          captureSession.addInput(audioInput!)
//      }
//
//      videoOutput = AVCaptureMovieFileOutput()
//      guard var videoOutput = videoOutput else {
//        return
//      }
//      if captureSession.canAddOutput(videoOutput) {
//          captureSession.addOutput(videoOutput)
//      }
//
//      previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//      previewLayer.frame = view.layer.bounds
//      previewLayer.videoGravity = .resizeAspectFill
//      view.layer.addSublayer(previewLayer)
//
//      captureSession.startRunning()
      
        captureSession = AVCaptureSession()
        
//        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
      // Specify that we want to use the front camera
      guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
          print("Failed to get the front camera")
          return
      }
      
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if captureSession!.canAddInput(videoInput) {
                captureSession!.addInput(videoInput)
            }
            
            videoOutput = AVCaptureMovieFileOutput()
            if captureSession!.canAddOutput(videoOutput!) {
                captureSession!.addOutput(videoOutput!)
            }
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            previewLayer.frame = view.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
            
            captureSession!.startRunning()
        } catch {
            print("Error setting up capture session: \(error)")
        }
    }
    
  func startRecording() {
      guard let videoOutput = videoOutput else {
          print("Video output is nil")
          return
      }
      
      let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
      let currentDateTime = dateFormatter.string(from: Date())
      let fileUrl = paths[0].appendingPathComponent("output_\(currentDateTime).mov")
      
      print("Attempting to write to: \(fileUrl.path)")
      
      do {
          let testData = "test".data(using: .utf8)!
          try testData.write(to: fileUrl)
          try FileManager.default.removeItem(at: fileUrl)
          print("Successfully wrote and deleted a test file at the target location")
      } catch {
          print("Error testing write permissions at target location: \(error)")
      }
      
      videoOutput.startRecording(to: fileUrl, recordingDelegate: self)
      
      if videoOutput.isRecording {
          print("Recording started successfully")
      } else {
          print("Failed to start recording")
      }
  }
    
    func stopRecording() {
        videoOutput?.stopRecording()
    }
  
  func playRecordedVideo(url: URL) {
      let player = AVPlayer(url: url)
      let playerLayer = AVPlayerLayer(player: player)
      playerLayer.frame = view.bounds
//      playerLayer.videoGravity = .resizeAspectFit
      view.layer.addSublayer(playerLayer)
      player.play()
      
      // Add a close button
      let closeButton = UIButton(frame: CGRect(x: 20, y: 40, width: 60, height: 30))
      closeButton.setTitle("Close", for: .normal)
      closeButton.backgroundColor = .blue
      closeButton.addTarget(self, action: #selector(closePlayback), for: .touchUpInside)
      view.addSubview(closeButton)
  }
  
  @objc func closePlayback() {
      // Remove the last added sublayer (which should be the player layer)
      if let playerLayer = view.layer.sublayers?.last as? AVPlayerLayer {
          playerLayer.removeFromSuperlayer()
      }
      // Remove the close button
      view.subviews.last?.removeFromSuperview()
  }

  
  func checkDirectoryPermissions() {
      let fileManager = FileManager.default
      let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
      
      print("Document directory: \(documentDirectory.path)")
      
      do {
          let testFileURL = documentDirectory.appendingPathComponent("test.txt")
          try "Test".write(to: testFileURL, atomically: true, encoding: .utf8)
          try fileManager.removeItem(at: testFileURL)
          print("Successfully wrote and deleted a test file")
      } catch {
          print("Error testing write permissions: \(error)")
      }
      
      // List contents of the directory
      do {
          let contents = try fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
          print("Directory contents:")
          for item in contents {
              print(item.lastPathComponent)
          }
      } catch {
          print("Error listing directory contents: \(error)")
      }
  }
  
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
      if let error = error {
              print("Error recording video: \(error)")
              if let error = error as? AVError {
                  print("AVError code: \(error.code.rawValue)")
              }
          } else {
              print("Video recorded successfully at \(outputFileURL)")
              
              // Check if the file exists
              if FileManager.default.fileExists(atPath: outputFileURL.path) {
                  print("File exists at the specified URL")
              } else {
                  print("File does not exist at the specified URL")
              }
              
              // Check file size
              do {
                  let attributes = try FileManager.default.attributesOfItem(atPath: outputFileURL.path)
                  let fileSize = attributes[.size] as? Int64 ?? 0
                  print("File size: \(fileSize) bytes")
              } catch {
                  print("Error getting file attributes: \(error)")
              }
            
//            DispatchQueue.main.async {
//                            self.playRecordedVideo(url: outputFileURL)
//                        }
            uploadVideoToServer(fileURL: outputFileURL)
            
          }
    }

  func uploadVideoToServer(fileURL: URL) {
//      let serverURL = URL(string: "https://yourserver.com/upload")!
    
    let filters: [String] = []
    
    let serverURLString = "http://34.72.202.95:8000/analyze_video"
        
        // Create URL components to add query parameters
        guard var urlComponents = URLComponents(string: serverURLString) else {
            return
        }
        
        // Add labels as a query parameter
        let labelsQueryItem = URLQueryItem(name: "labels", value: filters.joined(separator: ","))
        urlComponents.queryItems = [labelsQueryItem]
        
        guard let url = urlComponents.url else {
            return
        }

    var request = URLRequest(url: url)
      request.httpMethod = "POST"

      let boundary = UUID().uuidString
      request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

      var body = Data()
      body.append("--\(boundary)\r\n".data(using: .utf8)!)
      body.append("Content-Disposition: form-data; name=\"file\"; filename=\"output.mov\"\r\n".data(using: .utf8)!)
      body.append("Content-Type: video/quicktime\r\n\r\n".data(using: .utf8)!)
      body.append(try! Data(contentsOf: fileURL))
      body.append("\r\n".data(using: .utf8)!)
    
    // Add filters parameter
    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"labels\"\r\n\r\n".data(using: .utf8)!)
    body.append(filters.joined(separator: ",").data(using: .utf8)!)
    body.append("\r\n".data(using: .utf8)!)

    body.append("--\(boundary)--\r\n".data(using: .utf8)!)
    

      let task = URLSession.shared.uploadTask(with: request, from: body) { data, response, error in
          if let error = error {
              print("Error uploading video: \(error.localizedDescription)")
              return
          }

          if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
              print("Video uploaded successfully")
          } else {
              print("Error uploading video: \(String(describing: response))")
          }
      }

      task.resume()
  }
}

