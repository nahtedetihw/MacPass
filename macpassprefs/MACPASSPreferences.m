#include "MACPASSPreferences.h"
#import <AudioToolbox/AudioServices.h>
#import <Cephei/HBPreferences.h>

UIBarButtonItem *respringButtonItem;
UIBarButtonItem *changelogButtonItem;
UIBarButtonItem *twitterButtonItem;
UIBarButtonItem *paypalButtonItem;
UIViewController *popController;
UIColor *backgroundDynamicColor;
UIColor *tintDynamicColor;
_UIBackdropView *backdropViewRespring;
UIView *blackViewRespring;

@implementation MACPASSPreferencesListController
@synthesize killButton;
@synthesize versionArray;

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
    }

    return _specifiers;
}

- (instancetype)init {

    self = [super init];

    if (self) {
        
        backgroundDynamicColor = [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *traitCollection) {
            BOOL isDarkMode = traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
            BOOL isLightMode = traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight;
            BOOL isUnspecified = traitCollection.userInterfaceStyle == UIUserInterfaceStyleUnspecified;
            if (isDarkMode) {
                return [UIColor colorWithRed:147/255.0f green:162/255.0f blue:167/255.0f alpha:1.0f];
            }
            if (isLightMode) {
                return [UIColor colorWithRed:63/255.0f green:72/255.0f blue:83/255.0f alpha:1.0f];
            }
            if (isUnspecified) {
                return [UIColor colorWithRed:147/255.0f green:162/255.0f blue:167/255.0f alpha:1.0f];
            }
            return [UIColor colorWithRed:147/255.0f green:162/255.0f blue:167/255.0f alpha:1.0f];
        }];

        tintDynamicColor = [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *traitCollection) {
            BOOL isDarkMode = traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
            BOOL isLightMode = traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight;
            BOOL isUnspecified = traitCollection.userInterfaceStyle == UIUserInterfaceStyleUnspecified;
            if (isDarkMode) {
                return [UIColor colorWithRed:83/255.0f green:95/255.0f blue:109/255.0f alpha:1.0f];
            }
            if (isLightMode) {
                return [UIColor colorWithRed:97/255.0f green:120/255.0f blue:132/255.0f alpha:1.0f];
            }
            if (isUnspecified) {
                return [UIColor colorWithRed:83/255.0f green:95/255.0f blue:109/255.0f alpha:1.0f];
            }
            return [UIColor colorWithRed:83/255.0f green:95/255.0f blue:109/255.0f alpha:1.0f];
        }];
        
        MACPASSAppearanceSettings *appearanceSettings = [[MACPASSAppearanceSettings alloc] init];
        self.hb_appearanceSettings = appearanceSettings;
        UIButton *respringButton =  [UIButton buttonWithType:UIButtonTypeCustom];
        respringButton.frame = CGRectMake(0,0,30,30);
        respringButton.layer.cornerRadius = respringButton.frame.size.height / 2;
        respringButton.layer.masksToBounds = YES;
        respringButton.backgroundColor = backgroundDynamicColor;
        [respringButton setImage:[[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/macpassprefs.bundle/CHECKMARK.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [respringButton addTarget:self action:@selector(apply:) forControlEvents:UIControlEventTouchUpInside];
        respringButton.tintColor = tintDynamicColor;
        
        respringButtonItem = [[UIBarButtonItem alloc] initWithCustomView:respringButton];
        
        UIButton *changelogButton =  [UIButton buttonWithType:UIButtonTypeCustom];
        changelogButton.frame = CGRectMake(0,0,30,30);
        changelogButton.layer.cornerRadius = changelogButton.frame.size.height / 2;
        changelogButton.layer.masksToBounds = YES;
        changelogButton.backgroundColor = backgroundDynamicColor;
        [changelogButton setImage:[[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/macpassprefs.bundle/CHANGELOG.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [changelogButton addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
        changelogButton.tintColor = tintDynamicColor;
        
        changelogButtonItem = [[UIBarButtonItem alloc] initWithCustomView:changelogButton];
        
        UIButton *twitterButton =  [UIButton buttonWithType:UIButtonTypeCustom];
        twitterButton.frame = CGRectMake(0,0,30,30);
        twitterButton.layer.cornerRadius = twitterButton.frame.size.height / 2;
        twitterButton.layer.masksToBounds = YES;
        twitterButton.backgroundColor = backgroundDynamicColor;
        [twitterButton setImage:[[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/macpassprefs.bundle/TWITTER.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [twitterButton addTarget:self action:@selector(twitter:) forControlEvents:UIControlEventTouchUpInside];
        twitterButton.tintColor = tintDynamicColor;
        
        twitterButtonItem = [[UIBarButtonItem alloc] initWithCustomView:twitterButton];
        
        UIButton *paypalButton =  [UIButton buttonWithType:UIButtonTypeCustom];
        paypalButton.frame = CGRectMake(0,0,30,30);
        paypalButton.layer.cornerRadius = paypalButton.frame.size.height / 2;
        paypalButton.layer.masksToBounds = YES;
        paypalButton.backgroundColor = backgroundDynamicColor;
        [paypalButton setImage:[[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/macpassprefs.bundle/PAYPAL.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [paypalButton addTarget:self action:@selector(paypal:) forControlEvents:UIControlEventTouchUpInside];
        paypalButton.tintColor = tintDynamicColor;
        
        paypalButtonItem = [[UIBarButtonItem alloc] initWithCustomView:paypalButton];
        
        NSArray *rightButtons;
        rightButtons = @[respringButtonItem, changelogButtonItem, twitterButtonItem, paypalButtonItem];
        self.navigationItem.rightBarButtonItems = rightButtons;
        self.navigationItem.titleView = [UIView new];
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.text = @"";
        self.titleLabel.textColor = tintDynamicColor;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.navigationItem.titleView addSubview:self.titleLabel];

        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        self.iconView.contentMode = UIViewContentModeScaleAspectFit;
        self.iconView.image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/macpassprefs.bundle/headericon.png"];
        self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
        self.iconView.alpha = 0.0;
        [self.navigationItem.titleView addSubview:self.iconView];

        [NSLayoutConstraint activateConstraints:@[
            [self.titleLabel.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
            [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
            [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
            [self.titleLabel.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
            [self.iconView.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
            [self.iconView.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
            [self.iconView.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
            [self.iconView.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
        ]];

    }

    return self;

}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {

    return UIModalPresentationNone;
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    CGRect frame = self.table.bounds;
    frame.origin.y = -frame.size.height;

    self.navigationController.navigationController.navigationBar.barTintColor = [UIColor labelColor];
    [self.navigationController.navigationController.navigationBar setShadowImage: [UIImage new]];
    self.navigationController.navigationController.navigationBar.tintColor = [UIColor labelColor];
    self.navigationController.navigationController.navigationBar.translucent = NO;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.tableHeaderView = self.headerView;
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (void)viewDidLoad {

    [super viewDidLoad];
    
    _UIBackdropViewSettings *settings = [_UIBackdropViewSettings settingsForStyle:2];

    backdropViewRespring = [[_UIBackdropView alloc] initWithSettings:settings];
    backdropViewRespring.layer.masksToBounds = YES;
    backdropViewRespring.clipsToBounds = YES;
    backdropViewRespring.frame = [UIScreen mainScreen].bounds;
    backdropViewRespring.alpha = 0;
    [[[UIApplication sharedApplication] keyWindow] addSubview:backdropViewRespring];
    
    blackViewRespring = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    blackViewRespring.layer.masksToBounds = YES;
    blackViewRespring.clipsToBounds = YES;
    blackViewRespring.alpha = 0;
    blackViewRespring.backgroundColor = [UIColor blackColor];
    [[[UIApplication sharedApplication] keyWindow] addSubview:blackViewRespring];

    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.table.bounds.size.width,300)];
    
    self.artworkView = [[UIImageView alloc] initWithFrame:CGRectMake(self.headerView.frame.origin.x, self.headerView.frame.origin.y, self.headerView.frame.size.width, self.headerView.frame.size.height)];
    self.artworkView.contentMode = UIViewContentModeScaleAspectFit;
    self.artworkView.image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/macpassprefs.bundle/banner.png"];
    self.artworkView.layer.masksToBounds = YES;
    
    [self.headerView insertSubview:self.artworkView atIndex:0];
    
    self.artworkView.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint activateConstraints:@[
        [self.artworkView.topAnchor constraintEqualToAnchor:self.headerView.topAnchor],
        [self.artworkView.leadingAnchor constraintEqualToAnchor:self.headerView.leadingAnchor],
        [self.artworkView.trailingAnchor constraintEqualToAnchor:self.headerView.trailingAnchor],
        [self.artworkView.bottomAnchor constraintEqualToAnchor:self.headerView.bottomAnchor],
    ]];
    _table.tableHeaderView = self.headerView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat offsetY = scrollView.contentOffset.y;

    if (offsetY > 200) {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 1.0;
            self.titleLabel.alpha = 0.0;
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 0.0;
            self.titleLabel.alpha = 1.0;
        }];
    }

    if (offsetY > 0) offsetY = 0;
    self.artworkView.frame = CGRectMake(self.headerView.frame.origin.x, self.headerView.frame.origin.y, self.headerView.frame.size.width, 200 - offsetY);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.navigationController.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
}

- (void)apply:(UIButton *)sender {
    
    popController = [[UIViewController alloc] init];
    popController.modalPresentationStyle = UIModalPresentationPopover;
    popController.preferredContentSize = CGSizeMake(200,130);
    UILabel *respringLabel = [[UILabel alloc] init];
    respringLabel.frame = CGRectMake(20, 20, 160, 60);
    respringLabel.numberOfLines = 2;
    respringLabel.textAlignment = NSTextAlignmentCenter;
    respringLabel.adjustsFontSizeToFitWidth = YES;
    respringLabel.font = [UIFont boldSystemFontOfSize:20];
    respringLabel.textColor = tintDynamicColor;
    respringLabel.text = @"Are you sure you want to respring?";
    [popController.view addSubview:respringLabel];
    
    UIButton *yesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [yesButton addTarget:self
                  action:@selector(handleYesGesture:)
     forControlEvents:UIControlEventTouchUpInside];
    [yesButton setTitle:@"Yes" forState:UIControlStateNormal];
    yesButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [yesButton setTitleColor:tintDynamicColor forState:UIControlStateNormal];
    yesButton.frame = CGRectMake(100, 100, 100, 30);
    [popController.view addSubview:yesButton];
    
    UIButton *noButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [noButton addTarget:self
                  action:@selector(handleNoGesture:)
     forControlEvents:UIControlEventTouchUpInside];
    [noButton setTitle:@"No" forState:UIControlStateNormal];
    noButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [noButton setTitleColor:tintDynamicColor forState:UIControlStateNormal];
    noButton.frame = CGRectMake(0, 100, 100, 30);
    [popController.view addSubview:noButton];
     
    UIPopoverPresentationController *popover = popController.popoverPresentationController;
    popover.delegate = self;
    //[popover _setBackgroundBlurDisabled:YES];
    popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
    popover.barButtonItem = respringButtonItem;
    popover.backgroundColor = backgroundDynamicColor;
    
    [self presentViewController:popController animated:YES completion:nil];
    
    AudioServicesPlaySystemSound(1519);

}

- (void)showMenu:(id)sender {
    
    AudioServicesPlaySystemSound(1519);

    self.changelogController = [[OBWelcomeController alloc] initWithTitle:@"MacPass" detailText:@"1.2" icon:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/macpassprefs.bundle/changelogControllerIcon.png"]];

    [self.changelogController addBulletedListItemWithTitle:@"Auto Unlock" description:@"Fixed issues with auto unlock." image:[UIImage systemImageNamed:@"1.circle.fill"]];
    
    [self.changelogController addBulletedListItemWithTitle:@"Profile Picture" description:@"Added an option to remove Profile Picture." image:[UIImage systemImageNamed:@"2.circle.fill"]];
    
    [self.changelogController addBulletedListItemWithTitle:@"Background Blur" description:@"Added an option to adjust the blur opacity of the blur on the background." image:[UIImage systemImageNamed:@"3.circle.fill"]];
    
    [self.changelogController addBulletedListItemWithTitle:@"Passcode" description:@"Added an option to define the number of characters in your passcode to prevent disabling." image:[UIImage systemImageNamed:@"4.circle.fill"]];

    _UIBackdropViewSettings *settings = [_UIBackdropViewSettings settingsForStyle:2];

    _UIBackdropView *backdropView = [[_UIBackdropView alloc] initWithSettings:settings];
    backdropView.layer.masksToBounds = YES;
    backdropView.clipsToBounds = YES;
    backdropView.frame = self.changelogController.viewIfLoaded.frame;
    [self.changelogController.viewIfLoaded insertSubview:backdropView atIndex:0];
    
    backdropView.translatesAutoresizingMaskIntoConstraints = false;
    [backdropView.bottomAnchor constraintEqualToAnchor:self.changelogController.viewIfLoaded.bottomAnchor constant:0].active = YES;
    [backdropView.leftAnchor constraintEqualToAnchor:self.changelogController.viewIfLoaded.leftAnchor constant:0].active = YES;
    [backdropView.rightAnchor constraintEqualToAnchor:self.changelogController.viewIfLoaded.rightAnchor constant:0].active = YES;
    [backdropView.topAnchor constraintEqualToAnchor:self.changelogController.viewIfLoaded.topAnchor constant:0].active = YES;

    self.changelogController.viewIfLoaded.backgroundColor = [UIColor clearColor];
    self.changelogController.modalPresentationStyle = UIModalPresentationPageSheet;
    self.changelogController.modalInPresentation = NO;
    [self presentViewController:self.changelogController animated:YES completion:nil];
}
- (void)dismissVC {
    [self.changelogController dismissViewControllerAnimated:YES completion:nil];
}

- (void)twitter:(id)sender {
    AudioServicesPlaySystemSound(1519);
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/EthanWhited"] options:@{} completionHandler:nil];
}

- (void)paypal:(id)sender {
    AudioServicesPlaySystemSound(1519);
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://paypal.me/nahtedetihw"] options:@{} completionHandler:nil];
}

- (void)handleYesGesture:(UIButton *)sender {
    AudioServicesPlaySystemSound(1519);

    [popController dismissViewControllerAnimated:YES completion:nil];

    [UIView animateWithDuration:1.0 animations:^{
        backdropViewRespring.alpha = 1;
    }];
    
    [UIView animateWithDuration:2.0 animations:^{
        blackViewRespring.alpha = 1;
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    pid_t pid;
    const char* args[] = {"sbreload", NULL};
    posix_spawn(&pid, "/usr/bin/sbreload", NULL, NULL, (char* const*)args, NULL);
    });
}

- (void)handleNoGesture:(UIButton *)sender {
    AudioServicesPlaySystemSound(1519);
    [popController dismissViewControllerAnimated:YES completion:nil];
}

- (void)chooseUsername {
    HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier:@"com.nahtedetihw.macpassprefs"];
    
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"Username"
        message:@"What would you like your username to be?"
        preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
        handler:^(UIAlertAction * action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }
    ];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Username";
        textField.keyboardType = UIKeyboardTypeDefault;
    }];
    
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
        handler:^(UIAlertAction * action){
            NSString *name = [(UITextField *)alert.textFields[0] text];
            
            if (![name isEqual:@""]) {
                [preferences setObject:name forKey:@"usernameString"];
                
                UIAlertController* alert3 = [UIAlertController alertControllerWithTitle:@"Username set!"
                                                                                message:[NSString stringWithFormat:@"%@, your username was successfully set.", name] preferredStyle:UIAlertControllerStyleAlert];
                [alert3 addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                    [alert3 dismissViewControllerAnimated:YES completion:^{
                    }];
                }]];
                [self presentViewController:alert3 animated:YES completion:nil];
            }
            
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
    [alert addAction:cancel];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
    
    AudioServicesPlaySystemSound(1519);
}

- (void)removePicture {
    HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier:@"com.nahtedetihw.macpassprefs"];
    [preferences removeObjectForKey:@"profilePicture"];
    
    UIApplication *app = [UIApplication sharedApplication];
    [app performSelector:@selector(suspend)];
    [NSThread sleepForTimeInterval:1.0];
    exit(0); 
    
    AudioServicesPlaySystemSound(1519);
}

@end



@implementation MACPASSAppearanceSettings: HBAppearanceSettings

- (UIColor *)tintColor {

    return tintDynamicColor;

}

- (UIColor *)tableViewCellSeparatorColor {

    return [UIColor clearColor];

}


@end
