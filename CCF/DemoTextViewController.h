//
//  DemoTextViewController.h
//  DTCoreText
//
//  Created by Oliver Drobnik on 1/9/11.
//  Copyright 2011 Drobnik.com. All rights reserved.
//

#import "DTAttributedTextView.h"
#import "DTLazyImageView.h"

@interface DemoTextViewController : UIViewController < DTAttributedTextContentViewDelegate, DTLazyImageViewDelegate>

@property (nonatomic, strong) NSURL *lastActionLink;

@property (nonatomic, strong) NSURL *baseURL;


@end
