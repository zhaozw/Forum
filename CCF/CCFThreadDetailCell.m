//
//  CCFThreadDetailCell.m
//  CCF
//
//  Created by 迪远 王 on 16/1/2.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "CCFThreadDetailCell.h"
#import "UrlBuilder.h"
#import "Post.h"
#import "UrlBuilder.h"
#import "ForumCoreDataManager.h"
#import "UserEntry+CoreDataProperties.h"
#import <UIImageView+WebCache.h>
#import "CCFNSAttributedStringBuilder.h"


@interface CCFThreadDetailCell (){
    NSURL *baseURL;
    
    // private
    NSURL *lastActionLink;
    NSMutableSet *mediaPlayers;
    NSIndexPath * currentPath;
    ForumCoreDataManager *coreDateManager;
    
    BOOL _needsAdjustInsetsOnLayout;
    
    UIImage * defaultAvatar;
    
    NSMutableArray<UserEntry*> * cacheUsers;
    NSMutableDictionary * avatarCache;
    
}
@end


@implementation CCFThreadDetailCell

@synthesize lastActionLink;
@synthesize baseURL;

@synthesize htmlView = _htmlView;
@synthesize username = _username;
@synthesize louCeng = _louCeng;
@synthesize postTime = _postTime;
@synthesize avatarImage = _avatarImage;

- (void)awakeFromNib {

    self.htmlView.shouldDrawImages = NO;
    self.htmlView.shouldDrawLinks = NO;
    
    self.htmlView.delegate = self;
    
    self.htmlView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.htmlView.relayoutMask = DTAttributedTextContentViewRelayoutOnHeightChanged | DTAttributedTextContentViewRelayoutOnWidthChanged;

    
    if (defaultAvatar == nil) {
        defaultAvatar = [UIImage imageNamed:@"logo.jpg"];
    }
    
    avatarCache = [NSMutableDictionary dictionary];
    
    coreDateManager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeUser];
    if (cacheUsers == nil) {
        cacheUsers = [[coreDateManager selectData:^NSPredicate *{
            return [NSPredicate predicateWithFormat:@"userID > %d", 0];
        }] copy];
    }
    
    for (UserEntry * user in cacheUsers) {
        [avatarCache setValue:user.userAvatar forKey:user.userID];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setPost:(Post *)newPost forIndexPath:(NSIndexPath *)indexPath{
    currentPath = indexPath;
    
    NSString * html = newPost.postContent;
    self.htmlView.attributedString = [self showHtml:html];
    
    self.username.text = newPost.postUserInfo.userName;
    self.louCeng.text = newPost.postLouCeng;
    self.postTime.text = newPost.postTime;
    
    NSString * avatar = newPost.postUserInfo.userAvatar;
    
    
    if (newPost.postUserInfo.userID != nil) {
        NSString * cacheAvatar = [avatarCache objectForKey:newPost.postUserInfo.userID];
        
        if (cacheAvatar == nil) {
            
            [coreDateManager insertOneData:^(id src) {
                
                UserEntry * user =(UserEntry *)src;
                
                user.userID = newPost.postUserInfo.userID;
                
                NSString * avatar = newPost.postUserInfo.userAvatar;
                user.userAvatar = avatar == nil ? @"defaultAvatar" : avatar;
            }];
            
            // 添加到Cache中
            [avatarCache setValue:avatar == nil ? @"defaultAvatar": avatar forKey:newPost.postUserInfo.userID];
        }
    } else{
        [self.avatarImage setImage:defaultAvatar];
        return;
    }

    
    if (avatar == nil) {
        
        [self.avatarImage setImage:defaultAvatar];
        
    } else{
        
        NSURL * url = [UrlBuilder buildAvatarURL:avatar];

        [self.avatarImage sd_setImageWithURL:url placeholderImage:defaultAvatar];

    }
    
    
}


- (NSAttributedString *)showHtml:(NSString *)html{
    CGSize maxImageSize = CGSizeMake(self.window.bounds.size.width - 20.0, self.window.bounds.size.height - 20.0);
    CCFNSAttributedStringBuilder * builder = [[CCFNSAttributedStringBuilder alloc] init];
    return [builder buildNSAttributedString:html withImageSize:maxImageSize];
}

//#pragma mark DTAttributedTextContentViewDelegate
-(void)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView willDrawLayoutFrame:(DTCoreTextLayoutFrame *)layoutFrame inContext:(CGContextRef)context{
    
    
//    CGSize size = [attributedTextContentView suggestedFrameSizeToFitEntireStringConstraintedToWidth:layoutFrame.frame.size.width];
//    
//    CGRect frame = self.htmlView.frame;
//    frame.size.height = size.height;
//    self.htmlView.frame = frame;
    
    [self.detailDelegate relayoutContentHeigt:currentPath with:CGRectGetHeight(layoutFrame.frame) + 70];
}



#pragma mark Custom Views on Text

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttributedString:(NSAttributedString *)string frame:(CGRect)frame
{
    NSDictionary *attributes = [string attributesAtIndex:0 effectiveRange:NULL];
    
    NSURL *URL = [attributes objectForKey:DTLinkAttribute];
    NSString *identifier = [attributes objectForKey:DTGUIDAttribute];
    
    
    DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:frame];
    button.URL = URL;
    button.minimumHitSize = CGSizeMake(25, 25); // adjusts it's bounds so that button is always large enough
    button.GUID = identifier;
    
    // get image with normal link text
    UIImage *normalImage = [attributedTextContentView contentImageWithBounds:frame options:DTCoreTextLayoutFrameDrawingDefault];
    [button setImage:normalImage forState:UIControlStateNormal];
    
    // get image for highlighted link text
    UIImage *highlightImage = [attributedTextContentView contentImageWithBounds:frame options:DTCoreTextLayoutFrameDrawingDrawLinksHighlighted];
    [button setImage:highlightImage forState:UIControlStateHighlighted];
    
    // use normal push action for opening URL
    [button addTarget:self action:@selector(linkPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    // demonstrate combination with long press
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(linkLongPressed:)];
    [button addGestureRecognizer:longPress];
    
    return button;
}

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame{
    if ([attachment isKindOfClass:[DTImageTextAttachment class]])
    {
        // if the attachment has a hyperlinkURL then this is currently ignored
        DTLazyImageView *imageView = [[DTLazyImageView alloc] initWithFrame:frame];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.delegate = self;
        
        // sets the image if there is one
        //imageView.image = [(DTImageTextAttachment *)attachment image];
        
        [imageView sd_setImageWithURL:[attachment contentURL] placeholderImage:nil];
        
        // url for deferred loading
        imageView.url = attachment.contentURL;
        
        // if there is a hyperlink then add a link button on top of this image
        if (attachment.hyperLinkURL)
        {
            // NOTE: this is a hack, you probably want to use your own image view and touch handling
            // also, this treats an image with a hyperlink by itself because we don't have the GUID of the link parts
            imageView.userInteractionEnabled = YES;
            
            DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:imageView.bounds];
            button.URL = attachment.hyperLinkURL;
            button.minimumHitSize = CGSizeMake(25, 25); // adjusts it's bounds so that button is always large enough
            button.GUID = attachment.hyperLinkGUID;
            
            // use normal push action for opening URL
            [button addTarget:self action:@selector(linkPushed:) forControlEvents:UIControlEventTouchUpInside];
            
            // demonstrate combination with long press
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(linkLongPressed:)];
            [button addGestureRecognizer:longPress];
            
            [imageView addSubview:button];
        }
        
        return imageView;
    }
    else if ([attachment isKindOfClass:[DTIframeTextAttachment class]])
    {
        DTWebVideoView *videoView = [[DTWebVideoView alloc] initWithFrame:frame];
        videoView.attachment = attachment;
        
        return videoView;
    }
    else if ([attachment isKindOfClass:[DTObjectTextAttachment class]])
    {
        // somecolorparameter has a HTML color
        NSString *colorName = [attachment.attributes objectForKey:@"somecolorparameter"];
        UIColor *someColor = DTColorCreateWithHTMLName(colorName);
        
        UIView *someView = [[UIView alloc] initWithFrame:frame];
        someView.backgroundColor = someColor;
        someView.layer.borderWidth = 1;
        someView.layer.borderColor = [UIColor blackColor].CGColor;
        
        someView.accessibilityLabel = colorName;
        someView.isAccessibilityElement = YES;
        
        return someView;
    }
    
    return nil;
}

- (BOOL)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView shouldDrawBackgroundForTextBlock:(DTTextBlock *)textBlock frame:(CGRect)frame context:(CGContextRef)context forLayoutFrame:(DTCoreTextLayoutFrame *)layoutFrame
{
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(frame,1,1) cornerRadius:1];
    
    CGColorRef color = [[UIColor colorWithRed:246/255.0 green:246/255.0 blue:248/255.0 alpha:1] CGColor];
    if (color)
    {
        CGContextSetFillColorWithColor(context, color);
        CGContextAddPath(context, [roundedRect CGPath]);
        CGContextFillPath(context);
        
        CGContextAddPath(context, [roundedRect CGPath]);
        CGContextSetRGBStrokeColor(context, 207/255.0, 207/255.0, 209/255.0, 1);
        CGContextStrokePath(context);
        return NO;
    }
    
    return YES; // draw standard background
}


#pragma mark - DTLazyImageViewDelegate

- (void)lazyImageView:(DTLazyImageView *)lazyImageView didChangeImageSize:(CGSize)size {
    NSURL *url = lazyImageView.url;
    CGSize imageSize = size;
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"contentURL == %@", url];
    
    BOOL didUpdate = NO;
    
    // update all attachments that matchin this URL (possibly multiple images with same size)
    for (DTTextAttachment *oneAttachment in [self.htmlView.layoutFrame textAttachmentsWithPredicate:pred])
    {
        // update attachments that have no original size, that also sets the display size
        if (CGSizeEqualToSize(oneAttachment.originalSize, CGSizeZero))
        {
            oneAttachment.originalSize = imageSize;
            
            didUpdate = YES;
        }
    }
    
    if (didUpdate)
    {
        // layout might have changed due to image sizes
        [self.htmlView relayoutText];
    }
}

#pragma mark Actions

- (void)linkPushed:(DTLinkButton *)button
{
    NSURL *URL = button.URL;
    
    if ([[UIApplication sharedApplication] canOpenURL:[URL absoluteURL]])
    {
        [[UIApplication sharedApplication] openURL:[URL absoluteURL]];
    }
    else
    {
        if (![URL host] && ![URL path])
        {
            
            // possibly a local anchor link
//            NSString *fragment = [URL fragment];
            
//            if (fragment)
//            {
//                [self.htmlView scrollToAnchorNamed:fragment animated:NO];
//            }
        }
    }
}


- (void)linkLongPressed:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        DTLinkButton *button = (id)[gesture view];
        button.highlighted = NO;
        self.lastActionLink = button.URL;
        
        if ([[UIApplication sharedApplication] canOpenURL:[button.URL absoluteURL]])
        {
//            UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:[[button.URL absoluteURL] description] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open in Safari", nil];
//            [action showFromRect:button.frame inView:button.superview animated:YES];
        }
    }
}

- (void)handleTap:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateRecognized)
    {
        CGPoint location = [gesture locationInView:self.htmlView];
        NSUInteger tappedIndex = [self.htmlView closestCursorIndexToPoint:location];
        
        NSString *plainText = [self.htmlView.attributedString string];
        NSString *tappedChar = [plainText substringWithRange:NSMakeRange(tappedIndex, 1)];
        
        __block NSRange wordRange = NSMakeRange(0, 0);
        
        [plainText enumerateSubstringsInRange:NSMakeRange(0, [plainText length]) options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
            if (NSLocationInRange(tappedIndex, enclosingRange))
            {
                *stop = YES;
                wordRange = substringRange;
            }
        }];
        
        NSString *word = [plainText substringWithRange:wordRange];
        NSLog(@"%lu: '%@' word: '%@'", (unsigned long)tappedIndex, tappedChar, word);
    }
}

-(CGSize)sizeThatFits:(CGSize)size{
    return CGSizeMake(size.width, self.frame.size.height);
}
- (IBAction)showUserProfile:(UIButton *)sender {
    [self.showUserProfileDelegate showUserProfile:currentPath];
}
@end
