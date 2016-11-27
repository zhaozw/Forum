//
// Created by WDY on 2016/11/24.
// Copyright (c) 2016 andforce. All rights reserved.
//

#import "NSData+UTF8.h"


@implementation NSData (UTF8)


- (NSString *) utf8String{
    NSString *string = [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
    if (string == nil) {
        string = [[NSString alloc] initWithData:[self UTF8Data] encoding:NSUTF8StringEncoding];
    }
    return string;
}

- (NSData *)UTF8Data {
    //保存结果
    NSMutableData *resData = [[NSMutableData alloc] initWithCapacity:self.length];

    NSData *replacement = [@"�" dataUsingEncoding:NSUTF8StringEncoding];

    uint64_t index = 0;
    const uint8_t *bytes = self.bytes;

    long dataLength = self.length;
    
    while (index < dataLength) {
        uint8_t len = 0;
        uint8_t header = bytes[index];

        //单字节
        if ((header & 0x80) == 0) {
            len = 1;
            [resData appendBytes:bytes + index length:1];
            
            index += 1;
        }
            //2字节(并且不能为C0,C1)
        else if ((header & 0xE0) == 0xC0) {
            
            if (index + 1 <= dataLength -1) {
                uint8_t nextHeader = bytes[index + 1];
                if ((nextHeader & 0xC0) == 0x80) {
                    len = 2;
                    [resData appendBytes:bytes + index length:2];
                }
            }
            
            index += 2;
//            if (header != 0xC0 && header != 0xC1) {
//                len = 2;
//            }
        }
            //3字节
        else if ((header & 0xF0) == 0xE0) {
            if (index + 2 <= dataLength -1) {
                uint8_t nextHeader = bytes[index + 1];
                if ((nextHeader & 0xC0) == 0x80) {
                    uint8_t lastHeader = bytes[index + 2];
                    if ((lastHeader & 0xC0) == 0x80) {
                        //len = 3;
                        
                        NSMutableData *text = [[NSMutableData alloc] initWithCapacity:3];
                        [text appendBytes:bytes + index length:3];
                        NSString *orgHtml = [[NSString alloc] initWithData:text encoding:NSUTF8StringEncoding];
                        if (orgHtml == nil) {
                            [resData appendData:replacement];
                        } else{
                            [resData appendBytes:bytes + index length:3];
                        }
                    }
                }
            }
            
//            if (header == 0xed && bytes[index + 1] == 0xbf && bytes[index + 2] == 0xbd) {
//                len = 0;
//            } else{
//                len = 3;
//            }
            index += 3;
        }
            //4字节(并且不能为F5,F6,F7)
        else if ((header & 0xF8) == 0xF0) {
            if (header != 0xF5 && header != 0xF6 && header != 0xF7) {
                len = 4;
                [resData appendBytes:bytes + index length:4];
            }
            index += 4;
        } else{
            len = 0;
        }

//        //无法识别
//        if (len == 0) {
//            [resData appendData:replacement];
//            index++;
//            continue;
//        }
//
//        //检测有效的数据长度(后面还有多少个10xxxxxx这样的字节)
//        uint8_t validLen = 1;
//        while (validLen < len && index + validLen < self.length) {
//            if ((bytes[index + validLen] & 0xC0) != 0x80)
//                break;
//            validLen++;
//        }
//
//        //有效字节等于编码要求的字节数表示合法,否则不合法
//        if (validLen == len) {
//            [resData appendBytes:bytes + index length:len];
//        } else {
//            [resData appendData:replacement];
//        }
//
//        //移动下标
//        index += validLen;
    }

    return resData;
}
@end
