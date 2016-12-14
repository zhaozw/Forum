//
// Created by WDY on 2016/12/8.
// Copyright (c) 2016 andforce. All rights reserved.
//

#import "DRLForumHtmlParser.h"

#import "IGXMLNode+Children.h"
#import <IGHTMLQuery.h>

#import "ForumEntry+CoreDataClass.h"
#import "ForumCoreDataManager.h"
#import "NSUserDefaults+Extensions.h"
#import "NSString+Extensions.h"

#import "IGHTMLDocument+QueryNode.h"
#import "IGXMLNode+Children.h"
#import "AppDelegate.h"

@implementation DRLForumHtmlParser {

}

// private
- (NSString *)postMessages:(NSString *)html {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    
    IGXMLNodeSet *postMessages = [document queryWithXPath:@"//*[@id='posts']/div[*]/div/div/div/table/tr[2]/td[2]/div"];
    if (postMessages.count == 0) {
        postMessages = [document queryWithXPath:@"//*[@id='posts']/div/div/div/table/tr[2]/td[2]/div"];
    }
    NSMutableString * messages = [NSMutableString string];
    
    for (IGXMLNode *node in postMessages) {
        [messages appendString:node.text];
    }
    return [messages copy];
}


// private
- (NSString *)parseAjaxLastPost:(NSString *)html {
    NSString *searchText = [html stringWithRegular:@"var ajax_last_post = \\d+;" andChild:@"\\d+"];
    return searchText;
}


// private
- (NSMutableArray<Post *> *)parseShowThreadPosts:(IGHTMLDocument *)document {
    
    NSMutableArray<Post *> *posts = [NSMutableArray array];
    
    // 发帖的整个楼层 包含UserInfo 和 发帖内容
    IGXMLNodeSet *postMessages = [document queryWithXPath:@"//*[@id='posts']/div[*]"];
    
    for (IGXMLNode *node in postMessages) {
        
        // 重新构建Document 方便再次使用xPath 查询
        IGXMLDocument *postDocument = [[IGHTMLDocument alloc] initWithHTMLString:node.html error:nil];
        
        //======= Post Conent======//
        Post *post = [[Post alloc] init];
        
        // postId
        IGXMLNode * postIdNode = [postDocument queryWithXPath:@"/html/body/div/div/div/div/table/tr[2]/td[1]/div[1]"].firstObject;
        if (postIdNode == nil) {
            // 很蛋疼，DRL最后一楼，xPath跟前面的楼层不一样
            postIdNode = [postDocument queryWithXPath:@"/html/body/div/div/div/table/tr[2]/td[1]/div[1]"].firstObject;
        }
        
        NSString *postId = [[[postIdNode attribute:@"id"] componentsSeparatedByString:@"postmenu_"] lastObject];
        post.postID = postId;
        
        // post Time
        IGXMLNode *timeNode = [postDocument queryWithXPath:@"/html/body/div/div/div/div/table/tr[1]/td[1]"].firstObject;
        if (timeNode == nil || timeNode.html.length < 50) {
            // 很蛋疼，DRL最后一楼，xPath跟前面的楼层不一样
            timeNode = [postDocument queryWithXPath:@"/html/body/div/div/div/table/tr[1]/td[1]"].firstObject;
        }
        NSString * time = [[timeNode text] trim];
        post.postTime = [self timeForShort:time withFormat:@"MM-dd-yyyy, HH:mm"];
        //post.postTime = time;
        
        // post Louceng
        IGXMLNode * loucengNode = [postDocument queryWithXPath:@"/html/body/div/div/div/div/table/tr[1]/td[2]"].firstObject;
        if (loucengNode == nil) {
            // 很蛋疼，DRL最后一楼，xPath跟前面的楼层不一样
            loucengNode = [postDocument queryWithXPath:@"/html/body/div/div/div/table/tr[1]/td[2]"].firstObject;
        }
        NSString * louceng = [[loucengNode text] trim];
        post.postLouCeng = louceng;
        
        
        // post Content
        // 帖子内容 有三部分组成 1、message 2、attachments 3、edit note
        IGXMLNode * messageNode = [postDocument queryWithXPath:@"/html/body/div/div/div/div/table/tr[2]/td[2]/div[1]"].firstObject;
        if (messageNode == nil) {
            // 很蛋疼，DRL最后一楼，xPath跟前面的楼层不一样
            messageNode = [postDocument queryWithXPath:@"/html/body/div/div/div/table/tr[2]/td[2]/div"].firstObject;
        }
        NSString * message = [messageNode html];
        
        IGXMLNode * attchmentsNode = [postDocument queryWithXPath:@"/html/body/div/div/div/div/table/tr[2]/td[2]/div[2]"].firstObject;
        if (attchmentsNode == nil) {
            // 很蛋疼，DRL最后一楼，xPath跟前面的楼层不一样
            attchmentsNode = [postDocument queryWithXPath:@"/html/body/div/div/div/table/tr[2]/td[2]/div[2]"].firstObject;
        }
        NSString * attchments = [attchmentsNode html];
        
        IGXMLNode * editNoteNode = [postDocument queryWithXPath:@"/html/body/div/div/div/div/table/tr[2]/td[2]/div[3]"].firstObject;
        if (editNoteNode == nil) {
            // 很蛋疼，DRL最后一楼，xPath跟前面的楼层不一样
            editNoteNode = [postDocument queryWithXPath:@"/html/body/div/div/div/table/tr[2]/td[2]/div[3]"].firstObject;
        }
        NSString * editNote = [editNoteNode html];
        NSString * postContent = message;
        if (attchments != nil) {
            postContent = [postContent stringByAppendingString:attchments];
        }
        if (editNote != nil) {
            postContent = [postContent stringByAppendingString:editNote];
        }
        post.postContent = postContent;
        
        //=======User Info======//
        User * userInfo = [[User alloc] init];
        
        // user name
        NSString * userNameXPath = [NSString stringWithFormat:@"//*[@id='postmenu_%@']/a", postId];
        IGXMLNode * userNameNode = [postDocument queryWithXPath:userNameXPath].firstObject;
        NSString * userName = [[userNameNode text] trim];
        userInfo.userName = userName;
        
        // user id
        NSString * userId = [[userNameNode attribute:@"href"] stringWithRegular:@"\\d+"];
        userInfo.userID = userId;
        
        //*[@id="posts"]/div[*]/div/div/div/table/tr[2]/td[1]/div[4]/a/img
        //*[@id="posts"]/div[*]/div/div/div/table/tr[2]/td[1]/div[4]/a/img
        // user avatar                                          /html/body/div/div/div/table/tr[2]/td[1]/div[4]/a/img
        
        IGXMLNode * avatarNode = [postDocument queryWithXPath:@"/html/body/div/div/div/div/table/tr[2]/td[1]/div[2]/a/img"].firstObject;
        if (avatarNode == nil) {
            // /html/body/div/div/div/table/tr[2]/td[1]/div[2]/a/img
            avatarNode = [postDocument queryWithXPath:@"/html/body/div/div/div/table/tr[2]/td[1]/div[*]/a/img"].firstObject;
        }
        if (avatarNode == nil) {
            userInfo.userAvatar = @"/no_avatar.gif";;
        } else{
            NSString *avatar = [avatarNode attribute:@"src"];
            userInfo.userAvatar = [avatar componentsSeparatedByString:@"customavatars"].lastObject;
        }
        
        post.postUserInfo = userInfo;
        
        // 添加数据
        [posts addObject:post];
    }
    
    return posts;
}

// private 修改字体大小统一为2
-(NSString *) fixedFontSize:(NSString *) html{
    NSArray * fontSetString = [html arrayWithRegulat:@"<font size=\"\\d+\">"];
    
    NSString * fixFontSizeHTML= html;
    for (NSString * tmp in fontSetString) {
        fixFontSizeHTML = [fixFontSizeHTML stringByReplacingOccurrencesOfString:tmp withString:@"<font size=\"\2\">"];
    }
    return fixFontSizeHTML;
}

// private 修改链接
-(NSString *) fixedLink:(NSString *) html{
    // 去掉_http hxxp
    NSString * fuxkHttp = html;
    NSArray * httpArray = [html arrayWithRegulat:@"(_http|hxxp|_https|hxxps)://[\\w\\-_]+(\\.[\\w\\-_]+)+([\\w\\-\\.,@?^=%&amp;:/~\\+#]*[\\w\\-\\@?^=%&amp;/~\\+#])?"];
    NSString * httpPattern = @"<a href=\"%@\" target=\"_blank\">%@</a>";
    for (NSString * http in httpArray) {
        NSString * fixedHttp = [http stringByReplacingOccurrencesOfString:@"_http://" withString:@"http://"];
        fixedHttp = [fixedHttp stringByReplacingOccurrencesOfString:@"hxxp://" withString:@"http://"];
        fixedHttp = [fixedHttp stringByReplacingOccurrencesOfString:@"hxxps://" withString:@"https://"];
        fixedHttp = [fixedHttp stringByReplacingOccurrencesOfString:@"_https://" withString:@"https://"];
        
        NSString * patterned = [NSString stringWithFormat:httpPattern, fixedHttp, fixedHttp];
        fuxkHttp = [fuxkHttp stringByReplacingOccurrencesOfString:http withString:patterned];
        
    }
    return fuxkHttp;
}

// private
- (NSString *) fixedCodeBlodk:(NSString *)html{
    
    NSString *fixed = [html stringByReplacingOccurrencesOfString:@"<div style=\"margin:20px; margin-top:5px\">" withString:@"<div style=\"overflow-x: hidden\"><div style=\"margin:20px; margin-top:5px\">"];
    return fixed;
}

// private
- (NSString*) fixedImage:(NSString *)html{
    
    NSString *fixedImage = html;
    
    NSArray * images = [html arrayWithRegulat:@"<a href=\"attachment.php\\?attachmentid=\\d+&amp;stc=1\" target=\"_blank\"><img class=\"attach\" src=\"attachment.php\\?attachmentid=\\d+&amp;stc=1\" border=\"0\" alt=\"\" /></a>"];
    
    for (NSString * image in images) {
        NSString * imageSrc = [image stringWithRegular:@"<img class=\"attach\" src=\"attachment.php\\?attachmentid=\\d+&amp;stc=1\" border=\"0\" alt=\"\" />"];
        fixedImage = [fixedImage stringByReplacingOccurrencesOfString:image withString:imageSrc];
    }
    return fixedImage;
}

// private
- (NSString *) fixedQuote:(NSString *)html{

    NSString *result = [html stringByReplacingOccurrencesOfString:@"<div style=\"overflow: auto; height: 100px; padding: 2px;\" id=\"quote_d\">" withString:@"<div id=\"quote_d\">"];
    return result;
}

- (ViewThreadPage *)parseShowThreadWithHtml:(NSString *)html {
    
    
    NSString * fixedImage = [self fixedImage:html];
    
    NSString * fixFontSizeHTML = [self fixedFontSize:fixedImage];
    NSString * fixedClodeBlock = [self fixedCodeBlodk:fixFontSizeHTML];

    NSString * fixedQuoteHeight = [self fixedQuote:fixedClodeBlock];
    NSString * fixedHtml = [self fixedLink:fixedQuoteHeight];
    
    
    
    IGHTMLDocument *document = [[IGHTMLDocument alloc]initWithHTMLString:fixedHtml error:nil];
    
    ViewThreadPage * showThreadPage = [[ViewThreadPage alloc]init];
    // origin html
    showThreadPage.originalHtml = [self postMessages:fixedHtml];
    
    // forum Id
    NSString * forumId = [[fixedHtml stringWithRegular:@"<option value=\"\\d+\" class=\".*\" selected=\"selected\">" andChild:@"value=\"\\d+\""] stringWithRegular:@"\\d+"];
    showThreadPage.forumId = forumId;
    
    // token 【失败】
    NSString * securityToken = [self parseSecurityToken:html];
    showThreadPage.securityToken = securityToken;
    
    // ajax  【失败】
    NSString * ajaxLastPost = [self parseAjaxLastPost:html];
    showThreadPage.ajaxLastPost = ajaxLastPost;
    
    // all posts
    showThreadPage.postList = [self parseShowThreadPosts:document];
    
    // title
    IGXMLNode * titleNode = [document queryWithXPath:@"//*[@id='table1']/tr/td[1]/div/strong"].firstObject;
    
    if (titleNode != nil) {
        NSString * fixedTitle = [titleNode.text trim];
        if ([fixedTitle hasPrefix:@"【"]){
            fixedTitle = [fixedTitle stringByReplacingOccurrencesOfString:@"【" withString:@"["];
            fixedTitle = [fixedTitle stringByReplacingOccurrencesOfString:@"】" withString:@"]"];
        } else{
            fixedTitle = [@"讨论" stringByAppendingString:fixedTitle];
        }
        showThreadPage.threadTitle = fixedTitle;
    }



    // page number
    IGXMLNode * pageNumberNode = [document queryNodeWithXPath:@"/html/body/table/tr/td/div[2]/div/div/table[2]/tr/td[2]/div/table/tr/td[1]"];
    
    if (pageNumberNode == nil) {
        showThreadPage.totalPageCount = 1;
        showThreadPage.currentPage = 1;
        
    } else{
        
        NSString * currentPageAndTotalPageString = pageNumberNode.text;
        NSArray *pageAndTotalPage = [currentPageAndTotalPageString componentsSeparatedByString:@" "];
        
        showThreadPage.currentPage = [[pageAndTotalPage[0] stringWithRegular:@"\\d+"] intValue];
        showThreadPage.totalPageCount = [[pageAndTotalPage[1] stringWithRegular:@"\\d+"] intValue];
    }
    
    return showThreadPage;
}

// private 判断是不是置顶帖子
- (BOOL)isStickyThread:(NSString *)postTitleHtml {
    return [postTitleHtml containsString:@"images/drl2/misc/sticky.gif"];
}

// private 判断是不是精华帖子
- (BOOL)isGoodNessThread:(NSString *)postTitleHtml {
    return [postTitleHtml containsString:@"images/drl2/misc/elite_posticon.gif"];
}

// private 判断是否包含图片
- (BOOL)isContainsImagesThread:(NSString *)postTitlehtml {
    return [postTitlehtml containsString:@"images/drl2/misc/paperclip.gif"];
}

// private 获取回帖的页数
- (int)threadPostPageCount:(NSString *)postTitlehtml {
    NSArray *postPages = [postTitlehtml arrayWithRegulat:@"page=\\d+"];
    if (postPages == nil || postPages.count == 0) {
        return 1;
    } else {
        NSString *countStr = [postPages.lastObject stringWithRegular:@"\\d+"];
        return [countStr intValue];
    }
}

// private
- (NSString *)parseTitle:(NSString *)html {
    NSString *searchText = html;
    
    NSString *pattern = @"<a href=\"showthread.php\\?t.*";
    
    NSRange range = [searchText rangeOfString:pattern options:NSRegularExpressionSearch];
    
    if (range.location != NSNotFound) {
        //NSLog(@"%@", [searchText substringWithRange:range]);
        return [searchText substringWithRange:range];
    }
    return nil;
}

// private
- (NSString *)timeForShort:(NSString *)time withFormat:(NSString *)format {
    if ([time hasPrefix:@"今天"] || [time hasPrefix:@"昨天"]) {
        return time;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormatter setDateFormat:format];
    NSDate *date = [dateFormatter dateFromString:time];
    
    NSTimeInterval intervalTime = date.timeIntervalSinceNow;
    
    int interval = -intervalTime;
    if (interval < 60) {
        return @"刚刚";
    } else if (interval >= 60 && interval <= 60 * 60) {
        return [NSString stringWithFormat:@"%d分钟前", (int) (interval / 60)];
    } else if (interval > 60 * 60 && interval < 60 * 60 * 24) {
        return [NSString stringWithFormat:@"%d小时前", (int) (interval / (60 * 60))];
    } else if (interval >= 60 * 60 * 24 && interval < 60 * 60 * 24 * 7) {
        return [NSString stringWithFormat:@"%d天前", (int) (interval / (60 * 60 * 24))];
    } else if (interval >= 60 * 60 * 24 * 7 && interval < 60 * 60 * 24 * 30) {
        return [NSString stringWithFormat:@"%d周前", (int) (interval / (60 * 60 * 24 * 7))];
    } else if (interval >= 60 * 60 * 24 * 30 && interval <= 60 * 60 * 24 * 365) {
        return [NSString stringWithFormat:@"%d月前", (int) (interval / (60 * 60 * 24 * 30))];
    } else if (interval > 60 * 60 * 24 * 365) {
        return [NSString stringWithFormat:@"%d年前", (int) (interval / (60 * 60 * 24 * 365))];
    }
    
    return time;
}

- (ViewForumPage *)parseThreadListFromHtml:(NSString *)html withThread:(int)threadId andContainsTop:(BOOL)containTop {
    
    
    ViewForumPage *forumDisplayPage = [[ViewForumPage alloc] init];
    
    // /html/body/table/tr/td/div[3]/div/div/table[4]/tr[2]
    // /html/body/table/tr/td/div[3]/div/div/table[6]/tr[2]
    // /html/body/table/tr/td/div[3]/div/div/table[6]/tr[8]
    // /html/body/table/tr/td/div[3]/div/div/table[6]/tr[9]
    NSString *path = @"/html/body/table/tr/td/div[*]/div/div/table[*]/tr[position()>1]";
    
    NSMutableArray<NormalThread *> *threadList = [NSMutableArray<NormalThread *> array];
    
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNodeSet *contents = [document queryWithXPath:path];
    
    NSInteger totaleListCount = -1;
    
    for (int i = 0; i < contents.count; i++) {
        IGXMLNode *normallThreadNode = contents[i];
        
        if (normallThreadNode.children.count >= 8) { // 要>=8的原因是：过滤已经被删除的帖子 以及 被移动的帖子
            
            NormalThread *normalThread = [[NormalThread alloc] init];
            
            // 由于各个论坛的帖子格式可能不一样，因此此处的标题等所在的列也会发生变化
            // 需要根据不同的论坛计算不同的位置
            
            NSInteger childColumnCount = normallThreadNode.children.count;
            
            int titlePosition = 2;
            
            if (childColumnCount == 8) {
                titlePosition = 2;
            } else if (childColumnCount == 7) {
                titlePosition = 1;
            }
            
            // title Node
            IGXMLNode *threadTitleNode = [normallThreadNode childrenAtPosition:titlePosition];
            
            // title all html
            NSString *titleHtml = [threadTitleNode html];
            
            // title inner html
            NSString *titleInnerHtml = [threadTitleNode innerHtml];
            
            // 判断是不是置顶主题
            normalThread.isTopThread = [self isStickyThread:titleHtml];
            
            // 判断是不是精华帖子
            normalThread.isGoodNess = [self isGoodNessThread:titleHtml];
            
            // 是否包含小别针
            normalThread.isContainsImage = [self isContainsImagesThread:titleHtml];
            
            // 主题和分类
            NSString *titleAndCategory = [self parseTitle:titleInnerHtml];
            IGHTMLDocument *titleTemp = [[IGHTMLDocument alloc] initWithXMLString:titleAndCategory error:nil];
            
            NSString *titleText = [titleTemp text];
            
            if ([titleText hasPrefix:@"【"]) {
                titleText = [titleText stringByReplacingOccurrencesOfString:@"【" withString:@"["];
                titleText = [titleText stringByReplacingOccurrencesOfString:@"】" withString:@"]"];
            } else {
                titleText = [@"[讨论]" stringByAppendingString:titleText];
            }
            
            // 分离出主题
            normalThread.threadTitle = titleText;
            
            //[@"showthread.php?t=" length]    17的由来
            normalThread.threadID = [[titleTemp attribute:@"href"] substringFromIndex:17];
            
            // 作者相关
            int authorNodePosition = 3;
            if (childColumnCount == 7) {
                authorNodePosition = 2;
            }
            IGXMLNode *authorNode = [normallThreadNode childrenAtPosition:authorNodePosition];
            NSString *authorIdStr = [authorNode innerHtml];
            normalThread.threadAuthorID = [authorIdStr stringWithRegular:@"\\d+"];
            normalThread.threadAuthorName = [[authorNode text] trim];
            
            // 最后回帖时间
            int lastPostTimePosition = 4;
            if (childColumnCount == 7) {
                lastPostTimePosition = 3;
            }
            IGXMLNode *lastPostTime = [normallThreadNode childrenAtPosition:lastPostTimePosition];
            normalThread.lastPostTime = [self timeForShort:[[lastPostTime text] trim] withFormat:@"MM-dd-yyyy HH:mm"];
            
            // 回帖数量
            int commentCountPosition = 5;
            if (childColumnCount == 7) {
                commentCountPosition = 4;
            }
            IGXMLNode *commentCountNode = [normallThreadNode childrenAtPosition:commentCountPosition];
            normalThread.postCount = [commentCountNode text];
            
            // 查看数量
            int openCountNodePosition = 6;
            if (childColumnCount == 7) {
                openCountNodePosition = 5;
            }
            IGXMLNode *openCountNode = [normallThreadNode childrenAtPosition:openCountNodePosition];
            normalThread.openCount = [openCountNode text];
            
            [threadList addObject:normalThread];
        }
    }
    
    // 总页数
    if (totaleListCount == -1) {
        IGXMLNodeSet *totalPageSet = [document queryWithXPath:@"/html/body/table/tr/td/div[*]/div/div/table[4]/tr/td[2]/div/table/tr/td[1]"];
        
        if (totalPageSet == nil) {
            totaleListCount = 1;
            forumDisplayPage.totalPageCount = 1;
        } else {
            IGXMLNode *totalPage = totalPageSet.firstObject;
            NSString *pageText = [[totalPage text] trim];
            
            NSString *numberText = [[pageText componentsSeparatedByString:@" "] lastObject];
            numberText = [numberText stringWithRegular:@"\\d+"];
            NSUInteger totalNumber = [numberText integerValue];
            
            forumDisplayPage.totalPageCount = totalNumber;
            totaleListCount = totalNumber;
        }
        
    } else {
        forumDisplayPage.totalPageCount = totaleListCount;
    }
    forumDisplayPage.threadList = threadList;
    
    return forumDisplayPage;
}

- (ViewForumPage *)parseFavThreadListFromHtml:(NSString *)html {
    ViewForumPage *page = [[ViewForumPage alloc] init];
    
    NSString *path = @"/html/body/table/tr/td/div[2]/div/div/table[2]/tr/td[3]/form[2]/table/tr[position()>2]";
    
    //*[@id="threadbits_forum_147"]/tr[1]
    
    NSMutableArray<SimpleThread *> *threadList = [NSMutableArray<SimpleThread *> array];
    
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNodeSet *contents = [document queryWithXPath:path];
    
    NSInteger totaleListCount = -1;
    
    
    for (int i = 0; i < contents.count; i++) {
        IGXMLNode *threadListNode = contents[i];
        
        if (threadListNode.children.count >= 6) {
            
            SimpleThread *simpleThread = [[SimpleThread alloc] init];
            
            // Title
            IGXMLNode *threadTitleNode = threadListNode.children[2];
            NSString *titleText = [[[threadTitleNode text] trim] componentsSeparatedByString:@"\n"].firstObject;
            
            if (! ([titleText hasPrefix:@"["] && [titleText containsString:@"]"])){
                if ([titleText hasPrefix:@"【"]) {
                    titleText = [titleText stringByReplacingOccurrencesOfString:@"【" withString:@"["];
                    titleText = [titleText stringByReplacingOccurrencesOfString:@"】" withString:@"]"];
                } else {
                    titleText = [@"[讨论]" stringByAppendingString:titleText];
                }
            }
            simpleThread.threadTitle = titleText;
            
            // Thread Id
            NSString * threadStrig = [[threadTitleNode attribute:@"id"] stringWithRegular:@"\\d+"];
            simpleThread.threadID = threadStrig;
            
            //  Author
            IGXMLNode *authorNode = threadListNode.children[3];
            
            NSString *authorIdStr = [authorNode innerHtml];
            simpleThread.threadAuthorID = [authorIdStr stringWithRegular:@"\\d+"];
            
            simpleThread.threadAuthorName = [[authorNode text] trim];
            
            IGXMLNode *timeNode = threadListNode.children[4];
            NSString *time = [[timeNode text] trim];
            
            simpleThread.lastPostTime = time;
            
            [threadList addObject:simpleThread];
        }
    }
    
    // 总页数
    IGXMLNode * totalPageNode = [document queryNodeWithClassName:@"vbmenu_control"];
    if (totalPageNode == nil) {
        page.totalPageCount = 1;
        page.currentPage = 1;
    } else{
        NSString *pageText = [totalPageNode.text trim];
        page.totalPageCount = [[pageText stringWithRegular:@"共\\d+页" andChild:@"\\d+"] integerValue];
        page.currentPage = [[pageText stringWithRegular:@"第\\d+页" andChild:@"\\d+"] integerValue];
    }
    page.threadList = threadList;
    
    return page;
}

- (NSString *)parseSecurityToken:(NSString *)html {
    NSString *searchText = html;
    
    NSRange range = [searchText rangeOfString:@"\\d{10}-\\S{40}" options:NSRegularExpressionSearch];
    
    if (range.location != NSNotFound) {
        NSLog(@"parseSecurityToken   %@", [searchText substringWithRange:range]);
        return [searchText substringWithRange:range];
    }
    return nil;
}

- (NSString *)parsePostHash:(NSString *)html {
    NSString *hash = [html stringWithRegular:@"<input type=\"hidden\" name=\"posthash\" value=\"\\w{32}\" />" andChild:@"\\w{32}"];
    
    return hash;
}

// for drl
- (NSString *)parserPostStartTime:(NSString *)html {
    NSString * startTime = [html stringWithRegular:@"<input type=\"hidden\" name=\"poststarttime\" value=\"\\d+\" />" andChild:@"\\d+"];
    return startTime;
}

- (NSString *)parseLoginErrorMessage:(NSString *)html {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNodeSet *contents = [document queryWithXPath:@"/html/body/div[2]/div/div/table[3]/tr[2]/td/div/div/div"];
    
    return contents.firstObject.text;
}


// private
-(NSString *)parseListMyThreadRedirectUrl:(NSString *)html{
    NSString * xPath = @"/html/body/table/tr/td/div[2]/div/div/table[1]/tr/td[2]/table/tr[2]/td/a";
    
    IGHTMLDocument *document = [[IGHTMLDocument alloc]initWithHTMLString:html error:nil];
    IGXMLNodeSet * nodeSet = [document queryWithXPath:xPath];
    
    return [nodeSet.firstObject attribute:@"href"];
    
}

- (ViewSearchForumPage *)parseSearchPageFromHtml:(NSString *)html {
    IGHTMLDocument *document = [[IGHTMLDocument alloc]initWithHTMLString:html error:nil];
    
    
    IGXMLNodeSet * searchNodeSet = [document queryWithXPath:@"/html/body/table/tr/td/div[*]/div/div/table[*]/tr[position()>1]"];
    
    if (searchNodeSet == nil || searchNodeSet.count == 0) {
        return nil;
    }
    
    
    ViewSearchForumPage * resultPage = [[ViewSearchForumPage alloc]init];
    
    
    // 总页数 和 当前页数
    
    IGXMLNode* totalPageAndCurrentPageNumberSet = [document queryNodeWithXPath:@"/html/body/table/tr/td/div[2]/div/div/table[2]/tr/td/div/table/tr/td[1]"];
    if (totalPageAndCurrentPageNumberSet == nil) {
        resultPage.currentPage = 1;
        resultPage.totalPageCount = 1;
    } else{
        NSArray * page = [[totalPageAndCurrentPageNumberSet text] componentsSeparatedByString:@" "];
        NSString * currentPage = [page[0] stringWithRegular:@"\\d+"];
        resultPage.currentPage = [currentPage integerValue];
        
        NSString * totalPage = [page[1] stringWithRegular:@"\\d+"];
        resultPage.totalPageCount = [totalPage integerValue];
    }
    
    
    NSMutableArray<ThreadInSearch*>* post = [NSMutableArray array];
    
    for (IGXMLNode *node in searchNodeSet) {
        
        if (node.children.count == 9) {
            // 9个节点是正确的输出结果
            ThreadInSearch * searchThread = [[ThreadInSearch alloc]init];
            
            IGXMLNode * postForNode = [node childrenAtPosition:2];
            
            NSLog(@"--------------------- %ld", [postForNode children].count);
            
            NSString * postIdNode = [postForNode html];
            NSString * postId = [postIdNode stringWithRegular:@"t=\\d+" andChild:@"\\d+"];
            
            NSString * postTitle = [[[postForNode text] trim] componentsSeparatedByString:@"\n"].firstObject;
            NSString * postAuthor = [[[node childrenAtPosition:3] text] trim];
            NSString * postAuthorId = [[node.children[3] html] stringWithRegular:@"=\\d+" andChild:@"\\d+"];
            NSString * postTime = [[node.children[4] text] trim];
            NSString * postBelongForm = [node.children[8] text];
            
            searchThread.threadID = postId;
            
            NSString * titleText = [postTitle trim];
            
            if ([titleText hasPrefix:@"【"]) {
                titleText = [titleText stringByReplacingOccurrencesOfString:@"【" withString:@"["];
                titleText = [titleText stringByReplacingOccurrencesOfString:@"】" withString:@"]"];
            } else {
                titleText = [@"[讨论]" stringByAppendingString:titleText];
            }
            
            searchThread.threadTitle = titleText;
            searchThread.threadAuthorName = postAuthor;
            searchThread.threadAuthorID = postAuthorId;
            searchThread.lastPostTime = [postTime trim];
            searchThread.fromFormName = postBelongForm;
            
            
            [post addObject:searchThread];
        }
    }
    
    resultPage.threadList = post;
    
    return resultPage;
}

- (NSMutableArray<Forum *> *)parseFavForumFromHtml:(NSString *)html {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNodeSet *favFormNodeSet = [document queryWithXPath:@"//*[@id='collapseobj_usercp_forums']/tr[*]/td[2]/div[1]/a"];
    
    
    NSMutableArray *ids = [NSMutableArray array];
    
    //<a href="forumdisplay.php?f=158">『手机◇移动数码』</a>
    for (IGXMLNode *node in favFormNodeSet) {
        NSString *idsStr = [node.html stringWithRegular:@"f=\\d+" andChild:@"\\d+"];
        [ids addObject:[NSNumber numberWithInt:[idsStr intValue]]];
    }
    
    [[NSUserDefaults standardUserDefaults] saveFavFormIds:ids];
    
    
    // 通过ids 过滤出Form
    ForumCoreDataManager *manager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeForm];
    NSArray *result = [manager selectData:^NSPredicate * {
        return [NSPredicate predicateWithFormat:@"forumHost = %@ AND forumId IN %@", self.config.host ,ids];
    }];
    
    NSMutableArray<Forum *> *forms = [NSMutableArray arrayWithCapacity:result.count];
    
    for (ForumEntry *entry in result) {
        Forum *form = [[Forum alloc] init];
        form.forumName = entry.forumName;
        form.forumId = [entry.forumId intValue];
        [forms addObject:form];
    }
    
    return forms;
}

// for drl
- (ViewForumPage *)parsePrivateMessageFromHtml:(NSString *)html {
    ViewForumPage *page = [[ViewForumPage alloc] init];
    
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    
    IGXMLNodeSet *totalPage = [document queryWithXPath:@"/html/body/table/tr/td/div[2]/div/div/table[2]/tr/td[3]/form[2]/table[1]/tr/td/div/table/tr/td[1]"];
    //<td class="vbmenu_control" style="font-weight:normal">第 1 页，共 5 页</td>
    NSString *fullText = [[totalPage firstObject] text];
    NSString *currentPage = [fullText stringWithRegular:@"第\\d+页" andChild:@"\\d+"];
    if (currentPage == nil) {
        page.currentPage = 1;
    } else{
        page.currentPage = [currentPage integerValue];
    }
    
    NSString *totalPageCount = [fullText stringWithRegular:@"共\\d+页" andChild:@"\\d+"];
    if (totalPageCount == nil) {
        page.totalPageCount = 1;
    } else{
        page.totalPageCount = [totalPageCount integerValue];
    }
    
    NSMutableArray<Message *> *messagesList = [NSMutableArray array];
    IGXMLNodeSet *messages = [document queryWithXPath:@"/html/body/table/tr/td/div[2]/div/div/table[2]/tr/td[3]/form[2]/table/tbody[*]/tr"];
    for (IGXMLNode *node in messages) {
        long childCount = [[node children] count];
        if (childCount == 4) {
            // 有4个节点说明是正常的站内短信
            Message *message = [[Message alloc] init];
            
            IGXMLNodeSet *children = [node children];
            // 1. 是不是未读短信
            IGXMLNode *unreadFlag = children[0];
            message.isReaded = ![[unreadFlag html] containsString:@"pm_new.gif"];
            
            // 2. 标题
            IGXMLNode *title = [children[2] children][0];
            NSString *titleStr = [[title children][1] text];
            message.pmTitle = titleStr;
            
            NSString *messageLink = [[[title children][1] attribute:@"href"] stringWithRegular:@"\\d+"];
            message.pmID = messageLink;
            
            
            NSString *timeDay = [[title children][0] text];
            
            // 3. 发送PM作者
            IGXMLNode *author = [children[2] children][1];
            NSString *authorText = [[author children][1] text];
            message.pmAuthor = [authorText trim];
            
            // 4. 发送者ID
            NSString *authorId;
            if (message.isReaded) {
                authorId = [[author children][1] attribute:@"onclick"];
                authorId = [authorId stringWithRegular:@"\\d+"];
            } else {
                IGXMLNode *strongNode = [author children][1];
                strongNode = [strongNode children][0];
                authorId = [strongNode attribute:@"onclick"];
                authorId = [authorId stringWithRegular:@"\\d+"];
            }
            message.pmAuthorId = authorId;
            
            // 5. 时间
            NSString *timeHour = [[author children][0] text];
            message.pmTime = [[timeDay stringByAppendingString:@" "] stringByAppendingString:timeHour];
            
            [messagesList addObject:message];
            
        }
    }
    
    page.threadList = messagesList;
    
    return page;
}

// for drl
- (ViewMessagePage *)parsePrivateMessageContent:(NSString *)html {
    
    
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    
    // ===== message content =====
    ViewMessagePage *privateMessage = [[ViewMessagePage alloc] init];
    
    // PM Title
    IGXMLNode *pmTitleNode = [document queryWithXPath:@"/html/body/table/tr/td/div[2]/div/div/table[2]/tr/td[3]/form/table[1]/tr/td"].firstObject;
    NSString *pmTitle = [[pmTitleNode text] trim];
    privateMessage.pmTitle = pmTitle;
    
    // PM Content
    IGXMLNode *contentNode = [document queryWithXPath:@"/html/body/table/tr/td/div[2]/div/div/table[2]/tr/td[3]/form/table[2]/tr[2]/td[2]/div"].firstObject;
    privateMessage.pmContent = [contentNode html];
    
    // 回帖时间
    IGXMLNode *timeNode = [document queryWithXPath:@"/html/body/table/tr/td/div[2]/div/div/table[2]/tr/td[3]/form/table[2]/tr[1]/td[1]/text()"].firstObject;
    privateMessage.pmTime = [timeNode.text trim];
    
    // PM ID
    IGXMLNode *idNode = [document queryWithXPath:@"/html/body/table/tr/td/div[2]/div/div/table[2]/tr/td[3]/form/table[2]/tr[4]/td/a[2]"].firstObject;
    NSString *pmId = [[idNode attribute:@"href"] stringWithRegular:@"\\d+"];
    privateMessage.pmID = pmId;
    
    // ===== User Info =====
    User *pmAuthor = [[User alloc] init];
    
    // 用户名
    IGXMLNode *userInfoNode = [document queryNodeWithXPath:@"//*[@id='postmenu_']/a"];
    NSString *name = [[userInfoNode text] trim];
    pmAuthor.userName = name;
    // 用户ID
    NSString *userId = [[userInfoNode attribute:@"href"] stringWithRegular:@"\\d+"];
    pmAuthor.userID = userId;
    
    // 用户头像
    IGXMLNode * userAvatarNode = [document queryNodeWithXPath:@"/html/body/table/tr/td/div[2]/div/div/table[2]/tr/td[3]/form/table[2]/tr[2]/td[1]/div[2]/a/img"];
    NSString *userAvatar = [userAvatarNode attribute:@"src"];//[[userAvatarNode attribute:@"src"] componentsSeparatedByString:@"customavatars"].lastObject;
    if (userAvatar == nil) {
        userAvatar = self.config.avatarNo;
    }
    pmAuthor.userAvatar = userAvatar;
    
    // 用户等级
    NSString *userRank = [document queryNodeWithXPath:@"/html/body/table/tr/td/div[2]/div/div/table[2]/tr/td[3]/form/table[2]/tr[2]/td[1]/div[3]"].text;
    pmAuthor.userRank = userRank;
    // 注册日期
    NSString *userSignDate = [[document queryNodeWithXPath:@"/html/body/table/tr/td/div[2]/div/div/table[2]/tr/td[3]/form/table[2]/tr[2]/td[1]/div[5]/fieldset/div[1]"].text componentsSeparatedByString:@": "].lastObject;
    pmAuthor.userSignDate = userSignDate;
    // 帖子数量
    NSString *postCount = [[[[document queryNodeWithXPath:@"/html/body/table/tr/td/div[2]/div/div/table[2]/tr/td[3]/form/table[2]/tr[2]/td[1]/div[5]/fieldset/div[2]/text()"] text] trim] componentsSeparatedByString:@": "].lastObject;
    pmAuthor.userPostCount = postCount;
    
    privateMessage.pmUserInfo = pmAuthor;
    return privateMessage;
}

- (NSString *)parseQuickReplyQuoteContent:(NSString *)html {
    
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNodeSet *nodeSet = [document queryWithXPath:@"//*[@id='vB_Editor_QR_textarea']"];
    NSString *node = [[nodeSet firstObject] text];
    return node;
}

- (NSString *)parseQuickReplyTitle:(NSString *)html {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNodeSet *nodeSet = [document queryWithXPath:@"//*[@id='message_form']/div[1]/div/div/div[3]/input[9]"];
    
    NSString *node = [[nodeSet firstObject] attribute:@"value"];
    return node;
}

- (NSString *)parseQuickReplyTo:(NSString *)html {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNodeSet *nodeSet = [document queryWithXPath:@"//*[@id='message_form']/div[1]/div/div/div[3]/input[10]"];
    NSString *node = [[nodeSet firstObject] attribute:@"value"];
    return node;
}

- (NSString *)parseUserAvatar:(NSString *)html userId:(NSString *)userId {
    NSString *regular = [NSString stringWithFormat:@"/avatar%@_(\\d+).gif", userId];
    NSString *avatar = [html stringWithRegular:regular];
    if (avatar == nil) {
        avatar = @"/no_avatar.gif";
    }
    NSLog(@"avatarLink  >> %@", avatar);
    return avatar;
}

- (NSString *)parseListMyThreadSearchid:(NSString *)html {
    NSString *searchid = [html stringWithRegular:@"/search.php\\?searchid=\\d+" andChild:@"\\d+"];
    return searchid;
}

// private
- (NSString *)queryText:(IGHTMLDocument *)document withXPath:(NSString *)xpath {
    IGXMLNodeSet *nodeSet = [document queryWithXPath:xpath];
    NSString *text = [nodeSet.firstObject text];
    return text;
}

// for drl
- (UserProfile *)parserProfile:(NSString *)html userId:(NSString *)userId {
    
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    UserProfile *profile = [[UserProfile alloc] init];
    // 用户名
    NSString *userNameXPath = @"/html/body/table/tr/td/div[2]/div/div/table[2]/tr[2]/td/table/tr[1]/td/div[2]";
    profile.profileName = [[[document queryWithXPath:userNameXPath].firstObject text] trim];
    
    // 用户等级
    NSString *rankXPath = @"/html/body/table/tr/td/div[2]/div/div/table[2]/tr[2]/td/table/tr[1]/td/div[3]";
    profile.profileRank = [self queryText:document withXPath:rankXPath];
    
    // 注册日期                    /html/body/table/tr/td/div[2]/div/div/table[5]/tr[2]/td[1]/div/div/div/div
    NSString *signDatePattern = @"/html/body/table/tr/td/div[2]/div/div/table[*]/tr[2]/td[1]/div/div/div/div";
    
    profile.profileRegisterDate = [[[[[document queryWithXPath:signDatePattern].firstObject text] trim ] componentsSeparatedByString:@": "]lastObject];
    
    // 最近活动时间
    NSString *lastLoginDayXPath = @"/html/body/table/tr/td/div[2]/div/div/table[2]/tr[2]/td/table/tr[2]/td[2]/div[1]";
    NSString *lastDay = [[[self queryText:document withXPath:lastLoginDayXPath] trim] componentsSeparatedByString:@": "].lastObject;
    
    if (lastDay == nil) {
        profile.profileRecentLoginDate = @"隐私";
    } else {
        profile.profileRecentLoginDate = lastDay;
    }
    
    
    // 帖子总数                   /html/body/table/tr/td/div[2]/div/div/table[5]/tr[2]/td[1]/div/div/fieldset/table/tr[1]/td
    NSString *postCountXPath = @"/html/body/table/tr/td/div[2]/div/div/table[*]/tr[2]/td[1]/div/div/fieldset/table/tr[1]/td";
    NSString * postCount = [[[document queryWithXPath:postCountXPath].firstObject text] componentsSeparatedByString:@": "].lastObject;
    profile.profileTotalPostCount = postCount;
    
    profile.profileUserId = userId;
    return profile;
}


// private
- (Forum *)node2Form:(IGXMLNode *)node parentFormId:(int)parentFormId replaceId:(int)replaceId {
    Forum *parent = [[Forum alloc] init];
    NSString *name = [[node childrenAtPosition:0] text];
    NSString *url = [[node childrenAtPosition:0] html];
    int forumId = [[url stringWithRegular:@"f-\\d+" andChild:@"\\d+"] intValue];
    int fixForumId = forumId == 0 ? replaceId : forumId;
    parent.forumId = fixForumId;
    parent.parentForumId = parentFormId;
    parent.forumName = name;
    
    if (node.childrenCount == 2) {
        IGXMLNodeSet *childSet = [node childrenAtPosition:1].children;
        NSMutableArray<Forum *> *childForms = [NSMutableArray array];
        
        for (IGXMLNode *childNode in childSet) {
            [childForms addObject:[self node2Form:childNode parentFormId:fixForumId replaceId:replaceId]];
        }
        parent.childForums = childForms;
    }
    
    return parent;
}

// private
- (NSArray *)flatForm:(Forum *)form {
    NSMutableArray *resultArray = [NSMutableArray array];
    [resultArray addObject:form];
    for (Forum *childForm in form.childForums) {
        [resultArray addObjectsFromArray:[self flatForm:childForm]];
    }
    return resultArray;
}

- (NSArray<Forum *> *)parserForums:(NSString *)html {
    IGHTMLDocument *document = [[IGHTMLDocument alloc]initWithHTMLString:html error:nil];
    
    //                   /html/body/table/tr/td/div[3]/div/div/table[5]/tr/td[2]/div/form/select/optgroup[2]
    NSString * xPath = @"/html/body/table/tr/td/div[*]/div/div/table[5]/tr/td[2]/div/form/select/optgroup[2]";
    
    IGXMLNode * contents = [document queryNodeWithXPath:xPath];
    
    NSMutableArray<Forum *> * needInsert = [NSMutableArray array];
    
    int parentForumIDForTH1 = -1;
    int parentForumIDForTH2 = -1;
    for (IGXMLNode * child in contents.children) {
        
        Forum * forum = [[Forum alloc] init];
        
        NSString * classType = [child attribute:@"class"];
        int forumID = [[child attribute:@"value"] intValue];
        NSString * forumName = [[child text] trim];
        
        
        if ([classType isEqualToString:@"fjsel"] || [classType isEqualToString:@"fjdpth0"]) {
            parentForumIDForTH1 = forumID;
            forum.parentForumId = -1;
        } else if([classType isEqualToString:@"fjdpth1"]){
            forum.parentForumId = parentForumIDForTH1;
            parentForumIDForTH2 = forumID;
            
        } else if ([classType isEqualToString:@"fjdpth2"]){
            forum.parentForumId = parentForumIDForTH2;
        }
        
        forum.forumId = forumID;
        forum.forumName = forumName;
        forum.forumHost = self.config.host;
        
        [needInsert addObject:forum];
    }
    
    for (Forum * forum in needInsert) {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>> %@     formId: %d     parentFormId:%d\n\n\n", forum.forumName, forum.forumId, forum.parentForumId);
    }
    
    return [needInsert copy];
}
@end
