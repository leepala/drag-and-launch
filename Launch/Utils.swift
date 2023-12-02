//
//  utils.swift
//  Launch
//
//  Created by 李毓琪 on 2023/12/2.
//

import Foundation

func RandLocation() -> CGPoint {
    let x: Int = Int.random(in: -250...250)
    let y: Int = Int.random(in: 0...400)
    
    return CGPoint(x: x, y: y)
}
