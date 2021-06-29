#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
#import <spawn.h>
#import <SparkColourPickerUtils.h>
#import <SparkColourPickerView.h>
#import <Cephei/HBPreferences.h>
#include <dlfcn.h>

@interface MTAlarm : NSObject
@property (getter=isFiring,nonatomic,readonly) BOOL firing;
@end

@interface MTAlarmCache : NSObject
@property(nonatomic, retain)MTAlarm* nextAlarm;
@end

@interface MTAlarmManager : NSObject
@property(nonatomic, retain)MTAlarmCache* cache;
@end

@interface SBScheduledAlarmObserver : NSObject {
    MTAlarmManager* _alarmManager;
}
+ (id)sharedInstance;
@end

@interface CSPresentationViewController : UIViewController
@property (getter=isPresentingContent,nonatomic,readonly) BOOL presentingContent;
@end

@interface CSCoverSheetViewController : UIViewController
@property (nonatomic,readonly) CSPresentationViewController * mainPagePresentationViewController;
@property (assign,getter=isShowingMediaControls,nonatomic) BOOL showingMediaControls;
@property (nonatomic,readonly) BOOL hasContentAboveCoverSheet;
-(BOOL)_isShowingChargingModal;
- (void)updateStartup;
@end

@interface NCNotificationStructuredListViewController : UIViewController
@property (nonatomic,readonly) BOOL hasVisibleContent;
- (void)updateStartup;
@end

@interface UIPopoverPresentationController (Private)
@property (assign,setter=_setPopoverBackgroundStyle:,nonatomic) long long _popoverBackgroundStyle;
@property (assign,setter=_setBackgroundBlurDisabled:,nonatomic) BOOL _backgroundBlurDisabled;
@property (assign,setter=_setShouldHideArrow:,getter=_shouldHideArrow,nonatomic) BOOL _shouldHideArrow;
@property (setter=_setSourceOverlayView:,getter=_sourceOverlayView,nonatomic,retain) UIView * sourceOverlayView;
-(void)setArrowBackgroundColor:(id)arg1 ;
-(id)_backgroundView;
-(Class)_defaultChromeViewClass;
@end

@interface RespringViewController : UIViewController <UIPopoverPresentationControllerDelegate>
@end

@implementation RespringViewController
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
traitCollection:(UITraitCollection *)traitCollection {
    return UIModalPresentationNone;
}
@end

@interface SafeModeViewController : UIViewController <UIPopoverPresentationControllerDelegate>
@end

@implementation SafeModeViewController
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
traitCollection:(UITraitCollection *)traitCollection {
    return UIModalPresentationNone;
}
@end

@interface _UIBackdropView : UIView
-(id)initWithFrame:(CGRect)arg1 autosizesToFitSuperview:(BOOL)arg2 settings:(id)arg3 ;
-(id)initWithSettings:(id)arg1 ;
@end

@interface _UIBackdropViewSettings : NSObject
+(id)settingsForStyle:(long long)arg1 ;
@end

@interface CSPasscodeViewController : UIViewController<UITextFieldDelegate>
@property (nonatomic, strong) _UIBackdropViewSettings *settingsPasscodeBackground;
@property (nonatomic, strong) _UIBackdropView *blurViewPasscodeBackground;
@property (nonatomic, strong) UIView *profilePictureContainerView;
@property (nonatomic, strong) UIImageView *profilePictureView;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIButton *unlockButton;
@property (nonatomic, strong) UIButton *clearButton;
@property (nonatomic, strong) _UIBackdropViewSettings *settingsTextField;
@property (nonatomic, strong) _UIBackdropView *blurViewTextField;
@property (nonatomic, strong) UIButton *respringButton;
@property (nonatomic, strong) _UIBackdropViewSettings *settingsRespring;
@property (nonatomic, strong) _UIBackdropView *blurViewRespring;
@property (nonatomic, strong) UILabel *respringLabel;
@property (nonatomic, strong) UIButton *exitButton;
@property (nonatomic, strong) _UIBackdropViewSettings *settingsExit;
@property (nonatomic, strong) _UIBackdropView *blurViewExit;
@property (nonatomic, strong) UILabel *exitLabel;
@property (nonatomic, strong) UIButton *safeModeButton;
@property (nonatomic, strong) _UIBackdropViewSettings *settingsSafeMode;
@property (nonatomic, strong) _UIBackdropView *blurViewSafeMode;
@property (nonatomic, strong) UILabel *safeModeLabel;
- (void)attemptUnlock;
- (void)clearText;
- (void)dismiss;
- (void)unlockWithFaceID;
- (void)exitPasscode;
- (void)respring;
- (void)safeMode;
- (void)wrongPasscode;
- (void)beginEditing;
- (void)endEditing;
- (void)respringShowPopup:(UIButton *)sender;
- (void)respringNo;
- (void)respringYes;
- (void)safeModeShowPopup:(UIButton *)sender;
- (void)safeModeNo;
- (void)safeModeYes;
@end

@interface SBUIProudLockIconView : UIView
- (void)passcodeVisible;
- (void)passcodeNotVisible;
@end

@interface CSProudLockViewController : UIViewController
- (void)passcodeVisible;
- (void)passcodeNotVisible;
@end

@interface SBSimplePasscodeEntryFieldButton : UIButton
-(void)setRevealed:(BOOL)arg1 animated:(BOOL)arg2;
- (void)passcodeVisible;
- (void)passcodeNotVisible;
@end

@interface SBUIPasscodeBiometricAuthenticationView : UIView
@property (nonatomic, strong) UILabel *faceIDLabel;
@end

@interface SBUIPasscodeLockNumberPad : UIView
-(void)setVisible:(BOOL)arg1 animated:(BOOL)arg2;
- (void)passcodeVisible;
- (void)passcodeNotVisible;
@end

@interface CSPasscodeBackgroundView : UIView
- (void)passcodeVisible;
- (void)passcodeNotVisible;
@end

@interface SBUISimpleFixedDigitPasscodeEntryField : UIView
- (void)passcodeVisible;
- (void)passcodeNotVisible;
@end

@interface SBLockScreenManager : NSObject
+ (id)sharedInstance;
- (BOOL)isLockScreenVisible;
- (BOOL)isUILocked;
- (BOOL)unlockUIFromSource:(int)arg1 withOptions:(id)arg2;
- (void)attemptUnlockWithPasscode:(id)arg1 finishUIUnlock:(BOOL)arg2 completion:(id)arg3;
-(void)setPasscodeVisible:(BOOL)arg1 animated:(BOOL)arg2;
-(BOOL)_isPasscodeVisible;
- (void)showMacPass;
@end
