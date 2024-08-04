//
//  VideoRecordingViewController.swift
//  Helio
//
//  Created by Michelle Rueda on 7/20/24.
//
import UIKit
import AVFoundation
import AVKit

class VideoCaptureViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {

    var captureSession: AVCaptureSession!
    var videoOutput: AVCaptureMovieFileOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var isRecording = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
    }

    func setupCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high

        guard let videoDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }

        let audioDevice = AVCaptureDevice.default(for: .audio)
        let audioInput = try? AVCaptureDeviceInput(device: audioDevice!)

        if captureSession.canAddInput(audioInput!) {
            captureSession.addInput(audioInput!)
        }

        videoOutput = AVCaptureMovieFileOutput()
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }
  

    func startRecording() {
        let outputPath = NSTemporaryDirectory() + "output.mov"
        let outputFileURL = URL(fileURLWithPath: outputPath)
        videoOutput.startRecording(to: outputFileURL, recordingDelegate: self)
    }

    func stopRecording() {
        videoOutput.stopRecording()
    }

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error recording movie: \(error.localizedDescription)")
        } else {

            uploadVideoToServer(fileURL: outputFileURL)
        }
    }

    func uploadVideoToServer(fileURL: URL) {
        let serverURL = URL(string: "https://yourserver.com/upload")!
        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"output.mov\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: video/quicktime\r\n\r\n".data(using: .utf8)!)
        body.append(try! Data(contentsOf: fileURL))
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
