#import "Tweak.h"

// Some things were used from Diary by Litten
// https://github.com/schneelittchen/Diary
// https://twitter.com/schneelittchen

static NSMutableDictionary *colorDictionary;

static NSString *nsNotificationString = @"com.nahtedetihw.macpassprefs/preferences.changed";

HBPreferences *preferences;
BOOL enabled;
BOOL enableAutomaticUnlock;
BOOL showOnStartup;
BOOL startWithKeyboard;
NSString *usernameString;
NSData *profilePicture;
NSInteger passcodeType;
UIViewController *respringPopController;
UIViewController *safeModePopController;
BOOL canShowStartup;
BOOL isShowingMedia;
BOOL isShowingNotifs;
BOOL isShowingAlarm;
BOOL isShowingCharging;

static bool isiPad() {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return YES;
    }
    return NO;
}

static bool isBabyDevice() {
    if ([[UIScreen mainScreen] nativeBounds].size.height <= 1334) {
        return YES;
    }
    return NO;
}


%group MacPass

%hook NCNotificationStructuredListViewController
- (void)viewDidLoad {
    %orig;
    
    NSTimer *nowPlayingTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateStartup) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:nowPlayingTimer forMode:NSDefaultRunLoopMode];
}

%new
- (void)updateStartup {
    if (self.hasVisibleContent == YES) {
        isShowingNotifs = YES;
    } else {
        isShowingNotifs = NO;
    }
}
%end

%hook CSCoverSheetViewController
- (void)viewDidLoad {
    %orig;
    
    NSTimer *nowPlayingTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateStartup) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:nowPlayingTimer forMode:NSDefaultRunLoopMode];
}

-(void)_transitionChargingViewToVisible:(BOOL)arg1 showBattery:(BOOL)arg2 animated:(BOOL)arg3 {
    %orig;
    if (arg1 == YES) {
        isShowingCharging = YES;
    } else {
        isShowingCharging = NO;
    }
}

%new
- (void)updateStartup {
    if (self.showingMediaControls == YES) {
        isShowingMedia = YES;
    } else {
        isShowingMedia = NO;
    }
    if ([[[[[%c(SBScheduledAlarmObserver) sharedInstance] valueForKey:@"_alarmManager"] cache] nextAlarm] isFiring] == YES) {
        isShowingAlarm = YES;
    } else {
        isShowingAlarm = NO;
    }
}
%end

%hook SBLockScreenManager
-(void)_handleBacklightLevelWillChange:(id)arg1 {
    %orig;
    [self showMacPass];
}

%new
- (void)showMacPass {
    if (isShowingMedia == YES) return;
    if (isShowingNotifs == YES) return;
    if (isShowingAlarm == YES) return;
    if (isShowingCharging == YES) return;
    if (showOnStartup && [self isLockScreenVisible] && [self _isPasscodeVisible] == NO) [self setPasscodeVisible:YES animated:YES];
}
%end

%hook CSLockScreenSettings
-(BOOL)autoDismissUnlockedLockScreen {
    if (enableAutomaticUnlock) {
    if (isShowingMedia == YES) return NO;
    if (isShowingNotifs == YES) return NO;
    if (isShowingAlarm == YES) return NO;
    if (isShowingCharging == YES) return NO;
    return YES;
    }
    return %orig;
}
%end

%hook CSPasscodeViewController
%property (nonatomic, strong) _UIBackdropViewSettings *settingsPasscodeBackground;
%property (nonatomic, strong) _UIBackdropView *blurViewPasscodeBackground;
%property (nonatomic, strong) UIView *profilePictureContainerView;
%property (nonatomic, strong) UIImageView *profilePictureView;
%property (nonatomic, strong) UILabel *usernameLabel;
%property (nonatomic, strong) UITextField *textField;
%property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
%property (nonatomic, strong) UIButton *unlockButton;
%property (nonatomic, strong) UIButton *clearButton;
%property (nonatomic, strong) _UIBackdropViewSettings *settingsTextField;
%property (nonatomic, strong) _UIBackdropView *blurViewTextField;
%property (nonatomic, strong) UIButton *respringButton;
%property (nonatomic, strong) _UIBackdropViewSettings *settingsRespring;
%property (nonatomic, strong) _UIBackdropView *blurViewRespring;
%property (nonatomic, strong) UILabel *respringLabel;
%property (nonatomic, strong) UIButton *exitButton;
%property (nonatomic, strong) _UIBackdropViewSettings *settingsExit;
%property (nonatomic, strong) _UIBackdropView *blurViewExit;
%property (nonatomic, strong) UILabel *exitLabel;
%property (nonatomic, strong) UIButton *safeModeButton;
%property (nonatomic, strong) _UIBackdropViewSettings *settingsSafeMode;
%property (nonatomic, strong) _UIBackdropView *blurViewSafeMode;
%property (nonatomic, strong) UILabel *safeModeLabel;

- (void)viewDidLoad {
    %orig;
    
    self.view.alpha = 0;
    
    self.settingsPasscodeBackground = [_UIBackdropViewSettings settingsForStyle:2];

    self.blurViewPasscodeBackground = [[_UIBackdropView alloc] initWithSettings:self.settingsPasscodeBackground];
    self.blurViewPasscodeBackground.frame = self.view.frame;
    self.blurViewPasscodeBackground.clipsToBounds = YES;
    self.view.clipsToBounds = YES;
    self.blurViewPasscodeBackground.userInteractionEnabled = NO;
    [self.view insertSubview:self.blurViewPasscodeBackground atIndex:0];
    
    self.blurViewPasscodeBackground.translatesAutoresizingMaskIntoConstraints = false;
    [self.blurViewPasscodeBackground.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:0].active = YES;
    [self.blurViewPasscodeBackground.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:0].active = YES;
    [self.blurViewPasscodeBackground.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:0].active = YES;
    [self.blurViewPasscodeBackground.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:0].active = YES;
    
    if (isBabyDevice()) {
        self.profilePictureContainerView = [[UIView alloc] initWithFrame:CGRectMake(self.view.center.x,self.view.center.y,120,120)];
    } else {
        self.profilePictureContainerView = [[UIView alloc] initWithFrame:CGRectMake(self.view.center.x,self.view.center.y,175,175)];
    }
    self.profilePictureContainerView.layer.masksToBounds = NO;
    self.profilePictureContainerView.layer.shadowOffset = CGSizeMake(0, 10);
    self.profilePictureContainerView.layer.shadowRadius = 6;
    self.profilePictureContainerView.layer.shadowOpacity = 0.1;
    [self.view addSubview:self.profilePictureContainerView];
    
    if (isBabyDevice() == YES) {
        self.profilePictureContainerView.translatesAutoresizingMaskIntoConstraints = false;
        [self.profilePictureContainerView.widthAnchor constraintEqualToConstant:120].active = true;
        [self.profilePictureContainerView.heightAnchor constraintEqualToConstant:120].active = true;
        [self.profilePictureContainerView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:0].active = true;
        [self.profilePictureContainerView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:-190].active = true;
    } else {
        self.profilePictureContainerView.translatesAutoresizingMaskIntoConstraints = false;
        [self.profilePictureContainerView.widthAnchor constraintEqualToConstant:175].active = true;
        [self.profilePictureContainerView.heightAnchor constraintEqualToConstant:175].active = true;
        [self.profilePictureContainerView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:0].active = true;
        [self.profilePictureContainerView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:-190].active = true;
    }
    
    if (isBabyDevice()) {
        self.profilePictureView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x,self.view.center.y,120,120)];
    } else {
        self.profilePictureView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x,self.view.center.y,175,175)];
    }
    self.profilePictureView.image = [UIImage imageWithData:profilePicture];
    self.profilePictureView.layer.masksToBounds = YES;
    self.profilePictureView.layer.cornerRadius = self.profilePictureView.frame.size.height/2;
    self.profilePictureView.layer.borderWidth = 0.2;
    self.profilePictureView.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4].CGColor;
    self.profilePictureView.contentMode = UIViewContentModeScaleAspectFill;
    [self.profilePictureContainerView addSubview:self.profilePictureView];
    
    if (isBabyDevice() == YES) {
        self.profilePictureView.translatesAutoresizingMaskIntoConstraints = false;
        [self.profilePictureView.widthAnchor constraintEqualToConstant:120].active = true;
        [self.profilePictureView.heightAnchor constraintEqualToConstant:120].active = true;
        [self.profilePictureView.centerXAnchor constraintEqualToAnchor:self.profilePictureContainerView.centerXAnchor constant:0].active = true;
        [self.profilePictureView.centerYAnchor constraintEqualToAnchor:self.profilePictureContainerView.centerYAnchor constant:0].active = true;
    } else {
        self.profilePictureView.translatesAutoresizingMaskIntoConstraints = false;
        [self.profilePictureView.widthAnchor constraintEqualToConstant:175].active = true;
        [self.profilePictureView.heightAnchor constraintEqualToConstant:175].active = true;
        [self.profilePictureView.centerXAnchor constraintEqualToAnchor:self.profilePictureContainerView.centerXAnchor constant:0].active = true;
        [self.profilePictureView.centerYAnchor constraintEqualToAnchor:self.profilePictureContainerView.centerYAnchor constant:0].active = true;
    }
    
    self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x,self.view.center.y,200,40)];
    self.usernameLabel.text = usernameString;
    self.usernameLabel.textAlignment = NSTextAlignmentCenter;
    self.usernameLabel.font = [UIFont boldSystemFontOfSize:24];
    self.usernameLabel.textColor = [SparkColourPickerUtils colourWithString:[colorDictionary objectForKey:@"tintColor"] withFallback:@"#FFFFFF"];
    [self.view addSubview:self.usernameLabel];
    
    if (isBabyDevice() == YES) {
        self.usernameLabel.translatesAutoresizingMaskIntoConstraints = false;
        [self.usernameLabel.widthAnchor constraintEqualToConstant:150].active = true;
        [self.usernameLabel.heightAnchor constraintEqualToConstant:30].active = true;
        [self.usernameLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:0].active = true;
        [self.usernameLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:-100].active = true;
    } else {
        self.usernameLabel.translatesAutoresizingMaskIntoConstraints = false;
        [self.usernameLabel.widthAnchor constraintEqualToConstant:200].active = true;
        [self.usernameLabel.heightAnchor constraintEqualToConstant:40].active = true;
        [self.usernameLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:0].active = true;
        [self.usernameLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:-70].active = true;
    }
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [self.tapGesture setNumberOfTapsRequired:1];
    [self.tapGesture setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:self.tapGesture];
    
    if (isBabyDevice()) {
        self.textField = [[UITextField alloc] initWithFrame:CGRectMake(self.view.center.x,self.view.center.y, 180, 40)];
    } else {
        self.textField = [[UITextField alloc] initWithFrame:CGRectMake(self.view.center.x,self.view.center.y, 200, 40)];
    }
    
    self.textField.placeholder = @"Enter Passcode";
    self.textField.textAlignment = NSTextAlignmentCenter;
    self.textField.delegate = self;
    if (passcodeType == 0) {
        if (isiPad() == YES) {
        self.textField.keyboardType = UIKeyboardTypeDecimalPad;
        } else {
        self.textField.keyboardType = UIKeyboardTypeNumberPad;
        }
    } else if (passcodeType == 1) {
        self.textField.keyboardType = UIKeyboardTypeASCIICapable;
    }
    if (enableAutomaticUnlock) [self.textField addTarget:self action:@selector(autoUnlock) forControlEvents:UIControlEventEditingChanged];
     
    [self.textField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Enter Passcode" attributes:@{NSForegroundColorAttributeName:[[SparkColourPickerUtils colourWithString:[colorDictionary objectForKey:@"tintColor"] withFallback:@"#FFFFFF"] colorWithAlphaComponent:0.2], NSFontAttributeName : [UIFont boldSystemFontOfSize:16.0]}]];
    [[UITextField appearance] setTintColor:[SparkColourPickerUtils colourWithString:[colorDictionary objectForKey:@"tintColor"] withFallback:@"#FFFFFF"]];
    self.textField.textColor = [SparkColourPickerUtils colourWithString:[colorDictionary objectForKey:@"tintColor"] withFallback:@"#FFFFFF"];
    self.textField.clearsOnBeginEditing = NO;
    [self.textField setSecureTextEntry:YES];
    
    self.unlockButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.unlockButton setImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/MacPass/unlock.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.unlockButton addTarget:self action:@selector(attemptUnlock)
            forControlEvents:UIControlEventTouchUpInside];
    self.unlockButton.tintColor = [[SparkColourPickerUtils colourWithString:[colorDictionary objectForKey:@"tintColor"] withFallback:@"#FFFFFF"] colorWithAlphaComponent:0.5];

    self.textField.rightView = self.unlockButton;
    self.textField.rightViewMode = UITextFieldViewModeAlways;
    
    self.clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *clearImage = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/MacPass/clear.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.clearButton setImage:clearImage forState:UIControlStateNormal];
    [self.clearButton addTarget:self action:@selector(clearText)
            forControlEvents:UIControlEventTouchUpInside];
    self.clearButton.tintColor = [[SparkColourPickerUtils colourWithString:[colorDictionary objectForKey:@"tintColor"] withFallback:@"#FFFFFF"] colorWithAlphaComponent:0.5];

    self.textField.leftView = self.clearButton;
    self.textField.leftViewMode = UITextFieldViewModeAlways;

    [self.view addSubview:self.textField];
    
    if (isBabyDevice() == YES) {
        self.textField.translatesAutoresizingMaskIntoConstraints = false;
        [self.textField.widthAnchor constraintEqualToConstant:180].active = true;
        [self.textField.heightAnchor constraintEqualToConstant:40].active = true;
        [self.textField.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:0].active = true;
        [self.textField.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:-40].active = true;
    } else {
        self.textField.translatesAutoresizingMaskIntoConstraints = false;
        [self.textField.widthAnchor constraintEqualToConstant:200].active = true;
        [self.textField.heightAnchor constraintEqualToConstant:40].active = true;
        [self.textField.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:0].active = true;
        [self.textField.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:-10].active = true;
    }
    
    self.settingsTextField = [_UIBackdropViewSettings settingsForStyle:4005];

    self.blurViewTextField = [[_UIBackdropView alloc] initWithSettings:self.settingsTextField];
    self.blurViewTextField.frame = self.textField.frame;
    self.blurViewTextField.layer.masksToBounds = YES;
    self.blurViewTextField.layer.cornerRadius = self.textField.frame.size.height/2;
    [self.textField insertSubview:self.blurViewTextField atIndex:0];
    
    if (isBabyDevice()) {
        self.blurViewTextField.translatesAutoresizingMaskIntoConstraints = false;
        [self.blurViewTextField.widthAnchor constraintEqualToConstant:180].active = true;
        [self.blurViewTextField.heightAnchor constraintEqualToConstant:40].active = true;
        [self.blurViewTextField.centerXAnchor constraintEqualToAnchor:self.textField.centerXAnchor constant:0].active = true;
        [self.blurViewTextField.centerYAnchor constraintEqualToAnchor:self.textField.centerYAnchor constant:0].active = true;
    } else {
        self.blurViewTextField.translatesAutoresizingMaskIntoConstraints = false;
        [self.blurViewTextField.widthAnchor constraintEqualToConstant:200].active = true;
        [self.blurViewTextField.heightAnchor constraintEqualToConstant:40].active = true;
        [self.blurViewTextField.centerXAnchor constraintEqualToAnchor:self.textField.centerXAnchor constant:0].active = true;
        [self.blurViewTextField.centerYAnchor constraintEqualToAnchor:self.textField.centerYAnchor constant:0].active = true;
    }
    
    self.respringButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.respringButton setBackgroundImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/MacPass/respring.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.respringButton.imageEdgeInsets = UIEdgeInsetsMake(-2,-2,-2,-2);
    self.respringButton.titleEdgeInsets = UIEdgeInsetsMake(-2,-2,-2,-2);
    [self.respringButton setContentMode:UIViewContentModeCenter];
    [self.respringButton addTarget:self action:@selector(respringShowPopup:)
            forControlEvents:UIControlEventTouchUpInside];
    if (isBabyDevice()) {
        self.respringButton.frame = CGRectMake(self.view.center.x,self.view.center.y,40,40);
    } else {
        self.respringButton.frame = CGRectMake(self.view.center.x,self.view.center.y,50,50);
    }
    self.respringButton.layer.masksToBounds = YES;
    self.respringButton.layer.cornerRadius = self.respringButton.frame.size.height/2;
    self.respringButton.tintColor = [[SparkColourPickerUtils colourWithString:[colorDictionary objectForKey:@"tintColor"] withFallback:@"#FFFFFF"] colorWithAlphaComponent:0.5];
    [self.view addSubview:self.respringButton];
    
    if (isBabyDevice() == YES) {
        self.respringButton.translatesAutoresizingMaskIntoConstraints = false;
        [self.respringButton.widthAnchor constraintEqualToConstant:40].active = true;
        [self.respringButton.heightAnchor constraintEqualToConstant:40].active = true;
        [self.respringButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:0].active = true;
        [self.respringButton.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:150].active = true;
    } else {
        self.respringButton.translatesAutoresizingMaskIntoConstraints = false;
        [self.respringButton.widthAnchor constraintEqualToConstant:50].active = true;
        [self.respringButton.heightAnchor constraintEqualToConstant:50].active = true;
        [self.respringButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:0].active = true;
        [self.respringButton.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:200].active = true;
    }
    
    self.settingsRespring = [_UIBackdropViewSettings settingsForStyle:4005];

    self.blurViewRespring = [[_UIBackdropView alloc] initWithSettings:self.settingsRespring];
    if (isBabyDevice()) {
        self.blurViewRespring.frame = CGRectMake(self.view.center.x,self.view.center.y,40,40);
    } else {
        self.blurViewRespring.frame = CGRectMake(self.view.center.x,self.view.center.y,50,50);
    }
    self.blurViewRespring.layer.masksToBounds = YES;
    self.blurViewRespring.layer.cornerRadius = self.respringButton.frame.size.height/2;
    [self.view insertSubview:self.blurViewRespring belowSubview:self.respringButton];
    
    if (isBabyDevice() == YES) {
        self.blurViewRespring.translatesAutoresizingMaskIntoConstraints = false;
        [self.blurViewRespring.widthAnchor constraintEqualToConstant:40].active = true;
        [self.blurViewRespring.heightAnchor constraintEqualToConstant:40].active = true;
        [self.blurViewRespring.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:0].active = true;
        [self.blurViewRespring.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:150].active = true;
    } else {
        self.blurViewRespring.translatesAutoresizingMaskIntoConstraints = false;
        [self.blurViewRespring.widthAnchor constraintEqualToConstant:50].active = true;
        [self.blurViewRespring.heightAnchor constraintEqualToConstant:50].active = true;
        [self.blurViewRespring.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:0].active = true;
        [self.blurViewRespring.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:200].active = true;
    }
    
    self.respringLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x,self.view.center.y,80,20)];
    self.respringLabel.text = @"Respring";
    self.respringLabel.textAlignment = NSTextAlignmentCenter;
    self.respringLabel.font = [UIFont boldSystemFontOfSize:12];
    self.respringLabel.textColor = [SparkColourPickerUtils colourWithString:[colorDictionary objectForKey:@"tintColor"] withFallback:@"#FFFFFF"];
    [self.view addSubview:self.respringLabel];
    
    if (isBabyDevice()) {
        self.respringLabel.translatesAutoresizingMaskIntoConstraints = false;
        [self.respringLabel.widthAnchor constraintEqualToConstant:80].active = true;
        [self.respringLabel.heightAnchor constraintEqualToConstant:20].active = true;
        [self.respringLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:0].active = true;
        [self.respringLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:200].active = true;
    } else {
        self.respringLabel.translatesAutoresizingMaskIntoConstraints = false;
        [self.respringLabel.widthAnchor constraintEqualToConstant:80].active = true;
        [self.respringLabel.heightAnchor constraintEqualToConstant:20].active = true;
        [self.respringLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:0].active = true;
        [self.respringLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:250].active = true;
    }
    
    self.exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.exitButton setBackgroundImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/MacPass/exit.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.exitButton.imageEdgeInsets = UIEdgeInsetsMake(-2,-2,-2,-2);
    self.exitButton.titleEdgeInsets = UIEdgeInsetsMake(-2,-2,-2,-2);
    [self.exitButton setContentMode:UIViewContentModeCenter];
    [self.exitButton addTarget:self action:@selector(exitPasscode)
            forControlEvents:UIControlEventTouchUpInside];
    if (isBabyDevice()) {
        self.exitButton.frame = CGRectMake(self.view.center.x,self.view.center.y,40,40);
    } else {
        self.exitButton.frame = CGRectMake(self.view.center.x,self.view.center.y,50,50);
    }
    self.exitButton.layer.masksToBounds = YES;
    self.exitButton.layer.cornerRadius = self.exitButton.frame.size.height/2;
    self.exitButton.tintColor = [[SparkColourPickerUtils colourWithString:[colorDictionary objectForKey:@"tintColor"] withFallback:@"#FFFFFF"] colorWithAlphaComponent:0.5];
    [self.view addSubview:self.exitButton];
    
    if (isBabyDevice() == YES) {
        self.exitButton.translatesAutoresizingMaskIntoConstraints = false;
        [self.exitButton.widthAnchor constraintEqualToConstant:40].active = true;
        [self.exitButton.heightAnchor constraintEqualToConstant:40].active = true;
        [self.exitButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:-80].active = true;
        [self.exitButton.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:150].active = true;
    } else {
        self.exitButton.translatesAutoresizingMaskIntoConstraints = false;
        [self.exitButton.widthAnchor constraintEqualToConstant:50].active = true;
        [self.exitButton.heightAnchor constraintEqualToConstant:50].active = true;
        [self.exitButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:-100].active = true;
        [self.exitButton.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:200].active = true;
    }
    
    self.settingsExit = [_UIBackdropViewSettings settingsForStyle:4005];

    self.blurViewExit = [[_UIBackdropView alloc] initWithSettings:self.settingsExit];
    if (isBabyDevice()) {
        self.blurViewExit.frame = CGRectMake(self.view.center.x,self.view.center.y,40,40);
    } else {
        self.blurViewExit.frame = CGRectMake(self.view.center.x,self.view.center.y,50,50);
    }
    self.blurViewExit.layer.masksToBounds = YES;
    self.blurViewExit.layer.cornerRadius = self.exitButton.frame.size.height/2;
    [self.view insertSubview:self.blurViewExit belowSubview:self.exitButton];
    
    if (isBabyDevice() == YES) {
        self.blurViewExit.translatesAutoresizingMaskIntoConstraints = false;
        [self.blurViewExit.widthAnchor constraintEqualToConstant:40].active = true;
        [self.blurViewExit.heightAnchor constraintEqualToConstant:40].active = true;
        [self.blurViewExit.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:-80].active = true;
        [self.blurViewExit.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:150].active = true;
    } else {
        self.blurViewExit.translatesAutoresizingMaskIntoConstraints = false;
        [self.blurViewExit.widthAnchor constraintEqualToConstant:50].active = true;
        [self.blurViewExit.heightAnchor constraintEqualToConstant:50].active = true;
        [self.blurViewExit.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:-100].active = true;
        [self.blurViewExit.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:200].active = true;
    }
    
    self.exitLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x,self.view.center.y,80,20)];
    self.exitLabel.text = @"Go Back";
    self.exitLabel.textAlignment = NSTextAlignmentCenter;
    self.exitLabel.font = [UIFont boldSystemFontOfSize:12];
    self.exitLabel.textColor = [SparkColourPickerUtils colourWithString:[colorDictionary objectForKey:@"tintColor"] withFallback:@"#FFFFFF"];
    [self.view addSubview:self.exitLabel];
    
    if (isBabyDevice()) {
        self.exitLabel.translatesAutoresizingMaskIntoConstraints = false;
        [self.exitLabel.widthAnchor constraintEqualToConstant:80].active = true;
        [self.exitLabel.heightAnchor constraintEqualToConstant:20].active = true;
        [self.exitLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:-80].active = true;
        [self.exitLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:200].active = true;
    } else {
        self.exitLabel.translatesAutoresizingMaskIntoConstraints = false;
        [self.exitLabel.widthAnchor constraintEqualToConstant:80].active = true;
        [self.exitLabel.heightAnchor constraintEqualToConstant:20].active = true;
        [self.exitLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:-100].active = true;
        [self.exitLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:250].active = true;
    }
    
    self.safeModeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.safeModeButton setBackgroundImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/MacPass/safemode.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.safeModeButton.imageEdgeInsets = UIEdgeInsetsMake(-2,-2,-2,-2);
    self.safeModeButton.titleEdgeInsets = UIEdgeInsetsMake(-2,-2,-2,-2);
    [self.safeModeButton setContentMode:UIViewContentModeCenter];
    [self.safeModeButton addTarget:self action:@selector(safeModeShowPopup:)
            forControlEvents:UIControlEventTouchUpInside];
    if (isBabyDevice()) {
        self.safeModeButton.frame = CGRectMake(self.view.center.x,self.view.center.y,40,40);
    } else {
        self.safeModeButton.frame = CGRectMake(self.view.center.x,self.view.center.y,50,50);
    }
    self.safeModeButton.layer.masksToBounds = YES;
    self.safeModeButton.layer.cornerRadius = self.safeModeButton.frame.size.height/2;
    self.safeModeButton.tintColor = [[SparkColourPickerUtils colourWithString:[colorDictionary objectForKey:@"tintColor"] withFallback:@"#FFFFFF"] colorWithAlphaComponent:0.5];
    [self.view addSubview:self.safeModeButton];
    
    if (isBabyDevice() == YES) {
        self.safeModeButton.translatesAutoresizingMaskIntoConstraints = false;
        [self.safeModeButton.widthAnchor constraintEqualToConstant:40].active = true;
        [self.safeModeButton.heightAnchor constraintEqualToConstant:40].active = true;
        [self.safeModeButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:80].active = true;
        [self.safeModeButton.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:150].active = true;
    } else {
        self.safeModeButton.translatesAutoresizingMaskIntoConstraints = false;
        [self.safeModeButton.widthAnchor constraintEqualToConstant:50].active = true;
        [self.safeModeButton.heightAnchor constraintEqualToConstant:50].active = true;
        [self.safeModeButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:100].active = true;
        [self.safeModeButton.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:200].active = true;
    }
    
    self.settingsSafeMode = [_UIBackdropViewSettings settingsForStyle:4005];

    self.blurViewSafeMode = [[_UIBackdropView alloc] initWithSettings:self.settingsSafeMode];
    if (isBabyDevice()) {
        self.blurViewSafeMode.frame = CGRectMake(self.view.center.x,self.view.center.y,40,40);
    } else {
        self.blurViewSafeMode.frame = CGRectMake(self.view.center.x,self.view.center.y,50,50);
    }
    self.blurViewSafeMode.layer.masksToBounds = YES;
    self.blurViewSafeMode.layer.cornerRadius = self.safeModeButton.frame.size.height/2;
    [self.view insertSubview:self.blurViewSafeMode belowSubview:self.safeModeButton];
    
    if (isBabyDevice() == YES) {
        self.blurViewSafeMode.translatesAutoresizingMaskIntoConstraints = false;
        [self.blurViewSafeMode.widthAnchor constraintEqualToConstant:40].active = true;
        [self.blurViewSafeMode.heightAnchor constraintEqualToConstant:40].active = true;
        [self.blurViewSafeMode.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:80].active = true;
        [self.blurViewSafeMode.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:150].active = true;
    } else {
        self.blurViewSafeMode.translatesAutoresizingMaskIntoConstraints = false;
        [self.blurViewSafeMode.widthAnchor constraintEqualToConstant:50].active = true;
        [self.blurViewSafeMode.heightAnchor constraintEqualToConstant:50].active = true;
        [self.blurViewSafeMode.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:100].active = true;
        [self.blurViewSafeMode.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:200].active = true;
    }

    self.safeModeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x,self.view.center.y,80,20)];
    self.safeModeLabel.text = @"Safe Mode";
    self.safeModeLabel.textAlignment = NSTextAlignmentCenter;
    self.safeModeLabel.font = [UIFont boldSystemFontOfSize:12];
    self.safeModeLabel.textColor = [SparkColourPickerUtils colourWithString:[colorDictionary objectForKey:@"tintColor"] withFallback:@"#FFFFFF"];
    [self.view addSubview:self.safeModeLabel];
    
    if (isBabyDevice()) {
        self.safeModeLabel.translatesAutoresizingMaskIntoConstraints = false;
        [self.safeModeLabel.widthAnchor constraintEqualToConstant:80].active = true;
        [self.safeModeLabel.heightAnchor constraintEqualToConstant:20].active = true;
        [self.safeModeLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:80].active = true;
        [self.safeModeLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:200].active = true;
    } else {
        self.safeModeLabel.translatesAutoresizingMaskIntoConstraints = false;
        [self.safeModeLabel.widthAnchor constraintEqualToConstant:80].active = true;
        [self.safeModeLabel.heightAnchor constraintEqualToConstant:20].active = true;
        [self.safeModeLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:100].active = true;
        [self.safeModeLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:250].active = true;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unlockWithFaceID) name:@"MacPassPasscodeAuthentication" object:nil];
}

%new
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *updatedString = [self.textField.text stringByReplacingCharactersInRange:range withString:string];
    self.textField.text = updatedString;

    NSRange selectedRange = NSMakeRange(range.location + string.length, 0);
    UITextPosition* from = [self.textField positionFromPosition:self.textField.beginningOfDocument offset:selectedRange.location];
    UITextPosition* to = [self.textField positionFromPosition:from offset:selectedRange.length];
    self.textField.selectedTextRange = [self.textField textRangeFromPosition:from toPosition:to];

    [self.textField sendActionsForControlEvents:UIControlEventEditingChanged];
    return NO;
}

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    if ([[%c(SBLockScreenManager) sharedInstance] isLockScreenVisible] && startWithKeyboard) [self.textField becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    
    self.view.alpha = 0;
    [UIView animateWithDuration:0.3 delay:0 options:nil animations:^{
        self.view.alpha = 1;
    } completion:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MacPassPasscodeVisible" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    %orig;
    [self dismiss];
    [self dismissViewControllerAnimated:respringPopController completion:nil];
    [self dismissViewControllerAnimated:safeModePopController completion:nil];

    [UIView animateWithDuration:0.3 delay:0 options:nil animations:^{
        self.view.alpha = 0;
    } completion:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MacPassPasscodeNotVisible" object:nil];
}

%new
- (void)autoUnlock {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.textField.text.length >= 4) {
                [[%c(SBLockScreenManager) sharedInstance] attemptUnlockWithPasscode:[NSString stringWithFormat:@"%@", self.textField.text] finishUIUnlock:1 completion:nil];
        }
    });
    if (![[%c(SBLockScreenManager) sharedInstance] isUILocked]) [self dismiss];
    AudioServicesPlaySystemSound(1519);
}

%new
- (void)attemptUnlock {
    if ([self.textField.text length] < 4) [self wrongPasscode];
    if ([self.textField.text length] >= 4) [[%c(SBLockScreenManager) sharedInstance] attemptUnlockWithPasscode:[NSString stringWithFormat:@"%@", self.textField.text] finishUIUnlock:1 completion:nil];
    if ([[%c(SBLockScreenManager) sharedInstance] isUILocked]) [self wrongPasscode];
    if (![[%c(SBLockScreenManager) sharedInstance] isUILocked]) [self dismiss];
    AudioServicesPlaySystemSound(1519);
}

%new
- (void)clearText {
    [self.textField setText:@""];
    AudioServicesPlaySystemSound(1519);
}

%new
- (void)wrongPasscode {
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    anim.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-5.0f, 0.0f, 0.0f)],
        [NSValue valueWithCATransform3D:CATransform3DMakeTranslation( 5.0f, 0.0f, 0.0f)]];
    anim.autoreverses = YES;
    anim.repeatCount = 2.0f;
    anim.duration = 0.07f;
    [self.textField.layer addAnimation:anim forKey:@"shake"];
    
    [self.textField setText:@""];
    AudioServicesPlaySystemSound(1521);
}

%new
- (void)dismiss {
    [self.textField endEditing:YES];
    [self.textField resignFirstResponder];
}

%new
- (void)exitPasscode {
    AudioServicesPlaySystemSound(1519);
    
    [self.textField endEditing:YES];
    [self.textField resignFirstResponder];
    [[%c(SBLockScreenManager) sharedInstance] setPasscodeVisible:NO animated:YES];
}

%new
- (void)unlockWithFaceID {
    [self dismiss];
    [[%c(SBLockScreenManager) sharedInstance] unlockUIFromSource:17 withOptions:nil];
}

%new
- (void)respringShowPopup:(UIButton *)sender {
    
    respringPopController = [[UIViewController alloc] init];
    respringPopController.modalPresentationStyle = UIModalPresentationPopover;
    respringPopController.preferredContentSize = CGSizeMake(200,130);
    UILabel *respringPopLabel = [[UILabel alloc] init];
    respringPopLabel.frame = CGRectMake(20, 20, 160, 60);
    respringPopLabel.numberOfLines = 2;
    respringPopLabel.textAlignment = NSTextAlignmentCenter;
    respringPopLabel.adjustsFontSizeToFitWidth = YES;
    respringPopLabel.font = [UIFont boldSystemFontOfSize:20];
    respringPopLabel.textColor = [SparkColourPickerUtils colourWithString:[colorDictionary objectForKey:@"tintColor"] withFallback:@"#FFFFFF"];
    respringPopLabel.text = @"Are you sure you want to respring?";
    [respringPopController.view addSubview:respringPopLabel];
    
    UIButton *respringYesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [respringYesButton addTarget:self
                  action:@selector(respringYes)
     forControlEvents:UIControlEventTouchUpInside];
    [respringYesButton setBackgroundImage:[UIImage systemImageNamed:@"checkmark.circle.fill"] forState:UIControlStateNormal];
    respringYesButton.imageEdgeInsets = UIEdgeInsetsMake(-2,-2,-2,-2);
    respringYesButton.titleEdgeInsets = UIEdgeInsetsMake(-2,-2,-2,-2);
    [respringYesButton setContentMode:UIViewContentModeCenter];
    respringYesButton.tintColor = [SparkColourPickerUtils colourWithString:[colorDictionary objectForKey:@"tintColor"] withFallback:@"#FFFFFF"];
    //[respringYesButton setTitle:@"Yes" forState:UIControlStateNormal];
    respringYesButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [respringYesButton setTitleColor:[SparkColourPickerUtils colourWithString:[colorDictionary objectForKey:@"tintColor"] withFallback:@"#FFFFFF"] forState:UIControlStateNormal];
    respringYesButton.frame = CGRectMake(145, 80, 20, 20);
    [respringPopController.view addSubview:respringYesButton];
    
    UIButton *respringNoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [respringNoButton addTarget:self
                  action:@selector(respringNo)
     forControlEvents:UIControlEventTouchUpInside];
    [respringNoButton setBackgroundImage:[UIImage systemImageNamed:@"xmark.circle.fill"] forState:UIControlStateNormal];
    respringNoButton.imageEdgeInsets = UIEdgeInsetsMake(-2,-2,-2,-2);
    respringNoButton.titleEdgeInsets = UIEdgeInsetsMake(-2,-2,-2,-2);
    [respringNoButton setContentMode:UIViewContentModeCenter];
    respringNoButton.tintColor = [SparkColourPickerUtils colourWithString:[colorDictionary objectForKey:@"tintColor"] withFallback:@"#FFFFFF"];
    //[respringNoButton setTitle:@"No" forState:UIControlStateNormal];
    respringNoButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [respringNoButton setTitleColor:[SparkColourPickerUtils colourWithString:[colorDictionary objectForKey:@"tintColor"] withFallback:@"#FFFFFF"] forState:UIControlStateNormal];
    respringNoButton.frame = CGRectMake(45, 80, 20, 20);
    [respringPopController.view addSubview:respringNoButton];
     
    UIPopoverPresentationController *respringPopover = respringPopController.popoverPresentationController;
    RespringViewController *vc = [[RespringViewController alloc] init];
    respringPopover.delegate = vc;
    [respringPopover _setBackgroundBlurDisabled:YES];
    respringPopover.permittedArrowDirections = UIPopoverArrowDirectionDown;
    respringPopover.sourceView = sender;
    respringPopover.sourceRect = CGRectMake(0, 0, sender.frame.size.width, sender.frame.size.height);
    respringPopover.backgroundColor = [UIColor clearColor];
    
    _UIBackdropViewSettings *settingsRespringPop = [_UIBackdropViewSettings settingsForStyle:4005];

    _UIBackdropView *blurViewRespringPop = [[_UIBackdropView alloc] initWithFrame:respringPopController.view.frame autosizesToFitSuperview:YES settings:settingsRespringPop];
    blurViewRespringPop.layer.masksToBounds = YES;
    respringPopController.view.clipsToBounds = YES;
    [respringPopController.view insertSubview:blurViewRespringPop atIndex:0];
    
    [self presentViewController:respringPopController animated:YES completion:nil];
    
    AudioServicesPlaySystemSound(1519);

}

%new
- (void)respringNo {
    [self dismissViewControllerAnimated:respringPopController completion:nil];
    
    AudioServicesPlaySystemSound(1519);
}

%new
- (void)respringYes {
    AudioServicesPlaySystemSound(1519);
    
    pid_t pid;
    const char* args[] = {"sbreload", NULL};
    posix_spawn(&pid, "/usr/bin/sbreload", NULL, NULL, (char* const*)args, NULL);
}

%new
- (void)safeModeShowPopup:(UIButton *)sender {
    
    safeModePopController = [[UIViewController alloc] init];
    safeModePopController.modalPresentationStyle = UIModalPresentationPopover;
    safeModePopController.view.frame = CGRectMake(0,0,200,130);
    safeModePopController.preferredContentSize = CGSizeMake(200,130);
    UILabel *safeModePopLabel = [[UILabel alloc] init];
    safeModePopLabel.frame = CGRectMake(20, 20, 160, 60);
    safeModePopLabel.numberOfLines = 2;
    safeModePopLabel.textAlignment = NSTextAlignmentCenter;
    safeModePopLabel.adjustsFontSizeToFitWidth = YES;
    safeModePopLabel.font = [UIFont boldSystemFontOfSize:20];
    safeModePopLabel.textColor = [SparkColourPickerUtils colourWithString:[colorDictionary objectForKey:@"tintColor"] withFallback:@"#FFFFFF"];
    safeModePopLabel.text = @"Are you sure you want to enter safe mode?";
    [safeModePopController.view addSubview:safeModePopLabel];
    
    UIButton *safeModeYesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [safeModeYesButton addTarget:self
                  action:@selector(safeModeYes)
     forControlEvents:UIControlEventTouchUpInside];
    [safeModeYesButton setBackgroundImage:[UIImage systemImageNamed:@"checkmark.circle.fill"] forState:UIControlStateNormal];
    safeModeYesButton.imageEdgeInsets = UIEdgeInsetsMake(-2,-2,-2,-2);
    safeModeYesButton.titleEdgeInsets = UIEdgeInsetsMake(-2,-2,-2,-2);
    [safeModeYesButton setContentMode:UIViewContentModeCenter];
    safeModeYesButton.tintColor = [SparkColourPickerUtils colourWithString:[colorDictionary objectForKey:@"tintColor"] withFallback:@"#FFFFFF"];
    //[safeModeYesButton setTitle:@"Yes" forState:UIControlStateNormal];
    safeModeYesButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [safeModeYesButton setTitleColor:[SparkColourPickerUtils colourWithString:[colorDictionary objectForKey:@"tintColor"] withFallback:@"#FFFFFF"] forState:UIControlStateNormal];
    safeModeYesButton.frame = CGRectMake(145, 80, 20, 20);
    [safeModePopController.view addSubview:safeModeYesButton];
    
    UIButton *safeModeNoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [safeModeNoButton addTarget:self
                  action:@selector(safeModeNo)
     forControlEvents:UIControlEventTouchUpInside];
    [safeModeNoButton setBackgroundImage:[UIImage systemImageNamed:@"xmark.circle.fill"] forState:UIControlStateNormal];
    safeModeNoButton.imageEdgeInsets = UIEdgeInsetsMake(-2,-2,-2,-2);
    safeModeNoButton.titleEdgeInsets = UIEdgeInsetsMake(-2,-2,-2,-2);
    [safeModeNoButton setContentMode:UIViewContentModeCenter];
    safeModeNoButton.tintColor = [SparkColourPickerUtils colourWithString:[colorDictionary objectForKey:@"tintColor"] withFallback:@"#FFFFFF"];
    //[safeModeNoButton setTitle:@"No" forState:UIControlStateNormal];
    safeModeNoButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [safeModeNoButton setTitleColor:[SparkColourPickerUtils colourWithString:[colorDictionary objectForKey:@"tintColor"] withFallback:@"#FFFFFF"] forState:UIControlStateNormal];
    safeModeNoButton.frame = CGRectMake(45, 80, 20, 20);
    [safeModePopController.view addSubview:safeModeNoButton];
     
    UIPopoverPresentationController *safeModePopover = safeModePopController.popoverPresentationController;
    SafeModeViewController *vc = [[SafeModeViewController alloc] init];
    safeModePopover.delegate = vc;
    [safeModePopover _setBackgroundBlurDisabled:YES];
    safeModePopover.permittedArrowDirections = UIPopoverArrowDirectionDown;
    safeModePopover.sourceView = self.safeModeButton;
    safeModePopover.sourceRect = CGRectMake(0,0,self.safeModeButton.frame.size.width,self.safeModeButton.frame.size.height);
    safeModePopover.backgroundColor = [UIColor clearColor];
    [safeModePopover setArrowBackgroundColor:[UIColor clearColor]];
    
    _UIBackdropViewSettings *settingsSafeModePop = [_UIBackdropViewSettings settingsForStyle:4005];

    _UIBackdropView *blurViewSafeModePop = [[_UIBackdropView alloc] initWithFrame:safeModePopController.view.frame autosizesToFitSuperview:YES settings:settingsSafeModePop];
    blurViewSafeModePop.layer.masksToBounds = YES;
    [safeModePopController.view insertSubview:blurViewSafeModePop atIndex:0];
    
    [self presentViewController:safeModePopController animated:YES completion:nil];
    
    AudioServicesPlaySystemSound(1519);

}

%new
- (void)safeModeNo {
    [self dismissViewControllerAnimated:safeModePopController completion:nil];
    
    AudioServicesPlaySystemSound(1519);
}

%new
- (void)safeModeYes {
    AudioServicesPlaySystemSound(1519);
    
    pid_t pid;
    const char *args[] = {"killall", "-SEGV", "SpringBoard", NULL};
    posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char * const *)args, NULL);
}
%end

%hook SBUIProudLockIconView
-(void)layoutSubviews {
    %orig;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(passcodeVisible) name:@"MacPassPasscodeVisible" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(passcodeNotVisible) name:@"MacPassPasscodeNotVisible" object:nil];
}

%new
- (void)passcodeVisible {
    [self.superview setHidden:YES];
    [self setHidden:YES];
}

%new
- (void)passcodeNotVisible {
    NSDictionary *diaryDict = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/love.litten.diarypreferences.plist"];
    if ([[diaryDict objectForKey:@"Enabled"] boolValue] == YES && [[diaryDict objectForKey:@"enableHello"] boolValue] == YES) {
        [self.superview setHidden:YES];
        [self setHidden:YES];
    } else {
        [self.superview setHidden:NO];
        [self setHidden:NO];
    }
}
%end

%hook SBDashBoardBiometricUnlockController

- (void)setAuthenticated:(BOOL)arg1 {
    %orig;
    if (arg1) [[NSNotificationCenter defaultCenter] postNotificationName:@"MacPassPasscodeAuthentication" object:nil];
}
%end

%hook CSPasscodeBackgroundView
- (id)initWithFrame:(CGRect)frame {
    self = %orig;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(passcodeVisible) name:@"MacPassPasscodeVisible" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(passcodeNotVisible) name:@"MacPassPasscodeNotVisible" object:nil];
    
    return self;
}

%new
- (void)passcodeVisible {
    [UIView animateWithDuration:0.5 delay:0 options:nil animations:^{
        self.alpha = 0;
        self.hidden = YES;
    } completion:nil];
}

%new
- (void)passcodeNotVisible {
    [UIView animateWithDuration:0.5 delay:0 options:nil animations:^{
        self.alpha = 0;
        self.hidden = YES;
    } completion:nil];
}
%end

%hook SBUIPasscodeBiometricAuthenticationView
-(void)_updateConstraints {
    %orig;
    self.faceIDLabel.hidden = YES;
}
%end

%hook SBUIPasscodeLockViewWithKeypad
- (void)updateStatusText:(id)arg1 subtitle:(id)arg2 animated:(BOOL)arg3 {
    %orig(nil, nil, NO);
}
%end

%hook SBUIPasscodeLockViewSimpleFixedDigitKeyPad
- (void)setStatusText:(id)arg1 {
    %orig(nil);
}
%end

%hook SBSimplePasscodeEntryFieldButton

- (void)layoutSubviews {
    %orig;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(passcodeVisible) name:@"MacPassPasscodeVisible" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(passcodeNotVisible) name:@"MacPassPasscodeNotVisible" object:nil];
}

%new
- (void)passcodeVisible {
    [UIView animateWithDuration:0.5 delay:0 options:nil animations:^{
        self.alpha = 0;
        self.hidden = YES;
    } completion:nil];
}

%new
- (void)passcodeNotVisible {
    [UIView animateWithDuration:0.5 delay:0 options:nil animations:^{
        self.alpha = 1;
        self.hidden = NO;
    } completion:nil];
}
%end

%hook SBUISimpleFixedDigitPasscodeEntryField

- (void)layoutSubviews {
    %orig;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(passcodeVisible) name:@"MacPassPasscodeVisible" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(passcodeNotVisible) name:@"MacPassPasscodeNotVisible" object:nil];
}

%new
- (void)passcodeVisible {
    [UIView animateWithDuration:0.5 delay:0 options:nil animations:^{
        self.alpha = 0;
        self.hidden = YES;
    } completion:nil];
}

%new
- (void)passcodeNotVisible {
    [UIView animateWithDuration:0.5 delay:0 options:nil animations:^{
        self.alpha = 0;
        self.hidden = YES;
    } completion:nil];
}
%end
 
%hook SBUIPasscodeLockNumberPad

- (void)layoutSubviews {
    %orig;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(passcodeVisible) name:@"MacPassPasscodeVisible" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(passcodeNotVisible) name:@"MacPassPasscodeNotVisible" object:nil];
}

%new
- (void)passcodeVisible {
    [UIView animateWithDuration:0.5 delay:0 options:nil animations:^{
        self.alpha = 0;
        self.hidden = YES;
    } completion:nil];
}

%new
- (void)passcodeNotVisible {
    [UIView animateWithDuration:0.5 delay:0 options:nil animations:^{
        self.alpha = 1;
        self.hidden = NO;
    } completion:nil];
}
%end

%hook SBUIPasscodeBiometricResource
-(BOOL)hasBiometricAuthenticationCapabilityEnabled {
    return NO;
}
%end
%end

static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    colorDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/private/var/mobile/Library/Preferences/com.nahtedetihw.macpassprefs.color.plist"];
}

%ctor {
    notificationCallback(NULL, NULL, NULL, NULL, NULL);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, notificationCallback, (CFStringRef)nsNotificationString, NULL, CFNotificationSuspensionBehaviorCoalesce);

    preferences = [[HBPreferences alloc] initWithIdentifier:@"com.nahtedetihw.macpassprefs"];
    [preferences registerBool:&enabled default:NO forKey:@"enabled"];
    [preferences registerBool:&showOnStartup default:NO forKey:@"showOnStartup"];
    [preferences registerBool:&startWithKeyboard default:NO forKey:@"startWithKeyboard"];
    [preferences registerBool:&enableAutomaticUnlock default:NO forKey:@"enableAutomaticUnlock"];
    [preferences registerObject:&usernameString default:@"MacPass" forKey:@"usernameString"];
    [preferences registerObject:&profilePicture default:nil forKey:@"profilePicture"];
    [preferences registerInteger:&passcodeType default:0 forKey:@"passcodeType"];
    
    if (enabled) {
        %init(MacPass);
    return;
    }
    return;
}
