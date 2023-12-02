//
//  Goal.swift
//  Launch
//
//  Created by 李毓琪 on 2023/12/2.
//

import SpriteKit

let defaultColor = UIColor(red: 0.4, green: 0.4, blue: 0.9, alpha: 0.8)
let initLocation = CGPoint(x: 0, y: 300)

class Goal {
    var color: UIColor
    private var goal: SKSpriteNode?
    var categories: UInt32
    
    init (color: UIColor = defaultColor,categories: UInt32 = PhysicsCategories.goal) {
        self.color = color
        self.categories = categories
        goal = initNode()
        setPosition(reset: true)
    }
    
    func getNode() -> SKSpriteNode {
        return self.goal!
    }
    
    func addChildToSence(_ scene: SKScene) {
        guard goal != nil else { return }
        scene.addChild(goal!)
    }
    
    // remove goal from scene and add a new one in the target position
    func renew(_ scene: SKScene,at position: CGPoint? = nil) {
        remove()
        addChildToSence(scene)
        setPosition()
    }
    
    func initNode() -> SKSpriteNode {
        let goal = SKSpriteNode(color: color, size: CGSize(width: 100, height:10))
        
        goal.physicsBody = SKPhysicsBody(rectangleOf: goal.size)
        goal.physicsBody?.categoryBitMask = categories
        goal.physicsBody?.collisionBitMask = 0
        goal.physicsBody?.contactTestBitMask = PhysicsCategories.block
        goal.physicsBody?.isDynamic = false
        
        return goal
    }
    
    func setPosition(at position: CGPoint? = nil, reset: Bool = false) {
        guard goal != nil else { return }
        var targetPosition = position
        if reset  {
            targetPosition = initLocation
        }else if targetPosition == nil {
            targetPosition = RandLocation()
        }
        
        goal!.position = targetPosition!
    }
    
    func remove() {
        goal?.removeFromParent()
    }
}
