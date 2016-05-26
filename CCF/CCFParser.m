//
//  CCGParser.m
//  CCF
//
//  Created by 迪远 王 on 15/12/30.
//  Copyright © 2015年 andforce. All rights reserved.
//

#import "CCFParser.h"
#import <IGHTMLQuery.h>
#import "ShowThreadPage.h"
#import "ThreadInSearch.h"
#import "ForumDisplayPage.h"
#import "FormEntry+CoreDataProperties.h"
#import "ForumCoreDataManager.h"
#import "NSUserDefaults+Extensions.h"
#import "NSString+Extensions.h"
#import "Forum.h"
#import "PrivateMessage.h"
#import "SimpleThread.h"
#import "SearchForumDisplayPage.h"
#import "IGHTMLDocument+QueryNode.h"
#import "IGXMLNode+Children.h"


@implementation CCFParser

-(ForumDisplayPage *)parseThreadListFromHtml:(NSString *)html withThread:(int) threadId andContainsTop:(BOOL)containTop{
    
    ForumDisplayPage * page = [[ForumDisplayPage alloc] init];
    
    NSString * path = [NSString stringWithFormat:@"//*[@id='threadbits_forum_%d']/tr", threadId];
    
    NSMutableArray<NormalThread *> * threadList = [NSMutableArray<NormalThread *> array];
    
    IGHTMLDocument *document = [[IGHTMLDocument alloc]initWithHTMLString:html error:nil];
    IGXMLNodeSet* contents = [document queryWithXPath: path];
    
    NSInteger totaleListCount = -1;
    
    for (int i = 0; i < contents.count; i++){
        IGXMLNode * threadListNode = contents[i];
        
        if (threadListNode.children.count > 4) { // 要大于4的原因是：过滤已经被删除的帖子
            
            NormalThread * normalThread = [[NormalThread alloc]init];
            
            // title Node
            IGXMLNode * threadTitleNode = [threadListNode childrenAtPosition:2];

            // title all html
            NSString * titleHtml = [threadTitleNode html];
            
            // 回帖页数
            normalThread.totalPostPageCount = [self threadPostPageCount:titleHtml];
        
            // title inner html
            NSString * titleInnerHtml = [threadTitleNode innerHtml];
            
            // 判断是不是置顶主题
            normalThread.isTopThread = [self isStickyThread:titleHtml];
            
            // 判断是不是精华帖子
            normalThread.isGoodNess = [self isGoodNessThread:titleHtml];
            
            // 是否包含小别针
            normalThread.isContainsImage = [self isContainsImagesThread:titleHtml];

            // 主题和分类
            NSString *titleAndCategory = [self parseTitle: titleInnerHtml];
            IGHTMLDocument * titleTemp = [[IGHTMLDocument alloc]initWithXMLString:titleAndCategory error:nil];
            
            NSString * titleText = [titleTemp text];
            
            // 分离出主题分类
            normalThread.threadCategory = [self spliteCategory:titleText];
            // 分离出主题
            normalThread.threadTitle = [self spliteTitle:titleText];
            
            //[@"showthread.php?t=" length]    17的由来
            normalThread.threadID = [[titleTemp attribute:@"href"] substringFromIndex: 17];
            
            IGXMLNode * authorNode = threadListNode.children [3];

            NSString * authorIdStr = [authorNode innerHtml];
            normalThread.threadAuthorID = [authorIdStr stringWithRegular:@"\\d+"];
            
            normalThread.threadAuthorName = [authorNode text];
            
            IGXMLNode * lastPostTime = [threadListNode childrenAtPosition:4];
            normalThread.lastPostTime = [[lastPostTime text] trim];
            
            IGXMLNode * commentCountNode = threadListNode.children [5];
            normalThread.postCount = [commentCountNode text];
            
            IGHTMLDocument * openCountNode = threadListNode.children[6];
            normalThread.openCount = [openCountNode text];
            
            [threadList addObject:normalThread];
        }
    }
    
    // 总页数
    if (totaleListCount == -1) {
        IGXMLNodeSet* totalPageSet = [document queryWithXPath:@"//*[@id='inlinemodform']/table[4]/tr[1]/td[2]/div/table/tr/td[1]"];
        
        if (totalPageSet == nil) {
            totaleListCount = 1;
            page.totalPageCount = 1;
        }else{
            IGXMLNode * totalPage = totalPageSet.firstObject;
            NSString * pageText = [totalPage innerHtml];
            NSString * numberText = [[pageText componentsSeparatedByString:@"，"]lastObject];
            numberText = [numberText stringWithRegular:@"\\d+"];
            NSUInteger totalNumber = [numberText integerValue];
            //NSLog(@"总页数：   %@", pageText);
            page.totalPageCount = totalNumber;
            totaleListCount = totalNumber;
        }
        
    } else{
        page.totalPageCount = totaleListCount;
    }
    page.dataList = threadList;
    
    return page;
    
}

// 判断是不是置顶帖子
-(BOOL) isStickyThread:(NSString *) postTitleHtml{
    return [postTitleHtml containsString:@"images/CCFStyle/misc/sticky.gif"];
}

// 判断是不是精华帖子
-(BOOL) isGoodNessThread:(NSString *) postTitleHtml{
    return [postTitleHtml containsString:@"images/CCFStyle/misc/goodnees.gif"];
}

// 判断是否包含图片
-(BOOL) isContainsImagesThread:(NSString *) postTitlehtml{
    return [postTitlehtml containsString:@"images/CCFStyle/misc/paperclip.gif"];
}

// 获取回帖的页数
-(int) threadPostPageCount:(NSString *) postTitlehtml{
    NSArray * postPages = [postTitlehtml arrayWithRegulat:@"page=\\d+"];
    if (postPages == nil || postPages.count == 0) {
        return 1;
    } else{
        NSString * countStr = [postPages.lastObject stringWithRegular:@"\\d+"];
        return [countStr intValue];
    }
}


-(NSString *) parseTitle:(NSString *) html {
    NSString *searchText = html;
    
    NSString * pattern = @"<a href=\"showthread.php\\?t.*";
    
    NSRange range = [searchText rangeOfString:pattern options:NSRegularExpressionSearch];
    
    if (range.location != NSNotFound) {
        //NSLog(@"%@", [searchText substringWithRange:range]);
        return [searchText substringWithRange:range];
    }
    return nil;
}




-(ShowThreadPage *)parseShowThreadWithHtml:(NSString *)html{

    // 修改引用帖子的样式
    html = [html stringByReplacingOccurrencesOfString:@"<div class=\"smallfont\" style=\"margin-bottom:2px\">引用:</div>" withString:@""];
    
    // 查找设置了字体的回帖
    NSArray * fontSetString = [html arrayWithRegulat:@"<font size=\"\\d+\">"];
    
    NSString * fixFontSizeHTML= html;
    
    for (NSString * tmp in fontSetString) {
        fixFontSizeHTML = [fixFontSizeHTML stringByReplacingOccurrencesOfString:tmp withString:@"<font size=\"\2\">"];
    }
    // 去掉_http hxxp
    NSString * fuxkHttp = fixFontSizeHTML;
    NSArray * httpArray = [fixFontSizeHTML arrayWithRegulat:@"(_http|hxxp|_https|hxxps)://[\\w\\-_]+(\\.[\\w\\-_]+)+([\\w\\-\\.,@?^=%&amp;:/~\\+#]*[\\w\\-\\@?^=%&amp;/~\\+#])?"];
    NSString * httpPattern = @"<a href=\"%@\" target=\"_blank\">%@</a>";
    for (NSString * http in httpArray) {
        NSString * fixedHttp = [http stringByReplacingOccurrencesOfString:@"_http://" withString:@"http://"];
        fixedHttp = [fixedHttp stringByReplacingOccurrencesOfString:@"hxxp://" withString:@"http://"];
        fixedHttp = [fixedHttp stringByReplacingOccurrencesOfString:@"hxxps://" withString:@"https://"];
        fixedHttp = [fixedHttp stringByReplacingOccurrencesOfString:@"_https://" withString:@"https://"];
        
        NSString * patterned = [NSString stringWithFormat:httpPattern, fixedHttp, fixedHttp];
        fuxkHttp = [fuxkHttp stringByReplacingOccurrencesOfString:http withString:patterned];
        
    }
    
    // 单纯的引用
    fuxkHttp = [fuxkHttp stringByReplacingOccurrencesOfString:@"<div id=\"wrap\">" withString:@"<div id=\"wrap\"><br />"];
    
    // 引用回帖--->
    NSString * quoteTable = @"<td class=\"alt2\" style=\"border:1px inset\">\r\n\t\t\t\r\n\t\t\t\t<div>\r\n\t\t\t\t\t.*: <strong>.*</strong>\r\n\t\t\t\t\t<a href=\".*\" rel=\"nofollow\"><img class=\"inlineimg\" src=\".*\" border=\"0\" alt=\".*\" /></a>\r\n\t\t\t\t</div>\r\n\t\t\t\t<div>\r\n\t\t\t<!-- 修改防止撑破表格 -->\r\n\t\t\t<div class=\"tb\">\r\n\t\t\t<div id=\"wrap\">";
    NSArray * quoteArry = [fuxkHttp arrayWithRegulat:quoteTable];

    for (NSString * quote in quoteArry) {
        NSString *author = [quote stringWithRegular:@"<strong>.*</strong>"];
        author = [NSString stringWithFormat:@"<td>\r\n\t\t\t<div>\r\n\t\t\t<br /><strong>@</strong>%@<strong>:</strong>", author];
        
        fuxkHttp = [fuxkHttp stringByReplacingOccurrencesOfString:quote withString:author];
    }
    
    
    NSString * quoteBottom = @"</div></div>\r\n\t\t\t<!--/ 修改防止撑破表格 -->\t\r\n\t\t\t</div>";
    NSArray * quoteBottomArray = [fuxkHttp arrayWithRegulat:quoteBottom];
    for (NSString * quote in quoteBottomArray) {
        fuxkHttp = [fuxkHttp stringByReplacingOccurrencesOfString:quote withString:@"\r\n\t\t\t<br /></div>"];
    }
    
    fuxkHttp = [fuxkHttp stringByReplacingOccurrencesOfString:@"</div></div>\r\n\t\t\t<!--/ 修改防止撑破表格 -->" withString:@"<br /></div></div>\r\n\t\t\t<!--/ 修改防止撑破表格 -->"];
    // <--- 引用回帖结束
    
    
    IGHTMLDocument *document = [[IGHTMLDocument alloc]initWithHTMLString:fuxkHttp error:nil];
    
    
    NSString * formId = [fuxkHttp stringWithRegular:@"newthread.php\\?do=newthread&amp;f=\\d+" andChild:@"\\d+"];
    
    ShowThreadPage * showThreadPage = [[ShowThreadPage alloc]init];
    showThreadPage.formId = formId;
    
    NSString * securityToken = [self parseSecurityToken:html];
    showThreadPage.securityToken = securityToken;
    
    NSString * ajaxLastPost = [self parseAjaxLastPost:html];
    showThreadPage.ajaxLastPost = ajaxLastPost;
    
    showThreadPage.dataList = [self parseShowThreadPosts:document];
    

    IGXMLNode * titleNode = [document queryWithXPath:@"/html/body/div[2]/div/div/table[2]/tr/td[1]/table/tr[2]/td/strong"].firstObject;
    showThreadPage.threadTitle = titleNode.text;
    

    IGXMLNodeSet * threadInfoSet = [document queryWithXPath:@"/html/body/div[4]/div/div/table[1]/tr/td[2]/div/table/tr"];
    
    if (threadInfoSet == nil || threadInfoSet.count == 0) {
        showThreadPage.totalPageCount = 1;
        showThreadPage.currentPage = 1;
        showThreadPage.totalCount = showThreadPage.dataList.count;
        
    } else{
        IGXMLNode *currentPageAndTotalPageNode = threadInfoSet.firstObject.firstChild;
        NSString * currentPageAndTotalPageString = currentPageAndTotalPageNode.text;
        NSArray *pageAndTotalPage = [currentPageAndTotalPageString componentsSeparatedByString:@"页，共"];
        
        showThreadPage.totalPageCount = [[[pageAndTotalPage.lastObject stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"页" withString:@""] intValue];
        showThreadPage.currentPage = [[[pageAndTotalPage.firstObject stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"第" withString:@""] intValue];
        
        IGXMLNode *totalPostCount = [threadInfoSet.firstObject children][1];
        
        NSString * totalPostString = [totalPostCount.firstChild attribute:@"title"];
        NSString *tmp = [totalPostString componentsSeparatedByString:@"共计 "].lastObject;
        showThreadPage.totalCount = [[tmp stringByReplacingOccurrencesOfString:@" 条." withString:@""] intValue];
        
    }
    
    return showThreadPage;
}






-(NSMutableArray<Post *> *)parseShowThreadPosts:(IGHTMLDocument *)document{
    
    NSMutableArray<Post*> * posts = [NSMutableArray array];
    
    // 发帖内容的 table -> td
    IGXMLNodeSet *postMessages = [document queryWithXPath:@"//*[@id='posts']/div[*]/div/div/div/table/tr[1]/td[2]"];
    
    // 发帖时间
    NSString * xPathTime = @"//*[@id='table1']/tr/td[1]/div";
    
    
    for (IGXMLNode * node in postMessages) {
        
        Post * ccfpost = [[Post alloc]init];
        
        
        NSString * postId = [[[node attribute:@"id"] componentsSeparatedByString:@"td_post_"]lastObject];
        
        
        IGXMLDocument * postDocument = [[IGHTMLDocument alloc] initWithHTMLString:node.html error:nil];
        
        IGXMLNode * time = [postDocument queryWithXPath:xPathTime].firstObject;
        
        
        NSString *xPathMessage = [NSString stringWithFormat:@"//*[@id='post_message_%@']", postId];
        IGXMLNode *message = [postDocument queryWithXPath:xPathMessage].firstObject;
        
        ccfpost.postContent = message.html;
        
        
        
        
        
        
        NSString * pattern = @"<img %@ width=\"300\" height=\"300\" />";
        
        
        NSString * imageByUrlReg = @"<img src=\"http.*\" border=\"0\" alt=\"\">";
        NSRegularExpression *imageByUrlRegx = [NSRegularExpression regularExpressionWithPattern:imageByUrlReg options:NSRegularExpressionCaseInsensitive error:nil];
        
        
        NSString * needFixHtml = ccfpost.postContent;
        
        NSArray * imageByUrlresult = [imageByUrlRegx matchesInString:needFixHtml options:0 range:NSMakeRange(0, needFixHtml.length)];
        for (NSTextCheckingResult *tmpresult in imageByUrlresult) {
            
            NSString * image = [needFixHtml substringWithRange:tmpresult.range];
            NSString * src = [image stringWithRegular:@"src=\"\\S*\""];
            NSString *fixedImage = [NSString stringWithFormat:pattern, src];
            ccfpost.postContent = [ccfpost.postContent stringByReplacingOccurrencesOfString:image withString:fixedImage];
        }
        
        
        
        
        NSString * reg = @"<img src=\"http.*\" border=\"0\" alt=\"(\\W*)?(.*)?(\n)?(\\W*)?(.*)?(\n)?(\\W*)?(.*)?\"( style=\"margin: 2px\")?>";
        
        //NSString * reg = @"<img src=\"http.*\" border=\"0\" alt=\"\">";
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:reg options:NSRegularExpressionCaseInsensitive error:nil];
        // 添加的图片
        NSString * html = message.html;
        NSArray * result = [regex matchesInString:html options:0 range:NSMakeRange(0, html.length)];
        for (NSTextCheckingResult *tmpresult in result) {
     
                NSString * image = [html substringWithRange:tmpresult.range];
                NSString * src = [image stringWithRegular:@"src=\"\\S*\""];
                NSString *fixedImage = [NSString stringWithFormat:pattern, src];
                ccfpost.postContent = [ccfpost.postContent stringByReplacingOccurrencesOfString:image withString:fixedImage];
        }
   
        
        
        //ccfpost.postContent = [ccfpost.postContent stringByReplacingOccurrencesOfString:@"border=\"0\" alt=\"\">" withString:@"width=\"300\" height=\"300\">"];

        // 上传的附件
        NSString *xPathAttImage = [NSString stringWithFormat:@"//*[@id='td_post_%@']/div[2]/fieldset/div", postId];
        IGXMLNode *attImage = [postDocument queryWithXPath:xPathAttImage].firstObject;

        
        if (attImage != nil) {

            NSString * allImage = @"";
            
            
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<img class=\"attach\" src=\"attachment.php\\?attachmentid=(\\d+)" options:NSRegularExpressionCaseInsensitive error:nil];
            
            NSArray * result = [regex matchesInString:attImage.html options:0 range:NSMakeRange(0, attImage.html.length)];
            
            for (NSTextCheckingResult *tmpresult in result) {
                
                //    <img class="attach" src="attachment.php?attachmentid=872113
                NSString * image = [[attImage.html substringWithRange:tmpresult.range] stringByAppendingString:@"\"><br>"];
                NSString * fixedImage = [image stringByReplacingOccurrencesOfString:@"class=\"attach\"" withString:@"width=\"300\" height=\"300\""];
                NSString * fixUrl = [fixedImage stringByReplacingOccurrencesOfString:@"src=\"attachment.php" withString:@"src=\"https://bbs.et8.net/bbs/attachment.php"];
                
                allImage = [allImage stringByAppendingString:fixUrl];

            }
            ccfpost.postContent = [ccfpost.postContent stringByAppendingString:allImage];
        }
        
        NSRange louCengRange = [time.text rangeOfString:@"#\\d+" options:NSRegularExpressionSearch];
        
        if (louCengRange.location != NSNotFound) {
            ccfpost.postLouCeng = [time.text substringWithRange:louCengRange];
        }
        
        
        NSRange timeRange = [time.text rangeOfString:@"\\d{4}-\\d{2}-\\d{2}, \\d{2}:\\d{2}:\\d{2}" options:NSRegularExpressionSearch];
        
        if (timeRange.location != NSNotFound) {
            ccfpost.postTime = [time.text substringWithRange:timeRange];
        }
        // 保存数据
        ccfpost.postID = postId;
        
        // 添加数据
        [posts addObject:ccfpost];
        
        
    }
    

    // 发帖账户信息 table -> td
    //*[@id='posts']/div[1]/div/div/div/table/tr[1]/td[1]
    IGXMLNodeSet *postUserInfo = [document queryWithXPath:@"//*[@id='posts']/div[*]/div/div/div/table/tr[1]/td[1]"];
    //*[@id="post"]/tbody/tr[1]/td[1]
    
    int postPointer = 0;
    for (IGXMLNode * userInfoNode in postUserInfo) {
        
        if(userInfoNode.children.count < 5){
            continue;
        }
        IGXMLNode *nameNode = userInfoNode.firstChild.firstChild;
        
        User* ccfuser = [[User alloc]init];
        
        NSString *name = nameNode.innerHtml;
        ccfuser.userName = name;
        NSString *nameLink = [nameNode attribute:@"href"];
        ccfuser.userLink = [@"https://bbs.et8.net/bbs/" stringByAppendingString:nameLink];
        ccfuser.userID = [nameLink stringWithRegular:@"\\d+"];
        //avatar
        IGXMLNode * avatarNode = userInfoNode.children[1];
        NSString * avatarLink = [[[avatarNode children] [1] firstChild] attribute:@"src"];
        
        avatarLink = [avatarLink stringWithRegular:@"/avatar(\\d+)_(\\d+).gif"];
        NSLog(@"showAvatar   ==== detail %@", avatarLink);

        //avatarLink = [[avatarLink componentsSeparatedByString:@"/"]lastObject];
        
        ccfuser.userAvatar = avatarLink;
        
        //rank
        IGXMLNode * rankNode = userInfoNode.children[3];
        ccfuser.userRank = rankNode.text;
        // 资料div
        IGXMLNode * subInfoNode = userInfoNode.children[4];
        // 注册日期
        IGXMLNode * signDateNode = [[subInfoNode children][1] children] [1];
        ccfuser.userSignDate = signDateNode.text;
        // 帖子数量
        IGXMLNode * postCountNode = [[subInfoNode children][1] children] [2];
        ccfuser.userPostCount = postCountNode.text;
        // 精华 解答 暂时先不处理
        //IGXMLNode * solveCountNode = subInfoNode;
        
        
        posts[postPointer].postUserInfo = ccfuser;
        
        Post * newPost = posts[postPointer];
        newPost.postUserInfo = ccfuser;
        [posts removeObjectAtIndex:postPointer];
        [posts insertObject:newPost atIndex:postPointer];

        postPointer ++;
    }
    
    return posts;
}


-(NSString *)parseAjaxLastPost:(NSString *)html{
    NSString *searchText = [html stringWithRegular:@"var ajax_last_post = \\d+;" andChild:@"\\d+"];
    return searchText;
}


-(NSString *)parseSecurityToken:(NSString *)html{
    NSString *searchText = html;
    
    NSRange range = [searchText rangeOfString:@"\\d{10}-\\S{40}" options:NSRegularExpressionSearch];
    
    if (range.location != NSNotFound) {
        NSLog(@"parseSecurityToken   %@", [searchText substringWithRange:range]);
        return [searchText substringWithRange:range];
    }
    
    
    return nil;
}

-(NSString *)parserPostStartTime:(NSString *)html{
    NSString * reg = @"poststarttime=\\d+";
    NSString *result = [html stringWithRegular:reg andChild:@"\\d+"];
    return result;
}


-(NSString *)parsePostHash:(NSString *)html{
    //<input type="hidden" name="posthash" value="81b4404ec1db053e78df16a3536ee7ab" />
    NSString * hash = [html stringWithRegular:@"<input type=\"hidden\" name=\"posthash\" value=\"\\w{32}\" />" andChild:@"\\w{32}"];
    
    return hash;
}

-(NSString *)parseLoginErrorMessage:(NSString *)html{
    // /html/body/div[2]/div/div/table[3]/tr[2]/td/div/div/div
    IGHTMLDocument *document = [[IGHTMLDocument alloc]initWithHTMLString:html error:nil];
    IGXMLNodeSet* contents = [document queryWithXPath: @"/html/body/div[2]/div/div/table[3]/tr[2]/td/div/div/div"];
    
    return contents.firstObject.text;
    
}

-(ForumDisplayPage *)parseFavThreadListFormHtml:(NSString *)html{
    ForumDisplayPage * page = [[ForumDisplayPage alloc] init];
    
    NSString * path = @"/html/body/div[2]/div/div/table[3]/tr/td[3]/form[2]/table/tr[position()>2]";
    
    //*[@id="threadbits_forum_147"]/tr[1]
    
    NSMutableArray<SimpleThread *> * threadList = [NSMutableArray<SimpleThread *> array];
    
    IGHTMLDocument *document = [[IGHTMLDocument alloc]initWithHTMLString:html error:nil];
    IGXMLNodeSet* contents = [document queryWithXPath: path];
    
    NSInteger totaleListCount = -1;
    
    
    for (int i = 0; i < contents.count; i++){
        IGXMLNode * threadListNode = contents[i];
        
        if (threadListNode.children.count > 4) { // 要大于4的原因是：过滤已经被删除的帖子
            
            SimpleThread * simpleThread = [[SimpleThread alloc]init];
            
            // title
            IGXMLNode * threadTitleNode = threadListNode.children [2];
            
            NSString * titleInnerHtml = [threadTitleNode innerHtml];

            NSString *titleAndCategory = [self parseTitle: titleInnerHtml];
            //分离出Title 和 Category
            simpleThread.threadTitle = [self spliteTitle:titleAndCategory];
            simpleThread.threadCategory = [self spliteCategory:titleAndCategory];

            IGHTMLDocument * titleTemp = [[IGHTMLDocument alloc]initWithXMLString:titleAndCategory error:nil];
            
            //[@"showthread.php?t=" length]    17的由来
            simpleThread.threadID = [[titleTemp attribute:@"href"] substringFromIndex: 17];
            simpleThread.threadTitle = [titleTemp text];
            
            
            IGXMLNode * authorNode = threadListNode.children [3];
            
            NSString * authorIdStr = [authorNode innerHtml];
            simpleThread.threadAuthorID = [authorIdStr stringWithRegular:@"\\d+"];
            
            simpleThread.threadAuthorName = [authorNode text];
        
            [threadList addObject:simpleThread];
        }
    }
    
    // 总页数
    if (totaleListCount == -1) {
        IGXMLNodeSet* totalPageSet = [document queryWithXPath:@"//*[@id='inlinemodform']/table[4]/tr[1]/td[2]/div/table/tr/td[1]"];
        
        if (totalPageSet == nil) {
            totaleListCount = 1;
            page.totalPageCount = 1;
        }else{
            IGXMLNode * totalPage = totalPageSet.firstObject;
            NSString * pageText = [totalPage innerHtml];
            NSString * numberText = [[pageText componentsSeparatedByString:@"，"]lastObject];
            NSUInteger totalNumber = [numberText integerValue];
            NSLog(@"总页数：   %@", pageText);
            page.totalPageCount = totalNumber;
            totaleListCount = totalNumber;
        }
        
    } else{
        page.totalPageCount = totaleListCount;
    }
    page.dataList = threadList;
    
    return page;
}


-(SearchForumDisplayPage*)parseSearchPageFromHtml:(NSString *)html{
    IGHTMLDocument *document = [[IGHTMLDocument alloc]initWithHTMLString:html error:nil];
    IGXMLNodeSet * searchNodeSet = [document queryWithXPath:@"//*[@id='threadslist']/tr[*]"];
    
    if (searchNodeSet == nil || searchNodeSet.count == 0) {
        return nil;
    }
    
    
    SearchForumDisplayPage * resultPage = [[SearchForumDisplayPage alloc]init];

    IGXMLNode * postTotalCountNode = [document queryWithXPath:@"//*[@id='threadslist']/tr[1]/td/span[1]"].firstObject;

    NSString * postTotalCount = [postTotalCountNode.text stringWithRegular:@"共计 \\d+ 条" andChild:@"\\d+"];
    // 1. 结果总条数
    resultPage.totalPageCount = [postTotalCount integerValue];
    
    IGXMLNode * pageNode = [document queryWithXPath:@"/html/body/div[2]/div/div/table[3]/tr/td/div/table/tr/td[1]"].firstObject;
    // 2. 当前页数 和 总页数
    if (pageNode == nil) {
        resultPage.currentPage = 1;
        resultPage.totalPageCount = 1;
    } else{
        resultPage.currentPage = [[pageNode.text stringWithRegular:@"第 \\d+ 页" andChild:@"\\d+"] integerValue];
        resultPage.totalPageCount = [[pageNode.text stringWithRegular:@"共 \\d+ 页" andChild:@"\\d+"] integerValue];
    }
    
    NSMutableArray<ThreadInSearch*>* post = [NSMutableArray array];
    
    for (IGXMLNode *node in searchNodeSet) {
        
        if (node.children.count == 9) {
            // 9个节点是正确的输出结果
            ThreadInSearch * searchThread = [[ThreadInSearch alloc]init];
            
            IGXMLNode * postForNode = [node childrenAtPosition:2];
            
            NSLog(@"--------------------- %ld", [postForNode children].count);
            
            NSString * postIdNode = [postForNode html];
            NSString * postId = [postIdNode stringWithRegular:@"id=\"thread_title_\\d+\"" andChild:@"\\d+"];

            NSString * postTitle = [[[postForNode text] trim] componentsSeparatedByString:@"\n"].firstObject;
            NSString * postAuthor = [[node childrenAtPosition:3] text];
            NSString * postAuthorId = [[node.children[3] html] stringWithRegular:@"=\\d+" andChild:@"\\d+"];
            NSString * postTime = [node.children[4] text];
            NSString * postBelongForm = [node.children[8] text];
            
            searchThread.threadID = postId;
            
            NSString * fullTitle = [postTitle trim];
            
            searchThread.threadTitle = [self spliteTitle:fullTitle];
            searchThread.threadCategory = [self spliteCategory:fullTitle];
            searchThread.threadAuthorName = postAuthor;
            searchThread.threadAuthorID = postAuthorId;
            searchThread.lastPostTime = [postTime trim];
            searchThread.fromFormName = postBelongForm;
            
            
            [post addObject:searchThread];
        }
    }
    
    resultPage.redirectUrl = [self parseListMyThreadRedirectUrl: html];
    resultPage.dataList = post;
    
    return resultPage;
}

-(NSString *) spliteCategory:(NSString*)fullTitle{
    NSString * type = [fullTitle stringWithRegular:@"【.{1,4}】"];
    NSString * category = [type substringWithRange:NSMakeRange(1, type.length - 2)];
    return type == nil ? @"讨论" : category;
}

-(NSString *) spliteTitle:(NSString*)fullTitle{
    NSString * type = [fullTitle stringWithRegular:@"【.{1,4}】"];
    return type == nil ? fullTitle : [fullTitle substringFromIndex:type.length];
}

-(NSMutableArray<Forum *> *)parseFavFormFormHtml:(NSString *)html{
    
    IGHTMLDocument *document = [[IGHTMLDocument alloc]initWithHTMLString:html error:nil];
    IGXMLNodeSet * favFormNodeSet = [document queryWithXPath:@"//*[@id='collapseobj_usercp_forums']/tr[*]/td[2]/div[1]/a"];
    

    NSMutableArray* ids = [NSMutableArray array];
    
    //<a href="forumdisplay.php?f=158">『手机◇移动数码』</a>
    for (IGXMLNode *node in favFormNodeSet) {
        NSString * idsStr = [node.html stringWithRegular:@"f=\\d+" andChild:@"\\d+"];
        [ids addObject:[NSNumber numberWithInt:[idsStr intValue]]];
    }
    
    [[NSUserDefaults standardUserDefaults] saveFavFormIds:ids];


    // 通过ids 过滤出Form
    ForumCoreDataManager * manager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeForm];
    NSArray * result = [manager selectData:^NSPredicate *{
         return [NSPredicate predicateWithFormat:@"formId IN %@", ids];
    }];
    
    NSMutableArray<Forum *> * forms = [NSMutableArray arrayWithCapacity:result.count];
    
    for (FormEntry * entry in result) {
        Forum * form = [[Forum alloc] init];
        form.formName = entry.formName;
        form.formId = [entry.formId intValue];
        [forms addObject:form];
    }

    return forms;
}


-(ForumDisplayPage *)parsePrivateMessageFormHtml:(NSString *)html{
    ForumDisplayPage * page = [[ForumDisplayPage alloc] init];
    
    IGHTMLDocument *document = [[IGHTMLDocument alloc]initWithHTMLString:html error:nil];

    IGXMLNodeSet * totalPage = [document queryWithXPath:@"//*[@id='pmform']/table[1]/tr/td/div/table/tr/td[1]"];
    //<td class="vbmenu_control" style="font-weight:normal">第 1 页，共 5 页</td>
    NSString * fullText = [[totalPage firstObject] text];
    NSString * currentPage = [fullText stringWithRegular:@"第 \\d+ 页" andChild:@"\\d+"];
    page.currentPage = [currentPage integerValue];
    NSString * totalPageCount = [fullText stringWithRegular:@"共 \\d+ 页" andChild:@"\\d+"];
    page.totalPageCount = [totalPageCount integerValue];
    
    
    
    
    IGXMLNodeSet * totalCount = [document queryWithXPath:@"//*[@id='pmform']/table[1]/tr/td/div/table/tr/td[7]"];
    NSString * totalCountStr = [[[totalCount firstObject] html] stringWithRegular:@"共计 \\d+" andChild:@"\\d+"];
    page.totalCount = [totalCountStr integerValue];
    
    
    
    NSMutableArray<PrivateMessage*> * messagesList  = [NSMutableArray array];
    
    IGXMLNodeSet *messages = [document queryWithXPath:@"//*[@id='pmform']/table[2]/tbody[*]/tr"];
    for (IGXMLNode * node in messages) {
        long childCount = [[node children] count];
        if (childCount == 4) {
            // 有4个节点说明是正常的站内短信
            PrivateMessage * message = [[PrivateMessage alloc] init];
            
            IGXMLNodeSet * children = [node children];
            // 1. 是不是未读短信
            IGXMLNode * unreadFlag = children[0];
            message.isReaded = ![[unreadFlag html] containsString:@"pm_new.gif"];
            
            // 2. 标题
            IGXMLNode * title = [children[2] children][0];
            NSString * titleStr = [[title children] [1] text];
            message.pmTitle = titleStr;
            
            NSString * messageLink = [[[title children] [1] attribute:@"href"] stringWithRegular:@"\\d+"];
            message.pmID = messageLink;
            
            
            NSString * timeDay = [[title children] [0] text];
            
            // 3. 发送PM作者
            IGXMLNode * author = [children[2] children][1];
            NSString * authorText = [[author children] [1] text];
            message.pmAuthor = authorText;
            
            // 4. 发送者ID
            NSString *authorId;
            if (message.isReaded) {
                authorId = [[author children][1] attribute:@"onclick"];
                authorId = [authorId stringWithRegular:@"\\d+"];
            } else{
                IGXMLNode *strongNode = [author children][1];
                strongNode = [strongNode children][0];
                authorId = [strongNode attribute:@"onclick"];
                authorId = [authorId stringWithRegular:@"\\d+"];
            }
            message.pmAuthorId = authorId;

            // 5. 时间
            NSString * timeHour = [[author children] [0] text];
            message.pmTime = [[timeDay stringByAppendingString:@" "] stringByAppendingString:timeHour];
            
            [messagesList addObject:message];
            
        }
    }
    
    page.dataList = messagesList;
    
    return page;
    
}


-(ShowPrivateMessage *)parsePrivateMessageContent:(NSString *)html{
    // 修改引用帖子的样式
    html = [html stringByReplacingOccurrencesOfString:@"<div class=\"smallfont\" style=\"margin-bottom:2px\">引用:</div>" withString:@"<div class=\"smallfont\" style=\"margin-bottom:2px\"><br /></div>"];
    
    IGHTMLDocument *document = [[IGHTMLDocument alloc]initWithHTMLString:html error:nil];
    
    // message content
    ShowPrivateMessage * privateMessage = [[ShowPrivateMessage alloc] init];
    IGXMLNodeSet * contentNodeSet = [document queryWithXPath:@"//*[@id='post_message_']"];
    privateMessage.pmContent = [[contentNodeSet firstObject] html];
    // 回帖时间
    IGXMLNodeSet * privateSendTimeSet = [document queryWithXPath:@"//*[@id='table1']/tr/td[1]/div/text()"];
    privateMessage.pmTime = [[privateSendTimeSet [2] text] trim];
    // PM ID
    IGXMLNodeSet * privateMessageIdSet = [document queryWithXPath:@"/html/body/div[2]/div/div/table[2]/tr/td[1]/table/tr[2]/td/a"];
    NSString * pmId = [[[privateMessageIdSet firstObject] attribute:@"href"] stringWithRegular:@"\\d+"];
    privateMessage.pmID = pmId;
    
    // PM Title
    IGXMLNodeSet * pmTitleSet = [document queryWithXPath:@"/html/body/div[2]/div/div/table[2]/tr/td[1]/table/tr[2]/td/strong"];
    NSString * pmTitle = [[[pmTitleSet firstObject] text] trim];
    privateMessage.pmTitle = pmTitle;
    
    
    // User Info
    User * pmAuthor = [[User alloc] init];
    IGXMLNode *userInfoNode = [document queryNodeWithXPath:@"//*[@id='post']/tr[1]/td[1]"];
    // 用户名
    NSString * name = [[[userInfoNode childrenAtPosition:0] childrenAtPosition:0] text];
    pmAuthor.userName = name;
    // 用户ID
    NSString * userId = [[[[userInfoNode childrenAtPosition:0] childrenAtPosition:0] attribute:@"href"] stringWithRegular:@"\\d+"];
    pmAuthor.userID = userId;
    
    // 用户头像
    NSString* userAvatar = [[[[[[userInfoNode childrenAtPosition:1] childrenAtPosition:1] childrenAtPosition:0] attribute:@"src"] componentsSeparatedByString:@"/"] lastObject];
    pmAuthor.userAvatar = userAvatar;
    
    // 用户等级
    NSString * userRank = [[ userInfoNode childrenAtPosition:3] text];
    pmAuthor.userRank = userRank;
    // 注册日期
    NSString * userSignDate = [[[[[[userInfoNode childrenAtPosition:4] childrenAtPosition:1] childrenAtPosition:1] text] componentsSeparatedByString:@": "] lastObject];
    pmAuthor.userSignDate = userSignDate;
    // 帖子数量
    NSString * postCount = [[[[[[[userInfoNode childrenAtPosition:4] childrenAtPosition:1] childrenAtPosition:2] text] trim] componentsSeparatedByString:@": "] lastObject];
    pmAuthor.userPostCount = postCount;
    
    // 精华 和 解答

    //===========
    
    privateMessage.pmUserInfo = pmAuthor;
    return privateMessage;
}

-(NSString *)parseQuickReplyQuoteContent:(NSString *)html{
    
    IGHTMLDocument *document = [[IGHTMLDocument alloc]initWithHTMLString:html error:nil];
    IGXMLNodeSet * nodeSet = [document queryWithXPath:@"//*[@id='vB_Editor_QR_textarea']"];
    NSString * node = [[nodeSet firstObject] text];
    return node;
}


-(NSString *)parseQuickReplyTitle:(NSString *)html{
    IGHTMLDocument *document = [[IGHTMLDocument alloc]initWithHTMLString:html error:nil];
    IGXMLNodeSet * nodeSet = [document queryWithXPath:@"//*[@id='message_form']/div[1]/div/div/div[3]/input[9]"];
    
    NSString * node = [[nodeSet firstObject] attribute:@"value"];
    return node;
    
}

-(NSString *)parseQuickReplyTo:(NSString *)html{
    IGHTMLDocument *document = [[IGHTMLDocument alloc]initWithHTMLString:html error:nil];
    IGXMLNodeSet * nodeSet = [document queryWithXPath:@"//*[@id='message_form']/div[1]/div/div/div[3]/input[10]"];
    NSString * node = [[nodeSet firstObject] attribute:@"value"];
    return node;
}
-(NSString *)parseUserAvatar:(NSString *)html userId:(NSString *)userId{
    NSString * regular = [NSString stringWithFormat:@"/avatar%@_(\\d+).gif", userId];
    NSString * avatar = [html stringWithRegular:regular];
    return avatar;
}



-(NSString *)parseListMyThreadRedirectUrl:(NSString *)html{
    NSString * xPath = @"/html/body/div[2]/div/div/table[2]/tr/td[1]/table/tr[2]/td/a";
    IGHTMLDocument *document = [[IGHTMLDocument alloc]initWithHTMLString:html error:nil];
    IGXMLNodeSet * nodeSet = [document queryWithXPath:xPath];
    
    return [nodeSet.firstObject attribute:@"href"];
    
}

-(UserProfile *)parserProfile:(NSString *)html userId:(NSString *)userId{
    IGHTMLDocument *document = [[IGHTMLDocument alloc]initWithHTMLString:html error:nil];
    UserProfile * profile = [[UserProfile alloc] init];
    // 用户名
    NSString * userNameXPath = @"//*[@id='username_box']/h1/text()";
    profile.profileName = [[self queryText:document withXPath:userNameXPath] trim];
    
    // 用户等级
    NSString * rankXPath = @"//*[@id='username_box']/h2";
    profile.profileRank = [self queryText:document withXPath:rankXPath];
    
    // 注册日期
    NSString * signDatePattern = @"<li><span class=\"shade\">注册日期:</span> \\d{4}-\\d{2}-\\d{2}</li>";
    
    profile.profileRegisterDate = [html stringWithRegular:signDatePattern andChild:@"\\d{4}-\\d{2}-\\d{2}"];
    
    // 最近活动时间
    NSString * lastLoginDayXPath = @"//*[@id='collapseobj_stats']/div/fieldset[2]/ul/li[1]/text()";
    NSString * lastDay = [[self queryText:document withXPath:lastLoginDayXPath] trim];
    
    NSString * lastLoginTimeXPath = @"//*[@id='collapseobj_stats']/div/fieldset[2]/ul/li[1]/span[2]";
    NSString * lastTime = [[self queryText:document withXPath:lastLoginTimeXPath] trim];
    if (lastTime == nil) {
        lastTime = @"隐私";
        profile.profileRecentLoginDate = lastTime;
    } else{
        profile.profileRecentLoginDate = [NSString stringWithFormat:@"%@ %@", lastDay, lastTime];
    }
    
    
    // 帖子总数
    NSString * postCount = [html stringWithRegular:@"<li><span class=\"shade\">帖子总数:</span> ([0-9][,]?)+</li>" andChild:@"([0-9][,]?)+"];
    profile.profileTotalPostCount = postCount;
    
    profile.profileUserId = userId;
    return profile;
}


-(NSString *)queryText:(IGHTMLDocument*)document withXPath:(NSString*)xpath{
    IGXMLNodeSet * nodeSet = [document queryWithXPath:xpath];
    NSString * text = [nodeSet.firstObject text];
    return text;
}


-(NSArray<Forum *> *)parserForms:(NSString *)html{
    IGHTMLDocument *document = [[IGHTMLDocument alloc]initWithHTMLString:html error:nil];
    
    NSMutableArray<Forum *> * forms = [NSMutableArray array];
    
    //*[@id="content"]/ul
    
    NSString * xPath = @"//*[@id='content']/ul/li[position()>0]";
    
    IGXMLNodeSet * contents = [document query:xPath];
    
    int replaceId = 10000;
    for (IGXMLNode * child in contents) {
        [forms addObject:[self node2Form:child parentFormId:-1 replaceId:replaceId ++]];

    }

    NSMutableArray<Forum *> * needInsert = [NSMutableArray array];
    
    for (Forum *form in forms) {
        [needInsert addObjectsFromArray:[self flatForm:form]];
    }
    
    for (Forum * form in needInsert) {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>> %@     formId: %d     parentFormId:%d\n\n\n", form.formName, form.formId, form.parentFormId);
    }
    
    
    return [needInsert copy];
}


- (NSArray*) flatForm:(Forum*) form{
    NSMutableArray * resultArray = [NSMutableArray array];
    [resultArray addObject:form];
    for (Forum * childForm in form.childForms) {
        [resultArray addObjectsFromArray:[self flatForm:childForm]];
    }
    return resultArray;
}


-(Forum *) node2Form:(IGXMLNode*) node parentFormId:(int) parentFormId replaceId:(int) replaceId{
    Forum * parent = [[Forum alloc] init];
    NSString * name = [[node childrenAtPosition:0] text];
    NSString * url = [[node childrenAtPosition:0] html];
    int formId = [[url stringWithRegular:@"f-\\d+" andChild:@"\\d+"] intValue];
    int fixFormId = formId == 0 ? replaceId : formId;
    parent.formId = fixFormId;
    parent.parentFormId = parentFormId;
    parent.formName = name;
    
    if (node.childrenCount == 2) {
        IGXMLNodeSet * childSet = [node childrenAtPosition:1].children;
        NSMutableArray<Forum *> * childForms = [NSMutableArray array];
        
        for (IGXMLNode * childNode in childSet) {
            [childForms addObject:[self node2Form:childNode parentFormId:fixFormId replaceId:replaceId]];
        }
        parent.childForms = childForms;
    }
    
    return parent;
}




















@end
