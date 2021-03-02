//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Дарья on 31.01.2021.
//  Copyright © 2021 Дарья. All rights reserved.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    
    @ObservedObject var document: EmojiArtDocument
    
    @State private var chosenPalette: String = ""
    
    private let emojiFontSize: CGFloat = 40
    
    @GestureState private var gestureZoomScale: CGFloat = 1.0

    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var zoomScale: CGFloat {
        document.steadyStateZoomScale * gestureZoomScale
    }
    
    var isLoading: Bool {
        document.backgroundURL != nil && document.backgroundImage == nil
    }
    
    var body: some View {
        VStack {
            HStack {
                PaletteChoserView(document: EmojiArtDocument(), chosenPalette: $chosenPalette)
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(chosenPalette.map {String($0)}, id: \.self) { emoji in
                            Text(emoji)
                                .font(Font.system(size: self.emojiFontSize))
                                .onDrag { NSItemProvider(object: emoji as NSString) }
                        }
                    }
                }
                .onAppear { self.chosenPalette = self.document.defaultPalette }
            }
            GeometryReader { geometry in
                ZStack {
                    Color.white
                        .overlay(
                            OptionalImage(uiImage: self.document.backgroundImage)
                                .scaleEffect(self.zoomScale)
                                .offset(self.panOffset))
                        .gesture(self.doubleTapToZoom(in: geometry.size))
                    if self.isLoading {
                        Image(systemName: "hourglass").imageScale(.large).spinning()
                    } else {
                        ForEach(self.document.emojies) { emoji in
                            Text(emoji.text)
                                .font(animatableWithSize: CGFloat(emoji.size) * self.zoomScale)
                                .position(self.position(for: emoji, in: geometry.size))
                        }
                    }
                }
                .clipped()
                .gesture(self.zoomGesture())
                .gesture(self.panGesture())
                .edgesIgnoringSafeArea(.bottom)
                .onReceive(self.document.$backgroundImage) { image in
                    self.zoomToFit(image, in: geometry.size)
                }
                .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                    var location = CGPoint(x: location.x, y: geometry.convert(location, from: .global).y)
                    location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                    location = CGPoint(x: location.x - self.panOffset.width, y: location.y - self.panOffset.height)
                    location = CGPoint(x: location.x / self.zoomScale, y: location.y / self.zoomScale)
                    return self.drop(providers: providers, at: location)
                }
                .navigationBarItems(trailing: Button(action: {
                    if let url = UIPasteboard.general.url, url != self.document.backgroundURL {
                        self.confirmBackgroundPaste = true
                    } else {
                        self.explaneBackgroundPaste = true
                    }
                }, label: {
                    Image(systemName: "doc.on.clipboard")
                        .imageScale(.large)
                        .alert(isPresented: self.$explaneBackgroundPaste) {
                            Alert(title: Text("Paste background"), message: Text("Copy the URL of an image to the clipboard and touch this button to make it the background"), dismissButton: .default(Text("Ok")))
                    }
                }))
            }
        }
        .alert(isPresented: self.$confirmBackgroundPaste) {
            Alert(title: Text("Paste background"), message: Text("Replace your background with \(UIPasteboard.general.url?.absoluteString ?? "nothing")?"), primaryButton: .default(Text("Ok"), action: {
                self.document.backgroundURL = UIPasteboard.general.url
            }), secondaryButton: .cancel())
        }
    }
    
    @State private var explaneBackgroundPaste = false
    @State private var confirmBackgroundPaste = false

    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, transaction in
                gestureZoomScale = latestGestureScale
            }
            .onEnded { finalGestureScale in
                self.document.steadyStateZoomScale *= finalGestureScale
            }
    }
    
    private var panOffset: CGSize {
        (document.steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, transaction in
                gesturePanOffset = latestDragGestureValue.translation / self.zoomScale
        }
        .onEnded { finalDragGestureValue in
            self.document.steadyStatePanOffset = self.document.steadyStatePanOffset + (finalDragGestureValue.translation / self.zoomScale)
        }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    self.zoomToFit(self.document.backgroundImage, in: size)
                }
        }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0, size.width > 0, size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            self.document.steadyStatePanOffset = .zero
            self.document.steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: location.x + size.width/2, y: location.y + size.height/2)
        location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height)
        return location
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            self.document.backgroundURL = url
        }
        if !found {
            found = providers.loadFirstObject(ofType: String.self, using: { string in
                self.document.addEmoji(string, at: location, size: self.emojiFontSize)
            })
        }
        return found
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
    }
}
