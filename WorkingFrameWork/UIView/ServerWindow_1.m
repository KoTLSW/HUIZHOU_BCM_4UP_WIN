//
//  ServerWindow.m
//  BCM
//
//  Created by mac on 05/08/2018.
//  Copyright © 2018 macjinlongpiaoxu. All rights reserved.
//

#import "ServerWindow.h"
#import "Param.h"

@interface ServerWindow ()
{
  
    __weak IBOutlet NSTextField *Station_Name_TF;
    
    __weak IBOutlet NSTextField *Station_ID_TF;
    
    __weak IBOutlet NSTextField *Server_IP_TF;
    
    __weak IBOutlet NSTextField *NetWork_Port;
    
    __weak IBOutlet NSTextField *setTimes_TF;
    
    
    __weak IBOutlet NSTextField *UseName_TF;
    
    
    __weak IBOutlet NSSecureTextField *PassWord_TF;
    
    
    __weak IBOutlet NSTextField *ShowWrongMessagfe;
    
    
    Param  *  param;
    
    NSDictionary  * dic;

}

@end

@implementation ServerWindow

-(id)init
{
    self = [super initWithWindowNibName:@"ServerWindow"];
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    //1.显示原始数据
    param = [[Param alloc]init];
    [param ParamRead:@"Param"];
    dic = [NSDictionary dictionaryWithDictionary:param.ServerFC];
    
    
    [Station_Name_TF setStringValue:dic[@"Station_Name"]];
    [Station_ID_TF setStringValue:dic[@"Station_ID"]];
    [Server_IP_TF setStringValue:dic[@"Server_IP"]];
    [NetWork_Port setStringValue:dic[@"Net_Port"]];
    [setTimes_TF setStringValue:param.FoamNum];
    
    //FoamNum
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


- (IBAction)Click_Button:(id)sender {
    
    if ([UseName_TF.stringValue isEqualToString:@"Eastwin"]&&[PassWord_TF.stringValue isEqualToString:@"Eastwin123"]) {
        
        //1读取plist
        NSString *plistPath = [[NSBundle mainBundle]pathForResource:@"Param" ofType:@"plist"];
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        NSMutableDictionary *subDic = [dictionary objectForKey:@"ServerFC"];
    
        //2.写入plist文件
        [subDic setObject:Station_Name_TF.stringValue forKey:@"Station_Name"];
        [subDic setObject:Station_ID_TF.stringValue forKey:@"Station_ID"];
        [subDic setObject:Server_IP_TF.stringValue forKey:@"Server_IP"];
        [subDic setObject:NetWork_Port.stringValue forKey:@"Net_Port"];
        [dictionary setObject:subDic forKey:@"ServerFC"];
        [dictionary setObject:setTimes_TF.stringValue forKey:@"FoamNum"];
        [dictionary writeToFile:plistPath atomically:YES];
        //3.退出程序
        exit(0);
    }
    else
    {
        [ShowWrongMessagfe setStringValue:@"账号或密码有误"];
        [UseName_TF setStringValue:@""];
        [PassWord_TF setStringValue:@""];
        
    }
}
@end
