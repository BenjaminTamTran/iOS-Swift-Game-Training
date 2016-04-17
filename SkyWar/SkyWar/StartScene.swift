//
//  StartScene.swift
//  SkyWar
//
//  Created by Developer on 4/16/16.
//  Copyright © 2016 The Simple Studio. All rights reserved.
//

import SpriteKit

class StartScene: SKScene {
    var nodeFrame: SKSpriteNode!
    var nodeFrame2: SKSpriteNode!
    var backgroundPlay: SKSpriteNode!
    
    
    override func didMoveToView(view: SKView) {
        let nodeBackground = SKSpriteNode(imageNamed: "backgroundSky2.jpg")
        nodeBackground.size = self.size
        nodeBackground.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        nodeBackground.zPosition = -1
        self.addChild(nodeBackground)
        
        let textureFrame = SKTexture(imageNamed: "frame.jpg")
        
        nodeFrame = SKSpriteNode(texture: textureFrame)
        nodeFrame.size = CGSize(width: 200, height: 200)
        nodeFrame.position = CGPoint(x: CGRectGetMidX(self.frame)/2, y: CGRectGetMidY(self.frame) * 3/2)
        nodeFrame.zPosition = 2
        self.addChild(nodeFrame)
        
        nodeFrame2 = SKSpriteNode(texture: textureFrame)
        nodeFrame2.size = CGSize(width: 200, height: 200)
        nodeFrame2.position = CGPoint(x: CGRectGetMidX(self.frame) * 3/2, y: CGRectGetMidY(self.frame) * 3/2)
        nodeFrame2.zPosition = 2
        self.addChild(nodeFrame2)
        
        let nodePlan = SKSpriteNode(imageNamed: "plan01.png")
        nodePlan.size = CGSize(width: 100, height: 100)
        nodePlan.position = CGPoint(x: 0, y: 0 )
        nodePlan.zPosition = 3
        nodePlan.name = "plan"
        nodeFrame.addChild(nodePlan)
        
        let nodePlan2 = SKSpriteNode(imageNamed: "plan1_01.png")
        nodePlan2.size = CGSize(width: 100, height: 100)
        nodePlan2.position = CGPoint(x: 0 , y: 0 )
        nodePlan2.zPosition = 3
        nodePlan.name = "plan"
        nodeFrame2.addChild(nodePlan2)
        
       nodePlan.runAction(rotatePlan())
        
        backgroundPlay = SKSpriteNode(color: UIColor.darkGrayColor(), size: CGSize(width: 250, height: 100))
        backgroundPlay.position = CGPoint(x: CGRectGetMidX(self.frame), y: self.size.height * 1/4)
        
        
        let labelPlay = SKLabelNode(text: "PLAY")
        labelPlay.fontSize = 60
        labelPlay.fontName = "MarkerFelt-Wide"
        labelPlay.fontColor = UIColor.blackColor()
        labelPlay.position = CGPoint(x: 0, y:  -labelPlay.frame.size.height/2)
        backgroundPlay.addChild(labelPlay)
        
        if let path = NSBundle.mainBundle().pathForResource("FirePlay", ofType: "sks"),
            let firePlay = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? SKEmitterNode
        {
            firePlay.position = CGPoint(x: backgroundPlay.position.x, y: backgroundPlay.position.y - backgroundPlay.size.height/2)
            firePlay.particleSize = backgroundPlay.size
            self.addChild(firePlay)
        }
        
        addChild(backgroundPlay)
        
    }
    
    func rotatePlan() -> SKAction {
        let actionRotate = SKAction.rotateByAngle(2*3.14, duration: 3)
        let actionRotateForever = SKAction.repeatActionForever(actionRotate)
        return actionRotateForever
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            if nodeFrame.containsPoint(location) {
                if let nodeStop = nodeFrame2.children.first, let nodeStart = nodeFrame.children.first {
                    nodeStop.removeAllActions()
                    nodeStart.runAction(rotatePlan())
                }
                
            } else if nodeFrame2.containsPoint(location) {
                if let nodeStop = nodeFrame.children.first, let nodeStart = nodeFrame2.children.first {
                    nodeStop.removeAllActions()
                    nodeStart.runAction(rotatePlan())
                }
            } else if backgroundPlay.containsPoint(location) {
                let scene = GameScene(size: CGSize(width: 768, height: 1024))
                let skView = self.view
                skView?.ignoresSiblingOrder = true
                skView?.presentScene(scene, transition: SKTransition.doorsOpenVerticalWithDuration(2))
            }
        }
    }
}
