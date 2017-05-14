//
//  StepTableViewController.m
//  PolygonGame
//
//  Created by boxytt on 2017/5/10.
//  Copyright © 2017年 boxytt. All rights reserved.
//

#import "StepTableViewController.h"
#import "StepCell.h"
#import "STPopup.h"

typedef struct {
    NSInteger priorVertexNum;
    NSInteger priorVertexValue;
    NSInteger deletedEdgeNum;
    NSInteger nextVertexNum;
    NSInteger nextVertexValue;
}DeleteStep;

@interface StepTableViewController ()

@property (nonatomic, strong) NSMutableArray *stepArray;

@end

@implementation StepTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"StepCell" bundle:nil] forCellReuseIdentifier:@"stepCell"];
    
    
}

- (instancetype)init {
    if (self = [super init]) {
        self.title = @"历史步骤";
        
        self.contentSizeInPopup = CGSizeMake(300, 400);

        //注册通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getStep:) name:@"toStep" object:nil];
        
        self.tableView.tableFooterView = [[UIView alloc]init];

        self.tableView.separatorColor = [UIColor orangeColor];
        
        // cell自适应高度，需要在xib中设置上下约束
        self.tableView.estimatedRowHeight = 44;  //  随便设个不那么离谱的值
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
    return self;
}

- (void)getStep: (NSNotification *)notification {
    self.stepArray = notification.object;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"toStep" object:nil];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.stepArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StepCell *cell = [tableView dequeueReusableCellWithIdentifier:@"stepCell" forIndexPath:indexPath];
    DeleteStep step;
    [[self.stepArray objectAtIndex:indexPath.row] getValue:&step];
    cell.numLabel.text = [NSString stringWithFormat:@"第%ld步", indexPath.row + 1];
    cell.numLabel.font = [UIFont fontWithName:@"DFWaWaSC-W5" size:15];
    cell.operationLabel.text = [NSString stringWithFormat:@"移除第%ld条边", (long)step.deletedEdgeNum];
    cell.operationLabel.font = [UIFont fontWithName:@"DFWaWaSC-W5" size:20];
    return cell;
}


@end
