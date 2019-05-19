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
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadGameScene()
        self.view.backgroundColor = .clear
    }
    
    
    func loadGameScene() {
        let scene = GameScene(size: view.frame.size)
        scene.scaleMode = .fill
        let transitionType = SKTransition.flipHorizontal(withDuration: 1.0)
        let skView1 = SKView(frame: view.frame)
        skView1.ignoresSiblingOrder = true
        skView1.presentScene(scene,transition: transitionType)
        self.view.addSubview(skView1)
    }
}
