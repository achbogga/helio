//
//  CameraView.swift
//  Helio
//
//  Created by Michelle Rueda on 7/20/24.
//

import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    @Binding var isRecording: Bool
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let cameraViewController = CameraViewController()
        return cameraViewController
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        if isRecording {
            uiViewController.startRecording()
        } else {
            uiViewController.stopRecording()
        }
    }
}
