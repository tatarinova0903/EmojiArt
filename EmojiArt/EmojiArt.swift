//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by Дарья on 31.01.2021.
//  Copyright © 2021 Дарья. All rights reserved.
//

import Foundation

struct EmojiArt: Codable {
    var backgroundURL: URL?
    
    var emojies = Array<Emoji>()
    
    private var uniqueEmojiID: Int = 0
    
    struct Emoji: Identifiable, Codable {
        let id: Int
        let text: String
        var x: Int
        var y: Int
        var size: Int
        
        fileprivate init(id: Int, text: String, x: Int, y: Int, size: Int) {
            self.id = id
            self.text = text
            self.x = x
            self.y = y
            self.size = size
        }
    }
    
    var json: Data? {
        try? JSONEncoder().encode(self)
    }
    
    init?(json: Data?) {
        if json != nil {
            if let newEmojiArt = try? JSONDecoder().decode(EmojiArt.self, from: json!) {
                self = newEmojiArt
            }
        } else {
            return nil
        }
    }
    
    init() { }
    
    mutating func addEmoji(_ text: String, x: Int, y: Int, size: Int) {
        uniqueEmojiID += 1
        emojies.append(Emoji(id: uniqueEmojiID, text: text, x: x, y: y, size: size))
    }
}
