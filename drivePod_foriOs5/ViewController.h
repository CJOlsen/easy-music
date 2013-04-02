//
//  ViewController.h
//  drivePod_foriOs5
//
//  Created by Christopher on 3/13/12.
//  Copyright (c) 2012,2013 Christopher Olsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "TableViewController.h"


@interface ViewController : UIViewController <MPMediaPickerControllerDelegate, TableViewControllerDelegate>

@property (nonatomic, retain) MPMusicPlayerController*  musicPlayer;
@property (nonatomic, retain) MPMediaItemCollection*    playlist;
@property (nonatomic, retain) MPMediaItemCollection*    limboPlaylist;
@property (nonatomic, retain) IBOutlet UILabel*         nowPlayingLabel;
@property (nonatomic, retain) IBOutlet UILabel*         nowPlayingSublabel;
@property (nonatomic, retain) IBOutlet UIImageView*     nowPlayingArtwork;
@property (nonatomic, retain) IBOutlet UIToolbar*       toolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* getSongsButton;
@property (nonatomic, retain) IBOutlet UISwitch*        shakeSwitch;

@property (weak, nonatomic) IBOutlet UILabel *actionUpdateDisplay;



@property (nonatomic, retain) IBOutlet UIGestureRecognizer* singleTapGestureRecognizer;
@property (nonatomic, retain) IBOutlet UIGestureRecognizer* doubleTapGestureRecognizer;
@property (nonatomic, retain) IBOutlet UIGestureRecognizer* tripleTapGestureRecognizer;

- (IBAction)doubleTapGesture:(id)sender;
- (IBAction)tripleTapGesture:(id)sender;
- (IBAction)swipeLeftGesture:(id)sender;
- (IBAction)swipeRightGesture:(id)sender;
- (IBAction)swipeUpGesture:(id)sender;
- (IBAction)swipeDownGesture:(id)sender;
- (IBAction)twoFingerSwipeRightGesture:(id)sender;
- (IBAction)twoFingerSwipeLeftGesture:(id)sender;
- (IBAction)singleTapGesture:(id)sender;


- (IBAction)clickGetSongs:(id)sender;

-(void)presentMusicPicker;

//Media Picker Delegate
-(void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection;
-(void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker;

//TableViewController Delegate
-(void) ModalTableViewDidClickDone:(MPMediaItemCollection*)newPlaylist;
-(void) ModalTableViewDidClickCancel;

@end

