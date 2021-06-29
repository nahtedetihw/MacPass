#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <CepheiPrefs/HBRootListController.h>
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <spawn.h>
#import <SparkColourPickerUtils.h>
#import <SparkColourPickerView.h>
#import "libimagepicker.h"

@interface UIPopoverPresentationController (Private)
@property (assign,setter=_setPopoverBackgroundStyle:,nonatomic) long long _popoverBackgroundStyle;
@property (assign,setter=_setBackgroundBlurDisabled:,nonatomic) BOOL _backgroundBlurDisabled;
@end

@interface OBButtonTray : UIView
@property (nonatomic,retain) UIVisualEffectView * effectView;
- (void)addButton:(id)arg1;
- (void)addCaptionText:(id)arg1;;
@end

@interface OBBoldTrayButton : UIButton
- (void)setTitle:(id)arg1 forState:(unsigned long long)arg2;
+ (id)buttonWithType:(long long)arg1;
@end

@interface OBWelcomeController : UIViewController
@property (nonatomic, retain) UIView *viewIfLoaded;
@property (nonatomic, strong) UIColor *backgroundColor;
- (OBButtonTray *)buttonTray;
- (id)initWithTitle:(id)arg1 detailText:(id)arg2 icon:(id)arg3;
- (void)addBulletedListItemWithTitle:(id)arg1 description:(id)arg2 image:(id)arg3;
@end

@interface _UIBackdropView : UIView
-(id)initWithFrame:(CGRect)arg1 autosizesToFitSuperview:(BOOL)arg2 settings:(id)arg3 ;
@property (assign,nonatomic) BOOL blurRadiusSetOnce;
@property (assign,nonatomic) double _blurRadius;
@property (nonatomic,copy) NSString * _blurQuality;
-(id)initWithSettings:(id)arg1 ;
@end

@interface _UIBackdropViewSettings : NSObject
+(id)settingsForStyle:(long long)arg1 ;
@end

@interface MACPASSPreferencesListController : PSListController<UIPopoverPresentationControllerDelegate> {

    UITableView * _table;

}
@property (nonatomic, strong) UIImageView *artworkView;
@property (nonatomic, strong) UIImageView *artworkView2;
@property (nonatomic, retain) UIBarButtonItem *killButton;
@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UIImageView *iconView;
@property (nonatomic, retain) NSArray *versionArray;
@property (nonatomic, retain) OBWelcomeController *changelogController;
- (void)apply:(UIButton *)sender;
- (void)showMenu:(UIButton *)sender;
- (void)twitter:(UIButton *)sender;
- (void)paypal:(UIButton *)sender;
- (void)handleYesGesture:(UIButton *)sender;
- (void)handleNoGesture:(UIButton *)sender;
- (void)chooseUsername;
@end

@interface MACPASSAppearanceSettings: HBAppearanceSettings
@end
