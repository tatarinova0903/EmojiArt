//
//  PaletteChoserView.swift
//  EmojiArt
//
//  Created by Дарья on 02.02.2021.
//  Copyright © 2021 Дарья. All rights reserved.
//

import SwiftUI

struct PaletteChoserView: View {
    
    @ObservedObject var document: EmojiArtDocument
    
    @Binding var chosenPalette: String
    
    @State private var showPaletteEditor = false
    
    var body: some View {
        HStack {
            Stepper(onIncrement: {
                self.chosenPalette = self.document.palette(after: self.chosenPalette)
                EmojiArtDocument.palette = self.chosenPalette
            }, onDecrement: {
                self.chosenPalette = self.document.palette(before: self.chosenPalette)
                EmojiArtDocument.palette = self.chosenPalette
            }) {
                EmptyView()
            }
            Text(document.paletteNames[self.chosenPalette] ?? "")
            Image(systemName: "keyboard").imageScale(.large)
                .onTapGesture {
                    self.showPaletteEditor.toggle()
            }
            .sheet(isPresented: $showPaletteEditor) {
                PaletteEditorView(chosenPalette: self.$chosenPalette, isShowing: self.$showPaletteEditor)
                    .environmentObject(self.document)
                    .frame(minWidth: 300, minHeight: 500)
            }
        }
        .fixedSize(horizontal: true, vertical: false)
        .onAppear { self.chosenPalette = self.document.defaultPalette }
    }
}


struct PaletteEditorView: View {
    
    @EnvironmentObject var document: EmojiArtDocument
    
    @Binding var chosenPalette: String
    
    @State private var paletteName = ""
    
    @State private var emojiesToAdd = ""
    
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack {
            ZStack {
            Text("PaletteEditorView").font(.headline).padding()
                HStack {
                    Spacer()
                    Button(action: {
                        self.isShowing = false
                    }, label: { Text("Done").padding() })
                }
            }
            Divider()
            Form {
                Section(header: Text("Palette Name")) {
                    TextField("Palette Name", text: $paletteName, onEditingChanged: { began in
                        if !began {
                            self.document.renamePalette(self.chosenPalette, to: self.paletteName)
                        }
                    })
                }
                Section(header: Text("Editting")) {
                    TextField("Add emojies", text: $emojiesToAdd, onEditingChanged: { began in
                        if !began {
                            self.chosenPalette = self.document.addEmoji(self.emojiesToAdd, toPalette: self.chosenPalette)
                            self.emojiesToAdd = ""
                        }
                    })
                    Grid(chosenPalette.map {String($0)}, id: \.self) { emoji in
                        Text(emoji).font(Font.system(size: self.fontSize))
                            .onTapGesture {
                                self.chosenPalette = self.document.removeEmoji(emoji, fromPalette: self.chosenPalette)
                        }
                    }
                    .frame(height: height)
                }
            }
        }
        .onAppear {
            self.paletteName = self.document.paletteNames[self.chosenPalette] ?? ""
        }
    }
    
    // MARK: Drawing constants
    let fontSize: CGFloat = 40
    var height: CGFloat {
        CGFloat((chosenPalette.count - 1) / 6 ) * 70 + 70
    }
}


struct PaletteChoserView_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChoserView(document: EmojiArtDocument(), chosenPalette: Binding.constant(""))
    }
}
