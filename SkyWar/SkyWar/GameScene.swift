//
//  GameScene.swift
//  SkyWar
//
//  Created by Developer on 4/14/16.
//  Copyright (c) 2016 The Simple Studio. All rights reserved.
//

import SpriteKit
import UIKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    //MARK: SKNode
    var nodePlan: SKSpriteNode?
    var nodePause: SKSpriteNode?
    var nodeSound: SKSpriteNode?
    var nodeRestart: SKSpriteNode?
    var nodeBack: SKSpriteNode?
    var background: SKSpriteNode = SKSpriteNode()
    
    //MARK: Time
    var timeCreateShoot: NSTimer?
    
    var timeCreateStone: NSTimer?
    var timeCreateGift: NSTimer?
    
    var timeGame: NSTimer?
    //MARK: property
    var secondGame: Double = 0
    var isMovePlan = false
    var isSound = true
    var labelPoint: SKLabelNode?
    var point = 0
    var canRestart = false
    var gift = 1
    var timeStone: Double = 0.5
    
    //MARK: Physics contact
    let planContact: UInt32 = 1 << 1
    let stoneContact: UInt32 = 1 << 2
    let bulletContact: UInt32 = 1 << 3 // 0 1000
    let giftContact: UInt32 = 23       // 1 0000  => 1 0111 -> 31 - 8 = 23

    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.view?.showsPhysics = false
        self.physicsWorld.gravity = CGVector(dx: 0.0,dy: -9.8)
        self.physicsWorld.contactDelegate = self
        //create basic object
        self.createBasic()
        self.createObject()
        SKAction.playSoundFileNamed("brust.wav", waitForCompletion: false)
        timeGame = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(countTime), userInfo: nil, repeats: true)
    }
    
    func countTime() {
        if canRestart == false && paused == false {
            secondGame += 1
            if secondGame % 8 == 0 {
                timeStone /= 1.5
                timeCreateStone = NSTimer.scheduledTimerWithTimeInterval(timeStone, target: self, selector: #selector(GameScene.createStone), userInfo: nil, repeats: true)
            }
        }
    }
    
    func moveBackground(timer: NSTimer) {
        if let background = timer.userInfo as? SKSpriteNode {
            background.position.y -= 6
            if  background.position.y < 200 && background.name == "c1" {
//                background.position.y = -background.frame.minY
                background.name = "c2"
                //createnew background
                let nodeNewBackground = SKSpriteNode(imageNamed: "backgroundSky3.jpg")
                nodeNewBackground.size.width = self.size.width
                nodeNewBackground.position = CGPointMake(CGRectGetMidX(self.frame), background.size.height  )
                nodeNewBackground.zPosition = -1
                nodeNewBackground.name = "c1"
                self.addChild(nodeNewBackground)
                NSTimer.scheduledTimerWithTimeInterval(0.01
                    , target: self, selector: #selector(self.moveBackground), userInfo: nodeNewBackground, repeats: true)
            } else if background.position.y < -self.size.height {
                timer.invalidate()
            }
        }
    }
    
    func createBasic() {
        //create background 
        background = SKSpriteNode(imageNamed: "backgroundSky3.jpg")
        background.size.width = self.size.width
        background.position = CGPointMake(CGRectGetMidX(self.frame), background.size.height - self.size.height)
        background.zPosition = -1
        background.name = "c1"
        addChild(background)
        
        NSTimer.scheduledTimerWithTimeInterval(0.01
            , target: self, selector: #selector(self.moveBackground), userInfo: background, repeats: true)
        
        //create Label
        labelPoint = createLabel("0", position: CGPointMake(CGRectGetMidX(self.frame), self.frame.maxY*0.75))
        self.addChild(labelPoint!)
        
        //create pause button
        nodePause = SKSpriteNode(imageNamed: "pause.png")
        nodePause?.size = CGSize(width: 80, height: 80)
        nodePause?.position = CGPointMake(self.size.width-80, self.size.height-80)
        nodePause?.name = "pause"
        addChild(nodePause!)
        
        //create sound button
        nodeSound = SKSpriteNode(imageNamed: "sound.png")
        nodeSound?.size = CGSize(width: 80, height: 80)
        nodeSound?.position = CGPointMake(self.size.width-180, self.size.height-80)
        nodeSound?.name = "sound"
        addChild(nodeSound!)
        
        //create restart button
        nodeRestart = SKSpriteNode(imageNamed: "restart.png")
        nodeRestart?.size = CGSize(width: 150, height: 150)
        nodeRestart?.position = CGPointMake(self.size.width/2, self.size.height/2)
        nodeRestart?.name = "restart"
        
        nodeBack = SKSpriteNode(imageNamed: "back.png")
        nodeBack?.size = CGSize(width: 150, height: 150)
        nodeBack?.position = CGPointMake(self.size.width/2, self.size.height/2 - 200)
        nodeBack?.name = "back"
    }
    
    func createObject() {
        //create plan Node
        createPlan()
        
        //create bullet
        timeCreateShoot = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(GameScene.createBullet), userInfo: nil, repeats: true)
        
        //create stone
        //timeCreateStone = NSTimer.scheduledTimerWithTimeInterval(timeStone, target: self, selector: #selector(GameScene.createStone), userInfo: nil, repeats: true)
        
        //create gift
        timeCreateGift = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(self.createGift), userInfo: nil, repeats: true)
    }
    
    func createGift() {
        let tGift = SKTexture(imageNamed: "gift.png")
        let gift = SKSpriteNode(texture: tGift)
        gift.size = CGSize(width: 80, height: 80)
        let randX = arc4random_uniform(UInt32(self.size.width))
        gift.position = CGPoint(x: CGFloat(randX), y: self.size.height)
        gift.zPosition = 3
        gift.name = "gift"
        
        //physic setup
        gift.physicsBody = SKPhysicsBody(texture: tGift, size: gift.size)
        gift.physicsBody?.dynamic = true
        gift.physicsBody?.categoryBitMask = giftContact
        gift.physicsBody?.contactTestBitMask = planContact
        gift.physicsBody?.affectedByGravity = false
        gift.physicsBody?.allowsRotation = false
        gift.physicsBody?.collisionBitMask = 0
        //action
        let actionFallStone = SKAction.moveToY(-gift.size.height, duration: 1.5)
        gift.runAction(actionFallStone, completion: {
            gift.removeFromParent()
        })
        self.addChild(gift)
    }
    
    func createLabel(text: String,position: CGPoint,fontSize: CGFloat = 40, fontName: String = "MarkerFelt-Wide") -> SKLabelNode {
        let label = SKLabelNode()
        label.fontSize = fontSize
        label.fontName = fontName
        label.position = position
        label.text = text
        label.zPosition = 15
        return label
    }
    
    func createStone() {
        if self.paused == true || self.canRestart == true {
            return
        }
        let textureStone = SKTexture(imageNamed: "stone.png")
        let nodeStone = SKSpriteNode(texture: textureStone)
        let randX = arc4random_uniform(UInt32(self.size.width))
        let randW = arc4random_uniform(200 - 80) + 80
        let randH = arc4random_uniform(200 - 80) + 80
        nodeStone.size = CGSize(width: CGFloat(randW), height: CGFloat(randH))
        nodeStone.position = CGPoint(x: CGFloat(randX), y: self.size.height)
        nodeStone.zPosition = 3
        
        //physics setup
        nodeStone.physicsBody = SKPhysicsBody(texture: textureStone, size: CGSize(width: CGFloat(randW), height: CGFloat(randH)) )
        nodeStone.physicsBody?.dynamic = true
        nodeStone.physicsBody?.affectedByGravity = false
        nodeStone.physicsBody?.categoryBitMask = stoneContact
        nodeStone.physicsBody?.contactTestBitMask = bulletContact | planContact
        nodeStone.physicsBody?.collisionBitMask = bulletContact | planContact
        nodeStone.physicsBody?.allowsRotation = false
        
        let actionFallStone = SKAction.moveToY(-nodeStone.size.height, duration: 2)
        nodeStone.runAction(actionFallStone, completion: {
            nodeStone.removeFromParent()
        })
        self.addChild(nodeStone)
    }
    
    func createPlan() {
        let texturePlan01 = SKTexture(imageNamed: "plan01.png")
        nodePlan = SKSpriteNode(texture: texturePlan01)
        nodePlan?.position = CGPoint(x: CGRectGetMidX(self.frame), y: 0+40)
        nodePlan?.size = CGSize(width: 160, height: 200)
        nodePlan?.zPosition = 2
        
        //Physics
        nodePlan?.physicsBody = SKPhysicsBody(texture: texturePlan01, size: nodePlan!.size)
        nodePlan?.physicsBody?.categoryBitMask = planContact
        nodePlan?.physicsBody?.contactTestBitMask = stoneContact | giftContact
        nodePlan?.physicsBody?.dynamic = false
        //Action
        let actionPlan = SKAction.animateWithTextures([
            SKTexture(imageNamed: "plan01.png"),
            SKTexture(imageNamed: "plan02.png"),
            SKTexture(imageNamed: "plan03.png"),
            SKTexture(imageNamed: "plan04.png")
            ], timePerFrame: 0.2)
        
        let actionFPlan = SKAction.repeatActionForever(actionPlan)
        nodePlan?.runAction(actionFPlan)
        self.addChild(nodePlan!)
        
    }
    
    func removeNode(node: SKNode) {
        node.removeFromParent()
    }
    
    func createBullet() {
        if self.paused == true {
            return
        }
        for i in 1...gift {
            createBulletBasic(i)
        }
    }
    
    func createBulletBasic(level: Int)  {
        var positionRoot = CGPoint(x: CGRectGetMidX(nodePlan!.frame), y: CGRectGetMidY(nodePlan!.frame))
        switch level {
        case 1:
            break
        case 2:
            positionRoot.x -= 30
            break
        case 3:
            positionRoot.x += 30
            break
        case 4:
            positionRoot.x -= 60
            break
        case 5:
            positionRoot.x += 60
            break
        default:
            break
        }
        let textureBullet = SKTexture(imageNamed: "bullet01.png")
        let nodeBullet = SKSpriteNode(texture: textureBullet)
        nodeBullet.position = positionRoot
        nodeBullet.size = CGSize(width: 20, height: 40)
        let actionShoot = SKAction.moveTo(CGPoint(x: nodeBullet.frame.midX, y: self.size.height + 40), duration: 1.5)
        nodeBullet.zPosition = 2
        
        //Physics
        nodeBullet.physicsBody = SKPhysicsBody(texture: textureBullet, size: nodeBullet.size)
        nodeBullet.physicsBody?.categoryBitMask = bulletContact
        nodeBullet.physicsBody?.contactTestBitMask = stoneContact
        nodeBullet.physicsBody?.collisionBitMask = stoneContact
        nodeBullet.physicsBody?.allowsRotation = false
        nodeBullet.physicsBody?.dynamic = false
        
        //Action
        nodeBullet.runAction(actionShoot, completion: {
            nodeBullet.removeFromParent()
        })
        self.addChild(nodeBullet)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask  + contact.bodyB.categoryBitMask == ( bulletContact + stoneContact ) {
            if let path = NSBundle.mainBundle().pathForResource("FireStone", ofType: "sks")
                ,let fireStone = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? SKEmitterNode {
                fireStone.position = contact.contactPoint
                // self.addChild(smoke)
                contact.bodyA.node!.physicsBody?.categoryBitMask = 0
                removeNode(contact.bodyB.node!)
                removeNode(contact.bodyA.node!)
                self.point = self.point + 1
                self.labelPoint?.text = "\(self.point)"
                addChild(fireStone)
                //
                let action = SKAction.waitForDuration(1)
                let sound = SKAction.playSoundFileNamed("brust.wav", waitForCompletion: false)
                var groupAction: SKAction
                if isSound == false {
                    groupAction = SKAction.group([action])
                } else {
                    groupAction = SKAction.group([action,sound])
                }
                
                fireStone.runAction(groupAction, completion: {
                    fireStone.removeFromParent()
                })
            }
        } else if contact.bodyA.categoryBitMask  + contact.bodyB.categoryBitMask == ( planContact + stoneContact ) {
            if contact.bodyA.categoryBitMask == stoneContact {
                contact.bodyA.categoryBitMask = 0
                removeNode(contact.bodyA.node!)
            } else {
                contact.bodyB.categoryBitMask = 0
                removeNode(contact.bodyB.node!)
            }
            gift -= 1
            if gift < 1 {
                //stop create stone and bullet
                timeCreateStone?.invalidate()
                timeCreateShoot?.invalidate()
                timeCreateGift?.invalidate()
                //stop contact
                nodePlan?.physicsBody?.categoryBitMask = 0
                if let path = NSBundle.mainBundle().pathForResource("FirePlan", ofType: "sks"),
                    let firePlan = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? SKEmitterNode {
                    firePlan.position = contact.contactPoint
                    addChild(firePlan)
                    nodeRestart?.alpha = 0
                    nodeBack?.alpha = 0
                    let actionTemo = SKAction.fadeInWithDuration(3)
                    addChild(nodeRestart!)
                    addChild(nodeBack!)
                    nodeRestart?.runAction(actionTemo, completion: {
                        self.canRestart = true
                    })
                    nodeBack?.runAction(actionTemo)
                    nodePlan?.removeFromParent()
                }
            }
        } else if contact.bodyA.categoryBitMask + contact.bodyB.categoryBitMask == (giftContact + planContact) {
            let giftNode: SKNode?
            if contact.bodyA.categoryBitMask == giftContact {
                giftNode = contact.bodyA.node
                contact.bodyA.categoryBitMask = 102
            } else {
                giftNode = contact.bodyB.node
                contact.bodyB.categoryBitMask = 102
            }
            removeNode(giftNode!)
            if gift < 5 {
                gift += 1
            }
            print(gift)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            if nodePlan?.containsPoint(location) == true {
                isMovePlan = true
            } else if nodePause!.containsPoint(location) == true {
                if self.paused == false {
                    nodePause?.texture = SKTexture(imageNamed: "start.png")
                    self.paused = true
                } else {
                    nodePause?.texture = SKTexture(imageNamed: "pause.png")
                    self.paused = false
                }
            } else if nodeSound!.containsPoint(location) == true {
                if self.isSound == false {
                    nodeSound?.texture = SKTexture(imageNamed: "sound.png")
                    self.isSound = true
                } else {
                    nodeSound?.texture = SKTexture(imageNamed: "mute.png")
                    self.isSound = false
                }
            } else if nodeRestart!.containsPoint(location) && canRestart {
                createObject()
                nodeRestart?.removeFromParent()
                nodeBack?.removeFromParent()
                self.point = 0
                self.gift = 1
                self.labelPoint?.text = "\(self.point)"
                timeStone = 0.5
                secondGame = 0
                canRestart = false
            } else if nodeBack!.containsPoint(location) == true && canRestart == true {
                let scene = StartScene(size: CGSize(width: 768, height: 1024))
                let skView = self.view
                skView?.presentScene(scene, transition: SKTransition.doorsCloseHorizontalWithDuration(2))
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            if isMovePlan {
                nodePlan?.position = location
            }
        }
    }
   
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            isMovePlan = false
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
