//
//  Basket.swift
//  BasketFeedbackBallGame
//
//  Created by Ali Ebrahimi Pourasad on 28.04.19.
//  Copyright © 2019 Ali Ebrahimi Pourasad. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import GameplayKit

class Basket: SKSpriteNode {
    
    //MARK:- Properties
    var leftWall = SKShapeNode()
    var rightWall = SKShapeNode()
    var base = SKShapeNode()
    var bFront = SKSpriteNode(imageNamed: "basket")
    var bBack = SKSpriteNode(imageNamed: "basket")
    
    var pc: UInt32 = 0x1 << 0
    var colliderPc: UInt32 = 0x1 << 0
    var grid: Bool
    
    //MARK:- Init
    init(pc: UInt32, colliderPc: UInt32, grid: Bool, zPosition: CGFloat) {
        self.pc = pc
        self.colliderPc = colliderPc
        self.grid = grid
        
        let texture = SKTexture(imageNamed: "basket")
        super.init(texture: texture, color: .clear, size: texture.size())
        
        self.zPosition = zPosition
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        //Bin front and back
        let binScale = CGFloat(bBack.frame.width / bBack.frame.height)
        
        bBack.size.height = self.frame.height / 9
        bBack.size.width = bBack.size.height * binScale
        bBack.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 3)
        bBack.zPosition = self.zPosition
        self.addChild(bBack)
        
        bFront.size = bBack.size
        bFront.position = bBack.position
        bFront.zPosition = bBack.zPosition + 3
        self.addChild(bFront)
        
        // Left Wall of the bin1
        leftWall = SKShapeNode(rectOf: CGSize(width: 3, height: bFront.frame.height / 1.6))
        leftWall.fillColor = .red
        leftWall.strokeColor = .clear
        leftWall.position = CGPoint(x: bFront.position.x - bFront.frame.width / 2.5, y: bFront.position.y)
        leftWall.zPosition = 10
        leftWall.alpha = grid ? 1 : 0
        
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: leftWall.frame.size)
        leftWall.physicsBody?.categoryBitMask = self.pc
        leftWall.physicsBody?.collisionBitMask = self.colliderPc
        leftWall.physicsBody?.affectedByGravity = false
        leftWall.physicsBody?.isDynamic = false
        leftWall.zRotation = CGFloat(Double.pi / 25)
        self.addChild(leftWall)
        
        // Right wall of the bin
        rightWall = SKShapeNode(rectOf: CGSize(width: 3, height: bFront.frame.height / 1.6))
        rightWall.fillColor = .red
        rightWall.strokeColor = .clear
        rightWall.position = CGPoint(x: bFront.position.x + bFront.frame.width / 2.5, y: bFront.position.y)
        rightWall.zPosition = 10
        rightWall.alpha = grid ? 1 : 0
        
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: rightWall.frame.size)
        rightWall.physicsBody?.categoryBitMask = self.pc
        rightWall.physicsBody?.collisionBitMask = self.colliderPc
        rightWall.physicsBody?.affectedByGravity = false
        rightWall.physicsBody?.isDynamic = false
        rightWall.zRotation = CGFloat(-Double.pi / 25)
        self.addChild(rightWall)
        
        // The base of the bin
        base = SKShapeNode(rectOf: CGSize(width: bFront.frame.width / 2, height: 3))
        base.fillColor = .red
        base.strokeColor = .clear
        base.position = CGPoint(x: bFront.position.x, y: bFront.position.y - bFront.frame.height / 4)
        base.zPosition = 10
        base.alpha = grid ? 1 : 0
        base.physicsBody = SKPhysicsBody(rectangleOf: base.frame.size)
        base.physicsBody?.categoryBitMask = self.pc
        base.physicsBody?.collisionBitMask = self.colliderPc
        base.physicsBody?.contactTestBitMask = self.colliderPc
        base.physicsBody?.affectedByGravity = false
        base.physicsBody?.isDynamic = false
        self.addChild(base)
    }
}
