//
//  TestAction.h
//  WorkingFrameWork
//
//  Created by mac on 2017/10/27.
//  Copyright © 2017年 macjinlongpiaoxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "Table.h"
#import "Common.h"
#import "Item.h"
#import "ViewController.h"
#import "AppDelegate.h"
#import "FileCSV.h"
#import "FileTXT.h"
#import "Folder.h"
#import "GetTimeDay.h"
#import "Param.h"
#import "AgilentE4980A.h"
#import "AgilentB2987A.h"
#import "SerialPort.h"
#import "UpdateItem.h"
#import "Plist.h"
#import "Common.h"
#import "TestStep.h"


typedef enum : NSUInteger {
    AutoCode,
    ManualCode,
} MyQrcCode;

@interface TestAction : NSObject
@property(nonatomic,strong)Table  * tab;
@property(nonatomic,strong)NSTextField  * resultTF;
@property(nonatomic,strong)NSTextView   * Log_View;
@property(nonatomic,strong)NSTextView   * Fail_View;
@property(nonatomic,strong)NSTextField  * dutTF;
@property(nonatomic,strong)NSString     * toFold;


//需要传递写入csv中的值
@property(nonatomic,strong)NSString     * Version;               //版本号
@property(nonatomic,strong)NSString     * NestID;                //测试产品的型号
@property(nonatomic,strong)NSString     * Product_type;          //材料的类型
@property(nonatomic,strong)NSString     * Config_pro;            //配置文件的类型
@property(nonatomic,strong)NSString     * Operator_ID;           //操作员工的号码
@property(nonatomic,strong)NSDictionary * Config_Dic;            //上述相关参数


@property(nonatomic,strong)NSString     * fixture_uart_port_name;//治具名称
@property(nonatomic,strong)NSString     * fixture_uart_port_name_two;//治具名称
@property(nonatomic,strong)NSString     * fixture_uart_baud;     //治具波
@property(nonatomic,strong)NSString     * scan_uart_port_name;   //扫描枪

@property(nonatomic,strong)NSString     * instrument_name;       //仿真仪器名称
@property(nonatomic,strong)NSString     * instrument_baud;       //仿真仪器波特率
@property(nonatomic,strong)NSString     * dut_sn;                //产品的SN
@property(nonatomic,strong)NSString     * csvTitle;              //csv文件的title
@property(nonatomic,strong)NSString     * sw_ver;                //软件版本
@property(nonatomic,strong)NSString     * sw_name;               //软件名称


@property(nonatomic,strong)NSString     * instr_4980;
@property(nonatomic,strong)NSString     * instr_2987;
@property(nonatomic,assign)BOOL           isTest;
@property(nonatomic,assign)BOOL           SNisRight;             //SN检测OK
@property(nonatomic,assign)MyQrcCode      qrCode;




//==================================
-(id)initWithTable:(Table *)tab withFixParam:(Param *)param withType:(int)type_num;
-(void)TestAction; //测试流程
-(void)setDut_sn:(NSString *)dut_sn;
-(void)setCsvTitle:(NSString *)csvTitle;
-(void)threadStart;//线程开启
-(void)threadEnd;//线程结束


@end
