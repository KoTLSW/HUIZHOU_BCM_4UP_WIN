
//  TestAction.m
//  WorkingFrameWork
//
//  Created by mac on 2017/10/27.
//  Copyright © 2017年 macjinlongpiaoxu. All rights reserved.
//

#import "TestAction.h"
#import "FileTXT_N.h"




#define SNChangeNotice  @"SNChangeNotice"
NSString  *param_path=@"Param";

@interface TestAction ()
{
    
    //************ testItems ************
    double num;
    NSMutableArray  *txtLogMutableArr;
    NSString        *agilentReadString;
    NSDictionary    *dic;
    NSString        *SonTestName;
    NSString        *testResultStr;                           //测试结果
    NSMutableArray  *testResultArr;                           // 返回的结果数组
    NSMutableArray  *testItemTitleArr;                        //每个测试标题都加入数组中,生成数据文件要用到
    NSMutableArray  *testItemValueArr;                        //每个测试结果都加入数组中,生成数据文件要用到
    NSMutableArray  *testItemMinLimitArr;                     //每个测试项最小值数组
    NSMutableArray  *testItesmMaxLimitArr;                    //每个测试项最大值数组
    NSMutableArray  *testItemUnitArr;

    
    //************  各种类的定义 ***********
    NSThread        * thread;                                   //开启的线程
    AgilentE4980A   * agilentE4980A;                            //LCR表
    AgilentB2987A   * agilentB2987A;                            //静电计
    SerialPort      * serialport;                               //串口通讯类
    SerialPort      * scanport;                                 //扫码枪串口
    UpdateItem      * updateItem;                               //
    Plist           * plist;                                    //plist文件处理类
    
    
    int        delayTime;
    int        index;                                         // 测试流程下标
    int        item_index;                                    // 测试项下标
    int        row_index;                                     // table 每一行下标
    Item     * testItem;                                      //测试项
    Item     * showItem;                                      //显示的测试项
    
    
    NSString * fixtureBackString;                             //治具返回来的数据
    NSString * testvalue;                                   //测试项的字符串
   
    Folder       * fold;                                      //文件夹的类
    FileCSV      * csv_file;                                  //csv文件的类
    FileCSV      * total_file;                                //写csv总文件
    FileTXT      * txt_file;                                  //txt文件
    FileTXT_N    * txt_N_file;
    
    
    //************* timer *************
    NSString            * start_time;                         //启动测试的时间
    NSString            * end_time;                           //结束测试的时间
    GetTimeDay          * timeDay;                            //创建日期类
    
    //csv数据相关处理
    NSMutableArray * ItemArr;                                 //存测试对象的数组
    NSMutableArray * TestValueArr;                            //存储测试结果的数
    NSMutableString     * txtContentString;                   //打印txt文件中的log
    NSMutableString     * listFailItemString;                 //测试失败的项目
    NSMutableString     * ErrorMessageString;                 //失败测试项的原因
    
    //新增加测试时时的Log值
    NSString            * testLogPath;                        //生成的时时LOG值
    
    //检测PDCA和SFC的BOOL//测试结果PASS、FAIL
    BOOL      isPDCA;
    BOOL      isSFC;
    BOOL       PF;
    
    //存储生成文件的具体地址
    NSString   * eachCsvDir;
    int          fix_type;
    
    //所有的测试项均存入字典中
    NSMutableDictionary  * store_Dic;                          //所有的测试项存入字典中

    BOOL    nulltest;                                          //产品进行空测试
    float   nullTimes;                                         //空测试的次数
    double  B_E_Sum;                                           //产品测试nullTimes的总和
    double  B2_E2_Sum;                                         //产品测试B2_E2
    double  B4_E4_Sum;                                         //产品测试B4_E4
    double  ABC_DEF_Sum;                                       //产品测试ABC_DEF
    double  Cap_Sum;                                           //治具的容抗值
    
    //处理SFC相关的类
    BYDSFCManager          * sfcManager;                         //处理sfc的类
    TestStep               * teststep;                           //处理上传的方法
    NSString               * FixtureID;                          //治具的ID
    
    BOOL                   is_LRC_Collect;                       //LCR表是否连接
    BOOL                   is_JDY_Collect;                       //静电仪是否连接
    NSMutableString         * dcrAppendString;                    //DCR拼接的数据
    BOOL                   addDcr;                               //40组DCR数
    BOOL                   isDebug;
    
    //param.plist文件中的值
    NSString              * singleFloder;                        //共享文件路径
    BOOL                    Instrument;                          //仪器是否连接OK
    
    
    
    
}
@end

@implementation TestAction

/**相关的说明
  1.Fixture ID 返回的值    Fixture ID?\r\nEW011X*_*\r\n       其中x代表治具中A,B,C,D

 
 
*/


-(id)initWithTable:(Table *)tab withFixParam:(Param *)param withType:(int)type_num;
{
    
    if (self == [super init]) {
        
        isDebug      = param.isDebug;
        singleFloder = param.SingleFolder;
        
        
        NSDictionary  * fix;
        if (type_num == 1) fix = param.Fix1;
        if (type_num == 2) fix = param.Fix2;
        if (type_num == 3) fix = param.Fix3;
        if (type_num == 4) fix = param.Fix4;
        
        
        //初始化各种数据及其设备消息
        self.fixture_uart_port_name     = [fix objectForKey:@"fixture_uart_port_name"];
        self.fixture_uart_port_name_two = [fix objectForKey:@"fixture_uart_port_name_two"];
        self.fixture_uart_baud      = [fix objectForKey:@"fixture_uart_baud"];
        self.scan_uart_port_name    = [fix objectForKey:@"scan_uart_port_name"];
        self.instr_2987             = [fix objectForKey:@"b2987_adress"];
        self.instr_4980             = [fix objectForKey:@"e4980_adress"];
//        
//        testLogPath                 = [NSString stringWithFormat:@"%@/%@",[[NSUserDefaults standardUserDefaults] objectForKey:kTotalFoldPath],@"TestLog.txt"];
    
        //初始化各种的整型变量
        self.tab =tab;
        fix_type = type_num;
        index = 0;
        item_index   = 0;
        row_index    = 0;
        nullTimes    = 0;
        B_E_Sum      = 0;
        B2_E2_Sum    = 0;
        B4_E4_Sum    = 0;
        ABC_DEF_Sum  = 0;
        Cap_Sum      = 0;

        PF =  YES;
        addDcr  = NO;
        Instrument = NO;
        self.SNisRight = NO;
        
        _qrCode = ManualCode;

        //初始化各类数组和可变字符串
        ItemArr         = [[NSMutableArray alloc]initWithCapacity:10];
        TestValueArr    = [[NSMutableArray alloc] initWithCapacity:10];
        txtContentString=[[NSMutableString alloc]initWithCapacity:10];
        listFailItemString=[[NSMutableString alloc]initWithCapacity:10];
        ErrorMessageString=[[NSMutableString alloc]initWithCapacity:10];
        dcrAppendString = [[NSMutableString alloc] initWithCapacity:10];
        store_Dic = [[NSMutableDictionary alloc] initWithCapacity:10];


        plist = [Plist shareInstance];

        //初始化各种串口
        timeDay     =  [GetTimeDay shareInstance];
        sfcManager  =  [BYDSFCManager Instance];
        serialport  =  [[SerialPort alloc]init];
        updateItem  =  [[UpdateItem alloc] init];
        agilentE4980A = [[AgilentE4980A alloc]init];
        agilentB2987A = [[AgilentB2987A alloc]init];
        [serialport setTimeout:1 WriteTimeout:1];
        
        scanport = [[SerialPort alloc]init];
        
        //赋值
        updateItem.fix_ABC_DEF_Res  = [fix objectForKey:@"fix_ABC_DEF_Res"];
        updateItem.fix_B2_E2_Res    = [fix objectForKey:@"fix_B2_E2_Res"];
        updateItem.fix_B4_E4_Res    = [fix objectForKey:@"fix_B4_E4_Res"];
        updateItem.fix_B_E_Res      = [fix objectForKey:@"fix_B_E_Res"];
        updateItem.fix_Cap          = [fix objectForKey:@"fix_Cap"];
        //初始化文件处理类
        csv_file  = [[FileCSV alloc] init];
        //csv_file  = [FileCSV shareInstance];
        [csv_file addGlobalLock];
        txt_file  = [FileTXT shareInstance];
//        [txt_file TXT_Open:testLogPath];
        total_file= [[FileCSV alloc] init];
        [total_file addGlobalLock];
        fold     =  [[Folder  alloc] init];
        teststep = [TestStep Instance];
        [teststep addGlobalLock];
        
        txt_N_file = [FileTXT_N shareInstance];

        
       //=======================定义通知
        //监听启动
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NSThreadStart_Notification:) name:@"NSThreadStart_Notification" object:nil];
        //监听测试结束通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NSThreadEnd_Notification:) name:@"NSThreadEnd_Notification" object:nil];
        //监听空测试
        [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(selectNullTestNoti:) name:kNullTestNotice object:nil];
        //监听PDCA
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectPDCAandSCFNoti:) name:kPdcaUploadNotice object:nil];
        //监听SFC
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectPDCAandSCFNoti:) name:kSfcUploadNotice object:nil];
        //写入空测的值
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(writeNullValueToPlist:) name:@"WriteNullValue" object:nil];
        //Test数据选择
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectTestDataNoti:) name:kTest40DataNotice object:nil];
        //手动扫码
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectScanQRCode:) name:kManualScanQRCode object:nil];
        //自动扫码
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectScanQRCode:) name:kAutoScanQRCode object:nil];
        //重新检测SN扫码
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectScanQRCodeAgain:) name:kTestAgainNotice object:nil];
        
        //获取全局变量
        thread = [[NSThread alloc]initWithTarget:self selector:@selector(TestAction) object:nil];
        [thread start];
    }


     return  self;
}



-(void)TestAction
{
    while ([[NSThread currentThread] isCancelled]==NO) //线程未结束一直处于循环状态
    {
        
#pragma mark--------index = 0:连接治具
        if (index == 0) {
            
            [NSThread sleepForTimeInterval:0.5];
            
            if (isDebug) {
                 NSLog(@"%@==index= 0,连接治具%@,debug模式中",[NSThread currentThread],self.fixture_uart_port_name);
                //[txtContentString appendFormat:@"%@:index=0,进入debug模式",[timeDay getFileTime]];
                [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,进入debug模式",index]];
                [self UpdateTextView:@"index=0,进入debug模式" andClear:YES andTextView:self.Log_View];
                 index =1;
            }
            else
            {
                [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,治具开始连接",index]];
                 BOOL isCollect = [serialport Open:self.fixture_uart_port_name]||[serialport Open:self.fixture_uart_port_name_two];
                if (isCollect) {
                    
                     //发送指令获取ID的值
                    [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,治具连接成功",index]];
                    [NSThread sleepForTimeInterval:0.2];
                    [serialport WriteLine:@"Fixture ID?"];
                    [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,Fixture ID?",index]];
                    [NSThread sleepForTimeInterval:0.5];
                    FixtureID = [serialport ReadExisting];
                    if ([FixtureID containsString:@"\r\n"]&&[FixtureID containsString:@"*_*"]) {
                        FixtureID = [[FixtureID componentsSeparatedByString:@"\r\n"] objectAtIndex:1];
                        FixtureID = [FixtureID stringByReplacingOccurrencesOfString:@"*_*" withString:@""];
                        index =1;
                    }
                    [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,Fixture ID=%@",index,FixtureID]];
                    
                     NSLog(@"index= 0,连接治具%@",self.fixture_uart_port_name);
                    //[txtContentString appendFormat:@"%@:index=0,治具已经连接\n",[timeDay getFileTime]];
                    [self UpdateTextView:@"index=0,治具已经连接" andClear:NO andTextView:self.Log_View];
                    
                  
                }
            }
        }
        

#pragma mark--------index = 1:连接扫码器
        if (index == 1) {
            
            [NSThread sleepForTimeInterval:0.5];
            
            if (isDebug) {
                
                [self UpdateTextView:@"index=1,debug模式，扫码器连接" andClear:NO andTextView:self.Log_View];
                [self writeTestLog:fix_type withString:@"index=1,debug模式，扫码器连接"];
                
                index = 2;
            }
            else
            {
                if (_qrCode == AutoCode) {
                    
                    [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,扫码器开始连接",index]];
                    BOOL iscollect = [scanport Open:self.scan_uart_port_name];
                    
                    NSLog(@"%d===========%@",fix_type,self.scan_uart_port_name);
                    
                    if (iscollect) {
                        
                        [self UpdateTextView:@"index=1,扫码器已经连接" andClear:NO andTextView:self.Log_View];
                        [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,扫码器连接成功",index]];
                        
                        index = 2;
                    }
                    else
                    {
                        [self UpdateTextView:@"index=1,扫码器未连接成功" andClear:NO andTextView:self.Log_View];
                        [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,扫码器连接失败",index]];
                        
                    }
                    
                }
               
                if (_qrCode == ManualCode) {
                    
                    index = 2;
                }
            }
         }
        
        
#pragma mark--------index = 2:连接LCR表4980 和 静电仪器2987A
        if (index == 2) {
            
            [NSThread sleepForTimeInterval:0.5];
            
            if (isDebug) {
                
                NSLog(@"index= 2,仿仪器出口已连接%@,debug模式中",self.instrument_name);
                //[txtContentString appendFormat:@"%@:index=2,debug模式中\n",[timeDay getFileTime]];
                [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,debug,仪器仪表已连接",index]];
                [self UpdateTextView:@"index=2,进入debug模式,仪表已连接" andClear:NO andTextView:self.Log_View];
                if (_qrCode == AutoCode) {
                    
                    index = 3;
                    [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=2,自动扫码,index设置为%d",index]];
                }
                if (_qrCode == ManualCode) {
                    
                    index = 1000;
                    [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=2,手动扫码,index设置为%d",index]];
                }
                
            }
            else
            {
                
                if (!is_LRC_Collect) {
                    [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,开始连接LCR表",index]];
                    is_LRC_Collect = [agilentE4980A Find:self.instr_4980 andCommunicateType:AgilentE4980A_Communicate_DEFAULT]&&[agilentE4980A OpenDevice:nil andCommunicateType:AgilentE4980A_USB_Type];
                }
                
                if (!is_LRC_Collect){
                     NSLog(@"LCR-4980 Not Connected");
                    [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,LCR表连接失败",index]];
                    [self UpdateTextView:@"index=1,LCR-4980 Not Connected" andClear:NO andTextView:self.Log_View];
                }
                else{
                    NSLog(@"LCR-4980 Connected");
                    [self UpdateTextView:@"index=1,LCR-4980 Connected" andClear:NO andTextView:self.Log_View];
                    [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,LCR表连接成功",index]];
                }
                
                
                if (!is_JDY_Collect) {
                    
                    [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,开始连接静电仪",index]];
                    is_JDY_Collect = [agilentB2987A Find:self.instr_2987 andCommunicateType:AgilentB2987A_USB_Type]&&[agilentB2987A OpenDevice:self.instr_2987 andCommunicateType:AgilentB2987A_USB_Type];
                    
                }
                
                if (!is_JDY_Collect){
                    
                    NSLog(@"JDY-2987 Not Connected");
                    [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,静电仪连接失败",index]];
                    [self UpdateTextView:@"index=1,JDY-2987 Not Connected" andClear:NO andTextView:self.Log_View];
                }
                else
                {
                    NSLog(@"LCR-2987 Connected");
                    [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,静电仪连接成功",index]];
                    [self UpdateTextView:@"index=1,LCR-2987 Connected" andClear:NO andTextView:self.Log_View];
                    
                }
                
                if (is_LRC_Collect&&is_JDY_Collect) {
                    
                    //[txtContentString appendFormat:@"%@:index=1,测试仪器已连接\n",[timeDay getFileTime]];
                    [self UpdateTextView:@"index=1,测试仪器已连接" andClear:NO andTextView:self.Log_View];
                    [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,仪器连接成功",index]];
                    
                    Instrument = YES;
                    
                    if (_qrCode == AutoCode) {
                        
                        [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=2,自动扫码,index设置为%d",index]];
                        
                        index = 3;
                    }
                    if (_qrCode == ManualCode) {
                        
                        index = 1000;
                        [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=2,手动扫码,index设置为%d",index]];
                    }
                    
                }
            }
        }
        
#pragma mark--------index = 3:扫描SN
        if (index == 3) {
            
            if (_qrCode == AutoCode) {
                
                [NSThread sleepForTimeInterval:0.5];
                if (isDebug) {
                    
                    [self UpdateTextView:@"index=3,获取了SN" andClear:NO andTextView:self.Log_View];
                     _dut_sn = @"222222222222222222222";
                     NSLog(@"打印SN%d的值%@",fix_type,_dut_sn);
                    [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,SN=%@",index,_dut_sn]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kPushSNNotice object:[NSString stringWithFormat:@"%d=%@",fix_type,_dut_sn]];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                       
                        [self.dutTF setStringValue:_dut_sn];
                    });
                    
                    [self writeTestLog:fix_type withString:@"index=3,SN传递到控制主流程"];
                    index = 1000;
                }
                else
                {
                    if ([scanport IsOpen]) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [self.dutTF setStringValue:@""];
                        });
                        [NSThread sleepForTimeInterval:0.2];
                        [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,扫码枪发送LON开始扫码",index]];
                        [scanport WriteLine:@"LON"];
                        [NSThread sleepForTimeInterval:0.5];
                        _dut_sn = [scanport ReadExisting];
                        if ([_dut_sn containsString:@"ERROR"]) {
                            _dut_sn = [[_dut_sn componentsSeparatedByString:@"\n"] objectAtIndex:1];
                        }
                        [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,获取SN:%@",index,_dut_sn]];
                        [scanport WriteLine:@"LOFF"];
                        [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,扫码枪发送LOFF结束扫码",index]];
                       
                        if ([_dut_sn length]>17) {
                            //[txtContentString appendFormat:@"%@:index=3,扫描到了SN\n",[timeDay getFileTime]];
                            [self UpdateTextView:[NSString stringWithFormat:@"获取SN:%@",_dut_sn] andClear:NO andTextView:self.Log_View];
                            [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,sn=%@",index,_dut_sn]];
                            //发送通知，传递SN
                            NSLog(@"subIndex=3,第三步:传递获取的SN:%@",_dut_sn);
                            if (_dut_sn.length>21) {
                                _dut_sn = [_dut_sn substringToIndex:21];
                            }
                            if (17<_dut_sn.length&&_dut_sn.length<21) {
                                _dut_sn = [_dut_sn substringToIndex:17];
                            }
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                [self.dutTF setStringValue:_dut_sn];
                            });
                            
                            
                            [self writeTestLog:fix_type withString:@"index=3,SN传递到控制主流程"];
                            [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,SN传递到控制主流程",index]];
                            index = 1000;
                        }
                        else
                        {
                            [self UpdateTextView:@"index=3,未成功获取SN" andClear:NO andTextView:self.Log_View];
                            [self writeTestLog:fix_type withString:@"index=3,未成功获取SN"];
                            
                        }
                        
                    }
                    
                }
            }
            else
            {
                index = 4;
            }
        }
    
        
#pragma mark--------index = 4:获取输入框中的SN
        if (index == 4) {
            //通过通知抛过来SN，以及气缸的状态
            NSLog(@"index= 4,检测SN,并打印SN的值%@",_dut_sn);
           //启动测试的时间,csv里面用
            start_time = [[GetTimeDay shareInstance] getFileTime];
            //[txtContentString appendFormat:@"%@:index=4,SN已经检验成功\n",[timeDay getFileTime]];
            [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,SN已经检验成功",index]];
            [self UpdateTextView:@"index=4,SN已经检验成功" andClear:NO andTextView:self.Log_View];
            index =5;

        }
    
        
#pragma mark--------index = 5:进入正常测试中
        if (index == 5) {
            
            [NSThread sleepForTimeInterval:0.3];
            
            NSLog(@"index= 5,进入测试%@",self.fixture_uart_port_name);
            //[txtContentString appendFormat:@"%@:index=5,正式进入测试\n",[timeDay getFileTime]];
            [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,正式进入测试",index]];
            NSLog(@"打印tab中数组中的值%lu",(unsigned long)[self.tab.testArray count]);
            
            testItem = [[Item alloc]initWithItem:self.tab.testArray[item_index]];
            
            BOOL isPass =[self TestItem:testItem];
            
            if (isPass) {//测试成功
                
                [self UpdateTextView:[NSString stringWithFormat:@"index=5:%@ 测试OK",testItem.testName] andClear:NO andTextView:self.Log_View];
                [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,%@测试:Pass",index,testItem.testName]];
                
            }
            else//测试结果失败
            {
                 [self UpdateTextView:[NSString stringWithFormat:@"index=5:%@ 测试NG",testItem.testName] andClear:NO andTextView:self.Log_View];
                 [self UpdateTextView:[NSString stringWithFormat:@"FailItem:%@\n",testItem.testName] andClear:NO andTextView:self.Fail_View];
                 [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,%@测试:Fail",index,testItem.testName]];
                
            }
    
            //刷新界面
                 [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=5,%@-->刷新",testItem.testName]];
                 [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,%@-->刷新",index,testItem.testName]];
                 [self.tab flushTableRow:testItem RowIndex:row_index with:fix_type];

            
            item_index++;
            row_index++;
            //走完测试流程,进入下一步
            if (item_index == [self.tab.testArray count])
            {
                //给设备复位
                //[txtContentString appendFormat:@"%@:index=5,测试项测试结束\n",[timeDay getFileTime]];
                [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,%@-->测试结束",index,testItem.testName]];
                [self UpdateTextView:@"index=5,测试项测试结束" andClear:NO andTextView:self.Log_View];
                index = 6;
                
            }
            
        }
        
#pragma mark--------index = 6:生成本地数据
        if (index == 6) {
            
            
           //测试结束的时间,csv里面用
            end_time = [[GetTimeDay shareInstance] getFileTime];
            [NSThread sleepForTimeInterval:0.2];
            NSString * path = [[NSUserDefaults standardUserDefaults] objectForKey:kTotalFoldPath];
            //判断是否包含当前日期
            if (![path containsString:[timeDay getCurrentDay]]) {
                
                 path = [path stringByReplacingOccurrencesOfString:[path substringWithRange:NSMakeRange(11, 10)] withString:[timeDay getCurrentDay]];
            }
            self.Config_pro   = [self.Config_Dic objectForKey:kConfig_pro];
            self.NestID       = [self.Config_Dic objectForKey:kProductNestID];
            
            NSString * totalPath  = [NSString stringWithFormat:@"%@/%@/%@",path,self.NestID,[self.Config_pro length]>0?self.Config_pro:@"NoConfig"];
            NSLog(@"打印总文件的位置%d=========%@",fix_type,totalPath);
            
            [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,总文件路径:%@",index,totalPath]];
            [fold Folder_Creat:totalPath];
             NSString   * configCSV = [self backTotalFilePathwithFloder:totalPath];
            
            if (total_file!=nil) {
                
                BOOL need_title = [total_file CSV_Open:configCSV];
                //[txtContentString appendFormat:@"%@:index=6,打开总csv文件->%@\n",[timeDay getFileTime],configCSV];
                [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,打开totalCSV文件",index]];
                
                [self SaveCSV:total_file withBool:need_title];
                //[txtContentString appendFormat:@"%@:index=6,添加数据到totalCSV文件->%@\n",[timeDay getFileTime],configCSV];
                [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,添加数据到totalCSV文件",index]];
                [self UpdateTextView:@"index=6,往总文件中添加数据" andClear:NO andTextView:self.Log_View];
            }
            

            //2.============================生成BCMSingleLog中的文件
            @synchronized (self)
            {
                 end_time = [[GetTimeDay shareInstance] getFileTime];
                 [fold Folder_Creat:singleFloder];
                 NSString * eachCsvFile = [NSString stringWithFormat:@"%@/%@_%@_%u.csv",singleFloder,self.dut_sn,end_time,arc4random()%100];
                 if (csv_file!=nil)
                 {
                    BOOL need_title = [csv_file CSV_Open:eachCsvFile];
                    [self SaveCSV:csv_file withBool:need_title];
                    //[txtContentString appendFormat:@"%@:index=6,生成生成Single_Log文件%@\n",[timeDay getFileTime],eachCsvFile];
                     [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=%d,添加数据到totalCSV文件",index]];
                     [self UpdateTextView:@"index=6,生成Single_Log文件" andClear:NO andTextView:self.Log_View];
                 }
            }
            
            
            //3.============================生成总文件夹下面的单个文件
            @synchronized (self)
            {
                //生成单个产品的value值csv文件
                [NSThread sleepForTimeInterval:0.2];
                eachCsvDir = [NSString stringWithFormat:@"%@/%@_%@",totalPath,self.dut_sn,[timeDay getCurrentMinuteAndSecond]];
                [fold Folder_Creat:eachCsvDir];
                NSString * eachCsvFile = [NSString stringWithFormat:@"%@/%@_%@_%u.csv",eachCsvDir,self.dut_sn,end_time,arc4random()%100];
                if (csv_file!=nil)
                {
                    BOOL need_title = [csv_file CSV_Open:eachCsvFile];
                    [self SaveCSV:csv_file withBool:need_title];
                    //[txtContentString appendFormat:@"%@:index=6,生成单个csv文件%@\n",[timeDay getFileTime],eachCsvFile];
                    [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"%@:index=6,生成单个csv文件%@\n",[timeDay getFileTime],eachCsvFile]];
                    [self UpdateTextView:@"index=6,生成单个CSV文件" andClear:NO andTextView:self.Log_View];
                }
                
                
            }
            
            
//            //生成log文件
//            NSString * logFile = [NSString stringWithFormat:@"%@/log.txt",eachCsvDir];
//            if (txt_file!=nil)
//            {
//                
//                [txt_file TXT_Open:logFile];
//                [txt_file TXT_Write:txtContentString];
//            }
            
            
            
            
           //===============================
            [NSThread sleepForTimeInterval:0.2];
            NSLog(@"index= 6,本地数据生成完成%@",self.fixture_uart_port_name);
            [self writeTestLog:fix_type withString:@"index=6,本地数据生成完成"];
            [self UpdateTextView:@"index=6,本地数据生成完成" andClear:NO andTextView:self.Log_View];
            index = 7;
        }
        
#pragma mark--------index = 7:上传PDCA和SFC
        if (index == 7)
        {
            
            //上传PDCA和SFC
            [NSThread sleepForTimeInterval:0.3];
            
            //[txtContentString appendFormat:@"%@:index=7,准备上传SFC\n",[timeDay getFileTime]];
            [self UpdateTextView:@"index=7,准备上传SFC" andClear:NO andTextView:self.Log_View];

            
            index = 8;
        }
        
 #pragma mark--------index = 8:显示测试值
        if (index == 8)
        {
            
            //清空字符串
            //txtContentString =[NSMutableString stringWithString:@""];
            listFailItemString = [NSMutableString stringWithString:@""];
            ErrorMessageString = [NSMutableString stringWithString:@""];
            dcrAppendString    = [NSMutableString stringWithString:@""];
            [ItemArr removeAllObjects];
            //插入config和OP
            [TestValueArr insertObject:[self.Config_Dic objectForKey:kOperator_ID] atIndex:0];
            [TestValueArr insertObject:self.Config_pro atIndex:0];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.resultTF setStringValue:PF?@"PASS":@"FAIL"];
                
               if (PF)
               {
                   [self.resultTF setTextColor:[NSColor greenColor]];
                   NSMutableDictionary  * resultdic = [[NSMutableDictionary alloc]initWithCapacity:10];
                   [resultdic setObject:TestValueArr forKey:@"dic"];
                   
                   [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=8,写入字典中的值%@",resultdic]];
                   [[NSNotificationCenter defaultCenter] postNotificationName:SNChangeNotice object:[NSString stringWithFormat:@"%dP",fix_type] userInfo:resultdic];
                   [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=8,传送字典中的值%@",resultdic]];
                   
                   [txt_N_file TXT_Write:[NSString stringWithFormat:@"time=%@,fixtype=%d,SN=%@,resultdic=%@\n",[timeDay getCurrentTime],fix_type,_dut_sn,resultdic]];
                }
                else
                {
                    [self.resultTF setTextColor:[NSColor redColor]];
                     NSMutableDictionary  * resultdic = [[NSMutableDictionary alloc]initWithCapacity:10];
                    [resultdic setObject:TestValueArr forKey:@"dic"];
                    [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=8,写入字典中的值%@",resultdic]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:SNChangeNotice object:[NSString stringWithFormat:@"%dF",fix_type] userInfo:resultdic];
                    [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=8,传送字典中的值%@",resultdic]]
                    ;
                    [txt_N_file TXT_Write:[NSString stringWithFormat:@"time=%@,fixtype=%d,SN=%@,resultdic=%@\n",[timeDay getCurrentTime],fix_type,_dut_sn,resultdic]];
                }
                
                
                
            });
            index = 9;
        }
        
  #pragma mark--------index = 9:测试完成，释放对象
        if (index == 9)
        {
            
            [NSThread sleepForTimeInterval:0.1];
            
            //发送复位的指令
            [self writeTestLog:fix_type withString:@"index=9,测试完成，发送reset指令"];
            [serialport WriteLine:@"reset"];
            [NSThread sleepForTimeInterval:0.5];
            [serialport ReadExisting];
            
            
            //仪器仪表释放掉
            [self writeTestLog:fix_type withString:@"index=9,测试完成，释放仪器"];
            [agilentB2987A CloseDevice];
            [agilentE4980A CloseDevice];
            is_LRC_Collect = NO;
            is_JDY_Collect = NO;
            Instrument     = NO;
            // 重置测试BOOL变量
            self.isTest = NO;
            
            
            //清空SN
             _dut_sn=@"";
            [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=9,SN清空后的值:%@",_dut_sn]];
            if (nulltest) {
                nullTimes++;
            }
           
            
            if (_qrCode==AutoCode) {
                
                index = 2;
                [self writeTestLog:fix_type withString:@"index=9,自动扫码，index = 2"];
            }
            else if (_qrCode == ManualCode)
            {
                index = 2;
                [self writeTestLog:fix_type withString:@"index=9,手动扫码，index = 2"];
            }
            else
            {
                index = 1000;
                [self writeTestLog:fix_type withString:@"index=9,自动扫码，index = 1000"];
            }
            item_index =0;
            row_index = 0;
            PF = YES;
            
            
        }
     
#pragma mark===================发送消息，防止休眠
        if (index == 1000)
        {
            [NSThread sleepForTimeInterval:0.01];
        }
    }
}


//================================================
//测试项指令解析
//================================================
-(BOOL)TestItem:(Item*)testitem
{
    BOOL ispass=NO;
    NSDictionary  * dict;
    NSString      * subTestDevice;
    NSString      * subTestCommand;
    double          DelayTime;
    NSString      * startTime;
    NSString      * endTime;
    startTime = [timeDay getCurrentSecond];
    
 
    if (fix_type==1&&item_index==6) {
        
    }
    
    for (int i=0; i<[testitem.testAllCommand count]; i++)
    {
        
      
        
        dict =[testitem.testAllCommand objectAtIndex:i];
        subTestDevice = dict[@"TestDevice"];
        subTestCommand=dict[@"TestCommand"];
        DelayTime = [dict[@"TestDelayTime"] floatValue]/1000.0;
        NSLog(@"治具%@发送指令%@",subTestDevice,subTestCommand);
        //治具中收发指令
        if ([subTestDevice isEqualToString:@"Fixture"])
        {
          [self UpdateTextView:[NSString stringWithFormat:@"subTestDevice%@====subTestCommand:%@",subTestDevice,subTestCommand] andClear:NO andTextView:self.Log_View];
           int indexTime = 0;
            while (YES) {
                //[txtContentString appendFormat:@"%@:index=4,%@治具发送指令->%@\n",[timeDay getFileTime],self.fixture_uart_port_name,subTestCommand];
                 [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=5,%@治具发送指令%@",subTestDevice,subTestCommand]];
                 [serialport WriteLine:subTestCommand];
                
                 [NSThread sleepForTimeInterval:0.5];
                 fixtureBackString = [serialport ReadExisting];
                 [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"index=5,获取返回值%@",fixtureBackString]];
                 [self UpdateTextView:[NSString stringWithFormat:@"fixtureBackString:%@",fixtureBackString] andClear:NO andTextView:self.Log_View];
                 [txtContentString appendFormat:@"%@:index=4,%@治具接收返回值->%@\n",[timeDay getFileTime],self.fixture_uart_port_name,fixtureBackString];
                
                if ([fixtureBackString containsString:@"OK"]&&[fixtureBackString containsString:@"*_*"])
                {
                    break;
                }
                if (indexTime>=3) {
                    
                    break;
                }
                
                indexTime++;
                
            }
        }
        //LCR表
        else if ([subTestDevice isEqualToString:@"LCR"])
        {
            
             [self UpdateTextView:[NSString stringWithFormat:@"subTestDevice%@====subTestCommand:%@",subTestDevice,subTestCommand] andClear:NO andTextView:self.Log_View];
            
            
            if ([subTestCommand isEqualToString:@"RES"])
            {
                [self writeTestLog:fix_type withString:@"LCR表开始设置“RES”档位"];
                [agilentE4980A SetMessureMode:AgilentE4980A_RX andCommunicateType:AgilentE4980A_USB_Type];
                [agilentE4980A setFrequency:testItem.freq];
                [self writeTestLog:fix_type withString:@"LCR表设置“RES”档位结束"];

            }
            else if([subTestCommand isEqualToString:@"CPD"])
            {
                [self writeTestLog:fix_type withString:@"LCR表开始设置“CPD”档位"];
                [agilentE4980A SetMessureMode:AgilentE4980A_CPD andCommunicateType:AgilentE4980A_USB_Type];
                [agilentE4980A setFrequency:testItem.freq];
                [self writeTestLog:fix_type withString:@"LCR表设置“CPD”档位结束"];

            }
            else if ([subTestCommand isEqualToString:@"CPQ"])
            {
                [self writeTestLog:fix_type withString:@"LCR表开始设置“CPQ”档位"];
                [agilentE4980A SetMessureMode:AgilentE4980A_CPQ andCommunicateType:AgilentE4980A_USB_Type];
                [agilentE4980A setFrequency:testItem.freq];
                [self writeTestLog:fix_type withString:@"LCR表设置“CPQ”档位结束"];

            }
            else if ([subTestCommand isEqualToString:@"CSD"])
            {
                [self writeTestLog:fix_type withString:@"LCR表开始设置“CSD”档位"];
                [agilentE4980A SetMessureMode:AgilentE4980A_CSD andCommunicateType:AgilentE4980A_USB_Type];
                [agilentE4980A setFrequency:testItem.freq];
                [self writeTestLog:fix_type withString:@"LCR表设置“CSD”档位结束"];
                
            }
            else if ([subTestCommand containsString:@"CSQ"])
            {
                [self writeTestLog:fix_type withString:@"LCR表开始设置“CSQ”档位"];
                [agilentE4980A SetMessureMode:AgilentE4980A_CPQ andCommunicateType:AgilentE4980A_USB_Type];
                [agilentE4980A setFrequency:testItem.freq];
                [self writeTestLog:fix_type withString:@"LCR表设置“CSQ”档位结束"];
                
            }
            else if ([subTestCommand containsString:@"Read"])
            {
                [self writeTestLog:fix_type withString:@"LCR表开始Read"];
                [agilentE4980A WriteLine:@":FETC?" andCommunicateType:AgilentE4980A_USB_Type];
                [NSThread sleepForTimeInterval:0.5];
                agilentReadString=[agilentE4980A ReadData:16 andCommunicateType:AgilentE4980A_USB_Type];
                NSArray *arrResult=[agilentReadString componentsSeparatedByString:@","];
                num = [arrResult[0] floatValue];
                [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"LCR表读取数据:%f",num]];
            }
            else
            {
                NSLog(@"Other situation");
            
            }
            
        }
        //静电仪
        else if ([subTestDevice isEqualToString:@"DMM"])
        {
            
             [self UpdateTextView:[NSString stringWithFormat:@"subTestDevice%@====subTestCommand:%@",subTestDevice,subTestCommand] andClear:NO andTextView:self.Log_View];
            
            if ([testitem.testName isEqualToString:@"B4_E4_DCR"]) {
                
                if (isDebug) {
                    
                    [self writeTestLog:fix_type withString:@"静电仪开始读取"];
                    if ([subTestCommand containsString:@"Read"]) {
                       
                        int i = 40;
                        while (i>0) {
                            
                            i--;
                            [NSThread sleepForTimeInterval:0.4];
                            [dcrAppendString appendString:@",22222222"];
                        }
                    }
                    testvalue = @"11111111111";
                    
                }
                else if ([subTestCommand containsString:@"RES"]) {
                     [self writeTestLog:fix_type withString:@"静电仪开始设置“RES”档位"];
                     [agilentB2987A SetMessureMode:AgilentB2987A_RES andCommunicateType:AgilentB2987A_USB_Type];
                     [self writeTestLog:fix_type withString:@"静电仪设置“RES”档位成功"];
                }
                else if ([subTestCommand containsString:@"Read"]) {
                    
                    if (addDcr) {
                        double num1;
                        int readtimes = 40;
                        [self writeTestLog:fix_type withString:@"静电仪开始读取40组数据"];
                        while (readtimes>0) {
                            
                            readtimes--;
                            [agilentB2987A WriteLine:@":MEAS:RES?" andCommunicateType:AgilentB2987A_USB_Type];
                            [NSThread sleepForTimeInterval:0.4];
                            agilentReadString=[agilentB2987A ReadData:16 andCommunicateType:AgilentB2987A_USB_Type];
                            NSArray *arrResult=[agilentReadString componentsSeparatedByString:@","];
                            num1 = [arrResult[0] floatValue];
                            [dcrAppendString appendString:[NSString stringWithFormat:@"%.3f,",num1*1E-9]];
                        }
                        [self writeTestLog:fix_type withString:@"静电仪读取40组数据成功"];
                        NSArray *arrResult=[agilentReadString componentsSeparatedByString:@","];
                        num = [arrResult[0] floatValue];
                        
                    }
                    else
                    {
                        
                        int readtimes = 0;
                        [self writeTestLog:fix_type withString:@"静电仪开始正常读取数据"];
                        while (YES) {
                            
                            readtimes++;
                            
                            [agilentB2987A WriteLine:@":MEAS:RES?" andCommunicateType:AgilentB2987A_USB_Type];
                            [NSThread sleepForTimeInterval:0.4];
                            agilentReadString=[agilentB2987A ReadData:16 andCommunicateType:AgilentB2987A_USB_Type];
                            
                            if ([agilentReadString length]>0||readtimes>=2) {
                                
                                break;
                            }
                        }
                        
                        NSArray *arrResult=[agilentReadString componentsSeparatedByString:@","];
                        num = [arrResult[0] floatValue];
                        [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"静电仪读取数据:%f",num]];
                        
                    }
                }
            }
            else
            {
                if (isDebug) {
                    
                    testvalue = @"11111111111";
                }
                else if ([subTestCommand containsString:@"RES"]) {
                    [self writeTestLog:fix_type withString:@"静电仪开始设置“RES”档位"];
                    [agilentB2987A SetMessureMode:AgilentB2987A_RES andCommunicateType:AgilentB2987A_USB_Type];
                    [self writeTestLog:fix_type withString:@"静电仪设置“RES”档位成功"];
                }
                else if ([subTestCommand containsString:@"Read"]) {
                    
                     [self writeTestLog:fix_type withString:@"静电仪开始正常读取数据"];
                    int readtimes = 0;
                    while (YES) {
                        
                        readtimes++;
                        
                        [agilentB2987A WriteLine:@":MEAS:RES?" andCommunicateType:AgilentB2987A_USB_Type];
                        [NSThread sleepForTimeInterval:0.2];
                        agilentReadString=[agilentB2987A ReadData:16 andCommunicateType:AgilentB2987A_USB_Type];
                        
                        if ([agilentReadString length]>0||readtimes>=2) {
                            
                            break;
                        }
                    }
                    
                    NSArray *arrResult=[agilentReadString componentsSeparatedByString:@","];
                    num = [arrResult[0] floatValue];
                    [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"静电仪读取数据:%f",num]];

                }
            }
            
        }
        //延迟时间
        else if ([subTestDevice isEqualToString:@"SW"])
        {
            [self UpdateTextView:[NSString stringWithFormat:@"subTestDevice%@====subTestCommand:%@",subTestDevice,subTestCommand] andClear:NO andTextView:self.Log_View];
            
            if ([testitem.testName isEqualToString:@"B4_E4_DCR"]&&addDcr==YES) {

                [NSThread sleepForTimeInterval:0.5];
            }
            else
            {
                 NSLog(@"软件休眠时间");
                [NSThread sleepForTimeInterval:DelayTime];
                //[txtContentString appendFormat:@"%@:index=4,%@软件延时处理\n",[timeDay getFileTime],subTestDevice];
            }
            [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"软件延时处理:%f",DelayTime]];
            
        }
        else
        {
            NSLog(@"其它的情形");
        }
        
    }
    
    
#pragma mark--------对数据进行处理
    if ([testitem.units containsString:@"GOhm"]) {//GOhm
        if (![testitem.testName containsString:@"B2987_CHECK"]) {

            if (!nulltest)
            {
                if ([testitem.testName isEqualToString:@"B_E_DCR"]||[testitem.testName isEqualToString:@"B2_E2_DCR"]||[testitem.testName isEqualToString:@"B4_E4_DCR"]||[testitem.testName isEqualToString:@"ABC_DEF_DCR"]) {
                    
                     testvalue = [NSString stringWithFormat:@"%.3f",num*1E-9];
                    [self storeValueToDic_with_name:testitem.testName];
                }
            }
            else//空测试的情况
            {
                double Rfixture   = num*1E-9;
                if ([testitem.testName isEqualToString:@"B_E_DCR"]||[testitem.testName isEqualToString:@"B2_E2_DCR"]||[testitem.testName isEqualToString:@"B4_E4_DCR"]||[testitem.testName isEqualToString:@"ABC_DEF_DCR"]) {
                    
                    testvalue = [NSString stringWithFormat:@"%.3f",num*1E-9];
                    [self add_RFixture_Value_To_Sum_Testname:testitem.testName RFixture:Rfixture];
                }
            }

            
        }
        else
        {
              testvalue = [NSString stringWithFormat:@"%.3f",num*1E-9];
        }
        
    }
    else if ([testitem.units containsString:@"MOhm"])//MOhm
    {
        if (!nulltest) {
            
            if ([testitem.testName isEqualToString:@"B2_E2_ACR_1000"]||[testitem.testName isEqualToString:@"B4_E4_ACR_1000"]) {
                
                testvalue=[NSString stringWithFormat:@"%.3f",1E-6/(num*2*3.14159*testitem.freq.integerValue)];
                
                NSLog(@"打印测试的频率值%@",testitem.freq);
                
               [self storeValueToDic_With_Item:testitem];       //存储其它测试项的值
            }
        }
        else //空测试情况
        {
            
            double Cdut,Cfix,Rdut;
            NSString *smallCap=@"<1fF";
            NSString *largeACR=@">100GOhm";
            Cdut=0.0;
            Rdut=9999.00;
            Cfix=num*1E+12;
            testvalue=[NSString stringWithFormat:@"%.3f",1E-6/(num*2*3.14159*testitem.freq.integerValue)];
            
            if ([testitem.testName isEqualToString:@"B2_E2_ACR_1000"])
            {
                
                if (Cdut <= 0)
                {
                    [store_Dic setValue:[NSString stringWithFormat:@"%@",smallCap] forKey:@"B2_E2_ACR_1000_Cdut"];
                    [store_Dic setValue:[NSString stringWithFormat:@"%@",largeACR] forKey:@"B2_E2_ACR_1000_Rdut"];
                }
                else
                {
                    [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Cdut] forKey:@"B2_E2_ACR_1000_Cdut"];
                    [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Rdut] forKey:@"B2_E2_ACR_1000_Rdut"];
                }
                
                [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Cfix] forKey:@"B2_E2_ACR_1000_Cfix"];
            }
            
            if ([testitem.testName isEqualToString:@"B4_E4_ACR_1000"])
            {
                Cap_Sum+=Cfix;
                
                if (Cdut <= 0)
                {
                    [store_Dic setValue:[NSString stringWithFormat:@"%@",smallCap] forKey:@"B4_E4_ACR_1000_Cdut"];
                    [store_Dic setValue:[NSString stringWithFormat:@"%@",largeACR] forKey:@"B4_E4_ACR_1000_Rdut"];
                }
                else
                {
                    [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Cdut] forKey:@"B4_E4_ACR_1000_Cdut"];
                    [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Rdut] forKey:@"B4_E4_ACR_1000_Rdut"];
                }
                
                    [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Cfix] forKey:@"B4_E4_ACR_1000_Cfix"];
            }
            
            
        }
        
        
    }
    else if ([testitem.units containsString:@"Ohm"])//Ohm
    {
        testvalue = [NSString stringWithFormat:@"%.3f",num];
        if (isDebug)
        {
            double i=arc4random()%10+100.000000;
            testvalue=[NSString stringWithFormat:@"%.3f",i];
        }
    }
    else if ([testitem.testName containsString:@"TEMP"])
    {
        if (isDebug) {
            
            testvalue = @"26";
        }
        else
        {
            testvalue =[self.Config_Dic objectForKey:kTemp];
        }
        
     
    }
    else if ([testitem.testName containsString:@"HUMID"])
    {
        if (isDebug) {
            
            testvalue = @"56%";
        }
        else
        {
            testvalue =[self.Config_Dic objectForKey:kHumit];
        }
    }
    
    else
    {
        NSLog(@"Other test Item");
    
    }
    

#pragma mark--------对测试项进行赋值
    if ([testitem.testName containsString:@"_Vmeas"] || [testitem.testName containsString:@"_Rref"] || [testitem.testName containsString:@"_Cfix"] || [testitem.testName containsString:@"_Vs"] || [testitem.testName containsString:@"_Cref"] || [testitem.testName containsString:@"_Rdut"] || [testitem.testName containsString:@"_Cdut"] || [testitem.testName containsString:@"_Rfix"])
    {
        testvalue=[NSString stringWithFormat:@"%@",store_Dic[[NSString stringWithFormat:@"%@",testitem.testName]]];
        
         NSLog(@"打印多长的时间==========%@",testvalue);
        [self writeTestLog:fix_type withString:[NSString stringWithFormat:@"测试项:Item=%@-->value=%@",testitem.testName,testvalue]];
    
    }
    
    
//判断值得大小
#pragma mark--------对测试出来的结果进行判断和赋值
    //上下限值对比
    if (([testvalue floatValue]>[testitem.min floatValue]&&[testvalue floatValue]<=[testitem.max floatValue]) || ([testitem.max isEqualToString:@"--"]&&[testvalue floatValue]>=[testitem.min floatValue]) || ([testitem.max isEqualToString:@"--"] && [testitem.min isEqualToString:@"--"]) || ([testitem.min isEqualToString:@"--"]&&[testvalue floatValue]<=[testitem.max floatValue])|| [testvalue isEqualToString:@">100GOhm"]|| [testvalue isEqualToString:@"<1fF"]||[testvalue isEqualToString:@">1TOhm"])
    {
        if (fix_type == 1) {
            testitem.value1 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result1 = @"PASS";
        }
        else if (fix_type == 2)
        {
            testitem.value2 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result2 = @"PASS";
        }
        else if (fix_type == 3)
        {
            testitem.value3 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result3 = @"PASS";
        }
        else if (fix_type == 4)
        {
            testitem.value4 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result4 = @"PASS";
        }
        
        testitem.messageError=nil;
        ispass = YES;
    }
    else
    {
        if (fix_type == 1) {
            testitem.value1 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result1 = @"Fail";
        }
        else if (fix_type == 2)
        {
            testitem.value2 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result2 = @"Fail";
        }
        else if (fix_type == 3)
        {
            testitem.value3 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result3 = @"FAIL";
        }
        else if (fix_type == 4)
        {
            testitem.value4 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result4 = @"FAIL";
        }
        testitem.messageError=[NSString stringWithFormat:@"%@ Fail",testitem.testName];
        ispass = NO;
        PF = NO;
    }
    
    //对时间进行赋值
    endTime = [timeDay getCurrentSecond];
    testitem.startTime = startTime;
    testitem.endTime   = endTime;

    //处理相关的测试项
    [TestValueArr addObject:testvalue];
    [ItemArr addObject:testitem];      //将测试项加入数组中

    return ispass;
}


//================================================
//保存csv
//================================================
-(void)SaveCSV:(FileCSV *)csvFile withBool:(BOOL)need_title
{
    NSString * line    =  @"";
    NSString * value  =  @"";
    
    for(int i=0;i<[ItemArr count];i++)
    {
        Item *testitem=ItemArr[i];
        
        if (fix_type == 1) value   =testitem.value1;
        if (fix_type == 2) value   =testitem.value2;
        if (fix_type == 3) value   =testitem.value3;
        if (fix_type == 4) value   =testitem.value4;
        
        if(testitem.isTest)  //需要测试的才需要上传
        {
            if((testitem.isShow == YES)&&(testitem.isTest))    //需要显示并且需要测试的才保存
            {
                
                line=[line stringByAppendingString:[NSString stringWithFormat:@"%@,",value]];
                
            }
        }
    }
    line = [line stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    
    NSString *test_result;
    if (PF)
    {
        test_result = @"PASS";
    }
    else
    {
        test_result = @"FAIL";
    }
    //line字符串前面增加SN和测试结果
    NSString *  contentStr = [NSMutableString stringWithFormat:@"\n%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@",start_time,end_time,[self.Config_Dic objectForKey:kSoftwareVersion],self.NestID,@"Cr",self.Config_pro,self.dut_sn,test_result,FixtureID,[self.Config_Dic objectForKey:kOperator_ID],[[NSUserDefaults standardUserDefaults] objectForKey:@"totalCount"],line];
    
    NSMutableString  * contentString = [NSMutableString stringWithString:contentStr];
    
    //如果addDcr=YES,加数据加到contentString中
    if (addDcr) {
        
          [contentString appendString:[NSString stringWithFormat:@"%@",dcrAppendString]];
        
    }
    
   if(need_title == YES)[csvFile CSV_Write:self.csvTitle];
    
    [csvFile CSV_Write:contentString];
    
}


-(void)setCsvTitle:(NSString *)csvTitle
{
    _csvTitle = csvTitle;
}

-(void)setDut_sn:(NSString *)dut_sn
{
    _dut_sn = dut_sn;
}


-(void)setToFold:(NSString *)toFold
{
    _toFold = toFold;
}







#pragma mark=========================通知类消息
//监测开始测试的消息

-(void)NSThreadStart_Notification:(NSNotification *)noti
{
    if ((self.isTest&&Instrument)||(isDebug&&self.isTest)) {
        
        index = 4;
        [TestValueArr removeAllObjects];
    }
    
   
    [self UpdateTextView:[NSString stringWithFormat:@"控制板1:%d====仪器仪表:%hhd======测试准备:%hhd",fix_type,Instrument,self.isTest] andClear:NO andTextView:self.Log_View];
}

-(void)NSThreadEnd_Notification:(NSNotification *)noti
{
    
      dispatch_async(dispatch_get_main_queue(), ^{
         
          [self.dutTF setStringValue:@""];
          
           index = 2;
      });

    
    
}


//监测空测试时的消息
-(void)selectNullTestNoti:(NSNotification *)noti
{
    if ([noti.object isEqualToString:@"YES"]) {
        
         nulltest = YES;
    }
    else{
    
         nulltest = NO;
    }
   
}

-(void)selectPDCAandSCFNoti:(NSNotification *)noti
{
    
    if ([noti.name isEqualToString:kPdcaUploadNotice]) {
        
        if ([noti.object isEqualToString:@"YES"]) {
            
            isPDCA = YES;
        }
        else
        {
            isPDCA = NO;
        }
    }
    if ([noti.name isEqualToString:kSfcUploadNotice]) {
       
        if ([noti.object isEqualToString:@"YES"]) {
            
            isSFC = YES;
        }
        else
        {
            isSFC = NO;
        }
    }
    
    NSLog(@"%hhd======%hhd",isPDCA,isSFC);
}

-(void)writeNullValueToPlist:(NSNotification *)noti
{
    
    
    updateItem.fix_B_E_Res     = [NSString stringWithFormat:@"%f",B_E_Sum/nullTimes];
    updateItem.fix_B2_E2_Res   = [NSString stringWithFormat:@"%f",B2_E2_Sum/nullTimes];
    updateItem.fix_B4_E4_Res   = [NSString stringWithFormat:@"%f",B4_E4_Sum/nullTimes];
    updateItem.fix_ABC_DEF_Res = [NSString stringWithFormat:@"%f",ABC_DEF_Sum/nullTimes];
    updateItem.fix_Cap         = [NSString stringWithFormat:@"%f",Cap_Sum/nullTimes];
    

    
    if (fix_type == 1&&nullTimes>=2) {
        [plist PlistWrite:@"Param" UpdateItem:updateItem Key:kFixtureFix1];
         NSLog(@"%d-----%@==%@===%@===%@===%@",fix_type,updateItem.fix_ABC_DEF_Res,updateItem.fix_B2_E2_Res,updateItem.fix_B4_E4_Res,updateItem.fix_B_E_Res,updateItem.fix_Cap);
    }
    if (fix_type==2&&nullTimes>=2) {
        [plist PlistWrite:@"Param" UpdateItem:updateItem Key:kFixtureFix2];
         NSLog(@"%d-----%@==%@===%@===%@===%@",fix_type,updateItem.fix_ABC_DEF_Res,updateItem.fix_B2_E2_Res,updateItem.fix_B4_E4_Res,updateItem.fix_B_E_Res,updateItem.fix_Cap);
    }
    if (fix_type==3&&nullTimes>=2) {
        [plist PlistWrite:@"Param" UpdateItem:updateItem Key:kFixtureFix3];
         NSLog(@"%d-----%@==%@===%@===%@===%@",fix_type,updateItem.fix_ABC_DEF_Res,updateItem.fix_B2_E2_Res,updateItem.fix_B4_E4_Res,updateItem.fix_B_E_Res,updateItem.fix_Cap);
    }
    if (fix_type==4&&nullTimes>=2) {
        [plist PlistWrite:@"Param" UpdateItem:updateItem Key:kFixtureFix4];
         NSLog(@"%d-----%@==%@===%@===%@===%@",fix_type,updateItem.fix_ABC_DEF_Res,updateItem.fix_B2_E2_Res,updateItem.fix_B4_E4_Res,updateItem.fix_B_E_Res,updateItem.fix_Cap);
    }
    
    //空测试完
    [[NSNotificationCenter defaultCenter] postNotificationName:kFinshNullTestNotice object:nil];
    
    
}



#pragma mark--------------选择扫码模式
-(void)selectScanQRCode:(NSNotification *)noti
{
    
    if ([noti.name isEqualToString:kManualScanQRCode]) {
        
        _qrCode = ManualCode;
        
        index = 2;
    }
    if ([noti.name isEqualToString:kAutoScanQRCode]) {
        
        _qrCode = AutoCode;
        
        index = 2;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.dutTF setStringValue:@""];
    });
    
}


#pragma mark--------------SN检测失败，重新扫码
-(void)selectScanQRCodeAgain:(NSNotification *)noti
{
    
    if (self.SNisRight) {
        
        index = 3;
        self.SNisRight = NO;
    }
   
}



#pragma mark--------------选择测试40个测试数据
-(void)selectTestDataNoti:(NSNotification *)noti
{
    
    if ([noti.name isEqualToString:kTest40DataNotice]) {
        
        if ([noti.object isEqualToString:@"YES"]) {
            
            addDcr = YES;
        }
        else
        {
            addDcr = NO;
        }
    }
}


#pragma mark-----------------多次测试和的值
-(void)add_RFixture_Value_To_Sum_Testname:(NSString *)testname RFixture:(double)RFixture
{
    NSString *largeRes= @">1TOhm";
    if (RFixture<0) {
        
        RFixture = 3000+random()%2000;
    }
    if ([testname isEqualToString:@"B_E_DCR"])         B_E_Sum   = B_E_Sum + RFixture;
    if ([testname isEqualToString:@"B2_E2_DCR"])       B2_E2_Sum = B2_E2_Sum + RFixture;
    if ([testname isEqualToString:@"B4_E4_DCR"])       B4_E4_Sum = B4_E4_Sum + RFixture;
    if ([testname isEqualToString:@"ABC_DEF_DCR"])     ABC_DEF_Sum =ABC_DEF_Sum + RFixture;
    
    [store_Dic setValue:[NSString stringWithFormat:@"%@",largeRes] forKey:[NSString stringWithFormat:@"%@_Rdut",testname]];
    [store_Dic setValue:[NSString stringWithFormat:@"%.3f",RFixture] forKey:[NSString stringWithFormat:@"%@_Rfix",testname]];
}



#pragma mark----------------GΩ情况下调用方法，testname为测试项的名称
-(void)storeValueToDic_with_name:(NSString *)testname
{
    double Rdut,Rfixture;
    NSString *largeRes=@">1TOhm";
    Rfixture=num*1E-9;

    if ([testname isEqualToString:@"B_E_DCR"]) {
        Rfixture = [updateItem.fix_B_E_Res floatValue];
    }
    if ([testname isEqualToString:@"B2_E2_DCR"]) {
        Rfixture = [updateItem.fix_B2_E2_Res floatValue];
    }
    if ([testname isEqualToString:@"B4_E4_DCR"]) {
         Rfixture = [updateItem.fix_B4_E4_Res floatValue];
    }
    if ([testname isEqualToString:@"ABC_DEF_DCR"]) {
         Rfixture = [updateItem.fix_ABC_DEF_Res floatValue];
    }
    
    Rdut=(num*1E-9*Rfixture)/(Rfixture-num*1E-9);
    
    
    if (isDebug) {
        
        Rdut = arc4random()%100;
    }
    
    if (num*1E-9 >= Rfixture || Rdut > 1000 || num*1E-9 < 0)
    {
        [store_Dic setValue:[NSString stringWithFormat:@"%@",largeRes] forKey:[NSString stringWithFormat:@"%@_Rdut",testname]];
    }
    else
    {
        [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Rdut] forKey:[NSString stringWithFormat:@"%@_Rdut",testname]];
    }
    
     [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Rfixture] forKey:[NSString stringWithFormat:@"%@_Rfix",testname]];

    
}


#pragma mark----------------MΩ情况下调用的方法，
-(void)storeValueToDic_With_Item:(Item *)item
{
    double Cdut,Cfix,Rdut;
    NSString *smallCap=@"<1fF";
    NSString *largeACR=@">100GOhm";
    Cfix=[updateItem.fix_Cap floatValue];
    Cdut=fabs(num*1E+12-Cfix);
    Rdut=1E+6/(Cdut*2*3.14159*item.freq.integerValue);
    
    if (Cdut <= 0)
    {
        [store_Dic setValue:[NSString stringWithFormat:@"%@",smallCap] forKey:[NSString stringWithFormat:@"%@_Cdut",item.testName]];
        [store_Dic setValue:[NSString stringWithFormat:@"%@",largeACR] forKey:[NSString stringWithFormat:@"%@_Rdut",item.testName]];
    }
    else
    {
        [store_Dic setValue:[NSString stringWithFormat:@"%f",Cdut] forKey:[NSString stringWithFormat:@"%@_Cdut",item.testName]];
        [store_Dic setValue:[NSString stringWithFormat:@"%f",Rdut] forKey:[NSString stringWithFormat:@"%@_Rdut",item.testName]];
        
    }
    
    [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Cfix] forKey:[NSString stringWithFormat:@"%@_Cfix",item.testName]];

}


#pragma mark-------------返回总文件
-(NSString *)backTotalFilePathwithFloder:(NSString *)FoldStr
{
    if (fix_type==1) {
        
       return [NSString stringWithFormat:@"%@/%@_A.csv",FoldStr,[timeDay getCurrentDay]];
    }
    else if (fix_type==2)
    {
       return [NSString stringWithFormat:@"%@/%@_B.csv",FoldStr,[timeDay getCurrentDay]];
    }
    else if (fix_type==3)
    {
       return [NSString stringWithFormat:@"%@/%@_C.csv",FoldStr,[timeDay getCurrentDay]];
    }
    else
    {
       return [NSString stringWithFormat:@"%@/%@_D.csv",FoldStr,[timeDay getCurrentDay]];
    }
}


//更新upodateView
-(void)UpdateTextView:(NSString*)strMsg andClear:(BOOL)flagClearContent andTextView:(NSTextView *)textView
{
    if (flagClearContent)
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [textView setString:@""];
                       });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           if ([[textView string]length]>0)
                           {
                               NSString * messageString = [NSString stringWithFormat:@"%@: %@\n",[[GetTimeDay shareInstance] getFileTime],strMsg];
                               NSRange range = NSMakeRange([textView.textStorage.string length] , messageString.length);
                               [textView insertText:messageString replacementRange:range];
                              
                           }
                           else
                           {
                               [textView setString:[NSString stringWithFormat:@"%@：%@\n",[[GetTimeDay shareInstance] getFileTime],strMsg]];
                           }
                           
                           [textView setTextColor:[NSColor redColor]];
                       });
    }
}



//线程开始
-(void)threadStart
{
    
    [thread start];
    
}




//线程结束
-(void)threadEnd
{
    [thread cancel];
    [agilentB2987A CloseDevice];
    [agilentE4980A CloseDevice];
    [serialport Close];
    
    agilentB2987A = nil;
    agilentE4980A = nil;
    serialport = nil;
}


#pragma mark ===============唤醒2987A
-(void)timewake
{
     [agilentB2987A WriteLine:@"*RST" andCommunicateType:AgilentB2987A_USB_Type];
}



#pragma mark ===============写入Log文件
-(void)writeTestLog:(int)fixtype withString:(NSString *)writeString
{
    if (fix_type==1) {
        
        [txt_file TXT_Write:[NSString stringWithFormat:@"%@:A通道-->%@\n",[timeDay getFileTime],writeString]];
    }
    else if (fix_type==2)
    {
        [txt_file TXT_Write:[NSString stringWithFormat:@"%@:B通道-->%@\n",[timeDay getFileTime],writeString]];
    }
    else if (fix_type==3)
    {
        [txt_file TXT_Write:[NSString stringWithFormat:@"%@:C通道-->%@\n",[timeDay getFileTime],writeString]];
    }
    else if (fix_type==4)
    {
        [txt_file TXT_Write:[NSString stringWithFormat:@"%@:D通道-->%@\n",[timeDay getFileTime],writeString]];
    }
    else
    {
    
    }
}




@end
