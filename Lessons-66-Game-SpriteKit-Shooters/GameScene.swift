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
    
        var targetSpeed = 4.0
        var targetDelay = 0.8
        var targetsCreated = 0
        //var cursor: SKSpriteNode! // Узел для отображения курсора
    
        var isGameOver = false
    
    
    override func didMove(to view: SKView) {
     
        createBackground()
        createOverlay()
        
        levelUp()
        
        // Масштабируем сцену под экран
            //self.scaleMode = .Fill
        
        // Создаем и настраиваем "курсор"
//        cursor = SKSpriteNode(imageNamed: "cursor")
//        cursor.size = CGSize(width: 50, height: 50) // Размер курсора
//        cursor.zPosition = 1000 // Отображение поверх всех элементов
//        addChild(cursor)
//        
//        // Устанавливаем изначальную позицию
//        cursor.position = CGPoint(x: size.width / 2, y: size.height / 2)
    }
    
    func createBackground() {
    
            let background = SKSpriteNode(imageNamed: "wood-background")
            background.position = CGPoint(x: 512, y: 384)
            background.blendMode = .replace
            addChild(background)

            let grass = SKSpriteNode(imageNamed: "grass-trees")
            grass.position = CGPoint(x: 512, y: 50)
            addChild(grass)
            grass.zPosition = 100
        }
    
    func createOverlay() {
            let curtains = SKSpriteNode(imageNamed: "curtains")
            curtains.position = CGPoint(x: 512, y: 384)
            curtains.zPosition = 400
            addChild(curtains)

            bulletsSprite = SKSpriteNode(imageNamed: "shots3")
            bulletsSprite.position = CGPoint(x: 170, y: 60)
            bulletsSprite.zPosition = 500
            addChild(bulletsSprite)

            scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
            scoreLabel.horizontalAlignmentMode = .right
            scoreLabel.position = CGPoint(x: 854, y: 50)
            scoreLabel.zPosition = 500
            scoreLabel.text = "Score: 0"
            addChild(scoreLabel)
        }
    
    func createTarget() {
            let target = Target()
            target.setup()

            let level = Int.random(in: 0...2)
            var movingRight = true

            switch level {
            case 0:
                // in front of the grass
                target.zPosition = 150
                target.position.y = 200
                target.setScale(0.7)
            case 1:
                // in front of the water background
                target.zPosition = 250
                target.position.y = 190
                target.setScale(0.85)
                movingRight = false
            default:
                // in front of the water foreground
                target.zPosition = 350
                target.position.y = 100
            }

            let move: SKAction

            if movingRight {
                target.position.x = 0
                move = SKAction.moveTo(x: 1024, duration: targetSpeed)
            } else {
                target.position.x = 1024
                target.xScale = -target.xScale
                move = SKAction.moveTo(x: 0, duration: targetSpeed)
            }

            let sequence = SKAction.sequence([move, SKAction.removeFromParent()])
            target.run(sequence)
            addChild(target)

            levelUp()
        }

        func levelUp() {
            targetSpeed *= 0.99
            targetDelay *= 0.99
            targetsCreated += 1
            
            print(targetsCreated, targetSpeed)

            if targetsCreated < 10 {
                DispatchQueue.main.asyncAfter(deadline: .now() + targetDelay) { [unowned self] in
                    self.createTarget()
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [unowned self] in
                    self.gameOver()
                }
            }
        }
    
    func gameOver() {
        isGameOver = true
        
        // Создаем узел для отображения текста "Game Over"
        let gameOverTitle = SKSpriteNode(imageNamed: "game-over")
        gameOverTitle.position = CGPoint(x: size.width / 2, y: size.height / 1.5) // Центр сцены
        gameOverTitle.alpha = 0
        gameOverTitle.setScale(2) // Увеличенный начальный масштаб
        
        // Создаем анимации
        let fadeIn = SKAction.fadeIn(withDuration: 0.3) // Плавное появление
        let scaleDown = SKAction.scale(to: 1, duration: 0.3) // Уменьшение масштаба до 1
        let group = SKAction.group([fadeIn, scaleDown]) // Одновременное выполнение
        
        // Запускаем анимацию
        gameOverTitle.run(group)
        gameOverTitle.zPosition = 900 // Слой поверх всех элементов
        addChild(gameOverTitle) // Добавляем узел на сцену
        
        // Получаем доступ к текущему представлению и его контроллеру
        if let view = self.view, let viewController = view.window?.rootViewController {
            // Создаем UIAlertController
            let ac = UIAlertController(
                title: "Your score: \(score)",
                message: "Press OK to start the game again",
                preferredStyle: .alert
            )
            // Действие по нажатию "OK" для сброса и перезапуска игры
            ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                guard let self = self else { return }
                // Сброс всех игровых значений
                self.score = 0
                self.isGameOver = false
                self.targetSpeed = 4.0
                self.targetDelay = 0.8
                self.targetsCreated = 0
                
                // Удаляем все дочерние узлы на сцене
                    self.removeAllChildren()
                
                bulletsInClip = 3
                createBackground()
                createOverlay()
                levelUp()
            })
            // Отображаем UIAlertController
            viewController.present(ac, animated: true)
        }
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if isGameOver {
            if let newGame = SKScene(fileNamed: "GameScene") {
                let transition = SKTransition.doorway(withDuration: 1)
                view?.presentScene(newGame, transition: transition)
            }
        } else {
            // Проверяем, есть ли мишень в месте касания
            let hitNodes = nodes(at: location).filter { $0.name == "target" }
            
            if hitNodes.first != nil {
                // Если попали в мишень, стреляем
                if bulletsInClip > 0 {
                    run(SKAction.playSoundFileNamed("shot.wav", waitForCompletion: false))
                    bulletsInClip -= 1
                    shot(at: location)
                } else {
                    run(SKAction.playSoundFileNamed("empty.wav", waitForCompletion: false))
                }
            } else if bulletsInClip == 0 {
                // Если промахнулись, выполняем перезарядку
                reload()
            }
        }
    }

        func shot(at location: CGPoint) {
            let hitNodes = nodes(at: location).filter { $0.name == "target" }

            guard let hitNode = hitNodes.first else { return }
            guard let parentNode = hitNode.parent as? Target else { return }

            parentNode.hit()

            score += 3
        }
    
    func reload() {
        guard isGameOver == false else { return }
        
        run(SKAction.playSoundFileNamed("reload.wav", waitForCompletion: false))
        bulletsInClip = 3
        score -= 1
    }
}
