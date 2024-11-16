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
    
    var timerLabel: SKLabelNode!
    var timeRemaining: Int = 60
    var lastUpdateTime: TimeInterval = 0
    var gamePaused = false  // Флаг для остановки игры
    
    var isGameOver = false
    
    
    override func didMove(to view: SKView) {
        
        createBackground()
        createOverlay()
        timer()
        levelUp()
        createTargetsInfo()
        
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
        grass.position = CGPoint(x: 512, y: 250)
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
        
        // Проверка, добавляется ли мишень
            print("Создана мишень с именем: \(target.target.name ?? "без имени")")

        
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
        
      // print(targetsCreated, targetSpeed)
        
        if targetsCreated < 120 {
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
        gamePaused = true  // Останавливаем игру
        
        // Создаем узел для отображения текста "Game Over"
        let gameOverTitle = SKSpriteNode(imageNamed: "game-over")
        gameOverTitle.position = CGPoint(x: size.width / 2, y: size.height / 1.4) // Центр сцены
        gameOverTitle.alpha = 0
        gameOverTitle.setScale(2) // Увеличенный начальный масштаб
 
        // Создаем анимации
        let fadeIn = SKAction.fadeIn(withDuration: 0.3) // Плавное появление
        let scaleDown = SKAction.scale(to: 1, duration: 0.3) // Уменьшение масштаба до 1
        let group = SKAction.group([fadeIn, scaleDown]) // Одновременное выполнение
        
        //        // Запускаем анимацию
        gameOverTitle.run(group)
        gameOverTitle.zPosition = 900 // Слой поверх всех элементов
        addChild(gameOverTitle) // Добавляем узел на сцену
        
        // Вызываем кастомное окно оповещения
        showCustomAlert()
        
                          // системный алерт
        //        // Получаем доступ к текущему представлению и его контроллеру
        //        if let view = self.view, let viewController = view.window?.rootViewController {
        //            // Создаем UIAlertController
        //            let ac = UIAlertController(
        //                title: "Your score: \(score)",
        //                message: "Press OK to start the game again",
        //                preferredStyle: .alert
        //            )
        //            // Действие по нажатию "OK" для сброса и перезапуска игры
        //            ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
        //                guard let self = self else { return }
        //                // Сброс всех игровых значений
        //                self.score = 0
        //                self.isGameOver = false
        //                self.targetSpeed = 4.0
        //                self.targetDelay = 0.8
        //                self.targetsCreated = 0
        //
        //                // Удаляем все дочерние узлы на сцене
        //                self.removeAllChildren()
        //                self.timeRemaining = 60
        //
        //                timer()
        //                bulletsInClip = 3
        //                createBackground()
        //                createOverlay()
        //                levelUp()
        //            })
        //            // Отображаем UIAlertController
        //            viewController.present(ac, animated: true)
        //        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Если игра закончена, проверяем, была ли нажата кнопка перезапуска
        if isGameOver {
            let hitNodes = nodes(at: location).filter { $0.name == "startNewGameButton" }
            
            if let _ = hitNodes.first {
                // Перезапускаем игру, если нажата кнопка
                restartGame()
            }
        } else {
            // Проверяем, есть ли мишень в месте касания
            let hitNodes = nodes(at: location).filter { $0.name == "target3" || $0.name == "target0" || $0.name == "target1" || $0.name == "target2" }
            
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
    
//    func shot(at location: CGPoint) {
//        let hitNodes = nodes(at: location).filter { $0.name == "target" }
//        
//        guard let hitNode = hitNodes.first else { return }
//        guard let parentNode = hitNode.parent as? Target else { return }
//        
//        parentNode.hit()
//        
//        score += 3
//        
//    }
    
//    func shot(at location: CGPoint) {
//        // Проверяем, есть ли в месте касания мишень с именем "target3"
//        let hitNodes3 = nodes(at: location).filter { $0.name == "target3" }
//        
//        if let hitNode = hitNodes3.first {
//            // Если попали в target3, уменьшаем счет на 5
//            score -= 5
//            hitNode.removeFromParent() // Убираем мишень с экрана после попадания
//            return
//        }
//        
//        // Если попали в обычную мишень target0, target1 или target2, увеличиваем счет
//        let hitNodes = nodes(at: location).filter { $0.name == "target0" || $0.name == "target1" || $0.name == "target2" }
//        
//        if let hitNode = hitNodes.first {
//            switch hitNode.name {
//            case "target0":
//                score += 1
//            case "target1":
//                score += 3
//            case "target2":
//                score += 5
//            default:
//                break
//            }
//            
//            hitNode.removeFromParent() // Убираем мишень с экрана после попадания
//        }
//    }

    
    func shot(at location: CGPoint) {
        let hitNodes = nodes(at: location)

        for node in hitNodes {
            if let nodeName = node.name {
                switch nodeName {
                case "target0":
                    score += 1
                case "target1":
                    score += 2
                case "target2":
                    score += 3
                case "target3":
                    score -= 5
                default:
                    continue
                }
                
                // Удаляем узел после попадания
                node.removeFromParent()
                return
            }
        }
    }

    
    func reload() {
        guard isGameOver == false else { return }
        
        run(SKAction.playSoundFileNamed("reload.wav", waitForCompletion: false))
        bulletsInClip = 3
       // score -= 1
    }
    
    func timer() {
        timerLabel = SKLabelNode(fontNamed: "Chalkduster")
        timerLabel.fontSize = 40
        timerLabel.position = CGPoint(x: 100, y: size.height - 100)
        timerLabel.zPosition = 500
        timerLabel.text = "Time: \(timeRemaining)"
        addChild(timerLabel)
    }
    
    override func update(_ currentTime: TimeInterval) {
        let deltaTime = currentTime - lastUpdateTime
        if deltaTime >= 1 {
            lastUpdateTime = currentTime
            if timeRemaining > 0 {
                timeRemaining -= 1
                timerLabel.text = "Time: \(timeRemaining)"
            } else if !isGameOver {
                gameOver()
            }
        }
    }
    
    func showCustomAlert() {
        // Создаем фон для окна оповещения
        let alertBackground = SKSpriteNode(color: .black, size: CGSize(width: 400, height: 200))
        alertBackground.position = CGPoint(x: size.width / 2, y: size.height / 2)
        alertBackground.alpha = 0.5  // Прозрачность фона
        alertBackground.zPosition = 1000  // Слой поверх других элементов
        addChild(alertBackground)
        
        // Создаем текст с результатами игры
        let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.fontSize = 30
        scoreLabel.text = "Your score: \(score)"
        scoreLabel.position = CGPoint(x: 0, y: 40)
        scoreLabel.zPosition = 1001
        alertBackground.addChild(scoreLabel)
        
        // Создаем текст с предложением начать игру заново
        let messageLabel = SKLabelNode(fontNamed: "Chalkduster")
        messageLabel.fontSize = 25
        messageLabel.text = "Press OK to start again"
        messageLabel.position = CGPoint(x: 0, y: -20)
        messageLabel.zPosition = 1001
        alertBackground.addChild(messageLabel)
        
        // Создаем кнопку для начала новой игры
        let button = SKSpriteNode(color: .green, size: CGSize(width: 200, height: 50))
        button.position = CGPoint(x: 0, y: -70)
        button.zPosition = 1001
        button.name = "startNewGameButton"  // Добавляем имя кнопке для упрощенного обнаружения
        alertBackground.addChild(button)
        
        // Добавляем текст на кнопку
        let buttonText = SKLabelNode(fontNamed: "Chalkduster")
        buttonText.fontSize = 20
        buttonText.text = "Start New Game"
        buttonText.position = CGPoint(x: 0, y: 0)
        buttonText.zPosition = 1002
        button.addChild(buttonText)
    }
    
    func restartGame() {
        // Сбрасываем все значения
        score = 0
        isGameOver = false
        gamePaused = false  // Разрешаем продолжение игры
        targetSpeed = 4.0
        targetDelay = 0.8
        targetsCreated = 0
        timeRemaining = 60
        bulletsInClip = 3
        
        // Удаляем все дочерние узлы (игровые элементы)
        removeAllChildren()
        
        // Перезапускаем игру
        createBackground()
        createOverlay()
        levelUp()
        
        // Запускаем таймер
        timer()
    }
    
    func createTargetsInfo() {
        let infoNode = SKNode()
        infoNode.name = "targetsInfo" // Для удобства управления
        
        // Определяем позиции и размеры для целей
        let targetData = [
            ("target0", 1, CGPoint(x: -15, y: 0)),
            ("target1", 2, CGPoint(x: -15, y: -60)),
            ("target2", 3, CGPoint(x: -15, y: -120)),
            ("target3", -5, CGPoint(x: -15, y: -180))
        ]
        
        for (imageName, scoreValue, position) in targetData {
            // Создаем узел с изображением
            let targetSprite = SKSpriteNode(imageNamed: imageName)
            targetSprite.size = CGSize(width: 40, height: 40)
            targetSprite.position = position
            targetSprite.anchorPoint = CGPoint(x: 0, y: 0.3) // Выравнивание по левому краю
            
            // Создаем метку для отображения стоимости
            let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
            scoreLabel.fontSize = 20
            scoreLabel.fontColor = .white
            scoreLabel.text = "\(scoreValue)"
            scoreLabel.horizontalAlignmentMode = .left
            scoreLabel.position = CGPoint(x: position.x + 50, y: position.y)
            
            // Добавляем элементы в общий узел
            infoNode.addChild(targetSprite)
            infoNode.addChild(scoreLabel)
        }
        
        // Устанавливаем позицию и добавляем общий узел в сцену
        infoNode.position = CGPoint(x: size.width - 120, y: size.height - 100)
        infoNode.zPosition = 600 // Отображение поверх игрового фона
        addChild(infoNode)
    }
}
