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
    [self doNSOperation];
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
//    原因：同步任务会阻塞当前线程，然后把 Block 中的任务放到指定的队列中执行，只有等到 Block 中的任务完成后才会让当前线程继续往下运行。主线程在执行doGCD方法，而doGCD执行到第一个任务的时候，又要等第一个任务执行完才能往下执行，这样大家互相等待，所以就卡住了。
//    NSLog(@"before");
//    dispatch_sync(dispatch_get_main_queue(), ^{
//        NSLog(@"current:%@",[NSThread currentThread]);
//    });
//    NSLog(@"after");
    
    
    
    //    GCD的队列组 dispatch_group
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
    
    
    
//    GCD的栅栏方法 dispatch_barrier_async
//    有时需要异步执行两组操作，而且第一组操作执行完之后，才能开始执行第二组操作。这样我们就需要一个相当于栅栏一样的一个方法将两组异步执行的操作组给分割起来，当然这里的操作组里可以包含一个或多个任务。
    
    dispatch_queue_t queue = dispatch_queue_create("com.teo.queue4", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSLog(@"----1-----%@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"----2-----%@", [NSThread currentThread]);
    });
    
    dispatch_barrier_async(queue, ^{
        NSLog(@"----barrier-----%@", [NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"----3-----%@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"----4-----%@", [NSThread currentThread]);
    });
//    可以看出在执行完栅栏前面的操作之后，才执行栅栏操作，最后再执行栅栏后边的操作。

    
    
//    GCD的快速迭代方法 dispatch_apply
//    通常我们会用for循环遍历，但是GCD给我们提供了快速迭代的方法dispatch_apply，使我们可以同时遍历。比如说遍历0~5这6个数字，for循环的做法是每次取出一个元素，逐个遍历。dispatch_apply可以同时遍历多个数字。
    
    dispatch_queue_t queue5 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_apply(20, queue5, ^(size_t index) {
        NSLog(@"%zd------%@",index, [NSThread currentThread]);
    });
  

    
//    Dispatch Semaphore
    /*
     通过dispatch_semaphore_create 函数创建一个Semaphore并初始化信号的总量。
     通过dispatch_semaphore_signal 函数发送一个信号，让信号总量加1。
     通过dispatch_semaphore_wait可以使总信号量减1，当信号总量为0时就会一直等待，否则就可以正常执行
     */
    
    dispatch_queue_t queue6 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    NSMutableArray *array = [NSMutableArray new];
    for (NSInteger i = 0; i < 1000; i++) {
        dispatch_async(queue6, ^{
            /*
             此时semaphore信号量的值如果 >= 1时：对semaphore计数进行减1,然后dispatch_semaphore_wait 函数返回。该函数所处线程就继续执行下面的语句。
             
             此时semaphore信号量的值如果=0：那么就阻塞该函数所处的线程,阻塞时长为timeout指定的时间，如果阻塞时间内semaphore的值被dispatch_semaphore_signal函数加1了，该函数所处线程获得了信号量被唤醒。然后对semaphore计数进行减1并返回，继续向下执行。 如果阻塞时间内没有获取到信号量唤醒线程或者信号量的值一直为0，那么就要等到指定的阻塞时间后，该函数所处线程才继续向下执行。
             
             执行到这里semaphore的值总是1
             */
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            /* 因为dispatch_semaphore_create创建的semaphore的初始值为1，执行完上面的
             dispatch_semaphore_wait函数之后，semaphore计数值减1会变为0，所以可访问array对象的线程只有1个，因此可安全地对array进行操作。
             */
            
            [array addObject:[NSNumber numberWithInteger:i]];
            
            /*
             对array操作之后，通过dispatch_semaphore_signal将semaphore的计数值加1，此时semaphore的值由变成了1，所处
             */
            
            dispatch_semaphore_signal(semaphore);
        });
    }
    
    
    
    
    
//    dispatch_group_enter：通知group，下面的任务马上要放到group中执行了。
//    dispatch_group_leave：通知group，任务完成了，该任务要从group中移除了。
    
    dispatch_group_t group2 = dispatch_group_create();
    dispatch_group_enter(group2);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        sleep(5);//第一个网络请求
//        注意：因为内部为异步线程，应该在网络请求前写enter请求成功或者失败回调里写leave，否则无效
        NSLog(@"任务一完成");
        dispatch_group_leave(group2);
    });
    dispatch_group_enter(group2);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        sleep(8);//第二个网络请求
//        注意：应该在网络请求前写enter请求成功或者失败回调里写leave，否则无效
        NSLog(@"任务二完成");
        dispatch_group_leave(group2);
    });
    dispatch_group_notify(group2, dispatch_get_main_queue(), ^{
        NSLog(@"任务完成");
    });
    
}

/**
进程（process），指的是一个正在运行中的可执行文件。每一个进程都拥有独立的虚拟内存空间和系统资源，包括端口权限等，且至少包含一个主线程和任意数量的辅助线程。另外，当一个进程的主线程退出时，这个进程就结束了；
线程（thread），指的是一个独立的代码执行路径，也就是说线程是代码执行路径的最小分支。在 iOS 中，线程的底层实现是基于 POSIX threads API 的，也就是我们常说的 pthreads ；
任务（task），指的是我们需要执行的工作，是一个抽象的概念，用通俗的话说，就是一段代码。
**/

/**
支持在 operation 之间建立依赖关系，只有当一个 operation 所依赖的所有 operation 都执行完成时，这个 operation 才能开始执行；
支持一个可选的 completion block ，这个 block 将会在 operation 的主任务执行完成时被调用；
支持通过 KVO 来观察 operation 执行状态的变化；
支持设置执行的优先级，从而影响 operation 之间的相对执行顺序；
支持取消操作，可以允许我们停止正在执行的 operation 。
**/

- (void)doNSOperation{
    /**
    NSOperation 和 NSOperationQueue 分别对应 GCD 的 任务 和 队列 。
    操作步骤也很好理解：
    将要执行的任务封装到一个 NSOperation 对象中。
    将此任务添加到一个 NSOperationQueue 对象中。
     **/
    
//    NSOperation 只是一个抽象类，所以不能封装任务。但它有 2 个子类用于封装任务。分别是：NSInvocationOperation 和 NSBlockOperation 。创建一个 Operation 后，需要调用 start 方法来启动任务，它会 默认在当前队列同步执行。当然你也可以在中途取消一个任务，只需要调用其 cancel 方法即可。
    
//1.创建NSInvocationOperation对象NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(run) object:nil];
//2.开始执行
//      [operation start];
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"%@",[NSThread currentThread]);
    }];
    [operation start];
    
//    NSBlockOperation 还有一个方法：addExecutionBlock: ，通过这个方法可以给 Operation 添加多个执行 Block。这样 Operation 中的任务 会并发执行，它会 在主线程和其它的多个线程 执行这些任务
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"%@",[NSThread currentThread]);
    }];
//    NOTE：addExecutionBlock 方法必须在 start() 方法之前执行，否则就会报错
    for (NSInteger i = 0; i < 5; i++) {
        [op2 addExecutionBlock:^{
            NSLog(@"第%ld次：%@", i, [NSThread currentThread]);
        }];
    }
    [op2 start];


//    添加依赖。比如有 3 个任务：A: 从服务器上下载一张图片，B：给这张图片加个水印，C：把图片返回给服务器。这时就可以用到依赖了
    //1.任务一：下载图片
    NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"下载图片 - %@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:1.0];
    }];
    //2.任务二：打水印
    NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"打水印   - %@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:1.0];
    }];
    //3.任务三：上传图片
    NSBlockOperation *operation3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"上传图片 - %@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:1.0];
    }];
    //4.设置依赖
    [operation2 addDependency:operation1];      //任务二依赖任务一
    [operation3 addDependency:operation2];      //任务三依赖任务二
    //5.创建队列并加入任务
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperations:@[operation3, operation2, operation1] waitUntilFinished:NO];

    /**
     其他方法:
     
    NSOperation
    BOOL executing; //判断任务是否正在执行
    BOOL finished; //判断任务是否完成
    void (^completionBlock)(void); //用来设置完成后需要执行的操作
    - (void)cancel; //取消任务
    - (void)waitUntilFinished; //阻塞当前线程直到此任务执行完毕
    
     **************
     
    NSOperationQueue
    NSUInteger operationCount; //获取队列的任务数
    - (void)cancelAllOperations; //取消队列中所有的任务
    - (void)waitUntilAllOperationsAreFinished; //阻塞当前线程直到此队列中的所有任务执行完毕
    [queue setSuspended:YES]; // 暂停queue
    [queue setSuspended:NO]; // 继续queue
     
     **************
     
     最大并发数：maxConcurrentOperationCount
     maxConcurrentOperationCount默认情况下为-1，表示不进行限制，默认为并发执行。
     当maxConcurrentOperationCount为1时，进行串行执行。
     当maxConcurrentOperationCount大于1时，进行并发执行，当然这个值不应超过系统限制，即使自己设置一个很大的值，系统也会自动调整。
     **/
}


- (void)doSomething:(NSString *)string{
    NSLog(@"%@%@",string,[NSThread currentThread]);
}


@end
