//
//  VideoCaptureView.swift
//  Helio
//
//  Created by Michelle Rueda on 7/20/24.
//

import SwiftUI
import UIKit

struct VideoCaptureView: UIViewControllerRepresentable {

    class Coordinator: NSObject {
      var parent: VideoCaptureView
      var myViewController: VideoCaptureViewController?

        init(parent: VideoCaptureView) {
            self.parent = parent
        }
      
      func callMyViewControllerMethod() {
        parent.viewController?.startRecording()
      }
    }
  
  var viewController: VideoCaptureViewController?

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> VideoCaptureViewController {
      let viewController = VideoCaptureViewController()
      context.coordinator.parent.viewController = viewController
      return viewController
    }

    func updateUIViewController(_ uiViewController: VideoCaptureViewController, context: Context) {
        // Update the view controller if needed
    }

    static func dismantleUIViewController(_ uiViewController: VideoCaptureViewController, coordinator: Coordinator) {
        uiViewController.captureSession.stopRunning()
    }
}
