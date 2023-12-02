//
//  GameScene.swift
//  Launch
//
//  Created by 李毓琪 on 2023/10/26.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var scoreLabel: SKLabelNode!
    var resetButton: SKLabelNode!
    var block: SKShapeNode?
    let slingShotCenter = CGPoint(x: 0, y: -300)
    let maxSlingDistance: CGFloat = 150.0
    let slingshotRadius: CGFloat = 3
    var score: Int = 0
    var goalledNum: Int = 0
    var isDraggingBlock = false
    var goal: Goal = Goal()
    var superGoal: Goal = Goal(color: UIColor.yellow,categories: PhysicsCategories.superGoal)

    var isGoalled: Bool = false
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        goal.addChildToSence(self)
        
        scoreLabel = SKLabelNode(fontNamed: "Arial")
        scoreLabel.position = CGPoint(x: 0, y: 350)
        scoreLabel.fontSize = 100
        scoreLabel.text = "Drag!"
        addChild(scoreLabel)
        
        resetButton = SKLabelNode(fontNamed: "Arial")
        resetButton.text = "RESET"
        resetButton.fontSize = 24
        resetButton.horizontalAlignmentMode = .right
        resetButton.verticalAlignmentMode = .bottom
        resetButton.name = "resetButton"
        resetButton.position = CGPoint(x: self.size.width/2 + resetButton.frame.minX, y: self.size.height/2 + resetButton.frame.minX)
        addChild(resetButton)

        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        
        let slingshot = SKShapeNode(circleOfRadius: slingshotRadius)
        slingshot.position = slingShotCenter
        slingshot.fillColor = .gray
        addChild(slingshot)

        createBlock(at: slingShotCenter)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = self.atPoint(location)
        
        switch touchedNode.name {
        case resetButton.name:
            showConfirmationDialog()
        case "confirmButton":
            resetScore()
            hideConfirmationDialog()
        case "cancelButton":
            hideConfirmationDialog()
        case block?.name:
            if block!.frame.contains(location) {
                isDraggingBlock = true
                block!.physicsBody!.isDynamic = false
            }
        default:
            createBlock(at: slingShotCenter)
            if isGoalled {
                renewAllGoal()
                isGoalled = false
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, isDraggingBlock else { return }
        var location = touch.location(in: self)
        let offset = CGPoint(x: location.x - slingShotCenter.x, y: location.y - slingShotCenter.y)
        let distance = sqrt(offset.x * offset.x + offset.y * offset.y)
        if location.y > slingShotCenter.y {
            location.x = slingShotCenter.x + (offset.x / distance) * maxSlingDistance
            location.y = slingShotCenter.y
        } else if distance > maxSlingDistance {
            location.y = slingShotCenter.y + (offset.y / distance) * maxSlingDistance
            location.x = slingShotCenter.x + (offset.x / distance) * maxSlingDistance
        }
        
        block!.position = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isDraggingBlock {
            let dx = slingShotCenter.x - block!.position.x
            let dy = slingShotCenter.y - block!.position.y
            let launchVelocity = CGVector(dx: dx * 1, dy: dy * 1)
            block!.physicsBody!.isDynamic = true
            block!.physicsBody!.applyImpulse(launchVelocity)
            isDraggingBlock = false
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if let block = block, !frame.intersects(block.frame) {
            block.removeFromParent()
            self.block = nil
             
            let ssc = slingShotCenter
            self.createBlock(at: ssc)
            superGoal.remove()
            if isGoalled {
                renewAllGoal()
                if (goalledNum % 7) == 0 {
                    superGoal.addChildToSence(self)
                }
                isGoalled = false
            }
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let mask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if mask != PhysicsCategories.block {
            let goalType = mask ^ PhysicsCategories.block
            
            switch goalType {
            case PhysicsCategories.goal:
                goalledNum += 1
                score += GoalScore.goal
                goal.remove()
                isGoalled = true
            case PhysicsCategories.superGoal:
                score += GoalScore.superGoal
                superGoal.remove()
            default:
                print("do nothing")
            }
            
            scoreLabel.text = "\(score)"
        }
    }

    
    func createBlock(at position: CGPoint) {
        block?.removeFromParent()
        
        block = SKShapeNode(circleOfRadius: 20)
        block!.position = position
        block!.fillColor = .red
        block!.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        block!.physicsBody?.categoryBitMask = PhysicsCategories.block
        block!.physicsBody?.contactTestBitMask = PhysicsCategories.goal
        block!.physicsBody?.collisionBitMask = 0
        block!.physicsBody!.isDynamic = false
        self.addChild(block!)
    }

    // remove score and reset goal
    func resetScore() {
        score = 0
        scoreLabel.text = "Drag!"
        goal.setPosition(reset: true)
        superGoal.remove()
    }
    
    func showConfirmationDialog() {
        let mask = SKShapeNode(rect: self.frame)
        mask.fillColor = UIColor.black.withAlphaComponent(0.5)
        mask.zPosition = 100
        mask.name = "mask"
        addChild(mask)

        let confirmButton = SKLabelNode(fontNamed: "Arial")
        confirmButton.text = "Confirm"
        confirmButton.fontSize = 24
        confirmButton.position = CGPoint(x: 100 + confirmButton.frame.minX, y: 0)
        confirmButton.name = "confirmButton"
        confirmButton.fontColor = UIColor.red
        mask.addChild(confirmButton)

        let cancelButton = SKLabelNode(fontNamed: "Arial")
        cancelButton.text = "Cancel"
        cancelButton.fontSize = 24
        cancelButton.position = CGPoint(x: -100 - cancelButton.frame.minX, y: 0)
        cancelButton.name = "cancelButton"
        cancelButton.fontColor = UIColor.gray
        mask.addChild(cancelButton)

        let message = SKLabelNode(fontNamed: "Arial")
        message.text = "Are you sure to reset score?"
        message.fontSize = 30
        message.position = CGPoint(x: 0, y: 90)
        mask.addChild(message)
    }

    func hideConfirmationDialog() {
        childNode(withName: "mask")?.removeFromParent()
    }
    
    // renew goal and remove super goal
    func renewAllGoal() {
        goal.renew(self)
        superGoal.remove()
    }
}


struct PhysicsCategories {
    static let block: UInt32 = 0x1 << 1
    static let goal: UInt32 = 0x1 << 2
    static let superGoal: UInt32 = 0x1 << 3
    
    static let allGoal: UInt32 = goal | superGoal
}

struct GoalScore {
    static let goal: Int = 1
    static let superGoal: Int = 3
}
