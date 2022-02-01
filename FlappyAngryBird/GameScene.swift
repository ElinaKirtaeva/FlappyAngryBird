//
//  GameScene.swift
//  FlappyAngryBird
//
//  Created by Элина Рупова on 22.01.2022.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    var backgroundNode = SKNode()
    var scoreNode = SKSpriteNode()
    var pipes = SKNode()
    var groundNode = SKSpriteNode()
    var skyNode = SKSpriteNode()
    var bird: SKSpriteNode!
    var gameOver: SKLabelNode!
    let categoryBitMask = UInt32(1)
    let xScreens = 3.21
    let verticalPipeGap = Double(200)
    var pipeUpT: SKTexture!
    var pipeDownT: SKTexture!
    var movePipesAndRemove: SKAction!
    var pipePair = SKNode()
    var timerLabel:SKLabelNode!
    var timer = NSInteger()
    
    override func didMove(to view: SKView) {
        
        var time = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -3)
        self.physicsWorld.contactDelegate = self
        
        self.addChild(backgroundNode)
        backgroundNode.addChild(pipes)
        
        //creating land
        addLandNode()

        //creating sky
        addSkyNode()
 
        //creating bird
        addBirdNode()
        
        pipeUpT = SKTexture(imageNamed: "PipeUp")
        pipeDownT = SKTexture(imageNamed: "PipeDown")
        
        let distanceToMove = CGFloat(self.frame.maxX * 2 + 15.0 * pipeUpT.size().width)
        let movePipes = SKAction.moveBy(x: -distanceToMove, y:0.0, duration:TimeInterval(0.01 * distanceToMove))
        let removePipes = SKAction.removeFromParent()
        movePipesAndRemove = SKAction.sequence([movePipes, removePipes])
        
        // spawn the pipes
        let spawn = SKAction.run(addPipes)
        let delay = SKAction.wait(forDuration: TimeInterval(3.0))
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        let spawnThenDelayForever = SKAction.repeatForever(spawnThenDelay)
        self.run(spawnThenDelayForever)
        
        // Initialize label and create a label which holds the score
        timer = 0
        timerLabel = SKLabelNode(fontNamed:"MarkerFelt-Wide")
        timerLabel.fontSize = CGFloat(30)
        timerLabel.fontColor = .black
        timerLabel.position = CGPoint( x: self.frame.maxX - 100, y: self.frame.maxY - 100)
        timerLabel.zPosition = 100
        timerLabel.text = String(timer) + " sec."
        self.addChild(timerLabel)
        
        scoreNode = SKSpriteNode(imageNamed: "score")
        scoreNode.zPosition = 20
        scoreNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        scoreNode.isHidden = true
        scoreNode.size = CGSize(width: 300, height: 200)
        backgroundNode.addChild(scoreNode)

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if backgroundNode.speed > 0 {
            bird.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 50))
        } else {
            restart()
        }
        
    }
    
    func stopGame() {

        backgroundNode.speed = 0
        bird.speed = 0
        scoreNode.isHidden = false
        timerLabel.position = CGPoint( x: self.frame.midX + 80, y: self.frame.midY - 29)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        stopGame()
    }

    func addLandNode() {
        let ground = SKTexture(imageNamed: "land1")
        let width = ground.size().width
        let movingLand = SKAction.move(by: CGVector(dx: -width/xScreens, dy: 0), duration: TimeInterval(0.02 * width/xScreens))
        let resetMovingLand = SKAction.move(by: CGVector(dx: width/xScreens, dy: 0), duration: 0)
        let endlessMoving = SKAction.repeatForever(SKAction.sequence([movingLand, resetMovingLand]))
                                                                    
        groundNode = SKSpriteNode(texture: ground)
        groundNode.zPosition = 3
        groundNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 2000, height: 100))
        groundNode.size = CGSize(width: 2000, height: 100)
        groundNode.physicsBody?.isDynamic = false
        groundNode.physicsBody?.affectedByGravity = false
        groundNode.physicsBody?.affectedByGravity = false
        groundNode.physicsBody?.pinned = false
        groundNode.physicsBody?.allowsRotation = false
        groundNode.physicsBody?.categoryBitMask = categoryBitMask
        groundNode.physicsBody?.contactTestBitMask = categoryBitMask
        groundNode.position = CGPoint(x: self.frame.minX, y: self.frame.minY)
        groundNode.run(endlessMoving)
        backgroundNode.addChild(groundNode)
    }
    
    func addSkyNode() {
        
        let sky = SKTexture(imageNamed: "sky1")
        let width = sky.size().width
        let movingSky = SKAction.move(by: CGVector(dx: -width/xScreens, dy: 0), duration: TimeInterval(0.02 * width/xScreens))
        let resetMovingSky = SKAction.move(by: CGVector(dx: width/xScreens, dy: 0), duration: 0)
        let endlessMoving = SKAction.repeatForever(SKAction.sequence([movingSky, resetMovingSky]))

        skyNode = SKSpriteNode(texture: sky)
        skyNode.zPosition = -10
        skyNode.size = CGSize(width: 2000, height: 928)
        skyNode.position = CGPoint(x: self.frame.minX, y: self.frame.minY + 350)
        skyNode.run(endlessMoving)
        backgroundNode.addChild(skyNode)
    }
    
    func addBirdNode() {
        let bird1 = SKTexture(imageNamed: "1")
        bird1.filteringMode = .nearest
        let bird2 = SKTexture(imageNamed: "2")
        bird2.filteringMode = .nearest
     
        let flying = SKAction.animate(with: [bird1,bird2], timePerFrame: 0.4)
        let endlessFlying = SKAction.repeatForever(flying)
        bird = SKSpriteNode(texture: bird1)
        bird.position = CGPoint(x: -self.frame.width * 0.25, y: self.frame.midY)
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height/2)
        bird.physicsBody?.categoryBitMask = categoryBitMask
        bird.physicsBody?.isDynamic = true
        bird.physicsBody?.allowsRotation = false
        bird.run(endlessFlying)
        self.addChild(bird)
    }
    
    func addPipes() {
        pipePair = SKNode()
        pipePair.position = CGPoint(x: self.frame.maxX * 1.5 + pipeUpT.size().width, y: self.frame.minY)
        pipePair.zPosition = 2
        let height = UInt32(self.frame.maxY / 4)
        let y = Double(arc4random_uniform(height) + height)
        
        let pipeDown = SKSpriteNode(texture: pipeDownT)
        pipeDown.setScale(2.0)
        pipeDown.position = CGPoint(x: 0.0, y: y + Double(pipeDown.size.height) + verticalPipeGap)

        pipeDown.physicsBody = SKPhysicsBody(rectangleOf: pipeDown.size)
        pipeDown.physicsBody?.isDynamic = false
        pipeDown.physicsBody?.categoryBitMask = categoryBitMask
        pipeDown.physicsBody?.contactTestBitMask = categoryBitMask
        pipePair.addChild(pipeDown)
        
        let pipeUp = SKSpriteNode(texture: pipeUpT)
        pipeUp.setScale(2.0)
        pipeUp.position = CGPoint(x: 0.0, y: y)
        
        pipeUp.physicsBody = SKPhysicsBody(rectangleOf: pipeUp.size)
        pipeUp.physicsBody?.isDynamic = false
        pipeUp.physicsBody?.categoryBitMask = categoryBitMask
        pipeUp.physicsBody?.contactTestBitMask = categoryBitMask
        
        pipePair.addChild(pipeUp)

        pipePair.run(movePipesAndRemove)
        pipes.addChild(pipePair)
    }
    
    @objc func updateTime() {
        
        if backgroundNode.speed > 0 {
            timer += 1
            timerLabel.text = String(timer) + " sec."
            backgroundNode.speed += 0.1
        }
        
    }
    
    func restart() {
        bird.position = CGPoint(x: -self.frame.width * 0.25, y: self.frame.midY)
        pipes.removeAllChildren()
        
        backgroundNode.speed = 1
        bird.speed = 1
        scoreNode.isHidden = true
        timerLabel.position = CGPoint( x: self.frame.maxX - 100, y: self.frame.maxY - 100)
        timer = 0
        timerLabel.text = String(timer) + " sec."
        
    }
    
}
