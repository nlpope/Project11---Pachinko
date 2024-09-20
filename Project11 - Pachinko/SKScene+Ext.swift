//
//  SKScene+Ext.swift
//  Project11 - Pachinko
//
//  Created by Noah Pope on 9/20/24.
//

import Foundation
import SpriteKit

extension SKScene {
    func randomFloat(low: CGFloat, high: CGFloat) -> CGFloat {
        return CGFloat.random(in: low...high)
    }
}
