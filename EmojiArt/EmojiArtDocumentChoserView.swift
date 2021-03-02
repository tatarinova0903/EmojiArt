//
//  EmojiArtDocumentChoserView.swift
//  EmojiArt
//
//  Created by Дарья on 03.02.2021.
//  Copyright © 2021 Дарья. All rights reserved.
//

import SwiftUI

struct EmojiArtDocumentChoserView: View {
    
    @EnvironmentObject var store: EmojiArtDocumentStore
    
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.documents) { document in
                    NavigationLink(destination: EmojiArtDocumentView(document: document)
                        .navigationBarTitle(self.store.name(for: document))) {
                            EditableText(self.store.name(for: document), isEditing: self.editMode.isEditing) { name in
                                self.store.setName(name, for: document)
                            }
                    }
                }
                .onDelete { indexSet in
                    indexSet.map { self.store.documents[$0] }.forEach { document in
                        self.store.removeDocument(document)
                    }
                }
            }
            .navigationBarTitle(self.store.name)
            .navigationBarItems(
                leading: Button(action: { self.store.addDocument()}) { Image(systemName: "plus") },
                trailing: EditButton())
                .environment(\.editMode, $editMode)
        }
    }
}

struct EmojiArtDocumentChoser_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentChoserView()
    }
}
