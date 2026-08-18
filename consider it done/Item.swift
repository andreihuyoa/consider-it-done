//
//  Item.swift
//  consider it done
//
//  Created by Andrei Huyo-a on 8/18/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
