//
//  GameScene.swift
//  Lessons-66-Game-SpriteKit-Shooters
//
//  Created by Serhii Prysiazhnyi on 15.11.2024.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bulletsSprite: SKSpriteNode!   // патроны

        var bulletTextures = [
            SKTexture(imageNamed: "shots0"),
            SKTexture(imageNamed: "shots1"),
            SKTexture(imageNamed: "shots2"),
            SKTexture(imageNamed: "shots3"),
        ]
    var bulletsInClip = 3 {
            didSet {
                bulletsSprite.texture = bulletTextures[bulletsInClip]
            }
        }
    
    var scoreLabel: SKLabelNode!

        var score = 0 {
            didSet {
                scoreLabel.text = "Score: \(score)"
            }
        }
    
    var isGameOver = false
    
    
    override func didMove(to view: SKView) {
        
        // Получаем размеры экрана
               let screenSize = view.bounds.size
        print(screenSize)
     
        //createBackground()
        
        let background = SKSpriteNode(imageNamed: "wood-background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        addChild(background)

        let grass = SKSpriteNode(imageNamed: "grass-trees")
        grass.position = CGPoint(x: 512, y: 50)
        addChild(grass)
        grass.zPosition = 100
        
//        let background = SKSpriteNode(imageNamed: "whackBackground")
//        background.position = CGPoint(x: 512, y: 384)
//        background.blendMode = .replace
//        background.zPosition = -1
//        addChild(background)
    }
    
    func createBackground() {
    
        
//            let background = SKSpriteNode(imageNamed: "wood-background")
//            background.position = CGPoint(x: 512, y: 384)
//            background.blendMode = .replace
//           // background.size = screenSize
//            addChild(background)
//
//            let grass = SKSpriteNode(imageNamed: "grass-trees")
//            grass.position = CGPoint(x: 512, y: 384)
//            addChild(grass)
//            grass.zPosition = 100
        }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        }
}
