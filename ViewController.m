//
//  ViewController.m
//  Multithreading
//
//  Created by Thinkive on 2017/10/22.
//  Copyright © 2017年 Teo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self doNSThread];
    [self doGCD];
}

- (void)doNSThread{
//    [self performSelectorInBackground:@selector(doSomething:) withObject:nil];

//    1.
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(doSomething:) object:@"thread1"];
    [thread start];
    
//    2.
    NSThread *thread2 = [[NSThread alloc] initWithBlock:^{
        NSLog(@"thread2 %@",[NSThread currentThread]);
    }];
    [thread2 start];
    
//    3.
    [NSThread detachNewThreadSelector:@selector(doSomething:) toTarget:self withObject:@"thread3"];
    
//    4.
    [NSThread detachNewThreadWithBlock:^{
        NSLog(@"thread4");
    }];

//    5.
    //    waitUntilDone：当为yes的时候，先让主线程运行setEnd中的一些操作，之后再进行当前线程中的操作。当为no的时候，先进行当前线程中的操作,之后让主线程运行setEnd中的一些操作。
//    即为YES的话，子线程结束后 会阻塞主线程 走callBack；方法如果是NO的话，就不会阻塞主线程
    [self performSelectorOnMainThread:@selector(doSomething:) withObject:@"thread5" waitUntilDone:YES];
    
//    6.
    [self performSelectorInBackground:@selector(doSomething:) withObject:nil];
    
//    7.
    [self performSelector:@selector(doSomething:) onThread:[NSThread mainThread] withObject:@"thread7" waitUntilDone:YES];
}

- (void)doGCD{
//    同步与异步的区别在于是否会创建新的线程
//    如果是 同步（sync） 操作，它会阻塞当前线程并等待 Block 中的任务执行完毕，然后当前线程才会继续往下运行。
//    如果是 异步（async）操作，当前线程会直接往下执行，它不会阻塞当前线程
    
//    第一个参数是标识符，用于 DEBUG 的时候标识唯一的队列，可以为空
//    第二个参数用来表示创建的队列是串行的还是并行的，传入 DISPATCH_QUEUE_SERIAL 或 NULL 表示创建串行队列。传入 DISPATCH_QUEUE_CONCURRENT 表示创建并行队列。
    //串行队列
    dispatch_queue_t queue1 = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue2 = dispatch_queue_create("com.teo.queue2", NULL);
    //并行队列
    dispatch_queue_t queue3 = dispatch_queue_create("com.teo.queue3", DISPATCH_QUEUE_CONCURRENT);

//    同步获取主线程会导致死锁
//    原因：同步任务会阻塞当前线程，然后把 Block 中的任务放到指定的队列中执行，只有等到 Block 中的任务完成后才会让当前线程继续往下运行。
//    NSLog(@"before");
//    dispatch_sync(dispatch_get_main_queue(), ^{
//        NSLog(@"current:%@",[NSThread currentThread]);
//    });
//    NSLog(@"after");
    
    
    //1.创建队列组
    dispatch_group_t group = dispatch_group_create();
    //2.创建队列
    dispatch_queue_t queue4 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //3.多次使用队列组的方法执行任务, 只有异步方法
    dispatch_group_async(group, queue4, ^{
        for (NSInteger i = 0; i < 3; i++) {
            NSLog(@"group-01 - %@", [NSThread currentThread]);
        }
    });
    
    dispatch_group_async(group, dispatch_get_main_queue(), ^{
        for (NSInteger i = 0; i < 8; i++) {
            NSLog(@"group-02 - %@", [NSThread currentThread]);
        }
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"完成");
    });
    
    
}

- (void)doSomething:(NSString *)string{
    NSLog(@"%@%@",string,[NSThread currentThread]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
