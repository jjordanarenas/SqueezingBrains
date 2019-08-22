#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "cocos2d-ui.h"

typedef enum {
    stateTutorial = 0,
    stateTutorialDragging,
    stateTutorialCheckingSolution,
    stateTutorialSuccess
} GameState;
@interface GameScene : CCScene {
    
}

+ (GameScene *)scene;
- (id)init;

@end
