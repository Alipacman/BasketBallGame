//
//  GameScene.swift
//  PaperToss
//
//  Created by steve on 10/1/17.
//  Copyright © 2017 Steve Richardson. All rights reserved.
//

import SpriteKit
import GameplayKit

// The current state of the game
enum GameState {
    case playing
    case menu
    static var current = GameState.playing
}

struct pc { // Physics Category
    static let none: UInt32 = 0x1 << 0
    static let ball: UInt32 = 0x1 << 1
    static let basket: UInt32 = 0x1 << 2
    static let sG: UInt32 = 0x1 << 3 //startGround
}

// Really these can just be a variable inside the GameScene Class
struct t { // Start and end touch points - Records when we touch the ball (start) & when we let go (end)
    static var start = CGPoint()
    static var end = CGPoint()
}

// Same as these
struct c {  // Constants
    static var grav = CGFloat() // Gravity
    static var yVel = CGFloat() // Initial Y Velocity
    static var airTime = TimeInterval() // Time the ball is in the air
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Variables
    var grids = false   // turn on to see all the physics grid lines
    
    // SKSprites
    var bg = SKSpriteNode(imageNamed: "background")            // background image
    var pBall = SKSpriteNode(imageNamed: "basketball")  // Paper Ball skin
    
    //baskets
    var leftBasket: Basket
    var middleBasket: Basket
    var rightBasket: Basket
   
    //SKShapes
    var ball = SKShapeNode()
    var startG = SKShapeNode()  // Where the paper ball will start
    
    override init() {
        leftBasket = Basket(pc: pc.basket, colliderPc: pc.ball, grid: false, zPosition: bg.zPosition + 1)
        middleBasket = Basket(pc: pc.basket, colliderPc: pc.ball, grid: false, zPosition: bg.zPosition + 1)
        rightBasket = Basket(pc: pc.basket, colliderPc: pc.ball, grid: false, zPosition: bg.zPosition + 1)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        leftBasket = Basket(pc: pc.basket, colliderPc: pc.ball, grid: false, zPosition: bg.zPosition + 1)
        middleBasket = Basket(pc: pc.basket, colliderPc: pc.ball, grid: false, zPosition: bg.zPosition + 1)
        rightBasket = Basket(pc: pc.basket, colliderPc: pc.ball, grid: false, zPosition: bg.zPosition + 1)
        super.init(coder: aDecoder)
    }
    
    // CGFloats
    var pi = Double.pi
    
    var touchingBall = false
    
    // Did Move To View - The GameViewController.swift has now displayed GameScene.swift and will instantly run this function.
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            c.grav = -6
            c.yVel = self.frame.height / 4
            c.airTime = 1.5
        }else{
            // iPad
        }
        
        physicsWorld.gravity = CGVector(dx: 0, dy: c.grav)
        
        setUpGame()
    }
    
    private func setupBaskets() {
        leftBasket = Basket(pc: pc.basket, colliderPc: pc.ball, grid: false, zPosition: bg.zPosition + 1)
        middleBasket = Basket(pc: pc.basket, colliderPc: pc.ball, grid: false, zPosition: bg.zPosition + 1)
        rightBasket = Basket(pc: pc.basket, colliderPc: pc.ball, grid: false, zPosition: bg.zPosition + 1)
    }
    
    // Fires the instant a touch has made contact with the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if GameState.current == .playing {
                if ball.contains(location){
                    t.start = location
                    touchingBall = true
                }
            }
        }
    }
    
    // Fires as soon as the touch leaves the screen
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if GameState.current == .playing && !ball.contains(location) && touchingBall{
                t.end = location
                touchingBall = false
                fire()
            }
        }
    }
    
    // Set the images and physics properties of the GameScene
    func setUpGame() {
        GameState.current = .playing
        
        // Background
        let bgScale = CGFloat(bg.frame.width / bg.frame.height) // eg. 1.4 as a scale
        
        bg.size.height = self.frame.height
        bg.size.width = bg.size.height * bgScale
        bg.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        bg.zPosition = 0
        self.addChild(bg)
        
        
        // Start ground - make grids true at the top to see these lines
        startG = SKShapeNode(rectOf: CGSize(width: self.frame.width, height: 5))
        startG.fillColor = .red
        startG.strokeColor = .clear
        startG.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 10)
        startG.zPosition = 10
        startG.alpha = grids ? 1 : 0
        
        startG.physicsBody = SKPhysicsBody(rectangleOf: startG.frame.size)
        startG.physicsBody?.categoryBitMask = pc.sG
        startG.physicsBody?.collisionBitMask = pc.ball
        startG.physicsBody?.contactTestBitMask = pc.none
        startG.physicsBody?.affectedByGravity = false
        startG.physicsBody?.isDynamic = false
        self.addChild(startG)
        
        leftBasket.position = CGPoint(x: 0, y: self.frame.height / 3)
        middleBasket.position = CGPoint(x: leftBasket.frame.width, y: self.frame.height / 3)
        rightBasket.position = CGPoint(x: leftBasket.frame.width * 2, y: self.frame.height / 3)
        
        setBall()
    }
    
    // Set up the ball. This will be called to reset the ball too
    func setBall() {
        
        // Remove and reset incase the ball was previously thrown
        pBall.removeFromParent()
        ball.removeFromParent()
        
        ball.setScale(1)
        
        // Set up ball
        ball = SKShapeNode(circleOfRadius: self.view!.frame.width / 5)
        ball.fillColor = grids ? .blue : .clear
        ball.strokeColor = .clear
        ball.position = CGPoint(x: self.frame.width / 2, y: startG.position.y + ball.frame.height)
        ball.zPosition = 10
        
        // Add "paper skin" to the circle shape
        pBall.size = ball.frame.size
        ball.addChild(pBall)
        
        // Set up the balls physics properties
        ball.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "paperBallImage"), size: pBall.size)
        ball.physicsBody?.categoryBitMask = pc.ball
        ball.physicsBody?.collisionBitMask = pc.sG
        ball.physicsBody?.contactTestBitMask = pc.basket
        ball.physicsBody?.affectedByGravity = true
        ball.physicsBody?.isDynamic = true
        self.addChild(ball)
    }
    
    // When touches ended this is called to shoot the paper ball
    func fire() {
        
        let xChange = t.end.x - t.start.x
        let angle = (atan(xChange / CGFloat((t.end.y - t.start.y))) * 180 / CGFloat(pi))
        let amendedX = (tan(angle * CGFloat(pi) / CGFloat(180)) * c.yVel) * 0.5
        
        // Throw it!
        let throwVec = CGVector(dx: amendedX, dy: c.yVel)
        ball.physicsBody?.applyImpulse(throwVec, at: t.start)
        
        // Shrink
        ball.run(SKAction.scale(by: 0.3, duration: c.airTime))
        
        // Change Collision Bitmask
        let wait = SKAction.wait(forDuration: c.airTime / 2)
        let changeCollision = SKAction.run({
            self.ball.physicsBody?.collisionBitMask = pc.sG | pc.basket
            self.ball.zPosition = self.bg.zPosition + 2
        })
        
        self.run(SKAction.sequence([wait,changeCollision]))
        
        // Wait & reset
        let wait4 = SKAction.wait(forDuration: 4)
        let reset = SKAction.run({
            self.setBall()
        })
        self.run(SKAction.sequence([wait4,reset]))
    }
}
