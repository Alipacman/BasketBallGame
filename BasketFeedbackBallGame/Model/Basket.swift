//
//  Basket.swift
//  BasketFeedbackBallGame
//
//  Created by Ali Ebrahimi Pourasad on 28.04.19.
//  Copyright © 2019 Ali Ebrahimi Pourasad. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

enum BasketPositionData {
    case left
    case right
    case mid
    
    var basketFrontImageName: String {
        switch self {
        case .left:
            return "leftBasketFront"
        case .right:
            return "rightBasketFront"
        case .mid:
            return "midBasketFront"
        }
    }
    
    var basketBackImageName: String {
        switch self {
        case .left:
            return "leftBasketBack"
        case .right:
            return "rightBasketBack"
        case .mid:
            return "midBasketBack"
        }
    }
}

class Basket: SKSpriteNode {
    
    //MARK:- Properties
    var leftWall = SKShapeNode()
    var rightWall = SKShapeNode()
    
    var base = SKShapeNode()
    var front: SKSpriteNode
    var back: SKSpriteNode
    
    var pc: UInt32 = 0x1 << 0
    var colliderPc: UInt32 = 0x1 << 0
    var grid: Bool
    
    //MARK:- Init
    init(positionData: BasketPositionData, pc: UInt32, colliderPc: UInt32, grid: Bool, zPosition: CGFloat, size: CGSize) {
        self.pc = pc
        self.colliderPc = colliderPc
        self.grid = grid
        
        front = SKSpriteNode(imageNamed: positionData.basketFrontImageName)
        back = SKSpriteNode(imageNamed: positionData.basketBackImageName)
        
        let texture = SKTexture(imageNamed: positionData.basketFrontImageName)
        super.init(texture: texture, color: .clear, size: size)
        self.zPosition = zPosition
        
        setup()
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Setup
    private func setup() {
        
        back.zPosition = self.zPosition
        self.addChild(back)
        
        front.zPosition = self.zPosition + 3
        //self.addChild(front)
        
        // Left Wall of the bin1
        leftWall = SKShapeNode(rectOf: CGSize(width: 3, height: self.frame.height / 1.6))
        leftWall.fillColor = .red
        leftWall.strokeColor = .clear
        leftWall.zPosition = zPosition
        leftWall.alpha = grid ? 1 : 0
        
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: leftWall.frame.size)
        leftWall.physicsBody?.categoryBitMask = self.pc
        leftWall.physicsBody?.collisionBitMask = self.colliderPc
        leftWall.physicsBody?.affectedByGravity = false
        leftWall.physicsBody?.isDynamic = false
        leftWall.zRotation = CGFloat(Double.pi / 25)
        self.addChild(leftWall)
        
        // Right wall of the bin
        rightWall = SKShapeNode(rectOf: CGSize(width: 3, height: self.frame.height / 1.6))
        rightWall.fillColor = .red
        rightWall.strokeColor = .clear
        rightWall.zPosition = zPosition
        rightWall.alpha = grid ? 1 : 0
        
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: rightWall.frame.size)
        rightWall.physicsBody?.categoryBitMask = self.pc
        rightWall.physicsBody?.collisionBitMask = self.colliderPc
        rightWall.physicsBody?.affectedByGravity = false
        rightWall.physicsBody?.isDynamic = false
        rightWall.zRotation = CGFloat(-Double.pi / 25)
        self.addChild(rightWall)
        
        // The base of the bin
        base = SKShapeNode(rectOf: CGSize(width: self.frame.width / 2, height: 3))
        base.fillColor = .red
        base.strokeColor = .clear
        base.zPosition = 0
        base.alpha = grid ? 1 : 0
        base.physicsBody = SKPhysicsBody(rectangleOf: base.frame.size)
        base.physicsBody?.categoryBitMask = self.pc
        base.physicsBody?.collisionBitMask = self.colliderPc
        base.physicsBody?.contactTestBitMask = self.colliderPc
        base.physicsBody?.affectedByGravity = false
        base.physicsBody?.isDynamic = false
        self.addChild(base)
    }
    
    //MARK:- Layout
    private func layout() {
        back.size = self.size
        back.position = self.position
        
        rightWall.position = CGPoint(x: self.position.x + self.frame.width / 2.5, y: self.position.y)
        base.position = CGPoint(x: self.position.x, y: self.position.y - self.frame.height / 4)
        leftWall.position = CGPoint(x: self.position.x - self.frame.width / 2.5, y: self.position.y)
    }
}
