//
//  HistoryTableViewController.m
//  PolygonGame
//
//  Created by boxytt on 2017/5/10.
//  Copyright © 2017年 boxytt. All rights reserved.
//

#import "HistoryTableViewController.h"
#import <STPopup/STPopup.h>
#import "HistoryStepTableViewCell.h"

typedef struct {
    NSInteger priorVertexNum;
    NSInteger priorVertexValue;
    NSInteger deletedEdgeNum;
    NSInteger nextVertexNum;
    NSInteger nextVertexValue;
}DeleteStep;

@interface HistoryTableViewController ()

@property (nonatomic, strong) NSMutableArray *historyArray;
@end

@implementation HistoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"HistoryStepTableViewCell" bundle:nil] forCellReuseIdentifier:@"historyStepCell"];

    
}

- (instancetype)init {
    if (self = [super init]) {
        self.title = @"历史步骤";
        
        self.contentSizeInPopup = CGSizeMake(300, 400);
        
        //注册通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getHistory:) name:@"toHistory" object:nil];
        
        self.tableView.tableFooterView = [[UIView alloc]init];
        
        // cell自适应高度，需要在xib中设置上下约束
        self.tableView.estimatedRowHeight = 44;  //  随便设个不那么离谱的值
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
    return self;
}

- (void)getHistory: (NSNotification *)notification {
    self.historyArray = notification.object;
    NSLog(@"history: %@", self.historyArray);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"toHistory" object:nil];
    
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
    return self.historyArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HistoryStepTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"historyStepCell" forIndexPath:indexPath];
    DeleteStep step;
    [[self.historyArray objectAtIndex:indexPath.row] getValue:&step];
    cell.numLabel.text = [NSString stringWithFormat:@"第%ld步", indexPath.row + 1];
    cell.operationLabel.text = [NSString stringWithFormat:@"移除第%ld条边", (long)step.deletedEdgeNum];
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
