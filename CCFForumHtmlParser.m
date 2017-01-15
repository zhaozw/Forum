//
// Created by WDY on 2016/12/8.
// Copyright (c) 2016 andforce. All rights reserved.
//

#import "CCFForumHtmlParser.h"

#import "IGXMLNode+Children.h"
#import <IGHTMLQuery.h>

#import "ForumEntry+CoreDataClass.h"
#import "ForumCoreDataManager.h"
#import "NSUserDefaults+Extensions.h"
#import "NSString+Extensions.h"

#import "IGHTMLDocument+QueryNode.h"
#import "IGXMLNode+Children.h"
#import "AppDelegate.h"

@implementation CCFForumHtmlParser {

}

// private
- (NSString *)postMessages:(NSString *)html {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNodeSet *postMessages = [document queryWithXPath:@"//*[@id='posts']/div[*]/div/div/div/table/tr[1]/td[2]"];
    NSMutableString *messages = [NSMutableString string];

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

    // 发帖内容的 table -> td
    IGXMLNodeSet *postMessages = [document queryWithXPath:@"//*[@id='posts']/div[*]/div/div/div/table/tr[1]/td[2]"];

    // 发帖时间
    NSString *xPathTime = @"//*[@id='table1']/tr/td[1]/div";


    for (IGXMLNode *node in postMessages) {

        Post *post = [[Post alloc] init];


        NSString *postId = [[[node attribute:@"id"] componentsSeparatedByString:@"td_post_"] lastObject];


        IGXMLDocument *postDocument = [[IGHTMLDocument alloc] initWithHTMLString:node.html error:nil];

        IGXMLNode *time = [postDocument queryWithXPath:xPathTime].firstObject;


        NSString *xPathMessage = [NSString stringWithFormat:@"//*[@id='post_message_%@']", postId];
        IGXMLNode *message = [postDocument queryWithXPath:xPathMessage].firstObject;

        post.postContent = message.html;
        // 去掉引用inline 的样式设定
        post.postContent = [post.postContent stringByReplacingOccurrencesOfString:@"<div class=\"smallfont\" style=\"margin-bottom:2px\">引用:</div>" withString:@""];
        post.postContent = [post.postContent stringByReplacingOccurrencesOfString:@"style=\"margin:20px; margin-top:5px; \"" withString:@"class=\"post-quote\""];
        post.postContent = [post.postContent stringByReplacingOccurrencesOfString:@"<td class=\"alt2\" style=\"border:1px inset\">" withString:@"<td class=\"alt2\">"];


        NSString *xPathAttImage = [NSString stringWithFormat:@"//*[@id='td_post_%@']/div[2]", postId];
        IGXMLNode *attImage = [postDocument queryWithXPath:xPathAttImage].firstObject;

        NSString *attImageHtml = [attImage html];

        //<a href="attachment.php?attachmentid=725161&amp;stc=1" target="_blank">
        //<img class="attach" src="attachment.php?attachmentid=725161&amp;stc=1&amp;d=1261896941" onload="if(this.width>screen.width*0.7) {this.width=screen.width*0.7;}" border="0" alt="">
        //</a>

        // 上传的图片，外面包了一层，影响点击事件，
        // 因此要替换成<img src="attachment.php?attachmentid=725161&amp;stc=1" /> 这种形式
        IGHTMLDocument *attImageDocument = [[IGHTMLDocument alloc] initWithHTMLString:attImageHtml error:nil];

        IGXMLNodeSet *attImageSet = [attImageDocument queryWithXPath:@"/html/body/div/fieldset/div/a[*]"];


        NSString *newImagePattern = @"<img src=\"%@\" />";
        for (IGXMLNode *node in attImageSet) {
            NSString *href = [node attribute:@"href"];
            NSString *newImage = [NSString stringWithFormat:newImagePattern, href];

            attImageHtml = [attImageHtml stringByReplacingOccurrencesOfString:node.html withString:newImage];
        }


        if (attImage != nil) {
            post.postContent = [post.postContent stringByAppendingString:attImageHtml];
        }


        NSRange louCengRange = [time.text rangeOfString:@"#\\d+" options:NSRegularExpressionSearch];

        if (louCengRange.location != NSNotFound) {
            post.postLouCeng = [time.text substringWithRange:louCengRange];
        }


        NSRange timeRange = [time.text rangeOfString:@"\\d{4}-\\d{2}-\\d{2}, \\d{2}:\\d{2}:\\d{2}" options:NSRegularExpressionSearch];

        if (timeRange.location != NSNotFound) {
            NSString *fixTime = [[time.text substringWithRange:timeRange] stringByReplacingOccurrencesOfString:@", " withString:@" "];
            post.postTime = [self timeForShort:fixTime withFormat:@"yyyy-MM-dd HH:mm:ss"];
        }
        // 保存数据
        post.postID = postId;

        // 添加数据
        [posts addObject:post];


    }


    // 发帖账户信息 table -> td
    //*[@id='posts']/div[1]/div/div/div/table/tr[1]/td[1]
    IGXMLNodeSet *postUserInfo = [document queryWithXPath:@"//*[@id='posts']/div[*]/div/div/div/table/tr[1]/td[1]"];
    //*[@id="post"]/tbody/tr[1]/td[1]

    int postPointer = 0;
    for (IGXMLNode *userInfoNode in postUserInfo) {

        if (userInfoNode.children.count < 5) {
            continue;
        }
        IGXMLNode *nameNode = userInfoNode.firstChild.firstChild;

        User *user = [[User alloc] init];

        NSString *name = nameNode.innerHtml;
        user.userName = name;
        NSString *nameLink = [nameNode attribute:@"href"];
        user.userID = [nameLink stringWithRegular:@"\\d+"];
        //avatar
        IGXMLNode *avatarNode = userInfoNode.children[1];
        NSString *avatarLink = [[[avatarNode children][1] firstChild] attribute:@"src"];

        avatarLink = [avatarLink stringWithRegular:@"/avatar(\\d+)_(\\d+).gif"];
        if (avatarLink == nil) {
            avatarLink = @"/no_avatar.gif";
        }

        //avatarLink = [[avatarLink componentsSeparatedByString:@"/"]lastObject];

        user.userAvatar = avatarLink;

        //rank
        IGXMLNode *rankNode = userInfoNode.children[3];
        user.userRank = rankNode.text;
        // 资料div
        IGXMLNode *subInfoNode = userInfoNode.children[4];
        // 注册日期
        IGXMLNode *signDateNode = [[subInfoNode children][1] children][1];
        user.userSignDate = signDateNode.text;
        // 帖子数量html
        IGXMLNode *postCountNode = [[subInfoNode children][1] children][2];
        user.userPostCount = postCountNode.text;
        // 精华 解答 暂时先不处理
        //IGXMLNode * solveCountNode = subInfoNode;


        posts[postPointer].postUserInfo = user;

        Post *newPost = posts[postPointer];
        newPost.postUserInfo = user;
        [posts removeObjectAtIndex:postPointer];
        [posts insertObject:newPost atIndex:postPointer];

        postPointer++;
    }

    return posts;
}

- (ViewThreadPage *)parseShowThreadWithHtml:(NSString *)html {
    // 查找设置了字体的回帖
    NSArray *fontSetString = [html arrayWithRegulat:@"<font size=\"\\d+\">"];

    NSString *fixFontSizeHTML = html;

    for (NSString *tmp in fontSetString) {
        fixFontSizeHTML = [fixFontSizeHTML stringByReplacingOccurrencesOfString:tmp withString:@"<font size=\"\2\">"];
    }
    // 去掉_http hxxp
    NSString *fuxkHttp = fixFontSizeHTML;
    NSArray *httpArray = [fixFontSizeHTML arrayWithRegulat:@"(_http|hxxp|_https|hxxps)://[\\w\\-_]+(\\.[\\w\\-_]+)+([\\w\\-\\.,@?^=%&amp;:/~\\+#]*[\\w\\-\\@?^=%&amp;/~\\+#])?"];
    NSString *httpPattern = @"<a href=\"%@\" target=\"_blank\">%@</a>";
    for (NSString *http in httpArray) {
        NSString *fixedHttp = [http stringByReplacingOccurrencesOfString:@"_http://" withString:@"http://"];
        fixedHttp = [fixedHttp stringByReplacingOccurrencesOfString:@"hxxp://" withString:@"http://"];
        fixedHttp = [fixedHttp stringByReplacingOccurrencesOfString:@"hxxps://" withString:@"https://"];
        fixedHttp = [fixedHttp stringByReplacingOccurrencesOfString:@"_https://" withString:@"https://"];

        NSString *patterned = [NSString stringWithFormat:httpPattern, fixedHttp, fixedHttp];
        fuxkHttp = [fuxkHttp stringByReplacingOccurrencesOfString:http withString:patterned];

    }


    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:fuxkHttp error:nil];


    NSString *forumId = [fuxkHttp stringWithRegular:@"newthread.php\\?do=newthread&amp;f=\\d+" andChild:@"\\d+"];

    ViewThreadPage *showThreadPage = [[ViewThreadPage alloc] init];
    showThreadPage.originalHtml = [self postMessages:fuxkHttp];

    showThreadPage.forumId = forumId;

    NSString *securityToken = [self parseSecurityToken:html];
    showThreadPage.securityToken = securityToken;

    NSString *ajaxLastPost = [self parseAjaxLastPost:html];
    showThreadPage.ajaxLastPost = ajaxLastPost;

    showThreadPage.postList = [self parseShowThreadPosts:document];


    IGXMLNode *titleNode = [document queryWithXPath:@"/html/body/div[2]/div/div/table[2]/tr/td[1]/table/tr[2]/td/strong"].firstObject;
    NSString *fixedTitle = [titleNode.text trim];
    if ([fixedTitle hasPrefix:@"【"]) {
        fixedTitle = [fixedTitle stringByReplacingOccurrencesOfString:@"【" withString:@"["];
        fixedTitle = [fixedTitle stringByReplacingOccurrencesOfString:@"】" withString:@"]"];
    } else {
        fixedTitle = [@"讨论" stringByAppendingString:fixedTitle];
    }

    showThreadPage.threadTitle = fixedTitle;

    NSString *threadIdPattern = @"<input type=\"hidden\" name=\"searchthreadid\" value=\"\\d+\" />";
    NSString *threadID = [html stringWithRegular:threadIdPattern andChild:@"\\d+"];
    showThreadPage.threadID = threadID;

    IGXMLNodeSet *threadInfoSet = [document queryWithXPath:@"/html/body/div[4]/div/div/table[1]/tr/td[2]/div/table/tr"];

    if (threadInfoSet == nil || threadInfoSet.count == 0) {
        showThreadPage.totalPageCount = 1;
        showThreadPage.currentPage = 1;

    } else {
        IGXMLNode *currentPageAndTotalPageNode = threadInfoSet.firstObject.firstChild;
        NSString *currentPageAndTotalPageString = currentPageAndTotalPageNode.text;
        NSArray *pageAndTotalPage = [currentPageAndTotalPageString componentsSeparatedByString:@"页，共"];

        showThreadPage.totalPageCount = (NSUInteger) [[[pageAndTotalPage.lastObject stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"页" withString:@""] intValue];
        showThreadPage.currentPage = (NSUInteger) [[[pageAndTotalPage.firstObject stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"第" withString:@""] intValue];
    }

    return showThreadPage;
}

// private 判断是不是置顶帖子
- (BOOL)isStickyThread:(NSString *)postTitleHtml {
    return [postTitleHtml containsString:@"images/CCFStyle/misc/sticky.gif"];
}

// private 判断是不是精华帖子
- (BOOL)isGoodNessThread:(NSString *)postTitleHtml {
    return [postTitleHtml containsString:@"images/CCFStyle/misc/goodnees.gif"];
}

// private 判断是否包含图片
- (BOOL)isContainsImagesThread:(NSString *)postTitlehtml {
    return [postTitlehtml containsString:@"images/CCFStyle/misc/paperclip.gif"];
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
    ViewForumPage *page = [[ViewForumPage alloc] init];

    NSString *path = [NSString stringWithFormat:@"//*[@id='threadbits_forum_%d']/tr", threadId];

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

            // 回帖页数
            normalThread.totalPostPageCount = [self threadPostPageCount:titleHtml];

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
            normalThread.threadAuthorName = [authorNode text];

            // 最后回帖时间
            int lastPostTimePosition = 4;
            if (childColumnCount == 7) {
                lastPostTimePosition = 3;
            }
            IGXMLNode *lastPostTime = [normallThreadNode childrenAtPosition:lastPostTimePosition];
            normalThread.lastPostTime = [self timeForShort:[[lastPostTime text] trim] withFormat:@"yyyy-MM-dd HH:mm:ss"];

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
        IGXMLNodeSet *totalPageSet = [document queryWithXPath:@"//*[@id='inlinemodform']/table[4]/tr[1]/td[2]/div/table/tr/td[1]"];

        if (totalPageSet == nil) {
            totaleListCount = 1;
            page.totalPageCount = 1;
        } else {
            IGXMLNode *totalPage = totalPageSet.firstObject;
            NSString *pageText = [totalPage innerHtml];
            NSString *numberText = [[pageText componentsSeparatedByString:@"，"] lastObject];
            numberText = [numberText stringWithRegular:@"\\d+"];
            NSUInteger totalNumber = [numberText integerValue];
            //NSLog(@"总页数：   %@", pageText);
            page.totalPageCount = totalNumber;
            totaleListCount = totalNumber;
        }

    } else {
        page.totalPageCount = totaleListCount;
    }
    page.threadList = threadList;

    return page;
}

- (ViewForumPage *)parseFavThreadListFromHtml:(NSString *)html {
    ViewForumPage *page = [[ViewForumPage alloc] init];

    NSString *path = @"/html/body/div[2]/div/div/table[3]/tr/td[3]/form[2]/table/tr[position()>2]";

    //*[@id="threadbits_forum_147"]/tr[1]

    NSMutableArray<SimpleThread *> *threadList = [NSMutableArray<SimpleThread *> array];

    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNodeSet *contents = [document queryWithXPath:path];

    NSInteger totaleListCount = -1;


    for (int i = 0; i < contents.count; i++) {
        IGXMLNode *threadListNode = contents[i];

        if (threadListNode.children.count >= 7) { // 要大于7的原因是：过滤已经被删除的帖子 和已经被移动的帖子

            SimpleThread *simpleThread = [[SimpleThread alloc] init];

            // title
            IGXMLNode *threadTitleNode = threadListNode.children[2];
            NSString *titleText = [[[threadTitleNode text] trim] componentsSeparatedByString:@"\n"].firstObject;

            if ([titleText hasPrefix:@"【"]) {
                titleText = [titleText stringByReplacingOccurrencesOfString:@"【" withString:@"["];
                titleText = [titleText stringByReplacingOccurrencesOfString:@"】" withString:@"]"];
            } else {
                titleText = [@"[讨论]" stringByAppendingString:titleText];
            }

            //分离出Title
            simpleThread.threadTitle = titleText;

            NSString *timeHtml = [self parseTitle:[[threadTitleNode innerHtml] trim]];
            IGHTMLDocument *titleTemp = [[IGHTMLDocument alloc] initWithXMLString:timeHtml error:nil];

            //[@"showthread.php?t=" length]    17的由来
            simpleThread.threadID = [[titleTemp attribute:@"href"] substringFromIndex:17];


            IGXMLNode *authorNode = threadListNode.children[3];

            NSString *authorIdStr = [authorNode innerHtml];
            simpleThread.threadAuthorID = [authorIdStr stringWithRegular:@"\\d+"];

            simpleThread.threadAuthorName = [authorNode text];

            IGXMLNode *timeNode = threadListNode.children[4];
            NSString *time = [[timeNode text] trim];

            simpleThread.lastPostTime = time;

            [threadList addObject:simpleThread];
        }
    }

    // 总页数
    if (totaleListCount == -1) {
        IGXMLNodeSet *totalPageSet = [document queryWithXPath:@"//*[@id='inlinemodform']/table[4]/tr[1]/td[2]/div/table/tr/td[1]"];

        if (totalPageSet == nil) {
            totaleListCount = 1;
            page.totalPageCount = 1;
        } else {
            IGXMLNode *totalPage = totalPageSet.firstObject;
            NSString *pageText = [totalPage innerHtml];
            NSString *numberText = [[pageText componentsSeparatedByString:@"，"] lastObject];
            NSUInteger totalNumber = [numberText integerValue];
            NSLog(@"总页数：   %@", pageText);
            page.totalPageCount = totalNumber;
            totaleListCount = totalNumber;
        }

    } else {
        page.totalPageCount = totaleListCount;
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

- (NSString *)parserPostStartTime:(NSString *)html {
    NSString *reg = @"poststarttime=\\d+";
    NSString *result = [html stringWithRegular:reg andChild:@"\\d+"];
    return result;
}

- (NSString *)parseLoginErrorMessage:(NSString *)html {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNodeSet *contents = [document queryWithXPath:@"/html/body/div[2]/div/div/table[3]/tr[2]/td/div/div/div"];

    return contents.firstObject.text;
}

- (ViewSearchForumPage *)parseSearchPageFromHtml:(NSString *)html {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNodeSet *searchNodeSet = [document queryWithXPath:@"//*[@id='threadslist']/tr[*]"];

    if (searchNodeSet == nil || searchNodeSet.count == 0) {
        return nil;
    }


    ViewSearchForumPage *resultPage = [[ViewSearchForumPage alloc] init];

    IGXMLNode *postTotalCountNode = [document queryWithXPath:@"//*[@id='threadslist']/tr[1]/td/span[1]"].firstObject;

    NSString *postTotalCount = [postTotalCountNode.text stringWithRegular:@"共计 \\d+ 条" andChild:@"\\d+"];
    // 1. 结果总条数
    resultPage.totalPageCount = [postTotalCount integerValue];

    IGXMLNode *pageNode = [document queryWithXPath:@"/html/body/div[2]/div/div/table[3]/tr/td/div/table/tr/td[1]"].firstObject;
    // 2. 当前页数 和 总页数
    if (pageNode == nil) {
        resultPage.currentPage = 1;
        resultPage.totalPageCount = 1;
    } else {
        resultPage.currentPage = [[pageNode.text stringWithRegular:@"第 \\d+ 页" andChild:@"\\d+"] integerValue];
        resultPage.totalPageCount = [[pageNode.text stringWithRegular:@"共 \\d+ 页" andChild:@"\\d+"] integerValue];
    }

    NSMutableArray<ThreadInSearch *> *post = [NSMutableArray array];

    for (IGXMLNode *node in searchNodeSet) {

        if (node.children.count == 9) {
            // 9个节点是正确的输出结果
            ThreadInSearch *searchThread = [[ThreadInSearch alloc] init];

            IGXMLNode *postForNode = [node childrenAtPosition:2];

            NSLog(@"--------------------- %ld title: %@", [postForNode children].count, [[postForNode text] trim]);

            NSString *postIdNode = [postForNode html];
            NSString *postId = [postIdNode stringWithRegular:@"id=\"thread_title_\\d+\"" andChild:@"\\d+"];


            NSString *titleAndCategory = [self parseTitle:[postForNode html]];
            IGHTMLDocument *titleTemp = [[IGHTMLDocument alloc] initWithXMLString:titleAndCategory error:nil];
            NSString *titleText = [titleTemp text];

            NSString *postTitle = [[[postForNode text] trim] componentsSeparatedByString:@"\n"].firstObject;
            NSString *postAuthor = [[node childrenAtPosition:3] text];
            NSString *postAuthorId = [[node.children[3] html] stringWithRegular:@"=\\d+" andChild:@"\\d+"];
            NSString *postTime = [node.children[4] text];

            NSString *postBelongForm = [node.children[8] text];

            searchThread.threadID = postId;

            if ([titleText hasPrefix:@"【"]) {
                titleText = [titleText stringByReplacingOccurrencesOfString:@"【" withString:@"["];
                titleText = [titleText stringByReplacingOccurrencesOfString:@"】" withString:@"]"];
            } else {
                titleText = [@"[讨论]" stringByAppendingString:titleText];
            }

            searchThread.threadTitle = titleText;

            searchThread.threadAuthorName = postAuthor;
            searchThread.threadAuthorID = postAuthorId;
            searchThread.lastPostTime = [self timeForShort:[postTime trim] withFormat:@"yyyy-MM-dd HH:mm:ss"];
            searchThread.fromFormName = postBelongForm;


            [post addObject:searchThread];
        }
    }

    resultPage.searchid = [self parseListMyThreadSearchid:html];
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
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *result = [manager selectData:^NSPredicate * {
        return [NSPredicate predicateWithFormat:@"forumHost = %@ AND forumId IN %@", [NSURL URLWithString:appDelegate.forumBaseUrl].host, ids];
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

- (ViewForumPage *)parsePrivateMessageFromHtml:(NSString *)html {
    ViewForumPage *page = [[ViewForumPage alloc] init];

    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    IGXMLNodeSet *totalPage = [document queryWithXPath:@"//*[@id='pmform']/table[1]/tr/td/div/table/tr/td[1]"];
    //<td class="vbmenu_control" style="font-weight:normal">第 1 页，共 5 页</td>
    NSString *fullText = [[totalPage firstObject] text];
    NSString *currentPage = [fullText stringWithRegular:@"第 \\d+ 页" andChild:@"\\d+"];
    page.currentPage = [currentPage integerValue];
    NSString *totalPageCount = [fullText stringWithRegular:@"共 \\d+ 页" andChild:@"\\d+"];
    page.totalPageCount = [totalPageCount integerValue];


    NSMutableArray<Message *> *messagesList = [NSMutableArray array];

    IGXMLNodeSet *messages = [document queryWithXPath:@"//*[@id='pmform']/table[2]/tbody[*]/tr"];
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
            message.pmAuthor = authorText;

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

- (ViewMessagePage *)parsePrivateMessageContent:(NSString *)html {
    // 去掉引用inline 的样式设定
    html = [html stringByReplacingOccurrencesOfString:@"<div class=\"smallfont\" style=\"margin-bottom:2px\">引用:</div>" withString:@""];
    html = [html stringByReplacingOccurrencesOfString:@"style=\"margin:20px; margin-top:5px; \"" withString:@"class=\"post-quote\""];
    html = [html stringByReplacingOccurrencesOfString:@"<td class=\"alt2\" style=\"border:1px inset\">" withString:@"<td class=\"alt2\">"];


    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    // message content
    ViewMessagePage *privateMessage = [[ViewMessagePage alloc] init];
    IGXMLNodeSet *contentNodeSet = [document queryWithXPath:@"//*[@id='post_message_']"];
    privateMessage.pmContent = [[contentNodeSet firstObject] html];
    // 回帖时间
    IGXMLNodeSet *privateSendTimeSet = [document queryWithXPath:@"//*[@id='table1']/tr/td[1]/div/text()"];
    NSString *timeLong = [[privateSendTimeSet[2] text] trim];
    privateMessage.pmTime = [self timeForShort:timeLong withFormat:@"yyyy-MM-dd, HH:mm:ss"];
    // PM ID
    IGXMLNodeSet *privateMessageIdSet = [document queryWithXPath:@"/html/body/div[2]/div/div/table[2]/tr/td[1]/table/tr[2]/td/a"];
    NSString *pmId = [[[privateMessageIdSet firstObject] attribute:@"href"] stringWithRegular:@"\\d+"];
    privateMessage.pmID = pmId;

    // PM Title
    IGXMLNodeSet *pmTitleSet = [document queryWithXPath:@"/html/body/div[2]/div/div/table[2]/tr/td[1]/table/tr[2]/td/strong"];
    NSString *pmTitle = [[[pmTitleSet firstObject] text] trim];
    privateMessage.pmTitle = pmTitle;


    // User Info
    User *pmAuthor = [[User alloc] init];
    IGXMLNode *userInfoNode = [document queryNodeWithXPath:@"//*[@id='post']/tr[1]/td[1]"];
    // 用户名
    NSString *name = [[[userInfoNode childrenAtPosition:0] childrenAtPosition:0] text];
    pmAuthor.userName = name;
    // 用户ID
    NSString *userId = [[[[userInfoNode childrenAtPosition:0] childrenAtPosition:0] attribute:@"href"] stringWithRegular:@"\\d+"];
    pmAuthor.userID = userId;

    // 用户头像
    NSString *userAvatar = [[[[[[userInfoNode childrenAtPosition:1] childrenAtPosition:1] childrenAtPosition:0] attribute:@"src"] componentsSeparatedByString:@"/"] lastObject];
    if (userAvatar) {
        NSString *avatarPattern = @"%@/%@";
        userAvatar = [NSString stringWithFormat:avatarPattern, self.config.avatarBase, userAvatar];
    } else {
        userAvatar = self.config.avatarNo;
    }
    pmAuthor.userAvatar = userAvatar;

    // 用户等级
    NSString *userRank = [[userInfoNode childrenAtPosition:3] text];
    pmAuthor.userRank = userRank;
    // 注册日期
    NSString *userSignDate = [[[[[[userInfoNode childrenAtPosition:4] childrenAtPosition:1] childrenAtPosition:1] text] componentsSeparatedByString:@": "] lastObject];
    pmAuthor.userSignDate = userSignDate;
    // 帖子数量
    NSString *postCount = [[[[[[[userInfoNode childrenAtPosition:4] childrenAtPosition:1] childrenAtPosition:2] text] trim] componentsSeparatedByString:@": "] lastObject];
    pmAuthor.userPostCount = postCount;

    // 精华 和 解答

    //===========

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
    NSString *xPath = @"/html/body/div[2]/div/div/table[2]/tr/td[1]/table/tr[2]/td/a";
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNodeSet *nodeSet = [document queryWithXPath:xPath];

    return [[nodeSet.firstObject attribute:@"href"] stringWithRegular:@"\\d+"];
}

// private
- (NSString *)queryText:(IGHTMLDocument *)document withXPath:(NSString *)xpath {
    IGXMLNodeSet *nodeSet = [document queryWithXPath:xpath];
    NSString *text = [nodeSet.firstObject text];
    return text;
}

- (UserProfile *)parserProfile:(NSString *)html userId:(NSString *)userId {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    UserProfile *profile = [[UserProfile alloc] init];
    // 用户名
    NSString *userNameXPath = @"//*[@id='username_box']/h1/text()";
    profile.profileName = [[self queryText:document withXPath:userNameXPath] trim];

    // 用户等级
    NSString *rankXPath = @"//*[@id='username_box']/h2";
    profile.profileRank = [self queryText:document withXPath:rankXPath];

    // 注册日期
    NSString *signDatePattern = @"<li><span class=\"shade\">注册日期:</span> \\d{4}-\\d{2}-\\d{2}</li>";

    profile.profileRegisterDate = [html stringWithRegular:signDatePattern andChild:@"\\d{4}-\\d{2}-\\d{2}"];

    // 最近活动时间
    NSString *lastLoginDayXPath = @"//*[@id='collapseobj_stats']/div/fieldset[2]/ul/li[1]/text()";
    NSString *lastDay = [[self queryText:document withXPath:lastLoginDayXPath] trim];

    NSString *lastLoginTimeXPath = @"//*[@id='collapseobj_stats']/div/fieldset[2]/ul/li[1]/span[2]";
    NSString *lastTime = [[self queryText:document withXPath:lastLoginTimeXPath] trim];
    if (lastTime == nil) {
        lastTime = @"隐私";
        profile.profileRecentLoginDate = lastTime;
    } else {
        profile.profileRecentLoginDate = [NSString stringWithFormat:@"%@ %@", lastDay, lastTime];
    }


    // 帖子总数
    NSString *postCount = [html stringWithRegular:@"<li><span class=\"shade\">帖子总数:</span> ([0-9][,]?)+</li>" andChild:@"([0-9][,]?)+"];
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
    parent.forumHost = self.config.host;

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
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    NSMutableArray<Forum *> *forms = [NSMutableArray array];

    //*[@id="content"]/ul

    NSString *xPath = @"//*[@id='content']/ul/li[position()>0]";

    IGXMLNodeSet *contents = [document query:xPath];

    int replaceId = 10000;
    for (IGXMLNode *child in contents) {
        [forms addObject:[self node2Form:child parentFormId:-1 replaceId:replaceId++]];

    }

    NSMutableArray<Forum *> *needInsert = [NSMutableArray array];

    for (Forum *forum in forms) {
        [needInsert addObjectsFromArray:[self flatForm:forum]];
    }

    for (Forum *form in needInsert) {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>> %@     forumId: %d     parentForumId:%d\n\n\n", form.forumName, form.forumId, form.parentForumId);
    }


    return [needInsert copy];
}

@end