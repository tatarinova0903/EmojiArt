//
//  OptionalImage.swift
//  EmojiArt
//
//  Created by Дарья on 01.02.2021.
//  Copyright © 2021 Дарья. All rights reserved.
//

import SwiftUI

struct OptionalImage: View {
    
    var uiImage: UIImage?
    
    var body: some View {
        Group {
            if uiImage != nil {
                Image(uiImage: uiImage!)
            }
        }
    }
}
