//
//  CCFNSAttributedStringBuilder.m
//  CCF
//
//  Created by WDY on 16/4/21.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "CCFNSAttributedStringBuilder.h"

@implementation CCFNSAttributedStringBuilder

-(NSAttributedString *)buildNSAttributedString:(NSString *)html withImageSize:(CGSize)imageSize{
    NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
    
    // Create attributed string from HTML
    CGSize maxImageSize = imageSize;//CGSizeMake(self.window.bounds.size.width - 20.0, self.window.bounds.size.height - 20.0);
    
    // example for setting a willFlushCallback, that gets called before elements are written to the generated attributed string
    void (^callBackBlock)(DTHTMLElement *element) = ^(DTHTMLElement *element) {
        
        // the block is being called for an entire paragraph, so we check the individual elements
        
        for (DTHTMLElement *oneChildElement in element.childNodes)
        {
            // if an element is larger than twice the font size put it in it's own block
            if (oneChildElement.displayStyle == DTHTMLElementDisplayStyleInline && oneChildElement.textAttachment.displaySize.height > 2.0 * oneChildElement.fontDescriptor.pointSize)
            {
                oneChildElement.displayStyle = DTHTMLElementDisplayStyleBlock;
                oneChildElement.paragraphStyle.minimumLineHeight = element.textAttachment.displaySize.height;
                oneChildElement.paragraphStyle.maximumLineHeight = element.textAttachment.displaySize.height;
            }
        }
    };
    
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithFloat:1.4], NSTextSizeMultiplierDocumentOption,
                                    [NSValue valueWithCGSize:maxImageSize], DTMaxImageSize,
                                    @"Helvetica Neue", DTDefaultFontFamily,
                                    @"gray", DTDefaultLinkColor,
                                    @"blue", DTDefaultLinkHighlightColor,
                                    @(1.2), DTDefaultLineHeightMultiplier,
                                    callBackBlock,DTWillFlushBlockCallBack, nil];
    
    
    [options setObject:[NSURL URLWithString:@"https://bbs.et8.net/bbs/"] forKey:NSBaseURLDocumentOption];
    
    NSAttributedString *string = [[NSAttributedString alloc] initWithHTMLData:data options:options documentAttributes:NULL];
    
    
    
    return string;
}
@end
