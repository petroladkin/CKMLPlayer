//
//  PlayerViewController.m
//  CustomKMLPlayer
//
//  Created by Petro Ladkin on 29.01.15.
//  Copyright (c) 2015 PeLa. All rights reserved.
//

#import "PlayerViewController.h"
#import "WebDavManager.h"

#import <MediaPlayer/MediaPlayer.h>


@interface PlayerViewController ()


@property (weak, nonatomic) IBOutlet UIView *controlsView;

@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *prevButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;


@property (weak, nonatomic) IBOutlet UIView *tapView;

@property (strong, nonatomic) MPMoviePlayerController *player;
@property (strong, nonatomic) NSTimer *playerTimer;
@property (assign, atomic) NSTimeInterval idleTimeInterval;
@property (assign, atomic) BOOL dontUpdateSlider;

- (IBAction)actionPrev:(UIButton *)sender;
- (IBAction)actionPlay:(UIButton *)sender;
- (IBAction)actionPause:(UIButton *)sender;
- (IBAction)actionNext:(UIButton *)sender;

- (IBAction)actionTouchDown:(UISlider *)sender;
- (IBAction)actionTouchUp:(UISlider *)sender;
- (IBAction)actionProgressChangeValue:(UISlider *)sender;


@end


@implementation PlayerViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerPlaybackDidFinishNotification:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerNowPlayingMovieDidChangeNotification:)
                                                 name:MPMoviePlayerNowPlayingMovieDidChangeNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerPlaybackStateDidChangeNotification:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayeNotification:)
                                                 name:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayeNotification:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayeNotification:)
                                                 name:MPMoviePlayerIsAirPlayVideoActiveDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayeNotification:)
                                                 name:MPMoviePlayerReadyForDisplayDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayeNotification:)
                                                 name:MPMovieMediaTypesAvailableNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayeNotification:)
                                                 name:MPMovieSourceTypeAvailableNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayeNotification:)
                                                 name:MPMovieDurationAvailableNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayeNotification:)
                                                 name:MPMovieNaturalSizeAvailableNotification
                                               object:nil];
    
    [self.tapView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)]];

    self.controlsView.layer.cornerRadius = 8;
    
    self.dontUpdateSlider = NO;
 
    self.player = [[MPMoviePlayerController alloc] init];
    self.player.controlStyle = MPMovieControlStyleNone;
    
//    [[MPVolumeView ] ];
    
    int lwidth = self.view.frame.size.width;
    int lheight = self.view.frame.size.height;
    if (lheight > lwidth) {
        lwidth = self.view.frame.size.height;
        lheight = self.view.frame.size.width;
    }
    if ([self isLandscape:self.interfaceOrientation]) {
        [self.player.view setFrame:CGRectMake(0, 0, lwidth, lheight)];
    } else {
        [self.player.view setFrame:CGRectMake(0, 0, lheight, lwidth)];
    }
    [self.view insertSubview:self.player.view belowSubview:self.tapView];

    [self playCurrentFile];
    [self resetIdleTimer];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [self.player stop];
    self.player = nil;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if ([self isLandscape:toInterfaceOrientation] != [self isLandscape:self.interfaceOrientation]) {
        [UIView animateWithDuration:duration animations:^(){
            [self.player.view setFrame:CGRectMake(0, 0, self.player.view.bounds.size.height, self.player.view.bounds.size.width)];
        }];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - help methods

- (BOOL)isLandscape:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

- (void)playCurrentFile {
    self.progressSlider.value = 0.0;
    self.positionLabel.text = @"";
    self.durationLabel.text = @"";
    [self disableButtons];
    
//    WebDavItem* wdi = [self.files objectAtIndex:self.currentFileIndex];
//    
//    self.navigationItem.title = wdi.name;
//    
//    self.player.contentURL = [NSURL URLWithString:[wdi.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [self.player prepareToPlay];

    [self.player play];
}

- (NSString*)timeToString:(NSTimeInterval)timeInterval {
    NSString* ret = @"";
    if (timeInterval > 3600.0) {
        ret = [NSString stringWithFormat:@"%d:%02d:%02d", ((int)timeInterval) / 3600, (((int)timeInterval) / 60) % 60, ((int)timeInterval) % 60];
    } else {
        ret = [NSString stringWithFormat:@"%02d:%02d", (((int)timeInterval) / 60) % 60, ((int)timeInterval) % 60];
    }
    return ret;
}

- (BOOL)isShowingUI {
    return !self.navigationController.navigationBarHidden;
}

- (void)showUI {
    [self resetIdleTimer];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [UIView animateWithDuration:0.4 animations:^(){
        self.controlsView.alpha = 1.0f;
    }];
}

- (void)hideUI {
    [self resetIdleTimer];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [UIView animateWithDuration:0.4 animations:^(){
        self.controlsView.alpha = 0.0f;
    }];
}

- (void)enableButtons {
    self.prevButton.enabled = YES;
    self.nextButton.enabled = YES;
    self.playButton.enabled = YES;
    self.pauseButton.enabled = YES;
}

- (void)disableButtons {
    self.prevButton.enabled = NO;
    self.nextButton.enabled = NO;
    self.playButton.enabled = NO;
    self.pauseButton.enabled = NO;
}

- (void) resetIdleTimer {
    self.idleTimeInterval = [[NSDate date] timeIntervalSince1970];
}

#pragma mark - notifications

- (void)moviePlayerPlaybackDidFinishNotification:(NSNotification*)notif {
    NSNumber* reason = [notif.userInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    if ([reason intValue] == MPMovieFinishReasonPlaybackEnded) {
        [self actionNext:nil];
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)moviePlayerNowPlayingMovieDidChangeNotification:(NSNotification*)notif {
    self.playerTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(playerTimerUpdate:) userInfo:nil repeats:YES];
    [self enableButtons];
}

- (void)moviePlayerPlaybackStateDidChangeNotification:(NSNotification*)notif {
//    NSLog(@"%d", self.player.playbackState);
//    switch (self.player.playbackState) {
//        case MPMoviePlaybackStateStopped:
//            NSLog(@"MPMoviePlaybackStateStopped");
//            break;
//        case MPMoviePlaybackStatePlaying:
//            NSLog(@"MPMoviePlaybackStatePlaying");
//            break;
//        case MPMoviePlaybackStatePaused:
//            NSLog(@"MPMoviePlaybackStatePaused");
//            break;
//        case MPMoviePlaybackStateInterrupted:
//            NSLog(@"MPMoviePlaybackStateInterrupted");
//            break;
//        case MPMoviePlaybackStateSeekingForward:
//            NSLog(@"MPMoviePlaybackStateSeekingForward");
//            break;
//        case MPMoviePlaybackStateSeekingBackward:
//            NSLog(@"MPMoviePlaybackStateSeekingBackward");
//            break;
//    }
    if (self.dontUpdateSlider && self.player.playbackState == MPMoviePlaybackStatePlaying) {
        self.dontUpdateSlider = NO;
    }
}

- (void)moviePlayeNotification:(NSNotification*)notif {
//    NSLog(@"moviePlayeNotification - %@", notif);
}

- (void)tapGestureRecognizer:(UITapGestureRecognizer *)recognizer {
    if ([self isShowingUI]) {
        [self hideUI];
    } else {
        [self showUI];
    }
}

- (void)playerTimerUpdate:(id)userInfo {
    if ([self isShowingUI]) {
        if (!self.dontUpdateSlider) {
            self.progressSlider.value = self.player.currentPlaybackTime / self.player.duration;
            self.positionLabel.text = [self timeToString:self.player.currentPlaybackTime];
            self.durationLabel.text = [NSString stringWithFormat:@"-%@", [self timeToString:self.player.duration - self.player.currentPlaybackTime]];
        }
        
        if (!self.dontUpdateSlider) {
            if ([[NSDate date] timeIntervalSince1970] - self.idleTimeInterval > 5.0f) {
                [self hideUI];
            }
        }
    }
}


#pragma mark - help methods

- (IBAction)actionPrev:(UIButton *)sender {
    [self resetIdleTimer];
    if (self.currentFileIndex == 0) {
        self.currentFileIndex = self.files.count - 1;
    } else {
        --self.currentFileIndex;
    }
    
    [self.player stop];
    [self playCurrentFile];
}

- (IBAction)actionPlay:(UIButton *)sender {
    [self resetIdleTimer];
    [self.player play];
    self.playButton.hidden = YES;
    self.pauseButton.hidden = NO;
}

- (IBAction)actionPause:(UIButton *)sender {
    [self resetIdleTimer];
    [self.player pause];
    self.playButton.hidden = NO;
    self.pauseButton.hidden = YES;
}

- (IBAction)actionNext:(UIButton *)sender {
    [self resetIdleTimer];
    if (self.currentFileIndex == self.files.count - 1) {
        self.currentFileIndex = 0;
    } else {
        ++self.currentFileIndex;
    }
    
    [self.player stop];
    [self playCurrentFile];
}

- (IBAction)actionTouchDown:(UISlider *)sender {
    self.dontUpdateSlider = YES;
}

- (IBAction)actionTouchUp:(UISlider *)sender {
    [self resetIdleTimer];
//    self.dontUpdateSlider = NO;
    
    self.player.currentPlaybackTime = self.player.duration * sender.value;
}

- (IBAction)actionProgressChangeValue:(UISlider *)sender {
    NSTimeInterval playbackTime = self.player.duration * sender.value;
    self.positionLabel.text = [self timeToString:playbackTime];
    self.durationLabel.text = [NSString stringWithFormat:@"-%@", [self timeToString:self.player.duration - playbackTime]];
}


@end
