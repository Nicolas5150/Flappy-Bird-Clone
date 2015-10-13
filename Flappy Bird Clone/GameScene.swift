//
//  GameScene.swift
//  Flappy Bird Clone
//
//  Created by Nicolas Emery on 8/13/15.
//  Copyright (c) 2015 Nicolas Emery. All rights reserved.
//

import SpriteKit

// add SKPhysicsContactDelegate to allow contact awareness
class GameScene: SKScene, SKPhysicsContactDelegate {
    // stop game if player lost
    var gameOver = false;
    var gameOverLabel = SKLabelNode();
    
    // score and its label
    var score = 0;
    var scoreLabel = SKLabelNode();
    
    // create node for bird
    var bird = SKSpriteNode()
    // crate node for background
    var background = SKSpriteNode()
    // create nodes for pipes 
    var pipe1 = SKSpriteNode()
    var pipe2 = SKSpriteNode()
    
    // create groups for the object (making the restart of the game)
    var movingObjects = SKSpriteNode()
    var textObject = SKSpriteNode()
    
    // define enum for the object catagories
    enum ColliderType:UInt32
    {
        // use powers of two 1,2,4
        // we do this to avoid the adding of objects togther 
        // ex 3 = 1+2 so 1 and 2 are added
        case Bird = 1;
        case Object = 2;
        case scoreGap = 4;
    }
    
    // create the background within a function (to later be called on a game restart)
    func createBackground()
    {
        // BACKGROUND
        // assign background image to view one
        // texture is what the image is called
        let backgroundTexture = SKTexture(imageNamed: "bg.png")
        
        // animate the background to simulate movement (moving it -10 moves it to the left 10 deg
        let BackgroundAnimation = SKAction.moveByX(-backgroundTexture.size().width, y: 0, duration: 9)
        let cycleBackground = SKAction.moveByX(backgroundTexture.size().width, y: 0, duration: 0)
        // cycle the background
        let makeBackgroundAnimate = SKAction.repeatActionForever(SKAction.sequence([BackgroundAnimation, cycleBackground]))
        
        
        // loop to create three backgrounds to cycle trhough to remove the grey gap
        for var i:CGFloat = 0; i < 3; i++
        {
            // recreate the background image
            background = SKSpriteNode(texture: backgroundTexture)
            //define postion and size slightly diferent each time to fill in the gap of gray each cycle
            background.position = CGPoint(x: backgroundTexture.size().width/2 + backgroundTexture.size().width * i, y: CGRectGetMidY(self.frame))
            //gets the size / height of screen
            background.size.height = self.frame.height
            // set the postion to behind bird
            background.zPosition = -5;
            // add the action to the background
            background.runAction(makeBackgroundAnimate)
            // add to the UI screen / scene
            movingObjects.addChild(background)
        }//end i CGFloat for
        // once the scene is set up pause for user to start
        scene!.view!.paused = true
    }// end of createBackground func
    
    override func didMoveToView(view: SKView)
    {
        // this allows for contact and makes it aware 
        self.physicsWorld.contactDelegate = self;
        
        self.addChild(movingObjects);
        self.addChild(textObject);
        
        /* Setup your scene here */
        
        // call function to create first go around of the background
        createBackground()
        
        // SCORE LABEL
        // create the ui look for the text (via code)
        scoreLabel.fontName = "Times New Roman";
        scoreLabel.fontSize = 60;
        scoreLabel.text = "0";
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 70)
        self.addChild(scoreLabel);
        
        // BIRD
        // assign bird image to view one
        // texture is what the image is called
        let birdTexture = SKTexture(imageNamed: "flappy1.png");
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png");
        
        // animate the bird between the two images
        let birdAnimation = SKAction.animateWithTextures([birdTexture, birdTexture2], timePerFrame: 0.1);
        // make the animation continue over and over
        let makeBirdAnimate = SKAction.repeatActionForever(birdAnimation);
        
        // recreate the bird
        bird = SKSpriteNode(texture: birdTexture);
        
        // create the physics of the bird
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height/2)
        // adding gravity to the bird
        bird.physicsBody!.dynamic = true;
        bird.physicsBody!.allowsRotation = false
        
        // contact awarness
        // allow the collider type category
        bird.physicsBody!.categoryBitMask = ColliderType.Bird.rawValue
        // test for contact
        bird.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        // allows if an object can pass through another (stops a player from going thrugh a wall or ground)
        // use .Object (same as for the ground and ceiling) to stop the bird from going through bounds
        bird.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        //where to put the bird (center of screen)
        bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame));
        // add the action to the bird
        bird.runAction(makeBirdAnimate);
        // add to the UI screen / scene
        self.addChild(bird);
        
        
        // GROUND AND CEILING
        // creating the ground (bird will not fall off of and later on how the game ends)
        let groundLevel = SKNode();
        // set the height (from the ground)
        groundLevel.position = CGPointMake(0, 0);
        // set size /length of ground
        groundLevel.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, 1));
        // remove the idea of gravity from the ground level
        groundLevel.physicsBody!.dynamic = false;
        
        // contact awarness
        // allow the collider type category
        groundLevel.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        // test for contact (this is the most important on in this game!)
        groundLevel.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        // allows if an object can pass through another (stops a player from going thrugh a wall or ground)
        groundLevel.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        // add to the UI screen / scene
        self.addChild(groundLevel);
        
        
        // creating the ground (bird will not fall off of and later on how the game ends)
        let ceilingLevel = SKNode();
        // set the height (from the ground "technically" by screen height)
        ceilingLevel.position = CGPointMake(0, self.frame.size.height);
        // set size / length of ceiling
        ceilingLevel.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, 1));
        // remove the idea of gravity from the ground level
        ceilingLevel.physicsBody!.dynamic = false;
        
        // contact awarness
        // allow the collider type category
        ceilingLevel.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        // test for contact (this is the most important on in this game!)
        ceilingLevel.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        // allows if an object can pass through another (stops a player from going thrugh a wall or ground)
        ceilingLevel.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        // add to the UI screen / scene
        self.addChild(ceilingLevel);
        
        // timer to create new pipes after 3 seconds
        _ = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("makePipesOccur"), userInfo: nil, repeats: true)
    }
    
    // func for creating pipes every 3 seconds
    func makePipesOccur()
    {
        // PIPES
        // creating the gap height and ranomizing the value
        let gapHeight = bird.size.height * 4;
        // random height generator (but not off the screen)
        let randomHeight = arc4random() % UInt32(self.frame.size.height / 2 )
        // limit the height of each pipe
        let pipeOffset = CGFloat(randomHeight) - self.frame.height / 4
        
        // moving, removing, and respawning
        let movePipes = SKAction.moveByX(-self.frame.size.width * 2, y: 0, duration: NSTimeInterval(self.frame.size.width / 100));
        let removingPipes = SKAction.removeFromParent();
        let moveAndRemovePipes = SKAction.sequence([movePipes, removingPipes]);
        
        // assign texture to pipe one
        var pipeTexture = SKTexture(imageNamed: "pipe1.png");
        var pipe1 = SKSpriteNode(texture: pipeTexture);
        // assign location of pipe 1 ( move it up half the height of the pipe1 image)
        pipe1.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + pipeTexture.size().height / 2 + gapHeight / 2 + pipeOffset)
        // set the postion to in front of the background but in front of bird
        pipe1.zPosition = -4;
        // add the action of moving and removing pipe from screen
        pipe1.runAction(moveAndRemovePipes);
        
        // contact awarness
        // allow the collider type category
        pipe1.physicsBody = SKPhysicsBody(rectangleOfSize: pipeTexture.size());
        // allow the collider type category
        pipe1.physicsBody!.categoryBitMask = ColliderType.Object.rawValue;
        // test for contact (this is the most important on in this game!)
        pipe1.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue;
        // allows if an object can pass through another (stops a player from going thrugh a wall or ground)
        pipe1.physicsBody!.collisionBitMask = ColliderType.Object.rawValue;
        // remove the idea of gravity from the ground level
        pipe1.physicsBody!.dynamic = false;
        
        // add to the UI screen / scene
        movingObjects.addChild(pipe1);
        
        // assign texture to pipe two
        var pipe2Texture = SKTexture(imageNamed: "pipe2.png");
        var pipe2 = SKSpriteNode(texture: pipe2Texture);
        // assign location of pipe 1
        pipe2.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) - pipe2Texture.size().height / 2 - gapHeight / 2 + pipeOffset)
        // set the postion to in front of the background but in front of bird
        pipe2.zPosition = -4;
        // add the action of moving and removing pipe from screen
        pipe2.runAction(moveAndRemovePipes);
        
        // contact awarness
        // allow the collider type category
        pipe2.physicsBody = SKPhysicsBody(rectangleOfSize: pipeTexture.size());
        // allow the collider type category
        pipe2.physicsBody!.categoryBitMask = ColliderType.Object.rawValue;
        // test for contact (this is the most important on in this game!)
        pipe2.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue;
        // allows if an object can pass through another (stops a player from going thrugh a wall or ground)
        pipe2.physicsBody!.collisionBitMask = ColliderType.Object.rawValue;
        // remove the idea of gravity from the ground level
        pipe2.physicsBody!.dynamic = false;
        
        // add to the UI screen / scene
        movingObjects.addChild(pipe2);
        
        // SCORE VALUE & GAP
        var scoreGap = SKNode();
        // get the center of the gap between the two pipes
        scoreGap.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + pipeOffset)
        // move gap and remove old one 
        scoreGap.runAction(moveAndRemovePipes);
        // contact awarness
        // allow the collider type category
        // make the rectangle half the size of the width to make sure the bird actually makes it through
        scoreGap.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pipe1.size.width / 2, gapHeight))
        // allow the collider type category
        scoreGap.physicsBody!.categoryBitMask = ColliderType.scoreGap.rawValue;
        // test for contact (this is the most important on in this game!)
        scoreGap.physicsBody!.contactTestBitMask = ColliderType.Bird.rawValue;
        // allows if an object can pass through another (stops a player from going thrugh a wall or ground)
        scoreGap.physicsBody!.collisionBitMask = ColliderType.scoreGap.rawValue;
        // remove the idea of gravity from the ground level
        scoreGap.physicsBody!.dynamic = false
        
        // add to the UI screen / scene
        movingObjects.addChild(scoreGap);
    }
    
    func didBeginContact(contact: SKPhysicsContact)
    {
        print("CONTACT");
        
        // check to see if the bird went through the gap object
        if contact.bodyA.categoryBitMask == ColliderType.scoreGap.rawValue || contact.bodyB.categoryBitMask == ColliderType.scoreGap.rawValue
        {
            score++;
            scoreLabel.text = String(score);
        }//end of contact if
        else
        {
            // need the if statment becuase the bird bounces firing off the didBeginContact func several times causing label to be created 3 times, which is errors game
            if (gameOver == false)
            {
            
                // when game is over stop movement of all items and not allow interactions
                gameOver = true;
                // sets the speed to all objects to 0 (esentially stopping all objects on the UI
                self.speed = 0;
            
                // GAMEOVER LABEL
                // create the ui look for the text (via code)
                gameOverLabel.fontName = "Times New Roman";
                gameOverLabel.fontSize = 30;
                gameOverLabel.text = "Game over, double tap to retry";
                gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
            textObject.addChild(gameOverLabel);
            }//end of contact else
        }//end of gameOver false if
    }//end of didBeginContact func
    
    /* Called when a touch begins */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        // if the game is still active (no contact made to objects)
        if (gameOver == false)
        {
            // apply an impulse to the bird (measureing the force upwards)
            // ignore the velocity of the bird falling down due to gravity
            bird.physicsBody!.velocity = CGVectorMake(0, 0);
            bird.physicsBody!.applyImpulse(CGVectorMake(0, 55))
            scene!.view!.paused = false
        }//end of gameOver if
        // game is over (contact was made to an object)
        else
        {
            gameOver = false;
            self.speed = 1;
            
            score = 0;
            scoreLabel.text = "0";
            
            bird.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
            bird.physicsBody!.velocity = CGVectorMake(0, 0)
            
            // this will remove all the items that need to be reset (they will just be recreated on new game)
            movingObjects.removeAllChildren()
            textObject.removeAllChildren()
            // call the func to recreate the background(s)
            createBackground()
            // make users screen pause until a tap is done 2 times
            scene!.view!.paused = true
        }//end of else
     
    }//end of touchesBegan func
   
    override func update(currentTime: CFTimeInterval)
    {
        /* Called before each frame is rendered */
    }
}
