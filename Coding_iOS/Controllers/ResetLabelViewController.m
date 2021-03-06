//
//  ResetLabelViewController.m
//  Coding_iOS
//
//  Created by zwm on 15/4/17.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "ResetLabelViewController.h"
#import "ResetLabelCell.h"
#import "TPKeyboardAvoidingTableView.h"
#import "Coding_NetAPIManager.h"
#import "ProjectTag.h"

#define kCellIdentifier_ResetLabelCell @"ResetLabelCell"

@interface ResetLabelViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    NSString *_tempStr;
}
@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;

@property (nonatomic, weak) UITextField *mCurrentTextField;

@end

@implementation ResetLabelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"重命名标签";
    self.navigationController.title = @"重命名标签";
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"取消" target:self action:@selector(cancelBtnClick)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"完成" target:self action:@selector(okBtnClick)];
    self.navigationItem.rightBarButtonItem.enabled = FALSE;
    
    self.view.backgroundColor = kColorTableSectionBg;
 
    _myTableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[ResetLabelCell class] forCellReuseIdentifier:kCellIdentifier_ResetLabelCell];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
}

#pragma mark - click
- (void)cancelBtnClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)okBtnClick
{
    if (_tempStr.length > 0) {
        __weak typeof(self) weakSelf = self;
        _ptLabel.name = _tempStr;
        [[Coding_NetAPIManager sharedManager] request_ModifyTag:_ptLabel inProject:_curProject andBlock:^(id data, NSError *error) {
            if (data) {
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ResetLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ResetLabelCell forIndexPath:indexPath];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    cell.labelField.delegate = self;
    [cell.labelField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    cell.backgroundColor = kColorTableBG;
    cell.labelField.text = _ptLabel.name;
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ResetLabelCell cellHeight];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return FALSE;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.mCurrentTextField = textField;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField
{
    _tempStr = textField.text;
    if (_tempStr.length > 0) {
        self.navigationItem.rightBarButtonItem.enabled = [_tempStr isEqualToString:_ptLabel.name] ? FALSE : TRUE;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = FALSE;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.mCurrentTextField resignFirstResponder];
}

@end
