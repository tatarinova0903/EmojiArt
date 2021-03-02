//
//  Spinning.swift
//  EmojiArt
//
//  Created by Дарья on 02.02.2021.
//  Copyright © 2021 Дарья. All rights reserved.
//

import SwiftUI

struct Spinning: ViewModifier {
    
    @State var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(isVisible ? 360 : 0))
            .animation(Animation.linear.repeatForever(autoreverses: false))
            .onAppear {
                self.isVisible.toggle()
        }
    }
}

extension View {
    func spinning() -> some View {
        self.modifier(Spinning())
    }
}


