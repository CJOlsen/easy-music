//
//  ViewController.m
//  drivePod_foriOs5
//
//  Created by Christopher on 3/13/12.
//  Copyright (c) 2012,2013 Christopher Olsen. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize musicPlayer, toolbar, nowPlayingLabel, nowPlayingSublabel, nowPlayingArtwork, actionUpdateDisplay,
            getSongsButton, shakeSwitch, playlist, limboPlaylist,
            singleTapGestureRecognizer, doubleTapGestureRecognizer, tripleTapGestureRecognizer;


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //[self becomeFirstResponder];//for the shake gestures (maybe next version)
    
    //register for music player updates (collectors are in te MPMusicPlayer delegate methods)
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter
     addObserver: self
     selector:    @selector (handle_NowPlayingItemChanged:)
     name:        MPMusicPlayerControllerNowPlayingItemDidChangeNotification
     object:      musicPlayer];
    
    [notificationCenter
     addObserver: self
     selector:    @selector (handle_PlaybackStateChanged:)
     name:        MPMusicPlayerControllerPlaybackStateDidChangeNotification
     object:      musicPlayer];
 
    musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    
    [musicPlayer setShuffleMode:MPMusicShuffleModeOff];
    [musicPlayer setRepeatMode:MPMusicRepeatModeNone];
    [musicPlayer setQueueWithItemCollection:nil];
    
    [musicPlayer beginGeneratingPlaybackNotifications];
    
    
    //so the double and triple taps don't get called together
    [doubleTapGestureRecognizer requireGestureRecognizerToFail:tripleTapGestureRecognizer];
    [singleTapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
    [singleTapGestureRecognizer requireGestureRecognizerToFail:tripleTapGestureRecognizer];

    NSLog(@"shakeSwitch.state = %@", shakeSwitch.state);
    
    if ([playlist count] < 1)
    {
        NSLog(@"try to push media picker");
        [self performSelector:@selector(presentMusicPicker) withObject:nil afterDelay:0.5];
    }
}

- (void)viewDidUnload
{
    [self setActionUpdateDisplay:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return NO;
}

#pragma mark - Various Methods

-(void)presentMusicPicker
{
    MPMediaPickerController* picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
    
    [picker setDelegate:self];
    [picker setAllowsPickingMultipleItems:YES];
    picker.prompt = NSLocalizedString(@"Add songs to play", "Prompt in media item picker");
    [self presentModalViewController:picker animated: YES];
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void) updateNowPlayingLabel
{
    NSString*songName = [musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyTitle];
    NSString*artistName = [musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyArtist];
    NSString*albumName = [musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyAlbumTitle];
    
    if (songName){
        nowPlayingLabel.text = [NSString stringWithFormat:@"%@", songName];}
    if (!albumName){(albumName = @"album");}
    if (!artistName){artistName = (@"artist");}
    nowPlayingSublabel.text = [NSString stringWithFormat:@"%@ - %@", albumName, artistName];
    
    //the artwork is a bit trickier, we must get the artwork and then resize it to fit the UIImageView
    MPMediaItemArtwork* artwork = [musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyArtwork];
    CGSize imageViewSize = nowPlayingArtwork.bounds.size; 
    nowPlayingArtwork.image = [artwork imageWithSize:imageViewSize];
}

#pragma mark - Gesture Recognizer Methods

-(BOOL) gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{

    //without this the toolbar buttons won't work because the gestureRecognizers intercept the touches
    if ([touch.view.superview isKindOfClass:[UIToolbar class]])
    {
        return NO;
    }
    return YES;
}

-(void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    //this plain doesn't work...
    NSLog(@"motionEnded....shake ");
    if (event.type == UIEventSubtypeMotionShake )
    {
        [musicPlayer skipToNextItem];
    }
}
- (IBAction)tripleTapGesture:(id)sender 
{
    //triple tap = shuffle on/off
    if (!musicPlayer.shuffleMode || musicPlayer.shuffleMode == MPMusicShuffleModeOff)
    {
        musicPlayer.shuffleMode = MPMusicShuffleModeSongs;
    }
    else
    {
        musicPlayer.shuffleMode = MPMusicShuffleModeOff;
    }
}

- (IBAction)doubleTapGesture:(id)sender 
{    
    //double taqp = play/pause
    
    //if the playlist is empty we'll go get some songs
    if ([playlist count] == 0)
    {
        [self presentMusicPicker];
         return;
    }
    
    //if the musicPlayer is playing we'll pause it, if it isn't we'll start it
    if (musicPlayer.playbackState == MPMusicPlaybackStatePlaying)
    {
        [musicPlayer pause];
    }
    else if (musicPlayer.playbackState == MPMusicPlaybackStateStopped || musicPlayer.playbackState == MPMusicPlaybackStatePaused)
    {
        [musicPlayer play];
    }
    else
    {
        [musicPlayer stop]; //in case it's doing something funny we send it to a safe state
    }
}

- (IBAction)swipeLeftGesture:(id)sender 
{
    [musicPlayer skipToPreviousItem];
}

- (IBAction)swipeRightGesture:(id)sender 
{
    [musicPlayer skipToNextItem];
}

- (IBAction)swipeUpGesture:(id)sender 
{
    musicPlayer.volume += .05;
}

- (IBAction)swipeDownGesture:(id)sender 
{
    musicPlayer.volume -= .1;
}

- (IBAction)twoFingerSwipeRightGesture:(id)sender 
{
    NSLog(@"twoFingerSwipeRight");
    [musicPlayer beginSeekingForward];
    
    if (musicPlayer.playbackState == MPMusicPlaybackStateSeekingBackward) 
    {
        [musicPlayer endSeeking];
    }
    else
    {
        [musicPlayer beginSeekingForward];
    }
}

- (IBAction)twoFingerSwipeLeftGesture:(id)sender 
{
    NSLog(@"twoFingerSwipeLeft");
    if (musicPlayer.playbackState == MPMusicPlaybackStateSeekingForward) 
    {
        [musicPlayer endSeeking];
    }
    else
    {
    [musicPlayer beginSeekingBackward];
    }
}

- (IBAction)singleTapGesture:(id)sender 
{
    NSLog(@"singleTapGesture");
    if (musicPlayer.playbackState == MPMusicPlaybackStateSeekingForward || musicPlayer.playbackState == MPMusicPlaybackStateSeekingBackward) 
    {
        [musicPlayer endSeeking];
    }
}


- (IBAction)clickGetSongs:(id)sender 
{
    [self presentMusicPicker];
}


#pragma mark - MPMediaPicker Delegate Methods

-(void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissModalViewControllerAnimated:YES];
}

-(void)handle_NowPlayingItemChanged:(id)notification
{
    NSLog(@"now playing item changed");
    [self updateNowPlayingLabel];
}

-(void)handle_PlaybackStateChanged:(id)notification
{
    NSLog(@"handle_PlaybackStateChanged: method");
    [self updateNowPlayingLabel];
    
    if(musicPlayer.playbackState == MPMusicPlaybackStatePlaying)
    {
        actionUpdateDisplay.text = @"Playing";
        [actionUpdateDisplay performSelector:@selector(setText:) withObject:nil afterDelay:1.5];
    }
    else if(musicPlayer.playbackState == MPMusicPlaybackStatePaused)
    {
        actionUpdateDisplay.text = @"Paused";
    }
    else if(musicPlayer.playbackState == MPMusicPlaybackStateStopped)
    {
        actionUpdateDisplay.text = @"Stopped";
        [actionUpdateDisplay performSelector:@selector(setText:) withObject:nil afterDelay:1.5];
    }
    else if(musicPlayer.playbackState == MPMusicPlaybackStateSeekingForward)
    {
        actionUpdateDisplay.text = @"Seeking Forward";
    }
    else if(musicPlayer.playbackState == MPMusicPlaybackStateSeekingBackward)
    {
        actionUpdateDisplay.text = @"Seeking Backward";
    }
}


-(void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    //coming back from the Media Picker
    [self dismissModalViewControllerAnimated:YES];
    
    limboPlaylist = mediaItemCollection;//this stores the new playlist until it is decided how if it will be added to or overwrite the current playlist
    
    //if there are both new and old playlists, ask what to do
    if ([playlist count] > 0 && [mediaItemCollection count] > 0)
    {
        //button events handled in the UIAlertView Delegate (below)
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"New Playlist Created" message:@"Add songs to current playlist or create new playlist?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Add To Current", @"Create New", nil];
        [alert show];
        return;
    }
    
    [musicPlayer setQueueWithItemCollection:mediaItemCollection];
    playlist = mediaItemCollection;
}




#pragma mark - UIAlertView Delegate

-(void)alertView:(UIAlertView*)alertview clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"clicked button at index %i", buttonIndex);
    if (buttonIndex == 0) //Add To Current Playlist
    {
        
        //this may not be necessary, but for some reason stepping through the arrays one at a time made this work, the MPMediaItem objects and collections aren't as flexible as their NS counterparts
        NSMutableArray*newPlaylist = [[NSMutableArray alloc]init];
        
        //add the old items one by one, then the new
        for (int i = 0; i < [playlist.items count]; i++)
        {
            [newPlaylist addObject:[playlist.items objectAtIndex:i]];
        }
        for (int j = 0; j < [limboPlaylist.items count]; j++)
        {
            [newPlaylist addObject:[limboPlaylist.items objectAtIndex:j]];
        }
        playlist = [MPMediaItemCollection collectionWithItems:newPlaylist];
        [musicPlayer setQueueWithItemCollection:playlist];
    }
    else //overwrite existing playlist
    {
        playlist = limboPlaylist;
        [musicPlayer setQueueWithItemCollection:playlist];
    }
}

#pragma mark - Segue Methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ViewControllerToTableViewControllerSegue"])
    {
        TableViewController*ModalTableViewController = segue.destinationViewController;
        ModalTableViewController.delegate = self;
        ModalTableViewController.playlist = playlist;        
    }
}
#pragma mark - TableViewController Delegate Methods
-(void) ModalTableViewDidClickDone:(MPMediaItemCollection*)newPlaylist
{
    playlist = newPlaylist;
    [self dismissModalViewControllerAnimated:YES];
}

-(void) ModalTableViewDidClickCancel
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
