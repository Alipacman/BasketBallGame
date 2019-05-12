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
    static let basketTop: UInt32 = 0x1 << 2
    static let basketWalls: UInt32 = 0x1 << 4
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
    
    // MARK:-Properties
    var grids = false   // turn on to see all the physics grid lines
    lazy var basketY = self.frame.height / 2.6
    lazy var ballSize = self.view!.frame.width / 8.3
    lazy var trowVelocity = self.frame.height / 4
    
    var bg = SKSpriteNode(imageNamed: "background")            // background image
    var pBall = SKSpriteNode(imageNamed: "basketball")  // Paper Ball skin
    
    var leftBasket: Basket?
    var middleBasket: Basket?
    var rightBasket: Basket?
    
    var pi = Double.pi
    var touchingBall = true
    
    var ball = SKShapeNode()
    var startG = SKShapeNode()  // Where the paper ball will start
    
    let emojiView = EmojiView(frame: .zero)
    let questionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont(name: "PingFang HK", size: 22)
        label.text = "Do you like the design\n of the app?"
        return label
    }()
    
    // Did Move To View - The GameViewController.swift has now displayed GameScene.swift and will instantly run this function.
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
            c.grav = -6
            c.yVel = trowVelocity
            c.airTime = 1.5
        
        physicsWorld.gravity = CGVector(dx: 0, dy: c.grav)
        setupBaskets()
        setupGame()
        setupBall()
        setupEmojiView()
        setupQuestionLabel()
    }
    
    //MARK:- Setup
    private func setupBaskets() {
        leftBasket = Basket(positionData: BasketPositionData.left,
                            pcTop: pc.basketTop,
                            pcbasketWalls: pc.basketWalls,
                            colliderPc: pc.ball,
                            grid: grids,
                            zPosition: 2,
                            size: CGSize(width: self.frame.width / 3, height: self.frame.height / 5))
        
        middleBasket = Basket(positionData: BasketPositionData.mid,
                              pcTop: pc.basketTop,
                              pcbasketWalls: pc.basketWalls,
                              colliderPc: pc.ball,
                              grid: grids,
                              zPosition: 2,
                              size: CGSize(width: self.frame.width / 3, height: self.frame.height / 5))
        
        rightBasket = Basket(positionData: BasketPositionData.right,
                             pcTop: pc.basketTop,
                             pcbasketWalls: pc.basketWalls,
                             colliderPc: pc.ball,
                             grid: grids,
                             zPosition: 2,
                             size: CGSize(width: self.frame.width / 3, height: self.frame.height / 5))
    }
    
    // Set the images and physics properties of the GameScene
    func setupGame() {
        GameState.current = .playing
        
        // Background
        bg.size.height = self.frame.height
        bg.size.width = self.frame.width
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
        
        self.addChild(leftBasket!)
        self.addChild(middleBasket!)
        self.addChild(rightBasket!)
        
        let xVal = leftBasket!.frame.width - leftBasket!.frame.width / 2
        
        leftBasket!.position = CGPoint(x: xVal , y: basketY)
        middleBasket!.position = CGPoint(x: xVal * 3, y: basketY)
        rightBasket!.position = CGPoint(x: xVal * 5, y: basketY)
        
    }
    
    // Set up the ball. This will be called to reset the ball too
    func setupBall() {
        
        // Remove and reset incase the ball was previously thrown
        pBall.removeFromParent()
        ball.removeFromParent()
        
        ball.setScale(1)
        
        // Set up ball
        ball = SKShapeNode(circleOfRadius: ballSize)
        ball.fillColor = grids ? .blue : .clear
        ball.strokeColor = .clear
        ball.position = CGPoint(x: self.frame.width / 2, y: startG.position.y + ball.frame.height)
        ball.zPosition = 10
        
        // Add "paper skin" to the circle shape
        pBall.size = ball.frame.size
        ball.addChild(pBall)
        
        // Set up the balls physics properties
        ball.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "basketball"), size: pBall.size)
        ball.physicsBody?.categoryBitMask = pc.ball
        ball.physicsBody?.collisionBitMask = pc.sG
        ball.physicsBody?.contactTestBitMask = pc.basketWalls
        ball.physicsBody?.affectedByGravity = true
        ball.physicsBody?.isDynamic = true
        self.addChild(ball)
    }
    
    private func setupEmojiView() {
        self.view?.addSubview(emojiView)
        emojiView.frame = CGRect(x: 0, y: self.frame.height / 3, width: self.view?.frame.width ?? 0, height: 50)
    }
    
    private func setupQuestionLabel() {
        self.view?.addSubview(questionLabel)
        let width = (self.view?.frame.width)! - 32
        questionLabel.frame = CGRect(x: 16, y: self.frame.height / 8, width: width , height: 100)
    }
    
    //MARK:- Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if GameState.current == .playing {
                if ball.contains(location){
                    t.start = CGPoint(x: self.frame.width / 2, y: startG.position.y + ball.frame.height)
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
                setAccordingBasketAsEndPoint(with: location)
                touchingBall = false
                fire()
            }
        }
    }
    
    //MARK:-
    func setAccordingBasketAsEndPoint(with location: CGPoint) {
        let thirdOfScreen = self.frame.width/3
        let sixOfScreen = self.frame.width/6
        switch location.x {
        case 0...thirdOfScreen:
            t.end = CGPoint(x: sixOfScreen*2, y: basketY)
        case thirdOfScreen...thirdOfScreen*2:
            t.end = CGPoint(x: sixOfScreen*3, y: basketY)
        case thirdOfScreen*2...thirdOfScreen*3:
            t.end = CGPoint(x: sixOfScreen*4, y: basketY)
        default:
            t.end = location
        }
        print(t.end)
    }
    
    func fire() {
        
        let xChange = t.end.x - t.start.x
        let angle = (atan(xChange / CGFloat((t.end.y - t.start.y))) * 180 / CGFloat(pi))
        let amendedX = (tan(angle * CGFloat(pi) / CGFloat(180)) * c.yVel) * 0.5
        
        // Throw it!
        let throwVec = CGVector(dx: amendedX, dy: c.yVel)
        ball.physicsBody?.applyImpulse(throwVec, at: t.start)
        
        // Shrink
        ball.run(SKAction.scale(by: 0.2, duration: c.airTime))
        
        // Change Collision Bitmask
        let wait = SKAction.wait(forDuration: c.airTime / 2)
        let changeCollision = SKAction.run({
            self.ball.physicsBody?.collisionBitMask = pc.basketWalls | pc.basketTop
            self.ball.zPosition = 2
        })
        
        self.run(SKAction.sequence([wait,changeCollision]))
        
        // Wait & reset
        let wait4 = SKAction.wait(forDuration: 2.5)
        let reset = SKAction.run({
            self.setupBall()
        })
        self.run(SKAction.sequence([wait4,reset]))
    }
}
