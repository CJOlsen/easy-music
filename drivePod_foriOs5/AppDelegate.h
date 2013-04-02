//
//  AppDelegate.h
//  drivePod_foriOs5
//
//  Created by Christopher on 3/13/12.
//  Copyright (c) 2012, 2013 Christopher Olsen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end




// TO DO: 
//
// save playlist to persistent storage so it isn't lost every time the app is closed
// shake for nest song capability
//
// handle move to background a little better
// store playlist with NSKeyedArchiver
//
// really nice would be a small menu that could drop down and give some more options
// especially the option to end shuffle mode at the end of the current song and play that 
// song's album from its current position when the song ends
//
// also the ability to play from where the last song was paused, it sucks that it skips to
// the next song when you come back to the program

