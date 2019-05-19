//
//  Finger.swift
//  BasketFeedbackBallGame
//
//  Created by Ali Ebrahimi Pourasad on 12.05.19.
//  Copyright © 2019 Ali Ebrahimi Pourasad. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class Finger: SKSpriteNode {

    //MARK:- Init
    init(position: CGPoint, size: CGSize) {
        
        let texture = SKTexture(imageNamed: "finger")
        super.init(texture: texture, color: .clear, size: size)
        self.zPosition = 20
        
        self.position = position
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func rotate() {
        let rotate = SKAction.rotate(toAngle: -20, duration: 0.65, shortestUnitArc: true)
        let rotateBack = SKAction.rotate(toAngle: 0, duration: 0.65, shortestUnitArc: true)
        self.run(rotate, completion: {
            self.run(rotateBack, completion: {self.rotate()})
            })
    }
    
    func fadeOut() {
        self.run(SKAction.fadeOut(withDuration: 0.3),completion: {
            self.removeAllActions()
        })
        
    }
}
