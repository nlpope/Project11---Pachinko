//
//  GameScene.swift
//  Project11 - Pachinko
//
//  Created by Noah Pope on 9/18/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var ballCountLabel: SKLabelNode!
    var ballCount = 5 {
        didSet {
            ballCountLabel.text = "Balls Remaining: \(ballCount)"
        }
    }
    
    var editLabel: SKLabelNode!
    var editingMode: Bool = false {
        didSet { editLabel.text = editingMode ? "Done" : "Edit" }
    }
    
    override func didMove(to view: SKView) {
        let background                      = SKSpriteNode(imageNamed: "background.jpg")
        background.position                 = CGPoint(x: 512, y: 384)
        background.blendMode                = .replace
        background.zPosition                = -1
        addChild(background)
        physicsBody                         = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate        = self
            
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
        scoreLabel                              = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text                         = "Score: 0"
        scoreLabel.horizontalAlignmentMode      = .right
        scoreLabel.position                     = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        ballCountLabel                          = SKLabelNode(fontNamed: "Chalkduster")
        ballCountLabel.text                     = "Balls Remaining: 5"
        ballCountLabel.horizontalAlignmentMode  = .right
        ballCountLabel.position                 = CGPoint(x: 980, y: 650)
        addChild(ballCountLabel)
        
        editLabel                               = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text                          = "Edit"
        editLabel.position                      = CGPoint(x: 80, y: 700)
        addChild(editLabel)
    }
    
    
    func makeBouncer(at position: CGPoint) {
        let bouncer                     = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position                = position
        bouncer.physicsBody             = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody?.isDynamic  = false
        addChild(bouncer)
    }
    
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        slotBase                        = isGood ? SKSpriteNode(imageNamed: "slotBaseGood") : SKSpriteNode(imageNamed: "slotBaseBad")
        slotGlow                        = isGood ? SKSpriteNode(imageNamed: "slotGlowGood") : SKSpriteNode(imageNamed: "slotGlowBad")
        slotBase.name                   = isGood ? "good" : "bad"
        
        slotBase.position               = position
        slotGlow.position               = position
        
        slotBase.physicsBody            = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin                        = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever                 = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location                            = touch.location(in: self)
            let objects                             = nodes(at: location)
            if objects.contains(editLabel) { editingMode.toggle() }
            else { editingMode ? addBox(at: location) : addBall(at: location) }
        }
    }
    
    
    func addBox(at location: CGPoint) {
        let size                    = CGSize(width: Int.random(in: 16...128), height: 16)
        let box                     = SKSpriteNode(color: UIColor(red: randomFloat(low: 0, high: 1), green: randomFloat(low: 0, high: 1), blue: randomFloat(low: 0, high: 1), alpha: 1), size: size)
        box.zRotation               = randomFloat(low: 0, high: 3)
        box.position                = location
        box.physicsBody             = SKPhysicsBody(rectangleOf: box.size)
        box.physicsBody?.isDynamic  = false
        box.name                    = "pin"
        
        addChild(box)
    }
    
    
    func addBall(at location: CGPoint) {
        guard location.y >= 384 else { return }
        guard ballCount != 0 else {
            print("no more balls")
            return
        }
        
        let balls                               = ["ballRed","ballPurple", "ballBlue", "ballCyan", "ballGreen", "ballGrey", "ballYellow"]
        let ball                                = SKSpriteNode(imageNamed: balls.randomElement() ?? "ballRed")
        ball.name                               = "ball"
        ball.physicsBody                        = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
        ball.physicsBody!.contactTestBitMask    = ball.physicsBody!.collisionBitMask
        ball.physicsBody?.restitution           = 0.6
        ball.position                           = location
        addChild(ball)
        ballCount -= 1
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if contact.bodyA.node?.name == "ball" {
            collisionBetween(ball: nodeA, object: nodeB)
        } else if contact.bodyB.node?.name == "ball" {
            collisionBetween(ball: nodeB, object: nodeA)
        }
    }
    
    
    func collisionBetween(ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball: ball)
            score += 1
            ballCount += 1
        } else if object.name == "bad" {
            destroy(ball: ball)
            score -= 1
        } else if object.name == "pin" {
            object.removeFromParent()
        }
    }
    
    
    func destroy(ball: SKNode) {
//        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
//            fireParticles.position = ball.position
//            addChild(fireParticles)
//        } 
        if let magicParticles = SKEmitterNode(fileNamed: "MagicParticles") {
            magicParticles.position = ball.position
            addChild(magicParticles)
        }
        
        ball.removeFromParent()
    }
}
