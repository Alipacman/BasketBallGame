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
    var gameShrinkSize = CGFloat(0.7)
    
    lazy var basketY = (self.frame.height / 2.4)
    lazy var ballSize = (self.view!.frame.width / 8)
    lazy var trowVelocity = CGFloat(100.0)
    
    var transparentBorder = SKSpriteNode()
    var bg = SKSpriteNode(imageNamed: "background")            // background image
    var pBall = SKSpriteNode(imageNamed: "basketball")  // Paper Ball skin
    var notNowBotton = SKSpriteNode(imageNamed: "NotNowButton")
    
    var leftBasket: Basket?
    var middleBasket: Basket?
    var rightBasket: Basket?
    var finger: Finger?
    
    var ball = SKShapeNode()
    var startG = SKShapeNode()  // Where the paper ball will start
    var allSpriteNodes = [SKSpriteNode]()
    
    var pi = Double.pi
    var touchingBall = true
    var userInteractionAreEnabled = false
    
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
    
    //viewDidLoad
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        c.grav = -6
        c.yVel = trowVelocity
        c.airTime = 1.5
        
        physicsWorld.gravity = CGVector(dx: 0, dy: c.grav)
        setupBorder()
        setupBaskets()
        setupGame()
        setupBall()
        setupEmojiView()
        setupQuestionLabel()
        setupFinger()
        setupNotNowButton()
        
        allSpriteNodes = [middleBasket, finger, leftBasket, rightBasket, pBall, bg, transparentBorder, notNowBotton] as! [SKSpriteNode]
        
        hideGameScene()
        fadeInGameScene()
        enableUserInterAction(after: 0.5)
    }
    
    //MARK:- Setup
    private func setupNotNowButton() {
        notNowBotton.name = "btn"
        notNowBotton.size.height = 60
        notNowBotton.size.width = bg.frame.width
        notNowBotton.position = CGPoint(x: self.frame.width / 2, y: 70)
        self.addChild(notNowBotton)
    }
    
    private func setupFinger() {
        let position = CGPoint(x: 350, y: 180)
        finger = Finger(position: position, size: CGSize(width: 320, height: 55))
        self.addChild(finger!)
        finger?.rotate()
    }
    
    private func setupBorder() {
        transparentBorder.color = SKColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.6)
        transparentBorder.size.height = self.frame.height
        transparentBorder.size.width = self.frame.width
        transparentBorder.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        transparentBorder.zPosition = 0
        self.addChild(transparentBorder)
        
    }
    
    private func setupBaskets() {
        let width = (self.frame.width / 3) * gameShrinkSize
        let height = (self.frame.height / 5) * gameShrinkSize
        
        leftBasket = Basket(positionData: BasketPositionData.left,
                            pcTop: pc.basketTop,
                            pcbasketWalls: pc.basketWalls,
                            colliderPc: pc.ball,
                            grid: grids,
                            zPosition: 4,
                            size: CGSize(width: width, height: height))
        
        middleBasket = Basket(positionData: BasketPositionData.mid,
                              pcTop: pc.basketTop,
                              pcbasketWalls: pc.basketWalls,
                              colliderPc: pc.ball,
                              grid: grids,
                              zPosition: 4,
                              size: CGSize(width: width, height: height))
        
        rightBasket = Basket(positionData: BasketPositionData.right,
                             pcTop: pc.basketTop,
                             pcbasketWalls: pc.basketWalls,
                             colliderPc: pc.ball,
                             grid: grids,
                             zPosition: 4,
                             size: CGSize(width: width, height: height))
    }
    
    // Set the images and physics properties of the GameScene
    func setupGame() {
        GameState.current = .playing
        
        // Background
        bg.size.height = self.frame.height * gameShrinkSize
        bg.size.width = self.frame.width * gameShrinkSize
        bg.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        bg.zPosition = 1
        self.addChild(bg)
        
        
        // Start ground - make grids true at the top to see these lines
        startG = SKShapeNode(rectOf: CGSize(width: self.frame.width, height: 5))
        startG.fillColor = .red
        startG.strokeColor = .clear
        startG.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 5)
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
        
        let offset = self.frame.width * (1 - gameShrinkSize)/2
        let xVal = (leftBasket!.frame.width) - leftBasket!.frame.width / 2
        
        leftBasket!.position = CGPoint(x: xVal + offset , y: basketY)
        middleBasket!.position = CGPoint(x: xVal * 3 + offset, y: basketY)
        rightBasket!.position = CGPoint(x: xVal * 5 + offset, y: basketY)
        
    }
    
    // Set up the ball. This will be called to reset the ball too
    func setupBall() {
        
        // Remove and reset incase the ball was previously thrown
        pBall.removeFromParent()
        ball.removeFromParent()
        
        ball.setScale(1)
        
        // Set up ball
        ball = SKShapeNode(circleOfRadius: ballSize * gameShrinkSize)
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
        let width = (self.view?.frame.width ?? 0) * gameShrinkSize
        let height = CGFloat(50)
        let xOffset = self.frame.width * (1 - gameShrinkSize)/2
        
        self.view?.addSubview(emojiView)
        emojiView.frame = CGRect(x: xOffset, y: self.frame.height / 2.8, width: width, height: height)
    }
    
    private func setupQuestionLabel() {
        let width = ((self.view?.frame.width)! - 32) * gameShrinkSize
        let height = CGFloat(100)
        let xOffset = self.frame.width * (1 - gameShrinkSize)/2
        
        self.view?.addSubview(questionLabel)
        questionLabel.frame = CGRect(x: 8 + xOffset, y: self.frame.height / 6, width: width , height: height)
    }
    
    //MARK:- Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if userInteractionAreEnabled {
            for touch in touches {
                let location = touch.location(in: self)
                if GameState.current == .playing {
                    
                    let positionInScene = touch.location(in: self)
                    let touchedNode = self.atPoint(positionInScene)
                    
                    if let name = touchedNode.name {
                        if name == "btn" {
                            GameState.current = .menu
                            self.fadeOutGameScene()
                        }
                    }
                    
                    finger?.fadeOut()
                    if ball.contains(location){
                        t.start = CGPoint(x: self.frame.width / 2, y: startG.position.y + ball.frame.height)
                        touchingBall = true
                    }
                }
            }
        }
    }
    
    // Fires as soon as the touch leaves the screen
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if userInteractionAreEnabled {
            for touch in touches {
                let location = touch.location(in: self)
                if GameState.current == .playing && !ball.contains(location) && touchingBall{
                    setAccordingBasketAsEndPoint(with: location)
                    touchingBall = false
                    fire()
                    fadeOut(node: ball, withDuration: 0.3, withDelay: 1.2)
                }
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
        let amendedX = (tan(angle * CGFloat(pi) / CGFloat(180)) * 45) * 0.5
        
        // Throw it!
        let throwVec = CGVector(dx: amendedX, dy: c.yVel)
        ball.physicsBody?.applyImpulse(throwVec, at: t.start)
        
        // Shrink
        ball.run(SKAction.scale(by: 0.2, duration: c.airTime))
        
        // Change Collision Bitmask
        let wait = SKAction.wait(forDuration: 0.5)
        let changeCollision = SKAction.run({
            self.ball.physicsBody?.collisionBitMask = pc.basketWalls | pc.basketTop
            self.ball.zPosition = 3
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

extension GameScene {
    private func enableUserInterAction(after seconds: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: {
            self.userInteractionAreEnabled = true
        })
    }
    
    private func hideGameScene() {
        questionLabel.alpha = 0
        emojiView.alpha = 0
        allSpriteNodes.forEach {$0.alpha = 0}
    }
    
    private func fadeInGameScene() {
        let fadeInAction = SKAction.fadeIn(withDuration: 0.5)
        allSpriteNodes.forEach {$0.run(fadeInAction)}
        questionLabel.fadeIn()
        emojiView.fadeIn()
    }
    
    private func fadeOutGameScene() {
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        allSpriteNodes.forEach {$0.run(fadeOutAction)}
        questionLabel.fadeOut()
        emojiView.fadeOut()
    }
    
    private func fadeOut(node: SKNode, withDuration duration: Double, withDelay delay: Double) {
        let fadeOutAction = SKAction.fadeOut(withDuration: duration)
        let delay = SKAction.wait(forDuration: delay)
        
        node.run(SKAction.sequence([delay,fadeOutAction]))
    }
}

extension UIView {
    
    func fadeIn(){
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: nil)
    }
    
    
    func fadeOut(){
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.alpha = 0.0
        }, completion: nil)
    }
}
