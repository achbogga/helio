//
//  ContentView.swift
//  Helio
//
//  Created by Michelle Rueda on 7/20/24.
//

import SwiftUI

struct ContentViewV2: View {
  @State private var image: Image?
      @State private var showingImagePicker = false
  @State private var inputImage: UIImage?


      var body: some View {
          VStack {
              image?
                  .resizable()
                  .scaledToFit()

              Button("Select Image") {
                  showingImagePicker = true
              }
          }
          .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $inputImage)

          }
          .onChange(of: inputImage) { _ in loadImage() }

      }
  func loadImage() {
      guard let inputImage = inputImage else { return }
      image = Image(uiImage: inputImage)
  }
}
