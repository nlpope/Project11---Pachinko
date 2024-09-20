//
//  GameScene.swift
//  Project11 - Pachinko
//
//  Created by Noah Pope on 9/18/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    override func didMove(to view: SKView) {
        let background                  = SKSpriteNode(imageNamed: "background.jpg")
        background.position             = CGPoint(x: 512, y: 384)
        background.blendMode            = .replace
        background.zPosition            = -1
        addChild(background)
        physicsBody                     = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate    = self
            
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "ball" {
            collisionBetween(ball: contact.bodyA.node!, object: contact.bodyB.node!)
        } else if contact.bodyB.node?.name == "ball" {
            collisionBetween(ball: contact.bodyB.node!, object: contact.bodyA.node!)
        }
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
            let ball                                = SKSpriteNode(imageNamed: "ballRed")
            ball.name                               = "ball"
            ball.physicsBody                        = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
            ball.physicsBody!.contactTestBitMask    = ball.physicsBody!.collisionBitMask
            ball.physicsBody?.restitution           = 0.6
            ball.position                           = location
            addChild(ball)
        }
    }
    
    
    func collisionBetween(ball: SKNode, object: SKNode) {
        if object.name == "good" { destroy(ball: ball) }
        else if object.name == "bad" { destroy(ball: ball) }
    }
    
    
    func destroy(ball: SKNode) {
        ball.removeFromParent()
    }
}
