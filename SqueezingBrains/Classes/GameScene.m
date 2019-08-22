#import "GameScene.h"

// Number of tutorial options
#define kNUM_TUTORIAL_OPTIONS 4

#define kTutorialSucceded @"Tutorial_Succeded"

#define kCurrentLevel @"Current_Level"

@implementation GameScene{
    // Declare global variable for screen size
    CGSize _screenSize;

    // Declare left side number
    CCSprite *_leftNumber;
    
    // Declare right side number
    CCSprite *_rightNumber;
    
    // Declare operator
    CCSprite *_operator;
    
    // Declare equals symbol
    CCSprite *_equalsSymbol;
    
    // Declare result
    CCSprite *_result;
    
    // Declare state of the game
    GameState *_gameState;

    // Declare array of numbers
    NSMutableArray *_arrayOfOptions;
    
    // Declare global batch node
    CCSpriteBatchNode *_batchNode;
    
    // Label to show the tutorial texts
    CCLabelTTF *_tutorialLabel;
    
    // Declare droppable area
    CCDrawNode *_droppableArea;
    
    // Declare initial number position
    CGPoint _initialNumberPosition;
    
    // Declare check solution button
    CCButton *_buttonCheckSolution;

    // Declare next level button
    CCButton *_buttonNextLevel;

    // Declare solution variable
    NSString *_solution;
}

+ (GameScene *)scene
{
    return [[self alloc] init];
}

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    // Initialize the screen size variable for later calculations
    _screenSize = [CCDirector sharedDirector].viewSize;
    
    // Load texture atlas
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"squeezingbrains-hd.plist"];
    
    // Load batch node with texture atlas
    _batchNode = [CCSpriteBatchNode batchNodeWithFile:@"squeezingbrains-hd.png"];
    
    // Initialize the background
    CCSprite * blackboard = [CCSprite spriteWithImageNamed:@"SqueezingBrainsAtlas/blackboard.png"];
    // Set background position
    blackboard.position = CGPointMake(_screenSize.width / 2, _screenSize.height / 2);
    // Add background to the game scene
    [self addChild:blackboard z:-1];
    
    // Initialize game state
    _gameState = stateTutorial;
    
    // Enabling user interaction
    self.userInteractionEnabled = TRUE;
    
    // Create check button
    [self createCheckButton];
    
    // Create next level button
    [self createNextLevelButton];
    
    return self;
}

-(void) initializeGameTutorial {
    
    // Initialize left side number
    _leftNumber = [CCSprite spriteWithImageNamed:@"SqueezingBrainsAtlas/2.png"];
    // Set left number position
    _leftNumber.position = CGPointMake(_screenSize.width / 5 - _leftNumber.contentSize.width / 2, _screenSize.height / 2);
    // Add left number to the game scene
    [self addChild:_leftNumber];
    
    // Initialize operator
    _operator = [CCSprite spriteWithImageNamed:@"SqueezingBrainsAtlas/addition.png"];
    // Set operator position
    _operator.position = CGPointMake(2 * _screenSize.width / 5 - _operator.contentSize.width / 2, _screenSize.height / 2);
    // Add operator to the game scene
    [self addChild:_operator];
    
    // Initialize equals sign
    _equalsSymbol = [CCSprite spriteWithImageNamed:@"SqueezingBrainsAtlas/equals.png"];
    // Set equals sign position
    _equalsSymbol.position = CGPointMake(4 * _screenSize.width / 5 - _equalsSymbol.contentSize.width / 2, _screenSize.height / 2);
    // Add sign to the game scene
    [self addChild:_equalsSymbol];
    
    // Initialize result number
    _result = [CCSprite spriteWithImageNamed:@"SqueezingBrainsAtlas/4.png"];
    // Set result number position
    _result.position = CGPointMake(5 * _screenSize.width / 5 - _result.contentSize.width / 2, _screenSize.height / 2);
    // Add result number to the game scene
    [self addChild:_result];

    // Initialize tutorial options
    [self initializeTutorialOptions];
    
    // Initialize tutorial label
    _tutorialLabel = [CCLabelTTF labelWithString:@"Choose the correct number \nfrom those available" fontName:@"Chalkduster" fontSize:20];
    _tutorialLabel.color = [CCColor whiteColor];
    _tutorialLabel.position = CGPointMake(_screenSize.width / 2, _screenSize.height - _tutorialLabel.contentSize.height);
    
    // Right-alligning the label
    _tutorialLabel.anchorPoint = CGPointMake(0.5, 0.5);
    
    [self addChild:_tutorialLabel];
   
    // Update game state
    _gameState = stateTutorialDragging;
}

-(void) initializeTutorialOptions {
    // Initialize the array of options
    _arrayOfOptions = [NSMutableArray arrayWithCapacity:kNUM_TUTORIAL_OPTIONS];
    
    // Declare option sprite
    CCSprite *option;
    
    // Initialize number 3
    option = [CCSprite spriteWithImageNamed:@"SqueezingBrainsAtlas/3.png"];
    [option setName:@"3"];
    // Set  position
    option.position = CGPointMake(_screenSize.width / kNUM_TUTORIAL_OPTIONS - option.contentSize.width / 2, option.contentSize.height / 2);
    // Add number to the game scene
    [self addChild:option];
    [_arrayOfOptions addObject:option];
    
    // Initialize number 2
    option = [CCSprite spriteWithImageNamed:@"SqueezingBrainsAtlas/2.png"];
    [option setName:@"2"];
    // Set  position
    option.position = CGPointMake(2 * _screenSize.width / kNUM_TUTORIAL_OPTIONS - option.contentSize.width / 2, option.contentSize.height / 2);
    // Add number to the game scene
    [self addChild:option];
    [_arrayOfOptions addObject:option];
    
    // Initialize number 7
    option = [CCSprite spriteWithImageNamed:@"SqueezingBrainsAtlas/7.png"];
    [option setName:@"7"];
    // Set  position
    option.position = CGPointMake(3 * _screenSize.width / kNUM_TUTORIAL_OPTIONS - option.contentSize.width / 2, option.contentSize.height / 2);
    // Add option to the game scene
    [self addChild:option];
    [_arrayOfOptions addObject:option];
    
    // Initialize number 9
    option = [CCSprite spriteWithImageNamed:@"SqueezingBrainsAtlas/9.png"];
    [option setName:@"9"];
    // Set  position
    option.position = CGPointMake(4 * _screenSize.width / kNUM_TUTORIAL_OPTIONS - option.contentSize.width / 2, option.contentSize.height / 2);
    // Add option to the game scene
    [self addChild:option];
    [_arrayOfOptions addObject:option];
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if ((int)_gameState < stateTutorialCheckingSolution) {
        // Load droppable area
        [self defineDroppableArea];
    }
    // Check what number has been touched
    CGPoint touchLocation = [touch locationInNode:self];
    [self checkNumberTouched:touchLocation];
    
}

-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ((int)_gameState < stateTutorialCheckingSolution && [[NSUserDefaults standardUserDefaults] integerForKey:kCurrentLevel] == 0) {
        [_tutorialLabel setFontSize:20];
        [_tutorialLabel setString:@"Drop the number in the highlighted area"];
    } else {
        [_tutorialLabel setFontSize:22];
        [_tutorialLabel setString:[NSString stringWithFormat:@"Level %d", [[NSUserDefaults standardUserDefaults] integerForKey:kCurrentLevel]]];
    }
    // Moving the number along the screen
    CGPoint touchLocation = [touch locationInNode:self];
    _rightNumber.position = touchLocation;

}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    // Define area to drop the number
    CGRect boardRect = CGRectMake(3 * _screenSize.width / 5 - 3 * _operator.contentSize.width / 2, _screenSize.height / 2  - _equalsSymbol.contentSize.height / 2, 2 * _operator.contentSize.width, _equalsSymbol.contentSize.height);
    
    // Only drop number inside the defined area
    if (CGRectContainsPoint(boardRect, [touch locationInNode:self])) {
            _rightNumber.position = CGPointMake(3 * _screenSize.width / 5 - _rightNumber.contentSize.width / 2, _screenSize.height / 2);
            
        // Set button visible
        _buttonCheckSolution.visible = TRUE;

        if ((int)_gameState < stateTutorialCheckingSolution  && [[NSUserDefaults standardUserDefaults] integerForKey:kCurrentLevel] == 0) {
            // Remove droppable area from scene
            [self removeChild:_droppableArea];
            [_tutorialLabel setString:@"Now check the solution by\npushing the button on the right"];
            // Update game state
            _gameState = stateTutorialCheckingSolution;
        } else{
            // Remove droppable area from scene
            [self removeChild:_droppableArea];
        }
    } else {
        
        // Recover initial position
        _rightNumber.position = _initialNumberPosition;
        // Remove droppable area from scene
        [self removeChild:_droppableArea];
        if ((int)_gameState < stateTutorialCheckingSolution  && [[NSUserDefaults standardUserDefaults] integerForKey:kCurrentLevel] == 0) {
        //Update label
        [_tutorialLabel setString:@"Choose the correct number \nfrom those available"];
        }
    }
}

-(void) defineDroppableArea {
    CGPoint vertices[4];
    
    // Set droppable area vertices
    vertices[0] = CGPointMake(3 * _screenSize.width / 5 - 3 * _operator.contentSize.width / 2, _screenSize.height / 2  - _equalsSymbol.contentSize.height / 2); //bottom-left
    vertices[1] = CGPointMake(3 * _screenSize.width / 5 - 3 * _operator.contentSize.width / 2, _screenSize.height / 2  + _equalsSymbol.contentSize.height / 2); //top-left
    vertices[2] = CGPointMake(3 * _screenSize.width / 5 + _operator.contentSize.width / 2, _screenSize.height / 2  + _equalsSymbol.contentSize.height / 2); //top-right
    vertices[3] = CGPointMake(3 * _screenSize.width / 5 + _operator.contentSize.width / 2, _screenSize.height / 2  - _equalsSymbol.contentSize.height / 2); //bottom-right
    
    // Initialize draw node
    _droppableArea = [CCDrawNode node];
    _droppableArea.anchorPoint = CGPointMake(0.0, 0.0);
    
    // Draw droppable area
    [_droppableArea drawPolyWithVerts:vertices count:4 fillColor:[CCColor greenColor] borderWidth:2.0 borderColor:[CCColor blackColor]];
    
    // Add area to scene
    [self addChild:_droppableArea];
}

-(void) checkNumberTouched:(CGPoint)touchLocation{
    // For each option in the array
    for (CCSprite *number in _arrayOfOptions) {
        if (CGRectContainsPoint(number.boundingBox, touchLocation)) {
            // The touch location belongs to the number
            _rightNumber = number;
            // Store the initial number position
            _initialNumberPosition = _rightNumber.position;
            
            // Place the number over the rest of options
            _rightNumber.zOrder = 1;
            
            break;
        }
    }
}

-(void)createCheckButton {
    // Initialize frame for normal state
    CCSpriteFrame *buttonFrame = [CCSpriteFrame frameWithImageNamed:@"SqueezingBrainsAtlas/check_solution.png"];
    // Initialize frame for highlighted state
    CCSpriteFrame *buttonFrameHighLight = [CCSpriteFrame frameWithImageNamed:@"SqueezingBrainsAtlas/check_solution_highlight.png"];

    // Create button
    _buttonCheckSolution = [CCButton buttonWithTitle:@""
                                         spriteFrame:buttonFrame
                              highlightedSpriteFrame:buttonFrameHighLight
                                 disabledSpriteFrame:buttonFrame];
    
    // Set button position
    _buttonCheckSolution.position = CGPointMake(_screenSize.width - _buttonCheckSolution.contentSize.width / 2, _screenSize.height - 3 * _buttonCheckSolution.contentSize.height / 2);
    
    // Specify the method called when selected
    [_buttonCheckSolution setTarget:self selector:@selector(checkSolution:)];

    // Make it invisible
    _buttonCheckSolution.visible = FALSE;
    
    // Add the button to the scene
    [self addChild:_buttonCheckSolution];
}

-(void)checkSolution:(id)sender{
    if((int)_gameState == stateTutorialCheckingSolution && [[NSUserDefaults standardUserDefaults] integerForKey:kCurrentLevel] == 0) {
        if ([_rightNumber.name isEqualToString:@"2"]) {
            [_tutorialLabel setString:@"Correct!"];
            _gameState = stateTutorialSuccess;
            _buttonNextLevel.visible = TRUE;
        } else {
            [_tutorialLabel setString:@"Try again!"];
            _rightNumber.position = _initialNumberPosition;
            _gameState = stateTutorialDragging;
        }
        [_tutorialLabel setFontSize:25];
        _buttonCheckSolution.visible = FALSE;
    } else {
        if ([_rightNumber.name isEqualToString:_solution]) {
            [_tutorialLabel setString:@"Correct!"];
            _buttonNextLevel.visible = TRUE;
        } else {
            [_tutorialLabel setString:@"Try again!"];
            _rightNumber.position = _initialNumberPosition;
        }
        [_tutorialLabel setFontSize:25];
        _buttonCheckSolution.visible = FALSE;
    }
}

-(void)createNextLevelButton {
    // Initialize frame
    CCSpriteFrame *buttonFrame = [CCSpriteFrame frameWithImageNamed:@"SqueezingBrainsAtlas/next_level.png"];
    
    // Create button
    _buttonNextLevel = [CCButton buttonWithTitle:@""
                                     spriteFrame:buttonFrame
                          highlightedSpriteFrame:buttonFrame
                             disabledSpriteFrame:buttonFrame];
    // Set button position
    _buttonNextLevel.position = CGPointMake(_screenSize.width - _buttonNextLevel.contentSize.width, _screenSize.height - _buttonNextLevel.contentSize.height);
    
    // Specify the method called when selected
    [_buttonNextLevel setTarget:self selector:@selector(goToNextLevel:)];
    
    // Make it invisible initially
    _buttonNextLevel.visible = FALSE;
    
    // Add button to the scene
    [self addChild:_buttonNextLevel];
}

-(void)goToNextLevel:(id)sender{
    // If we had succeeded the tutorial
    if((int)_gameState == stateTutorialSuccess) {
        // Store tutorial success in user default
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kTutorialSucceded];
    }
    
    // Get level information
    int currentLevel = [[NSUserDefaults standardUserDefaults] integerForKey:kCurrentLevel];
    // Increase level number
    currentLevel++;
    // Update level information
    [[NSUserDefaults standardUserDefaults] setInteger:currentLevel++ forKey:kCurrentLevel];
    // Force to update defaults
    [[NSUserDefaults standardUserDefaults] synchronize];
    GameScene *nextLevelScene = [GameScene scene];
    // Create transition
    CCTransition *transition = [CCTransition transitionMoveInWithDirection:CCTransitionDirectionLeft duration:0.5f];
    // Push scene with transition
    [[CCDirector sharedDirector] pushScene:nextLevelScene withTransition:transition];
}

-(void) onEnter {
    // When overriding onEnter we have to call [super onEnter]
    [super onEnter];
    
    // If tutorial state
    if(_gameState == stateTutorial && [[NSUserDefaults standardUserDefaults] integerForKey:kCurrentLevel] == 0) {
        [self initializeGameTutorial];
    } else {
        // Load plist file into a dictionary
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"levelsInfo" ofType:@"plist"]];
        
        // Load current level data
        NSDictionary *levelDictionary = [dictionary valueForKey:[NSString stringWithFormat:@"Level%d", [[NSUserDefaults standardUserDefaults] integerForKey:kCurrentLevel]]];
        
        // Read left number information
        _leftNumber =  [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"SqueezingBrainsAtlas/%@.png", [levelDictionary valueForKey:@"left number"]]];
        // Set sprite position
        _leftNumber.position = CGPointMake(_screenSize.width / 5 - _leftNumber.contentSize.width / 2, _screenSize.height / 2);
        // Add number to the game scene
        [self addChild:_leftNumber];
        
        // Read operator information
        _operator =  [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"SqueezingBrainsAtlas/%@.png", [levelDictionary valueForKey:@"operation"]]];
        // Set sprite position
        _operator.position = CGPointMake(2 * _screenSize.width / 5 - _operator.contentSize.width / 2, _screenSize.height / 2);
        // Add operator to the game scene
        [self addChild:_operator];
        
        // Read equals symbol information
        _equalsSymbol = [CCSprite spriteWithImageNamed:@"SqueezingBrainsAtlas/equals.png"];
        // Set symbol position
        _equalsSymbol.position = CGPointMake(4 * _screenSize.width / 5 - _equalsSymbol.contentSize.width / 2, _screenSize.height / 2);
        // Add symbol to the game scene
        [self addChild:_equalsSymbol];
        
        // Read result information
        _result =  [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"SqueezingBrainsAtlas/%@.png", [levelDictionary valueForKey:@"result"]]];
        // Set result position
        _result.position = CGPointMake(5 * _screenSize.width / 5 - _result.contentSize.width / 2, _screenSize.height / 2);
        // Add result to the game scene
        [self addChild:_result];
        
        // Store solution value
        _solution = [levelDictionary valueForKey:@"solution"];
        
        // Load options data
        NSDictionary * levelOptionsDictionary = [levelDictionary objectForKey:@"options"];
        
        // Load options in an array
        NSArray *options = [levelOptionsDictionary allKeys];
        
        // Initialize the array of choices
        _arrayOfOptions = [NSMutableArray arrayWithCapacity:kNUM_TUTORIAL_OPTIONS];
        
        CCSprite *optionNumber;
        // Iterate array
        for(int i = 0; i < [options count]; i++) {
            NSString *name = [levelOptionsDictionary valueForKey:[options objectAtIndex:i]];
            // Initialize number
            optionNumber = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"SqueezingBrainsAtlas/%@.png", name]];
            // Set option name
           [optionNumber setName:name];

            // Set number position
            optionNumber.position = CGPointMake((i + 1) * _screenSize.width / [options count] - optionNumber.contentSize.width / 2, optionNumber.contentSize.height / 2);
            // Add number to the game scene
            [self addChild:optionNumber];
            // Add number to array
            [_arrayOfOptions addObject:optionNumber];
        }
        
        // Initialize tutorial label
        _tutorialLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Level %d", [[NSUserDefaults standardUserDefaults] integerForKey:kCurrentLevel]] fontName:@"Chalkduster" fontSize:22];
        _tutorialLabel.color = [CCColor whiteColor];
        _tutorialLabel.position = CGPointMake(_screenSize.width / 2, _screenSize.height - 2 * _tutorialLabel.contentSize.height);
        
        // Right-alligning the label
        _tutorialLabel.anchorPoint = CGPointMake(0.5, 0.5);
        
        [self addChild:_tutorialLabel];
    }
}

@end
