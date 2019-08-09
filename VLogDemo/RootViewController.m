//
//  RootViewController.m
//  VLogDemo
//
//  Created by 刘冉 on 2019/6/6.
//  Copyright © 2019 LRCY. All rights reserved.
//

#import "RootViewController.h"
#import "RecordVideoViewController.h"
#import "LottieAnimationViewController.h"
#import "AnimationViewController.h"
#import "GPUImageRecorderViewController.h"

@interface RootViewController ()

/** dataSource */
@property (nonatomic,strong) NSDictionary *dataSource;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = @{
                        @"RecordVideoViewController":@"GPUImage录制",
                        @"GPUImageRecorderViewController":@"GPUImage视频合成",
                        @"AnimationViewController":@"动画制作",
                        @"LottieAnimationViewController":@"lottie动画",
                        };
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"vLog"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.allKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"vLog" forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"vLog"];
    }
    cell.textLabel.text = self.dataSource.allValues[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self pushController:self.dataSource.allKeys[indexPath.row]];
}

- (void)pushController:(NSString *)controller {
    if (!controller.length) {
        return;
    }
    [self.navigationController pushViewController:[[NSClassFromString(controller) alloc] init] animated:YES];
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
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
