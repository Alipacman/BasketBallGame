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

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                scene.size = self.view.bounds.size
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
