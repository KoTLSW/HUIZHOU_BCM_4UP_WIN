//
//  ViewController.m
//  WorkingFrameWork
//
//  Created by mac on 2017/10/27.
//  Copyright © 2017年 macjinlongpiaoxu. All rights reserved.
//

#import "ViewController.h"
#import "Table.h"
#import "Plist.h"
#import "Param.h"
#import "TestAction.h"
#import "MKTimer.h"
#import "AppDelegate.h"
#import "Folder.h"
#import "GetTimeDay.h"
#import "FileCSV.h"
#import "visa.h"
#import "SerialPort.h"
#import "Common.h"
#import "TestStep.h"
#import "BYDSFCManager.h"
#import "Alert.h"
#import "FileTXT.h"
#import "AFNetworking.h"
#import "Reachability.h"
#import "FileTXT_N.h"








//文件名称
NSString * param_Name = @"Param";

@interface ViewController()<NSTextFieldDelegate>
{
    Table * tab1;
    Table * tab2;
    
    Folder   * fold;
    FileCSV  * csvFile;
    FileTXT  * txtFile;
    FileTXT  * txtInshare;
    FileTXT_N * txt_N_file;
    
    NSThread * thread;
    NSThread * scanthread;
    
    Plist * plist;
    Param * param;
    SerialPort *   serialport;        //控制板类
    SerialPort *   humiturePort;      //温湿度控制类
    
    NSArray    *   itemArr1;
    NSArray    *   itemArr2;
    
    Alert      *   alert;
    TestAction * action1;
    TestAction * action2;
    TestAction * action3;
    TestAction * action4;
    
    //定时器相关
    MKTimer * mkTimer;
    int      ct_cnt;                  //记录cycle time定时器中断的次数
    
    
    
    
    IBOutlet NSTextField *Scan_SN_TF;                 //产品SN扫码
    IBOutlet NSTextField *NS_TF1;                     //产品1输入框
    IBOutlet NSTextField *NS_TF2;                     //产品2输入框
    IBOutlet NSTextField *NS_TF3;                     //产品3输入框
    IBOutlet NSTextField *NS_TF4;                     //产品4输入
    
    IBOutlet NSTextField *  Status_TF;                //显示状态栏
    IBOutlet NSTextField *  testFieldTimes;           //时间显示输入框
    IBOutlet NSTextField *  humiture_TF;              //温湿度显示lable
    IBOutlet NSTextField *  TestCount_TF;             //测试的次数
    
    IBOutlet NSTextField *  Forum_TF;                 //泡棉测试次数
    IBOutlet NSButton    *  IsUploadPDCA_Button;      //上传PDCA的按钮
    IBOutlet NSButton    *  IsUploadSFC_Button;       //上传SFC的按钮
    IBOutlet NSTextField *  Version_TF;               //软件版本
    IBOutlet NSTextView  *  Log_View;                    //Log日志
    
    
    IBOutlet NSTextView *A_LOG_TF;
    IBOutlet NSTextView *B_LOG_TF;
    IBOutlet NSTextView *C_LOG_TF;
    IBOutlet NSTextView *D_LOG_TF;
    
    IBOutlet NSTextView *A_FailItem;
    IBOutlet NSTextView *B_FailItem;
    IBOutlet NSTextView *C_FailItem;
    IBOutlet NSTextView *D_FailItem;
    IBOutlet NSButton *Choose_SN;
    IBOutlet NSTextField *Product_NUM;
    IBOutlet NSButton *choose_dut1;
    IBOutlet NSButton *choose_dut2;
    IBOutlet NSButton *choose_dut3;
    IBOutlet NSButton *choose_dut4;
    IBOutlet NSTextField *product_Config;
    IBOutlet NSTextField *Operator_TF;
    IBOutlet NSPopUpButton *NestID_Change;
    IBOutlet NSButton      *config_change;
    IBOutlet NSTextField   *loopTest_Label;
    IBOutlet NSButton      *change_OpID;
    IBOutlet NSButton      *nulltest_button;
    IBOutlet NSButton      *startbutton;
    IBOutlet NSButton      *ComfirmButton;
    IBOutlet NSButton      *singlebutton;
    IBOutlet NSPopUpButton *num_PopButton;
    
    IBOutlet NSTextField *network_State_TF;
    IBOutlet NSTextField *Server_State_TF;
    IBOutlet NSTextField *cache_data;
    
    
    int index;
    //创建相关的属性
    NSString * foldDir;               //config属性总文件
    NSString * totalFold;             //所有文件总文件
    NSString * totalPath;             //包含到cr的文件路径
    
    //温湿度相关属性
    NSString             * humitureString;
    NSString             * temptureString;
    
    //测试结束通知中返回的对象===数据中含有P代表成功，含有F代表失败
    NSString             * notiString_A;
    NSString             * notiString_B;
    NSString             * notiString_C;
    NSString             * notiString_D;
    NSString             * testingFixStr;         //正在测试的治具
    
    //产品通过的的次数和测试的总数
    int                   passNum;             //通过的测试次数
    int                   totalNum;            //通过的测试总数
    int                   nullNum;             //空测试完成的次数
    int                   fix_A_num;
    int                   fix_B_num;
    int                   fix_C_num;
    int                   fix_D_num;
    
    
    
    
    int                   testnum;            //传送过来产品的总个数
    
    NSMutableDictionary        * config_Dic;  //相关的配置参数属
    
    BOOL                        singleTest;         //产品单个测试
    NSString                  * fixtureID;         //fixture的值
    
    //===================新增的项
    TestStep                  * testStep;
    BYDSFCManager             * sfcManager;
    NSDictionary              * A_resultDic;  //接收A通道的测试数据
    NSDictionary              * B_resultDic;  //接收B通道的测试数据
    NSDictionary              * C_resultDic;  //接收C通道的测试数据
    NSDictionary              * D_resultDic;  //接收D通道的测试数据
    
    //===================NG的产品
    NSMutableArray           * snArr;         //SN的字符串数组
    NSMutableArray           * SnArr_TF;      //SN TextField数组
    
    //===================通过可变数组的大小，判断当前有几个在测试
    NSMutableArray            *ChooseNumArray; //测试个数
    //===================工位数据生成地址单独设置
    BOOL                      isShowNestID_Change;
    BOOL                      isUpLoadPDCA;
    BOOL                      isUpLoadSFC;
    
    //===================提示仪器仪表连接
    BOOL                 IsInstrument;
    BOOL                 isComfirmOK;    //是否确定选项
    BOOL                 isNullTest;     //是否空测试
    BOOL                 isLoopTest;     //循环测试
    
    //进行网络监测判断的bool值
    Reachability    *    hostReachbility;
    BOOL                 isWebOpen;     //检测网络
    int                  WebOpenNum;    //网络正常计数
    BOOL                 isServer;      //服务器
    NSString            * updata_path;  //断网存储的数据
    NSString            * testLog_path;  //断网存储的数据
    NSString            * LostData_path;  //断网存储的数据
    
    //SN的值
    NSString            * SN1_String;
    NSString            * SN2_String;
    NSString            * SN3_String;
    NSString            * SN4_String;
    
    //同二维码上传的次数和总数
    int                 presentCount;
    int                 totalCount;
    
}

@property(nonatomic,strong) AFHTTPSessionManager   * session;


@end

@implementation ViewController


//软件测试整个流程  //door close--->SN---->config-->监测start--->下压气缸---->抛出SN-->直接运行


- (void)viewDidLoad {
    [super viewDidLoad];
    //***********************变量定义区***********************//
    index    = 0;
    passNum  = 0;
    totalNum = 0;
    nullNum  = 0;
    WebOpenNum = 0;
    
    fix_A_num = 0;
    fix_B_num = 0;
    fix_C_num = 0;
    fix_D_num = 0;
    testnum   = 0;
    presentCount = 1;
    totalCount = 0;
    
    
    testingFixStr = @"";
    
    
    IsInstrument = NO;
    isComfirmOK  = NO;
    isNullTest   = NO;
    isLoopTest   = NO;
    //BOOL变量
    singleTest = NO;
    isUpLoadSFC  = YES;
    isUpLoadPDCA =  NO;
    //NestID 使用这个界面上的
    isShowNestID_Change = YES;
    //***********************对象初始化***********************//
    testStep = [TestStep Instance];
    config_Dic = [[NSMutableDictionary alloc]initWithCapacity:10];
    plist = [Plist shareInstance];
    param = [[Param alloc]init];
    [param ParamRead:param_Name];
    snArr = [[NSMutableArray alloc]initWithCapacity:10];
    SnArr_TF = [[NSMutableArray alloc]initWithCapacity:10];
    ChooseNumArray =[[NSMutableArray alloc]initWithCapacity:10];
    [config_Dic setValue:param.sw_ver forKey:kSoftwareVersion];
    [Version_TF setStringValue:param.sw_ver];
    
    
    
    A_resultDic = [[NSDictionary alloc]init];
    B_resultDic = [[NSDictionary alloc]init];
    C_resultDic = [[NSDictionary alloc]init];
    D_resultDic = [[NSDictionary alloc]init];
    
    //***********************数据加载区***********************//
    [Scan_SN_TF acceptsFirstResponder];
    
    //加载界面
    itemArr1 = [plist PlistRead:@"Station_Cr_1_Humid" Key:@"AllItems"];
    tab1 = [[Table  alloc]init:Tab1_View DisplayData:itemArr1];
    //初始化温湿度和主控板
    humiturePort = [[SerialPort alloc]init];
    [humiturePort setTimeout:1 WriteTimeout:1];
    serialport   = [[SerialPort alloc]init];
    [serialport setTimeout:1 WriteTimeout:1];
    alert       = [Alert shareInstance];
    dispatch_async(dispatch_get_main_queue(), ^{
       
        [Forum_TF setStringValue:[NSString stringWithFormat:@"%d/%@",[[[NSUserDefaults standardUserDefaults] objectForKey:kPresentNum] intValue],param.FoamNum]];
    });
    
    //***********************文件处理区***********************//
    mkTimer = [[MKTimer alloc]init];
    fold    = [[Folder alloc]init];
    csvFile = [[FileCSV alloc]init];
    txtFile = [[FileTXT alloc] init];
    txtInshare = [FileTXT shareInstance];
    //数据丢失验证对象
    txt_N_file = [FileTXT_N shareInstance];
    
    //生成测试Log的文件夹
    totalPath = [NSString stringWithFormat:@"%@/%@/%@_%@/%@",param.foldDir,[[GetTimeDay shareInstance] getCurrentDay],param.sw_name,param.sw_ver,@"Cr"];
    [[NSUserDefaults standardUserDefaults] setValue:totalPath forKey:kTotalFoldPath];
    [fold Folder_Creat:totalPath];
    
    //生成缓存数据路径
    updata_path = [NSString stringWithFormat:@"%@/%@",totalPath,@"uploaddata.txt"];
    [txtFile TXT_Open:updata_path];
    //生成测试Log路径
    testLog_path = [NSString stringWithFormat:@"%@/%@",totalPath,@"TestLog.txt"];
    [txtInshare TXT_Open:testLog_path];
    
    //生成数据鉴定LOG
    LostData_path = [NSString stringWithFormat:@"%@/%@",totalPath,@"LostData.txt"];
    //[txt_N_file TXT_Open:LostData_path];

    
    
    
    //上传相关文件
    testStep   = [TestStep Instance];
    sfcManager = [BYDSFCManager Instance];
    
    
    
    //***********************通知处理区***********************//
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectSnChangeNoti:) name:@"SNChangeNotice" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectTestModeNotice:) name:kSingleTestNotice object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectTestModeNotice:) name:kNullTestNotice object:nil];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(selectTestModeNotice:) name:kLoopTestNotice object:nil];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(selectSfc_PdcaUpload:) name:kSfcUploadNotice object:nil];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(selectSfc_PdcaUpload:) name:kPdcaUploadNotice object:nil];
    //监听NestID的改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectNestIDNotice:) name:kTestNoChangeNotice object:nil];
    //监听仪器是否有断开连接
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectInstrument:) name:kInStrumentNotice object:nil];
    //监测空测试完
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectFinshNullTest) name:kFinshNullTestNotice object:nil];
    //手动扫码
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectScanQRCode:) name:kManualScanQRCode object:nil];
    //自动扫码
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectScanQRCode:) name:kAutoScanQRCode object:nil];
    
    //***********************断网上传区***********************//
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:@"kNetworkReachabilityChangedNotification" object:nil];
   hostReachbility = [Reachability reachabilityWithHostName:[param.ServerFC objectForKey:@"Server_IP"]];
   [self NetworkState:hostReachbility];
   [hostReachbility startNotifier];

    
    //***********************线程开启区***********************//
    [self createThreadWithNum:1];
    [self createThreadWithNum:2];
    [self createThreadWithNum:3];
    [self createThreadWithNum:4];
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(Working) object:nil];
    [thread start];
    
}


#pragma mark=====选择测试NestID/Config/OP
- (IBAction)Choose_SN_Action:(id)sender {
    
    if (Choose_SN.state) {
        
        Scan_SN_TF.editable =YES;
        Product_NUM.editable = YES;
        Scan_SN_TF.stringValue=@"";
        NS_TF1.stringValue =@"";
        NS_TF2.stringValue =@"";
        NS_TF3.stringValue =@"";
        NS_TF4.stringValue =@"";
        [Scan_SN_TF becomeFirstResponder];
        [Product_NUM setStringValue:@""];
        index = 3;
    }else
    {
        Scan_SN_TF.editable  = NO;
        Product_NUM.editable = NO;
        //清零
        presentCount = 1;
        totalCount = [Product_NUM.stringValue intValue];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",totalCount] forKey:@"totalCount"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    
    
}


- (IBAction)change_Action:(id)sender {
    
    if (config_change.state) {
        
        product_Config.editable =YES;
    }else
    {
        product_Config.editable =NO;
    }
    
    [config_Dic setValue: product_Config.stringValue forKey:kConfig_pro];
    
    [self UpdateTextView:[NSString stringWithFormat:@"输入 product_Config=%@",product_Config.stringValue] andClear:NO andTextView:Log_View];
    
}


- (IBAction)changeID_Action:(id)sender {
    
    if (change_OpID.state) {
        
        Operator_TF.editable =YES;
    }else
    {
        Operator_TF.editable =NO;
    }
    
    [config_Dic setValue: Operator_TF.stringValue forKey:kOperator_ID];
    
    [self UpdateTextView:[NSString stringWithFormat:@"输入 Operator_TF=%@",Operator_TF.stringValue] andClear:NO andTextView:Log_View];
}





- (IBAction)change_Station_Button:(id)sender {
    
    if ([sender isEqual:NestID_Change]) {
        
        NSLog(@"点击 NestID_Change=%@",NestID_Change.titleOfSelectedItem);
        [self UpdateTextView:[NSString stringWithFormat:@"点击 NestID_Change=%@",NestID_Change.titleOfSelectedItem] andClear:NO andTextView:Log_View];
        if (!isNullTest) {
            
            itemArr1 = [plist PlistRead:@"Station_Cr_1_Humid" Key:@"AllItems"];
            tab1 = [tab1 init:Tab1_View DisplayData:itemArr1];
        }
        
        [config_Dic setValue: NestID_Change.titleOfSelectedItem forKey:kProductNestID];
    }
    
}


#pragma mark=======================保存配置文件的状态
-(void)saveConfigStation
{
    [config_Dic setValue: NestID_Change.titleOfSelectedItem forKey:kProductNestID];
    [config_Dic setValue: [product_Config.stringValue length]>0?product_Config.stringValue:@"" forKey:kConfig_pro];
    [config_Dic setValue: [Operator_TF.stringValue length]>0?Operator_TF.stringValue:@"" forKey:kOperator_ID];
    
}


- (IBAction)start_Action:(id)sender {//发送通知开始测试
    
   
    if ([Product_NUM.stringValue length]>0) {
        
        if (singleTest) {
            
            if (isComfirmOK) {
                
                index = 8;
                startbutton.enabled = NO;
            }
            else
            {
                [Status_TF setStringValue:@"请点击Comfirm确认选项"];
            }
        }else
        {
            index = 8;
            startbutton.enabled = NO;
        }

         [serialport WriteLine:@"start"];
    }
    else
    {
        [alert ShowCancelAlert:@"请输入SN的数量"];
    }
    
}



#pragma mark=======================通道测试完成通知
//=============================================
-(void)selectSnChangeNoti:(NSNotification *)noti
{
    totalNum++;
    
    if ([noti.object containsString:@"1"]) {
        
        fix_A_num = 101;
        notiString_A = noti.object;
        A_resultDic = [noti.userInfo mutableCopy];
        [txtInshare TXT_Write:[NSString stringWithFormat:@"%@:主流程-->%@\n",[[GetTimeDay shareInstance] getFileTime],[NSString stringWithFormat:@"A通道接收数据:A_resultDic=%@",A_resultDic]]];
        
        ////[txt_N_file TXT_Write:[NSString stringWithFormat:@"%@:主流程-->%@\n",[[GetTimeDay shareInstance] getFileTime],[NSString stringWithFormat:@"A通道接收数据:A_resultDic=%@",A_resultDic]]];
        NSLog(@"fixture_A 测试已经完成了");
    }
    if ([noti.object containsString:@"2"]) {
        
        fix_B_num = 102;
        notiString_B = noti.object;
        B_resultDic  = [noti.userInfo mutableCopy];
        [txtInshare TXT_Write:[NSString stringWithFormat:@"%@:主流程-->%@\n",[[GetTimeDay shareInstance] getFileTime],[NSString stringWithFormat:@"B通道接收数据:B_resultDic=%@",B_resultDic]]];
        ////[txt_N_file TXT_Write:[NSString stringWithFormat:@"%@:主流程-->%@\n",[[GetTimeDay shareInstance] getFileTime],[NSString stringWithFormat:@"B通道接收数据:B_resultDic=%@",B_resultDic]]];
        NSLog(@"fixture_B 测试已经完成了");
    }
    if ([noti.object containsString:@"3"]) {
        
        fix_C_num = 103;
        notiString_C = noti.object;
        C_resultDic = [noti.userInfo mutableCopy];
        [txtInshare TXT_Write:[NSString stringWithFormat:@"%@:主流程-->%@\n",[[GetTimeDay shareInstance] getFileTime],[NSString stringWithFormat:@"C通道接收数据:C_resultDic=%@",C_resultDic]]];
        ////[txt_N_file TXT_Write:[NSString stringWithFormat:@"%@:主流程-->%@\n",[[GetTimeDay shareInstance] getFileTime],[NSString stringWithFormat:@"C通道接收数据:C_resultDic=%@",C_resultDic]]];
        NSLog(@"fixture_C 测试已经完成了");
    }
    if ([noti.object containsString:@"4"]) {
        fix_D_num = 104;
        notiString_D = noti.object;
        D_resultDic  = [noti.userInfo mutableCopy];
        [txtInshare TXT_Write:[NSString stringWithFormat:@"D通道接收数据:D_resultDic=%@",D_resultDic]];
        [txtInshare TXT_Write:[NSString stringWithFormat:@"%@:主流程-->%@\n",[[GetTimeDay shareInstance] getFileTime],[NSString stringWithFormat:@"D通道接收数据:D_resultDic=%@",D_resultDic]]];
        
        ////[txt_N_file TXT_Write:[NSString stringWithFormat:@"%@:主流程-->%@\n",[[GetTimeDay shareInstance] getFileTime],[NSString stringWithFormat:@"D通道接收数据:D_resultDic=%@",D_resultDic]]];
        
        NSLog(@"fixture_D 测试已经完成了");
    }
}



//发送通知，监听大小NestID变化
-(void)selectNestIDNotice:(NSNotification *)noti
{
    
    if ([noti.name isEqualToString:kTestNoChangeNotice]) {
        
        isShowNestID_Change = YES;
        
        index = 3;
    }
    
}


//判断仪器是否连接好
-(void)selectInstrument:(NSNotification *)noti
{
    IsInstrument = YES;
}


//判断是否空测试完成
-(void)selectFinshNullTest
{
    nullNum++;
    
    if (nullNum == 4) {
        
        exit(0);
    }
    
}


//=============================================
-(void)Working
{
    
    while ([[NSThread currentThread] isCancelled]==NO) //线程未结束一直处于循环状态
    {
#pragma mark-------------//index = 0,初始化控制板串口
        if (index == 0) {
            
            
            [NSThread sleepForTimeInterval:0.5];
            BOOL  isOpen = [serialport Open:param.contollerBoard]||[serialport Open:param.contollerBoard_two];
            
            if (param.isDebug) {
                
                NSLog(@"index = 0,debug中，模拟控制板初始化");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Status_TF setStringValue:@"index = 0,模拟控制板初始化"];
                });
                index = 1;
                [self UpdateTextView:@"index=0:板子初始化" andClear:NO andTextView:Log_View];
            }
            else if(isOpen)
            {
                NSLog(@"控制板成功连接");
                [self UpdateTextView:@"index=1:控制板连接成功" andClear:NO andTextView:Log_View];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Status_TF setStringValue:@"index=0,控制板(O)连接成功"];
                });
                
                if ([param.fixtureID containsString:@"EW"]) {
                    fixtureID = param.fixtureID;
                }else
                {
                    [NSThread sleepForTimeInterval:0.5];
                    [serialport WriteLine:@"Fixture ID?"];
                    [self UpdateTextView:@"serialport send Fixture ID?" andClear:NO andTextView:Log_View];
                    [NSThread sleepForTimeInterval:0.5];
                    
                    fixtureID = [serialport ReadExisting];
                    
                    if ([fixtureID containsString:@"\r\n"]) {

                        fixtureID = [[fixtureID componentsSeparatedByString:@"\r\n"] objectAtIndex:1];
                        fixtureID = [fixtureID stringByReplacingOccurrencesOfString:@"*_*" withString:@""];
                    }
                }
                sfcManager.station_id = fixtureID;
                if ([fixtureID length]>0&&[fixtureID containsString:@"EW"]) {
                    
                    index = 1;
                    [self UpdateTextView:@"index=0:控制板通信正常" andClear:NO andTextView:Log_View];
                    
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [Status_TF setStringValue:@"请检查治具电源"];
                        [self UpdateTextView:@"index=0:请检查治具电源" andClear:NO andTextView:Log_View];
                    });
                    
                }
                [self UpdateTextView:[NSString stringWithFormat:@"fixtureID:%@",fixtureID] andClear:NO andTextView:Log_View];
                
                [txtInshare TXT_Write:[NSString stringWithFormat:@"%@:主流程-->fixtureID=%@\n",[[GetTimeDay shareInstance] getFileTime],fixtureID]];
            }
            else
            {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Status_TF setStringValue:@"index=0,控制板(O)连接失败"];
                });
                [self UpdateTextView:@"index=0:控制板连接失败" andClear:NO andTextView:Log_View];
                [txtInshare TXT_Write:[NSString stringWithFormat:@"%@:主流程-->%@\n",[[GetTimeDay shareInstance] getFileTime],@"控制板连接失败"]];
                
            }
        }
#pragma mark-------------//index=1,初始化温湿度板子
        if (index == 1) {
            
            [NSThread sleepForTimeInterval:0.3];
            
            if (param.isDebug) {
                
                NSLog(@"index = 1,debug 模式中");
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Status_TF setStringValue:@"index=1,debug,温湿度成功"];
                });
                
                [self UpdateTextView:@"index=1:温湿度连接成功" andClear:NO andTextView:Log_View];
                
                index = 2;
            }
            else if (!humiturePort.IsOpen)
            {
                BOOL  isOpen = [humiturePort Open:param.humiture_uart_port_name]|| [humiturePort Open:param.humiture_uart_port_name_two];
                if (isOpen) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [Status_TF setStringValue:@"index=1,Humiture connect success"];
                    });
                    [self UpdateTextView:@"index=1:温湿度连接成功" andClear:NO andTextView:Log_View];
                    //获取温湿度的值
                    [NSThread sleepForTimeInterval:0.2];
                    [humiturePort WriteLine:@"Read"];
                    [NSThread sleepForTimeInterval:0.5];
                    NSString  * back_humitureStr = [[humiturePort ReadExisting] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    back_humitureStr= [back_humitureStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                    //显示温湿度
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [humiture_TF setStringValue:back_humitureStr];
                    });
                    if ([back_humitureStr containsString:@","]) {
                        
                        NSArray  * arr = [back_humitureStr componentsSeparatedByString:@","];
                        //存储温湿度
                        [config_Dic setValue:arr[0] forKey:kTemp];
                        [config_Dic setValue:arr[1] forKey:kHumit];
                        index = 2;
                    }
                    [self UpdateTextView:[NSString stringWithFormat:@"index=1:humiture_TF=%@",back_humitureStr] andClear:NO andTextView:Log_View];
                    [txtInshare TXT_Write:[NSString stringWithFormat:@"%@:主流程-->humiture_TF=%@\n",[[GetTimeDay shareInstance] getFileTime],back_humitureStr]];
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [Status_TF setStringValue:@"index=1,Humiture connect Fail"];
                    });
                    [self UpdateTextView:@"index=1,温湿度连接失败" andClear:NO andTextView:Log_View];
                     [txtInshare TXT_Write:[NSString stringWithFormat:@"%@:主流程-->humiture_TF=%@\n",[[GetTimeDay shareInstance] getFileTime],@"温湿度连接失败"]];
                }
            }
            else
            {
                NSLog(@"温湿度打开成功");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Status_TF setStringValue:@"index=1,Humiture connect success"];
                });
                
                //获取温湿度的值
                [NSThread sleepForTimeInterval:0.2];
                [humiturePort WriteLine:@"Read"];
                [NSThread sleepForTimeInterval:0.5];
                NSString  * back_humitureStr = [humiturePort ReadExisting];
                
                //显示温湿度
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [humiture_TF setStringValue:back_humitureStr];
                });
                
                if ([back_humitureStr containsString:@","]) {
                    
                    NSArray  * arr = [back_humitureStr componentsSeparatedByString:@","];
                    //存储温湿度
                    [config_Dic setValue:arr[0] forKey:kTemp];
                    [config_Dic setValue:arr[1] forKey:kHumit];
                    index = 2;
                }
                 [txtInshare TXT_Write:[NSString stringWithFormat:@"%@:主流程-->humiture_TF=%@\n",[[GetTimeDay shareInstance] getFileTime],back_humitureStr]];
            }
            
            
        }
        
        
#pragma mark-------------//index = 2,检测服务器
        if (index == 2) {
            
            [NSThread sleepForTimeInterval:0.3];
            
            if (param.isDebug) {//debug模式
                [self UpdateTextView:@"index=2,Debug模式:服务器检测OK" andClear:NO andTextView:Log_View];
                index = 3;
                [self CheckServer];
                
            }else if (isUpLoadSFC)  //上传服务器
            {
                [self CheckServer];
                
            }else  //不上传模式
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [Status_TF setStringValue:@"index=2,非服务器检测模式"];
                });
                [self UpdateTextView:@"index=2,非服务器检测模式" andClear:NO andTextView:Log_View];
                index = 3;
                isServer = NO;
            }
        }

        
#pragma mark-------------//index = 3,检测SN
        if (index == 3) {
            
            [NSThread sleepForTimeInterval:0.3];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [Status_TF setStringValue:@"index=3,输入或者扫SN"];
            });
            if (param.isDebug) {//debug模式
                [self UpdateTextView:@"index=2,Debug模式:给SN赋值\n22222222222222222" andClear:NO andTextView:Log_View];
                
                while (YES) {
                    
                    [NSThread sleepForTimeInterval:0.2];
                    
                    if ([Scan_SN_TF.stringValue length] == [num_PopButton.titleOfSelectedItem intValue]) {
                        
                        break;
                        
                    }
                }

                index = 4;
            }
            else
            {
                while (YES) {
                    
                     [NSThread sleepForTimeInterval:0.2];
                    
                    if ([Scan_SN_TF.stringValue length] == [num_PopButton.titleOfSelectedItem intValue]) {
                        
                        break;
                        
                    }
                }
            
                index = 4;
            }
        
        }
        
        
        
#pragma mark-------------//index = 4,给输入框赋值
        
        if (index == 4) {
            
            [NSThread sleepForTimeInterval:0.3];
            
            if (param.isDebug) {//debug模式
                [self UpdateTextView:@"index=4,Debug模式:给SN赋值\n22222222222222222" andClear:NO andTextView:Log_View];
                
                [NSThread sleepForTimeInterval:0.5];
                sfcManager.station_id = fixtureID;
                
                if (choose_dut1.state) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [NS_TF1 setStringValue:Scan_SN_TF.stringValue];
                        SN1_String = Scan_SN_TF.stringValue;
                    });
                    
                    
                }
                if (choose_dut2.state) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [NS_TF2 setStringValue:Scan_SN_TF.stringValue];
                        
                        SN2_String = Scan_SN_TF.stringValue;
                    });
                    
                }
                if (choose_dut3.state) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [NS_TF3 setStringValue:Scan_SN_TF.stringValue];
                        
                        SN3_String = Scan_SN_TF.stringValue;
                    });
                    
                    
                }
                if (choose_dut4.state) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [NS_TF4 setStringValue:Scan_SN_TF.stringValue];
                        SN4_String = Scan_SN_TF.stringValue;
                    });
                    
                }
                
                index = 7;
            }
            else
            {
                [NSThread sleepForTimeInterval:0.5];
                sfcManager.station_id = fixtureID;
                
                if (choose_dut1.state) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                         [NS_TF1 setStringValue:Scan_SN_TF.stringValue];
                         SN1_String = Scan_SN_TF.stringValue;
                    });
                    
                   
                }
                if (choose_dut2.state) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [NS_TF2 setStringValue:Scan_SN_TF.stringValue];
                        
                        SN2_String = Scan_SN_TF.stringValue;
                    });
                   
                }
                if (choose_dut3.state) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                          [NS_TF3 setStringValue:Scan_SN_TF.stringValue];
                        
                          SN3_String = Scan_SN_TF.stringValue;
                    });
                    
                 
                }
                if (choose_dut4.state) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [NS_TF4 setStringValue:Scan_SN_TF.stringValue];
                        SN4_String = Scan_SN_TF.stringValue;
                    });
                  
                }
                
                index = 7;
            }
            
        }
        
        
        
        
//#pragma mark-------------//index = 3,检测SN1的输入值
//        if (index == 3) {
//            
//            [NSThread sleepForTimeInterval:0.5];
//            sfcManager.station_id = fixtureID;
//            if (param.isDebug&&singleTest) {
//                
//                if (choose_dut1.state) {
//                    
//                    [self ShowcompareNumwithTextField:NS_TF1 Index:3 SnIndex:1];
//                }
//                else
//                {
//                    index = 4;
//                    
//                }
//                
//            }
//            else if (param.isDebug){
//                
//                if ([NS_TF1.stringValue length] == [num_PopButton.titleOfSelectedItem intValue]) {
//                    
//                    index = 4;
//                    
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        
//                        [Status_TF setStringValue:@"index = 3,SN1 is OK"];
//                    });
//                }
//                else{
//                    
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        
//                        [Status_TF setStringValue:@"index = 3,SN1 is Wrong"];
//                        
//                    });
//                }
//                
//            }
//            else if (singleTest){
//                
//                if (choose_dut1.state) {
//
//                    [self ShowcompareNumwithTextField:NS_TF1 Index:3 SnIndex:1];
//                }
//                else
//                {
//                    index = 4;
//                    
//                }
//            }
//            else{
//   
//                [self ShowcompareNumwithTextField:NS_TF1 Index:3 SnIndex:1];
//                
//            }
//        }
//        
//#pragma mark-------------//index = 4,检测SN2的输入值
//        if (index == 4) {
//            [NSThread sleepForTimeInterval:0.5];
//            if (param.isDebug&&singleTest) {
//                
//                if (choose_dut2.state)
//                {
//                    [self ShowcompareNumwithTextField:NS_TF2 Index:4 SnIndex:2];
//                }
//                else
//                {
//                    index = 5;
//                }
//            }
//            else if (param.isDebug) {
//                if ([NS_TF2.stringValue length] == [num_PopButton.titleOfSelectedItem intValue]){
//                    index = 5;
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        
//                        [Status_TF setStringValue:@"index = 4,SN2 is OK"];
//                    });
//                }
//                else{
//                    
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        
//                        [Status_TF setStringValue:@"index = 4,SN2 is Wrong"];
//                    });
//                    
//                }
//            }
//            else if (singleTest) {
//                if (choose_dut2.state)
//                {
//                    [self ShowcompareNumwithTextField:NS_TF2 Index:4 SnIndex:2];
//                }
//                else
//                {
//                    index = 5;
//                }
//            }
//            else
//            {
//                [self ShowcompareNumwithTextField:NS_TF2 Index:4 SnIndex:2];
//            }
//        }
//        
//#pragma mark-------------//index = 5,检测SN3的输入值
//        if (index == 5) {
//            [NSThread sleepForTimeInterval:0.5];
//            if (param.isDebug&&singleTest) {
//                
//                if (choose_dut3.state) {
//                    [self ShowcompareNumwithTextField:NS_TF3 Index:5 SnIndex:3];
//                }
//                else
//                {
//                    index = 6;
//                }
//            }
//            else if (param.isDebug) {
//                
//                if ([NS_TF3.stringValue length] == [num_PopButton.titleOfSelectedItem intValue]) {
//                    index = 6;
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        
//                        [Status_TF setStringValue:@"index = 5,SN3 is OK"];
//                    });
//                }else
//                {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        
//                        [Status_TF setStringValue:@"index = 5,SN3 is wrong"];
//                    });
//                }
//            }
//            else if (singleTest){
//                if (choose_dut3.state) {
//                    [self ShowcompareNumwithTextField:NS_TF3 Index:5 SnIndex:3];
//                }
//                else
//                {
//                    index = 6;
//                }
//            }
//            else
//            {
//                [self ShowcompareNumwithTextField:NS_TF3 Index:5 SnIndex:3];
//            }
//        }
//        
//#pragma mark-------------//index = 6,检测SN4的输入值
//        
//        if (index == 6) {
//            
//            [NSThread sleepForTimeInterval:0.5];
//            
//            if (param.isDebug&&singleTest) {
//                
//                if (choose_dut4.state) {
//                    [self ShowcompareNumwithTextField:NS_TF4 Index:6 SnIndex:4];
//                }
//                else
//                {
//                    index = 7;
//                }
//                
//            }
//            else if (param.isDebug)
//            {
//                if ([NS_TF4.stringValue length] == [num_PopButton.titleOfSelectedItem intValue]) {
//                    index = 7;
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        
//                        [Status_TF setStringValue:@"index = 6,SN4 is OK"];
//                    });
//                }
//                else{
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        
//                        [Status_TF setStringValue:@"index = 6,SN4 is Wrong"];
//                    });
//                }
//            }
//            else if (singleTest) {
//                
//                if (choose_dut4.state) {
//                    [self ShowcompareNumwithTextField:NS_TF4 Index:6 SnIndex:4];
//                }
//                else
//                {
//                    index = 7;
//                }
//            }
//            else
//            {
//                [self ShowcompareNumwithTextField:NS_TF4 Index:6 SnIndex:4];
//            }
//            
//            
//        }
        
        
        
#pragma mark------------//index=7,判断当前配置文件和changeID等配置
        if (index == 7) { //判断当前配置文件和changeID等配置
            
            [NSThread sleepForTimeInterval:0.3];
            
            [self saveConfigStation];
            
            
            //index = 1000;等待点击
            dispatch_async(dispatch_get_main_queue(), ^{
               
                startbutton.enabled = YES;
                
                [Status_TF setStringValue:@"index = 7,点击键盘或者鼠标"];
            });
            index = 1000;

            //=============判断config
            if (config_change.state) {
                
                NSLog(@"Please cancell Config Button");
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //startbutton.enabled = YES;
                    [Status_TF setStringValue:@"index=7,Cancell Config Button"];
                });
                
                index = 7;
            }
            
            //=============判断OP_ID
            if (change_OpID.state) {
                
                NSLog(@"Please cancell Change_ID");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Status_TF setStringValue:@"index=7,Cancell Change_ID Button"];
                });
                
                index = 7;
            }
            
            //=============判断config
            if (Choose_SN.state) {
                
                NSLog(@"Please cancell C Button");
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //startbutton.enabled = YES;
                    [Status_TF setStringValue:@"index=7,Cancell C Button"];
                });
                
                index = 7;
            }
        }
        
#pragma mark-------------//index=8,双击start按钮/或者点击界面上的start按钮
        if (index == 8) {
            
            [NSThread sleepForTimeInterval:0.5];
            
            NSString  * backstring = [serialport ReadExisting] ;
            
            [self UpdateTextView:[NSString stringWithFormat:@"index=8:backstring=%@",backstring] andClear:NO andTextView:Log_View];
            
            if (param.isDebug&&!startbutton.enabled) {
                NSLog(@"index = 8,debug 模式中");
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [Status_TF setStringValue:@"index=8,debug模式，双击启动"];
                    
                });
                index = 9;
            }
            else if ([backstring containsString:@"START"]&&[backstring containsString:@"*_*\r\n"])
            {
                NSLog(@"检测START，软件开始测试");
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [Status_TF setStringValue:@"index=9,Start OK"];
                    startbutton.enabled = NO;
                    
                });
                [self UpdateTextView:@"index=8,双击启动成功" andClear:NO andTextView:Log_View];
                index = 9;
                
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Status_TF setStringValue:@"index=8,Start NG,请启动"];
                    
                    startbutton.enabled = YES;
                });
                [self UpdateTextView:@"index=8,请重新双击启动" andClear:NO andTextView:Log_View];
                
            }
            
            
        }
        
        
        
#pragma mark-------------//index=9,发送开始测试的通知
        if (index == 9) {
            
            
            //配置好了，将相关参数传送
            if (action1!=nil) {
                action1.Config_Dic = [NSDictionary dictionaryWithDictionary:config_Dic];
            }
            if (action2!=nil) {
                action2.Config_Dic = [NSDictionary dictionaryWithDictionary:config_Dic];
            }
            if (action3!=nil) {
                action3.Config_Dic = [NSDictionary dictionaryWithDictionary:config_Dic];
            }
            if (action4!=nil) {
                action4.Config_Dic = [NSDictionary dictionaryWithDictionary:config_Dic];
            }
            
            //给SN赋值
            if(choose_dut1.state){
                action1.dut_sn = NS_TF1.stringValue;
                action1.isTest = YES;
                [ChooseNumArray addObject:@"Test"];
            }
            if (choose_dut2.state) {
                
                action2.dut_sn = NS_TF2.stringValue;
                action2.isTest = YES;
                [ChooseNumArray addObject:@"Test"];
            }
            if (choose_dut3.state) {
                action3.dut_sn = NS_TF3.stringValue;
                action3.isTest = YES;
                [ChooseNumArray addObject:@"Test"];
            }
            if (choose_dut4.state) {
                action4.dut_sn = NS_TF4.stringValue;
                action4.isTest = YES;
                [ChooseNumArray addObject:@"Test"];
            }
            
            
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NSThreadStart_Notification" object:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                startbutton.enabled = NO;
//              Operator_TF.editable = NO;
                [tab1 ClearTable];
                [DUT_Result1_TF setStringValue:@""];
                [DUT_Result2_TF setStringValue:@""];
                [DUT_Result3_TF setStringValue:@""];
                [DUT_Result4_TF setStringValue:@""];
            });
            [testFieldTimes setStringValue:@"0"];
            [mkTimer setTimer:0.1];
            [mkTimer startTimerWithTextField:testFieldTimes];
            ct_cnt = 1;
            dispatch_async(dispatch_get_main_queue(), ^{
                [Status_TF setStringValue:@"index=10,Testing......"];
            });
            index = 1000;
            
        }
        
        
#pragma mark-------------//index=101,A治具测试结束，发送指令信号灯
        if (fix_A_num == 101) {
            
            [NSThread sleepForTimeInterval:0.3];
            
            testingFixStr = @"ASN1";
            
            if (param.isDebug) {
                
                NSLog(@"治具A测试完毕，灯光操作完成");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Status_TF setStringValue:@"fix_A_num=101,A测试结束，点亮灯"];
                });
                
                [self LightAndShowResultWithFix:notiString_A withSN:SN1_String TestingFixStr:testingFixStr Dictionary:A_resultDic PresentIndex:presentCount  TotalIndex:totalCount];
                
            }
            else
            {
                [self LightAndShowResultWithFix:notiString_A withSN:SN1_String TestingFixStr:testingFixStr Dictionary:A_resultDic PresentIndex:presentCount  TotalIndex:totalCount];
                
            }
            
        }
        
        
#pragma mark-------------//index=102,B治具测试结束，发送指令信号灯
        if (fix_B_num == 102) {
            
            [NSThread sleepForTimeInterval:0.3];
            testingFixStr = @"BSN2";
            
            if (param.isDebug) {
                
                NSLog(@"治具B测试完毕，灯光操作完成");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Status_TF setStringValue:@"fix_B_num=102,B测试结束，点亮灯"];
                });
                
                [self LightAndShowResultWithFix:notiString_B withSN:SN2_String TestingFixStr:testingFixStr Dictionary:B_resultDic PresentIndex:presentCount TotalIndex:totalCount];
            }
            else
            {
                
                [self LightAndShowResultWithFix:notiString_B withSN:SN2_String TestingFixStr:testingFixStr Dictionary:B_resultDic PresentIndex:presentCount TotalIndex:totalCount];
            }
            
            
            
        }
        
#pragma mark-------------//index=103,C治具测试结束，发送指令信号灯
        if (fix_C_num == 103) {
            
            [NSThread sleepForTimeInterval:0.3];
            testingFixStr = @"CSN3";
            
            if (param.isDebug) {
                
                NSLog(@"治具C测试完毕，灯光操作完成");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Status_TF setStringValue:@"fix_C_num=103,C测试结束，点亮灯"];
                });
                
                [self LightAndShowResultWithFix:notiString_C withSN:SN3_String TestingFixStr:testingFixStr Dictionary:C_resultDic PresentIndex:presentCount TotalIndex:totalCount];
            }
            else
            {
                [self LightAndShowResultWithFix:notiString_C withSN:SN3_String TestingFixStr:testingFixStr Dictionary:C_resultDic PresentIndex:presentCount TotalIndex:totalCount];
            }
        }
        
        
#pragma mark-------------//index=104,D治具测试结束，发送指令信号灯
        if (fix_D_num == 104) { //扫描SN
            
            [NSThread sleepForTimeInterval:0.3];
            testingFixStr = @"DSN4";
            if (param.isDebug) {
                NSLog(@"治具D测试完毕，灯光操作完成");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Status_TF setStringValue:@"fix_D_num=104,D测试结束，点亮灯"];
                });
                  [self LightAndShowResultWithFix:notiString_D withSN:SN4_String TestingFixStr:testingFixStr Dictionary:D_resultDic PresentIndex:presentCount TotalIndex:totalCount];
            }
            else
            {
                 [self LightAndShowResultWithFix:notiString_D withSN:SN4_String TestingFixStr:testingFixStr Dictionary:D_resultDic PresentIndex:presentCount TotalIndex:totalCount];
            }
            
        }
        
#pragma mark-------------//index=105,所有软件测试结束
        if (index == 105) {
            //========定时器结束========
            [mkTimer endTimer];
            ct_cnt = 0;
            
            
            [NSThread sleepForTimeInterval:0.5];
            if (param.isDebug) {
                NSLog(@"整个测试已经结束，回到初始状态");
                [self UpdateTextView:[NSString stringWithFormat:@"index = 105:%@",@"所有测试结束，回到初始状态"] andClear:NO andTextView:Log_View];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [TestCount_TF setStringValue:[NSString stringWithFormat:@"%d/%d",passNum,totalNum]];
                    startbutton.enabled = YES;
                    ComfirmButton.enabled = YES;
                    
                    //清空所有NStextView的值
                    [self UpdateTextView:@"" andClear:YES andTextView:A_LOG_TF];
                    [self UpdateTextView:@"" andClear:YES andTextView:B_LOG_TF];
                    [self UpdateTextView:@"" andClear:YES andTextView:C_LOG_TF];
                    [self UpdateTextView:@"" andClear:YES andTextView:D_LOG_TF];
                    
                    //设置OP_ID输入框可以输入
                    Operator_TF.enabled = YES;
                    
                    testnum = 0;
                    //========定时器结束========
                    [mkTimer endTimer];
                    ct_cnt = 0;
                    
                });
                
                
                //[[NSNotificationCenter defaultCenter] postNotificationName:@"NSThreadEnd_Notification" object:nil];
                
                [ChooseNumArray removeAllObjects];
                
                if (singleTest) {
                    
                    index = 3;
                }
                else if (isLoopTest)
                {
                    [NSThread sleepForTimeInterval:10];
                    index = 7;
                }
                else
                {
                    index = 2;
                }
            }
            else
            {
                [self UpdateTextView:[NSString stringWithFormat:@"index = 105:%@",@"所有测试结束，回到初始状态"] andClear:NO andTextView:Log_View];
                
                
                
                
                //发送reset的命令
                [serialport WriteLine:@"reset"];
                
                [NSThread sleepForTimeInterval:0.5];
                
                if ([[serialport ReadExisting] containsString:@"OK"]) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [Status_TF setStringValue:@"治具复位OK"];
                    });
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [TestCount_TF setStringValue:[NSString stringWithFormat:@"%d/%d",passNum,totalNum]];
                        startbutton.enabled = NO;
                        ComfirmButton.enabled = YES;
                        
                        //清空所有NStextView的值
                        [self UpdateTextView:@"" andClear:YES andTextView:A_LOG_TF];
                        [self UpdateTextView:@"" andClear:YES andTextView:B_LOG_TF];
                        [self UpdateTextView:@"" andClear:YES andTextView:C_LOG_TF];
                        [self UpdateTextView:@"" andClear:YES andTextView:D_LOG_TF];
                        
                        //设置OP_ID输入框可以输入
                        Operator_TF.enabled = YES;
                        testnum = 0;
                         NSTextField *TF = [self.view viewWithTag:1];
                        [TF becomeFirstResponder];
                        
                    });
                    
                    //测试结束时，发送结束通知
                   // [[NSNotificationCenter defaultCenter] postNotificationName:@"NSThreadEnd_Notification" object:nil];
                    
                    [ChooseNumArray removeAllObjects];
                    
                    if (singleTest) {
                        
                        index = 3;
                    }
                    else if (isLoopTest)
                    {
                        [NSThread sleepForTimeInterval:10];
                        index = 7;
                    }
                    else
                    {
                        index = 2;
                    }
                    
                    
                    [self updateFoam];
                }
                
                
            }
            
            
        }
        
#pragma mark-------------//index=1000,测试结束
        if (index == 1000) { //等待测试结束，并返回测试的结果
            [NSThread sleepForTimeInterval:0.001];
        }
        
    }
    
    
}


#pragma mark====================测试模式:空测，单测，循环
-(void)selectTestModeNotice:(NSNotification *)noti
{
    
    if ([noti.name isEqualToString:kNullTestNotice]) {//空测模式
        
        if ([noti.object isEqualToString:@"YES"]) {
            
            nulltest_button.hidden = NO;
            isNullTest = YES;
            itemArr1 = [plist PlistRead:@"Station_Cr_3_Humid" Key:@"AllItems"];
            tab1 = [tab1 init:Tab1_View DisplayData:itemArr1];
            
            [action1 setCsvTitle:plist.titile];
            [action2 setCsvTitle:plist.titile];
            [action3 setCsvTitle:plist.titile];
            [action4 setCsvTitle:plist.titile];
        }
        else
        {
            
            nulltest_button.hidden = YES;
            itemArr1 = [plist PlistRead:@"Station_Cr_1_Humid" Key:@"AllItems"];
            isNullTest = NO;
            tab1 = [tab1 init:Tab1_View DisplayData:itemArr1];
            
        }
    }
    
    
    if ([noti.name isEqualToString:kLoopTestNotice]) { //循环测试模式
        
        
        if ([noti.object isEqualToString:@"YES"]) {
            
            isLoopTest = YES;
        }
        else
        {
            
            isLoopTest = NO;
            
        }
        
        
        
    }
    
    
}


//PDCA和SFC的改变
-(void)selectSfc_PdcaUpload:(NSNotification *) noti
{
    if ([noti.name isEqualToString:kPdcaUploadNotice]) {
        
        if ([noti.object isEqualToString:@"YES"]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                IsUploadPDCA_Button.state = YES;
                isUpLoadPDCA = YES;
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                IsUploadPDCA_Button.state = NO;
                isUpLoadPDCA = NO;
            });
            
        }
        
        NSLog(@"isUpLoadPDCA===%d",isUpLoadPDCA);
    }
    if ([noti.name isEqualToString:kSfcUploadNotice]) {
        
        if ([noti.object isEqualToString:@"YES"]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                IsUploadSFC_Button.state = YES;
                
                isUpLoadSFC = YES;
            });
            
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                IsUploadSFC_Button.state = NO;
                
                isUpLoadSFC = NO;
            });
        }
        
        NSLog(@"isUpLoadSFC===%d",isUpLoadSFC);
    }
    
    
    
    
}




//创建A,B,C,D治具对应的文件ABCD
-(void)creat_TotalFile
{
    NSString  *  day = [[GetTimeDay shareInstance] getCurrentDay];
    
    totalFold = [NSString stringWithFormat:@"/%@/%@",totalPath,NestID_Change.titleOfSelectedItem];
    
    if ([product_Config.stringValue length]>0) {
        
        foldDir = [totalFold stringByAppendingFormat:@"/%@",product_Config.stringValue];
    }
    else
    {
        foldDir = [totalFold stringByAppendingFormat:@"/%@",@"NoConfig"];
    }
    
    
    [self createFileWithstr:[NSString stringWithFormat:@"%@/%@_A.csv",foldDir,day] withFold:foldDir];
    [self createFileWithstr:[NSString stringWithFormat:@"%@/%@_B.csv",foldDir,day] withFold:foldDir];
    [self createFileWithstr:[NSString stringWithFormat:@"%@/%@_C.csv",foldDir,day] withFold:foldDir];
    [self createFileWithstr:[NSString stringWithFormat:@"%@/%@_D.csv",foldDir,day] withFold:foldDir];
    
}


/**
 *  生成文件
 *
 *  @param fileString 文件的地址
 */
-(void)createFileWithstr:(NSString *)fileString withFold:(NSString *)foldStr
{
    while (YES) {
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:fileString]) {
            break;
        }
        else
        {
            
            [fold Folder_Creat:foldStr];
            [csvFile CSV_Open:fileString];
            [csvFile CSV_Write:plist.titile];
        }
        
    }
    
}




#pragma mark---------------监听网络通知
-(void)reachabilityChanged:(NSNotification *)noti
{
    
    Reachability  * curReach = [noti object];
    NSCParameterAssert([curReach isKindOfClass:[Reachability class]]);
    NetworkStatus netStatus = [curReach currentReachabilityStatus];

    if(curReach == hostReachbility)
    {
        [self NetworkState:hostReachbility];
    }
    
    
    NSLog(@"%ld",(long)netStatus);
    
}



#pragma mark---------------选择扫码模式
-(void)selectScanQRCode:(NSNotification *)noti
{
    
    index = 3;//重新检测SN1
    
    
}


#pragma mark---------------选择测试项
- (IBAction)single_test_action:(id)sender {
    
    if (singlebutton.state) {
        
        ComfirmButton.hidden = NO;
        choose_dut1.enabled = YES;
        choose_dut2.enabled = YES;
        choose_dut3.enabled = YES;
        choose_dut4.enabled = YES;
    }
    else
    {
        choose_dut1.enabled  = NO;
        choose_dut2.enabled  = NO;
        choose_dut3.enabled  = NO;
        choose_dut4.enabled  = NO;
        ComfirmButton.hidden = YES;
    }
}


#pragma mark------------写入空测值
- (IBAction)NullTestDone_Button:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WriteNullValue" object:nil];
    
}


#pragma mark-------------数据清零
- (IBAction)flush_Result:(id)sender {
    
    totalNum = 0;
    passNum  = 0;
    
    [TestCount_TF setStringValue:@"0/0"];
}






//重新选择产品测试
- (IBAction)makesureDut:(id)sender {
    
    singlebutton.state = NO;
    singleTest = YES;
    isComfirmOK = YES;
    
    //makesure之后不可点击
    choose_dut1.enabled = NO;
    choose_dut2.enabled = NO;
    choose_dut3.enabled = NO;
    choose_dut4.enabled = NO;
    ComfirmButton.hidden = YES;
    
    [ChooseNumArray removeAllObjects];
    
    if (singleTest) {
        
        index = 3;
    }
    if (choose_dut1.state) {
        
        [self createThreadWithNum:1];
    }
    if (choose_dut2.state) {
        
        [self createThreadWithNum:2];
    }
    
    if (choose_dut3.state) {
        
        [self createThreadWithNum:3];
    }
    
    if (choose_dut4.state) {
        
        [self createThreadWithNum:4];
        
    }
    
}





#pragma mark 控制光标 成为第一响应者

-(void)controlTextDidChange:(NSNotification *)obj{
    
    NSTextField *tf = (NSTextField *)obj.object;
    
//    if (tf.tag == 4) {
//        
//        [tf setEditable:YES];
//    }
    
    if (tf.stringValue.length == [num_PopButton.titleOfSelectedItem intValue]) {
        
        
        NSTextField *nextTF;
        if (tf.tag == 100) {
            
            tf.editable = NO;
        }
        else
        {
            nextTF = [self.view viewWithTag:1];
        }
        
        
        if (nextTF) {
            
            
            if (nextTF.tag == 4) {
                
                [nextTF setEditable:YES];
                
            }
            [tf resignFirstResponder];
            [nextTF becomeFirstResponder];
            
        }
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
                               [NSThread sleepForTimeInterval:0.01];
                               NSString * messageString = [NSString stringWithFormat:@"%@: %@\n",[[GetTimeDay shareInstance] getFileTime],strMsg];
                               NSRange range = NSMakeRange([textView.textStorage.string length] , messageString.length);
                               [textView insertText:messageString replacementRange:range];
                               
                           }
                           else
                           {
                               NSString * messageString = [NSString stringWithFormat:@"%@: %@\n",[[GetTimeDay shareInstance] getFileTime],strMsg];
                               [textView setString:[NSString stringWithFormat:@"%@",messageString]];
                           }
                           
                           [textView setTextColor:[NSColor redColor]];
                           
                       });
    }
}




#pragma mark----------------生成线程

-(void)createThreadWithNum:(int)num
{
    
    if (num == 1 && action1 == nil) {
        action1  = [[TestAction alloc] initWithTable:tab1 withFixParam:param withType:num];
        action1.resultTF  = DUT_Result1_TF;//显示结果的lable
        action1.Log_View  = A_LOG_TF;
        action1.Fail_View = A_FailItem;
        action1.dutTF     = NS_TF1;
        [action1 setCsvTitle:plist.titile];
        
    }
    
    if (num == 2 && action2 == nil) {
        action2  = [[TestAction alloc] initWithTable:tab1 withFixParam:param withType:num];
        action2.resultTF  = DUT_Result2_TF;//显示结果的lable
        action2.Log_View  = B_LOG_TF;
        action2.Fail_View =B_FailItem;
        action2.dutTF     = NS_TF2;
        [action2 setCsvTitle:plist.titile];
    }
    
    if (num == 3 && action3 == nil) {
        
        action3 = [[TestAction alloc]initWithTable:tab1 withFixParam:param withType:num];
        action3.resultTF   = DUT_Result3_TF;//显示结果的lable
        action3.Log_View   = C_LOG_TF;
        action3.Fail_View  = C_FailItem;
        action3.dutTF      = NS_TF3;
        [action3 setCsvTitle:plist.titile];
    }
    
    if (num ==4 && action4 == nil){
        action4 = [[TestAction alloc] initWithTable:tab1 withFixParam:param withType:num];
        action4.resultTF  = DUT_Result4_TF;//显示结果的lable
        action4.Log_View  = D_LOG_TF;
        action4.Fail_View = D_FailItem;
        action4.dutTF     = NS_TF4;
        [action4 setCsvTitle:plist.titile];
    }
    
}


#pragma mark---------------释放仪器仪表
-(void)viewWillDisappear
{
    
    if (action1 != nil) {
        
        [action1 threadEnd];
        action1 = nil;
    }
    if (action2 != nil) {
        
        [action2 threadEnd];
        action2 = nil;
    }
    if (action3 != nil) {
        
        [action3 threadEnd];
        action3 = nil;
    }
    if (action4 != nil) {
        
        [action4 threadEnd];
        action4 = nil;
    }
    
    [serialport Close];
    [humiturePort Close];
    
    
    
}




#pragma mark---------------正常测试时，数据校验
-(void)compareSNToServerwithTextField:(NSTextField *)tf Index:(int)testIndex SnIndex:(int)snIndex
{
    
    if ([tf.stringValue length] == [num_PopButton.titleOfSelectedItem intValue]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [Status_TF setStringValue:[NSString stringWithFormat:@"index = %d:SN%d Enter OK",testIndex,snIndex]];
            tf.editable = NO;
        });
        
        NSString  * startTime = [[GetTimeDay shareInstance] getCurrentDateAndTime];
        testStep.strSN  = tf.stringValue;
        [NSThread sleepForTimeInterval:0.05];
        
        if (isUpLoadPDCA) {
            
            [NSThread sleepForTimeInterval:0.1];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [Status_TF setStringValue:[NSString stringWithFormat:@"index = %d:SN%d不检验",testIndex,snIndex]];
            });
            
            if (snIndex==1)SN1_String = tf.stringValue;
            if (snIndex==2)SN2_String = tf.stringValue;
            if (snIndex==3)SN3_String = tf.stringValue;
            if (snIndex==4)SN4_String = tf.stringValue;
        }
        else
        {
            if ([testStep StepSFC_CheckUploadSN:YES Option:@"isPassOrNot" testResult:nil startTime:startTime testArgument:nil PresentIndex:presentCount TotalIndex:totalCount]&&isServer)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Status_TF setStringValue:[NSString stringWithFormat:@"SN%d 检验OK",snIndex]];
                });
                
                index = testIndex+1;;
                [txtInshare TXT_Write:[NSString stringWithFormat:@"%@:主流程-->SN=%@\n",[[GetTimeDay shareInstance] getFileTime],[NSString stringWithFormat:@"SN%d 检验OK",snIndex]]];
                
                if (snIndex==1)SN1_String = tf.stringValue;
                if (snIndex==2)SN2_String = tf.stringValue;
                if (snIndex==3)SN3_String = tf.stringValue;
                if (snIndex==4)SN4_String = tf.stringValue;
               
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [tf  setStringValue:@"上一个工站检测NG"];
                });
                if (snIndex==1)action1.SNisRight = YES;
                if (snIndex==2)action2.SNisRight = YES;
                if (snIndex==3)action3.SNisRight = YES;
                if (snIndex==4)action4.SNisRight = YES;
                
                //通知子线程，重新扫码
                [[NSNotificationCenter defaultCenter] postNotificationName:kTestAgainNotice object:nil];
            }
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [Status_TF setStringValue:[NSString stringWithFormat:@"index = %d:SN%d NG,Enter right SN",testIndex,snIndex]];
        });
        [txtInshare TXT_Write:[NSString stringWithFormat:@"%@:主流程-->SN=%@\n",[[GetTimeDay shareInstance] getFileTime],[NSString stringWithFormat:@"index = %d:SN%d NG,Enter right SN",testIndex,snIndex]]];
        
    }
    
}


#pragma mark---------------正常测试时，无SFC请求时
-(void)ShowcompareNumwithTextField:(NSTextField *)tf Index:(int)testIndex SnIndex:(int)snIndex
{
    
    
    if ([tf.stringValue length] == [num_PopButton.titleOfSelectedItem intValue]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [Status_TF setStringValue:[NSString stringWithFormat:@"index = %d:SN%d Enter OK",testIndex,snIndex]];
            
             tf.editable = NO;
        });
        
        index = testIndex+1;;
        
        if (snIndex==1)SN1_String = tf.stringValue;
        if (snIndex==2)SN2_String = tf.stringValue;
        if (snIndex==3)SN3_String = tf.stringValue;
        if (snIndex==4)SN4_String = tf.stringValue;
       
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [Status_TF setStringValue:[NSString stringWithFormat:@"index = %d:SN%d NG,Enter right SN",testIndex,snIndex]];
        });
        
    }
}


#pragma mark--------------点亮指示灯，并显示测试的结果
-(void)LightAndShowResultWithFix:(NSString *)notiString withSN:(NSString *)sn TestingFixStr:(NSString *)testingFix Dictionary:(NSDictionary *)resultDic PresentIndex:(int)presentIndex TotalIndex:(int)totalIndex
{
    
    NSLog(@"notiString=%@,sn=%@",notiString,sn);
    
    NSString  * SnString = [testingFix substringFromIndex:1];
    NSString* startTime = [[GetTimeDay shareInstance] getCurrentDateAndTime];
    NSArray   *   arr  = [resultDic objectForKey:@"dic"];
    presentCount++;
    if (isUpLoadSFC&&isServer&&isWebOpen) {//数据上传
        
        //上传3次ng，将数据存储到本地
        int i = 0;
        BOOL isUploadOK = NO;
        while (i<3) {
            testStep.strSN  = sn;
            if ([testStep StepSFC_CheckUploadSN:YES Option:@"uploadLog" testResult:[notiString containsString:@"P"]?@"Pass":@"Fail" startTime:startTime testArgument:arr PresentIndex:presentIndex TotalIndex:totalIndex])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [Status_TF setStringValue:[NSString stringWithFormat:@"%@ SFC upload success",SnString]];
                });
                
                [txtInshare TXT_Write:[NSString stringWithFormat:@"%@:主流程-->%@\n",[[GetTimeDay shareInstance] getFileTime],[NSString stringWithFormat:@"%@ SFC upload success",SnString]]];
                
                //[txt_N_file TXT_Write:[NSString stringWithFormat:@"%@:主流程-->%@\n",[[GetTimeDay shareInstance] getFileTime],[NSString stringWithFormat:@"%@ SFC upload success",SnString]]];
                
                isUploadOK = YES;
                break;
            }
            
            i++;
        }
        
        if (isUploadOK==NO) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [Status_TF setStringValue:[NSString stringWithFormat:@"%@ SFC upload fail",SnString]];
            });
            
            @autoreleasepool {
                NSMutableString    *  urlString = [[NSMutableString alloc] initWithCapacity:10];
                [urlString appendFormat:@"%@=%@&", SFC_TEST_SN, sn];
                [urlString appendFormat:@"%@=%@&", SFC_TEST_RESULT, [notiString containsString:@"P"]?@"Pass":@"Fail"];
                [urlString appendFormat:@"%@=%@",SFC_TEST_START_TIME,startTime];
                [urlString appendFormat:@"&p%d=%d",1,presentIndex];
                [urlString appendFormat:@"&p%d=%d",2,totalIndex];
                for(int i = 0; i < [arr count]; i++)
                {
                    [urlString appendFormat:@"&p%d=%@",i+3,arr[i]];
                }
                [urlString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                [urlString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                [urlString appendString:@"\n"];
                [txtFile TXT_Open:updata_path];
                [txtFile TXT_Write:urlString];
            }
            
            [txtInshare TXT_Write:[NSString stringWithFormat:@"%@:主流程-->%@\n",[[GetTimeDay shareInstance] getFileTime],[NSString stringWithFormat:@"%@ SFC upload fail",SnString]]];
            //[txt_N_file TXT_Write:[NSString stringWithFormat:@"%@:主流程-->%@\n",[[GetTimeDay shareInstance] getFileTime],[NSString stringWithFormat:@"%@ SFC upload fail",SnString]]];
        }
        
        //将数据上传的结果显示在compare_path路径中
        @autoreleasepool {
            
            NSMutableString * content = [[NSMutableString alloc]initWithCapacity:10];
            [content appendFormat:@"StartTime=%@;SN=%@;arr=%lu;isUploadOK=%hhd\n",startTime,sn,(unsigned long)[arr count],isUploadOK];
            NSString * compare_path = [NSString stringWithFormat:@"%@/%@",totalPath,@"comparedata.txt"];
            [txtFile TXT_Open:compare_path];
            [txtFile TXT_Write:content];
        }
    }
    else//数据保存在本地
    {
        @autoreleasepool {
            NSMutableString    *  urlString = [[NSMutableString alloc] initWithCapacity:10];
            [urlString appendFormat:@"%@&",fixtureID];
            [urlString appendFormat:@"%@=%@&", SFC_TEST_SN, sn];
            [urlString appendFormat:@"%@=%@&", SFC_TEST_RESULT, [notiString containsString:@"P"]?@"Pass":@"Fail"];
            [urlString appendFormat:@"%@=%@",SFC_TEST_START_TIME,startTime];
            [urlString appendFormat:@"&p%d=%d",1,presentIndex];
            [urlString appendFormat:@"&p%d=%d",2,totalIndex];
            NSArray   *   arr  = [resultDic objectForKey:@"dic"];
            for(int i = 0; i < [arr count]; i++)
            {
                [urlString appendFormat:@"&p%d=%@",i+1,arr[i]];
            }
            [urlString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            [urlString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            [urlString appendString:@"\n"];
            [txtFile TXT_Open:updata_path];
            [txtFile TXT_Write:urlString];
        }
        
        
        //将数据上传的结果显示在compare_path路径中
        @autoreleasepool {
            
            NSMutableString * content = [[NSMutableString alloc]initWithCapacity:10];
            [content appendFormat:@"StartTime=%@;SN=%@;arr=%lu;isUploadOK=%d\n",startTime,sn,(unsigned long)[arr count],false];
            NSString * compare_path = [NSString stringWithFormat:@"%@/%@",totalPath,@"comparedata.txt"];
            [txtFile TXT_Open:compare_path];
            [txtFile TXT_Write:content];
        }
        
        
    }
    
    NSString  * string = [testingFix substringToIndex:1];
    //发送指示灯
    if ([notiString containsString:@"P"]) {
        
        passNum++;
        
        [serialport WriteLine:[NSString stringWithFormat:@"FIX_%@ pass",string]];
        
        [NSThread sleepForTimeInterval:0.5];
        
        if ([[serialport ReadExisting] containsString:@"OK"]) {
            NSLog(@"FIX_%@，亮绿灯",string);
        }
        
    }
    else
    {
        [serialport WriteLine:[NSString stringWithFormat:@"FIX_%@ fail",string]];
        [NSThread sleepForTimeInterval:0.5];
        if ([[serialport ReadExisting] containsString:@"OK"]) {
            NSLog(@"FIX_%@,亮红灯",string);
        }
    }
    
    
    if ([string containsString:@"A"])fix_A_num=0;
    if ([string containsString:@"B"])fix_B_num=0;
    if ([string containsString:@"C"])fix_C_num=0;
    if ([string containsString:@"D"])fix_D_num=0;
    testnum++;
    
    //    [self UpdateTextView:[NSString stringWithFormat:@"fix_A_num=%d,testnum=%d",fix_A_num,testnum] andClear:NO andTextView:Log_View];
    
    [txtInshare TXT_Write:[NSString stringWithFormat:@"%@:主流程-->%@\n",[[GetTimeDay shareInstance] getFileTime],[NSString stringWithFormat:@"testnum=%d",testnum]]];
    //[txt_N_file TXT_Write:[NSString stringWithFormat:@"%@:主流程-->%@\n",[[GetTimeDay shareInstance] getFileTime],[NSString stringWithFormat:@"testnum=%d",testnum]]];
    
    if (testnum== 4||testnum==[ChooseNumArray count]) {
        
        index = 105;
        
        NSLog(@"%@====%d",string,testnum);
    }
}



#pragma mark----------------刷新泡棉次数
-(void)updateFoam
{

    //测试结束时，发送结束通知
     [txt_N_file TXT_Write:@"*********************************\n\n\n*********************************\n"];
    
    //泡棉弹窗，超过预设值时清零
    int  Test_Foam_Num = [[[NSUserDefaults standardUserDefaults] objectForKey:kPresentNum] intValue];
    Test_Foam_Num = Test_Foam_Num +1;
    if (Test_Foam_Num>=[param.FoamNum intValue]){
        [alert ShowCancelAlert:[NSString stringWithFormat:@"泡棉已达到%d,请更换泡棉",[param.FoamNum intValue]]];
    }
    //存在本地
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d",Test_Foam_Num>=[param.FoamNum intValue]?0:Test_Foam_Num] forKey:kPresentNum];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [Forum_TF setStringValue:[NSString stringWithFormat:@"%d/%@",Test_Foam_Num,param.FoamNum]];
    });





}


//#pragma mark--------------点亮指示灯，并显示测试的结果
//-(void)LightAndShowResultWithFix:(NSString *)notiString withSN:(NSString *)sn TestingFixStr:(NSString *)testingFix Dictionary:(NSDictionary *)resultDic
//{
//    
//    NSLog(@"notiString=%@,sn=%@",notiString,sn);
//    
//    NSString  * SnString = [testingFix substringFromIndex:1];
//    NSString* startTime = [[GetTimeDay shareInstance] getCurrentDayTime];
//    NSArray   *   arr  = [resultDic objectForKey:@"dic"];
//    
//    if (isUpLoadSFC&&isServer&&isWebOpen) {//数据上传
//        
//        //上传3次ng，将数据存储到本地
//        int i = 0;
//        BOOL isUploadOK = NO;
//        while (i<3) {
//            testStep.strSN  = sn;
//            if ([testStep StepSFC_CheckUploadSN:YES Option:@"uploadLog" testResult:[notiString containsString:@"P"]?@"Pass":@"Fail" startTime:startTime testArgument:arr])
//            {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    
//                    [Status_TF setStringValue:[NSString stringWithFormat:@"%@ SFC upload success",SnString]];
//                });
//                
//                [txtInshare TXT_Write:[NSString stringWithFormat:@"%@:主流程-->%@\n",[[GetTimeDay shareInstance] getFileTime],[NSString stringWithFormat:@"%@ SFC upload success",SnString]]];
//                
//                ////[txt_N_file TXT_Write:[NSString stringWithFormat:@"%@:主流程-->%@\n",[[GetTimeDay shareInstance] getFileTime],[NSString stringWithFormat:@"%@ SFC upload success",SnString]]];
//                
//                isUploadOK = YES;
//                break;
//            }
//            i++;
//        }
//        
//        if (isUploadOK==NO) {
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [Status_TF setStringValue:[NSString stringWithFormat:@"%@ SFC upload fail",SnString]];
//            });
//            
//            @autoreleasepool {
//                NSMutableString    *  urlString = [[NSMutableString alloc] initWithCapacity:10];
//                [urlString appendFormat:@"%@=%@&", SFC_TEST_SN, sn];
//                [urlString appendFormat:@"%@=%@&", SFC_TEST_RESULT, [notiString containsString:@"P"]?@"Pass":@"Fail"];
//                [urlString appendFormat:@"%@=%@",SFC_TEST_START_TIME,startTime];
//                
//                for(int i = 0; i < [arr count]; i++)
//                {
//                    [urlString appendFormat:@"&p%d=%@",i+1,arr[i]];
//                }
//                [urlString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
//                [urlString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//                [urlString appendString:@"\n"];
//                [txtFile TXT_Open:updata_path];
//                [txtFile TXT_Write:urlString];
//            }
//            
//            [txtInshare TXT_Write:[NSString stringWithFormat:@"%@:主流程-->%@\n",[[GetTimeDay shareInstance] getFileTime],[NSString stringWithFormat:@"%@ SFC upload fail",SnString]]];
//            //[txt_N_file TXT_Write:[NSString stringWithFormat:@"%@:主流程-->%@\n",[[GetTimeDay shareInstance] getFileTime],[NSString stringWithFormat:@"%@ SFC upload fail",SnString]]];
//        }
//        
//        //将数据上传的结果显示在compare_path路径中
//        @autoreleasepool {
//            
//            NSMutableString * content = [[NSMutableString alloc]initWithCapacity:10];
//            [content appendFormat:@"StartTime=%@;SN=%@;arr=%lu;isUploadOK=%hhd\n",startTime,sn,(unsigned long)[arr count],isUploadOK];
//            NSString * compare_path = [NSString stringWithFormat:@"%@/%@",totalPath,@"comparedata.txt"];
//            [txtFile TXT_Open:compare_path];
//            [txtFile TXT_Write:content];
//        }
//    }
//    else//数据保存在本地
//    {
//        @autoreleasepool {
//            NSMutableString    *  urlString = [[NSMutableString alloc] initWithCapacity:10];
//            [urlString appendFormat:@"%@&",fixtureID];
//            [urlString appendFormat:@"%@=%@&", SFC_TEST_SN, sn];
//            [urlString appendFormat:@"%@=%@&", SFC_TEST_RESULT, [notiString containsString:@"P"]?@"Pass":@"Fail"];
//            [urlString appendFormat:@"%@=%@",SFC_TEST_START_TIME,startTime];
//            NSArray   *   arr  = [resultDic objectForKey:@"dic"];
//            for(int i = 0; i < [arr count]; i++)
//            {
//                [urlString appendFormat:@"&p%d=%@",i+1,arr[i]];
//            }
//            [urlString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
//            [urlString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//            [urlString appendString:@"\n"];
//            [txtFile TXT_Open:updata_path];
//            [txtFile TXT_Write:urlString];
//        }
//    }
//    
//    NSString  * string = [testingFix substringToIndex:1];
//    //发送指示灯
//    if ([notiString containsString:@"P"]) {
//        
//        passNum++;
//        
//        [serialport WriteLine:[NSString stringWithFormat:@"FIX_%@ pass",string]];
//        
//        [NSThread sleepForTimeInterval:0.5];
//        
//        if ([[serialport ReadExisting] containsString:@"OK"]) {
//            
//            NSLog(@"FIX_%@，亮绿灯",string);
//        }
//        
//    }
//    else
//    {
//        
//        [serialport WriteLine:[NSString stringWithFormat:@"FIX_%@ fail",string]];
//        
//        [NSThread sleepForTimeInterval:0.5];
//        
//        if ([[serialport ReadExisting] containsString:@"OK"]) {
//            
//            NSLog(@"FIX_%@,亮红灯",string);
//        }
//    }
//    
//    
//    if ([string containsString:@"A"])fix_A_num=0;
//    if ([string containsString:@"B"])fix_B_num=0;
//    if ([string containsString:@"C"])fix_C_num=0;
//    if ([string containsString:@"D"])fix_D_num=0;
//    testnum++;
//    
////    [self UpdateTextView:[NSString stringWithFormat:@"fix_A_num=%d,testnum=%d",fix_A_num,testnum] andClear:NO andTextView:Log_View];
//    
//     [txtInshare TXT_Write:[NSString stringWithFormat:@"%@:主流程-->%@\n",[[GetTimeDay shareInstance] getFileTime],[NSString stringWithFormat:@"testnum=%d",testnum]]];
//     //[txt_N_file TXT_Write:[NSString stringWithFormat:@"%@:主流程-->%@\n",[[GetTimeDay shareInstance] getFileTime],[NSString stringWithFormat:@"testnum=%d",testnum]]];
//    
//    if (testnum== 4||testnum==[ChooseNumArray count]) {
//        
//        index = 105;
//        
//        NSLog(@"%@====%d",string,testnum);
//    }
//}


#pragma mark--------------监测服务器
-(void)CheckServer
{
    int connectNum = 0;
    while (connectNum<3) {
        
        if ([testStep StepSFC_CheckUploadSN:YES Option:@"isConnectServer" testResult:nil startTime:nil testArgument:nil PresentIndex:presentCount TotalIndex:totalCount]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [Status_TF setStringValue:@"index=2,服务器检测OK"];
                [Server_State_TF setStringValue:@"服务器正常"];
                [Server_State_TF setBackgroundColor:[NSColor greenColor]];
            });
            [self UpdateTextView:@"index=2,服务器检测OK" andClear:NO andTextView:Log_View];
            index = 3;
            isServer = YES;
            break;
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [Status_TF setStringValue:@"index=2,服务器检测NG"];
                [Server_State_TF setStringValue:@"服务器异常"];
                [Server_State_TF setBackgroundColor:[NSColor redColor]];
            });
            [self UpdateTextView:@"index=2,服务器检测NG" andClear:NO andTextView:Log_View];
            isServer = NO;
            connectNum++;
            if (connectNum==3) {
                index = 3;
                break;
            }
        }
    }
}


#pragma mark------------判断当前网络是否征程
-(void)NetworkState:(Reachability *)reach
{
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    
    if (netStatus == NotReachable) {
        NSLog(@"没网");
        dispatch_async(dispatch_get_main_queue(), ^{
            [network_State_TF setStringValue:@"网络断开"];
            [network_State_TF setBackgroundColor:[NSColor redColor]];
            WebOpenNum=0;
        });
        isWebOpen = NO;
    }
    else if(netStatus == ReachableViaWiFi) {
        isWebOpen = YES;
        if (WebOpenNum==0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [network_State_TF setStringValue:@"网络正常"];
                [network_State_TF setBackgroundColor:[NSColor greenColor]];
                WebOpenNum=1;
            });
            NSLog(@"有网");
        }
        
        //上传数据
        NSFileManager  * manager  = [NSFileManager defaultManager];
        BOOL isExist = [manager fileExistsAtPath:updata_path];//判断文件是否存在
        BOOL __block isUploadSuccess = YES;
        if(isExist){
            //读取文件内容
            [txtFile TXT_Open:updata_path];
            NSString  * contentStr = [txtFile TXT_Read];
            NSArray   * dataArr  = [contentStr componentsSeparatedByString:@"\n"];
            BYDSFCManager  * uploadManager = [[BYDSFCManager alloc]init];
            //上传数据
            for (int i=0;i<[dataArr count]-1;i++) {
                
                @autoreleasepool {
                    
                    dispatch_queue_t  queue = dispatch_queue_create([[NSString stringWithFormat:@"queue_%d",i] cStringUsingEncoding:NSUTF8StringEncoding],0);
                    
                    dispatch_async(queue, ^{
                        if(NO==[uploadManager UploadDataFromLocalFile:[dataArr objectAtIndex:i]])
                        {
                            
                            isUploadSuccess = NO;
                            
                            return;
                        }
                    });
                }
            }
            //删掉数据
            if (isUploadSuccess) {
                
                BOOL sucess4 = [manager removeItemAtPath:updata_path error:nil];
                if(sucess4){
                    //删除成功
                }else{
                    //删除失败
                }
            }
        }
    }
    else
    {
        NSLog(@"WLAN 形式连接");
        
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}

@end
