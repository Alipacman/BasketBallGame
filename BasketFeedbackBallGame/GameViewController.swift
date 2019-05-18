//
//  GameViewController.swift
//  BasketFeedbackBallGame
//
//  Created by Ali Ebrahimi Pourasad on 13.04.19.
//  Copyright © 2019 Ali Ebrahimi Pourasad. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

public class GameViewController: UIViewController {
    
    let frame = CGRect(x: 0, y: 0, width: 375, height: 812)
    
    let gameView = SKView(frame: CGRect(x: 0, y: 0, width: 375, height: 812))
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the SKScene from 'GameScene.sks'
        if let scene = SKScene(fileNamed: "GameScene") {
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            scene.size = frame.size
            // Present the scene
            gameView.presentScene(scene)
        }
        
        gameView.ignoresSiblingOrder = true
        //self.view.addSubview(gameView)
    }
    
    public func getGameView() -> UIView {
        return gameView
    }
}
