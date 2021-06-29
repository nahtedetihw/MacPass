@interface LIPImageChooseCell : UITableViewCell
@end

%hook LIPImageChooseCell
- (void)didMoveToSuperview {
    %orig;
    UIImageView *previewImage = MSHookIvar<UIImageView *>(self, "previewImage");
    previewImage.layer.masksToBounds = YES;
    previewImage.center = CGPointMake(previewImage.center.x-10,previewImage.center.y);
    previewImage.layer.cornerRadius = previewImage.frame.size.height/2;
}
%end
