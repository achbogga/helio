//
//  ImagePicker.swift
//  Helio
//
//  Created by Michelle Rueda on 7/20/24.
//

import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
  class Coordinator: NSObject, PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
      // Tell the picker to go away
      picker.dismiss(animated: true)

      // Exit if no selection was made
      guard let provider = results.first?.itemProvider else { return }

      // If this has an image we can use, use it
      if provider.canLoadObject(ofClass: UIImage.self) {
          provider.loadObject(ofClass: UIImage.self) { image, _ in
              self.parent.image = image as? UIImage
          }
      }
    }
    
          var parent: ImagePicker

          init(_ parent: ImagePicker) {
              self.parent = parent
          }
      }

      @Binding var image: UIImage?

//      func makeUIViewController(context: Context) -> PHPickerViewController {
//          var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
//          config.filter = .images
//
//          let picker = PHPickerViewController(configuration: config)
//          picker.delegate = context.coordinator
//          return picker
//      }
//  
//
//      func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
//
//      }
  func makeUIViewController(context: Context) -> VideoCaptureViewController {
    let viewController = VideoCaptureViewController()
//    context.coordinator.myViewController = viewController
    return viewController
  }
  
  func updateUIViewController(_ uiViewController: VideoCaptureViewController, context: Context) {

  }




      func makeCoordinator() -> Coordinator {
          Coordinator(self)
      }
}
