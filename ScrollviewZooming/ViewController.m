//
//  ViewController.m
//  ScrollviewZooming
//
//  Created by 钱江江 on 16/6/21.
//  Copyright © 2016年 Arthur. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIScrollViewDelegate,UIActionSheetDelegate>

@property (nonatomic,strong)UIScrollView *scrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGRect frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2-100, [UIScreen mainScreen].bounds.size.height/2-100, 200, 200);
    UIImage *image = [UIImage imageNamed:@"1.jpg"];
    [self _createOriginalImageViewWithFrame:frame zoomImage:image];
    
}

- (void)_createOriginalImageViewWithFrame:(CGRect)frame zoomImage:(UIImage *)image {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    [self.view addSubview:imageView];
    imageView.image = image;
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *click = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_createZoomView:)];
    [imageView addGestureRecognizer:click];
}

- (void)_createZoomView:(UITapGestureRecognizer *)tap {
    UIImageView *imageView = (UIImageView *)tap.view;
    if (imageView.image) {
        [self _createScrollView];
        [self _createZoomImageView:imageView.image];
    }

}

- (void)_createScrollView {
    //状态栏改为白色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _scrollView.backgroundColor = [UIColor blackColor];
    _scrollView.contentSize = _scrollView.frame.size;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    _scrollView.bounces = YES;
    _scrollView.minimumZoomScale = 1;
    _scrollView.maximumZoomScale = 2;
    _scrollView.bouncesZoom = YES;
    [self.view addSubview:_scrollView];
}

- (void)_createZoomImageView:(UIImage *)image {
    CGFloat imageViewWidth = image.size.width;
    CGFloat imageViewHeight = image.size.height;
    
    CGFloat scale = 1;
    if (imageViewHeight <= _scrollView.frame.size.height && imageViewWidth <= _scrollView.frame.size.width) {
        
        for (int i = 1; i < 10; i++) {
            if (imageViewWidth*i > _scrollView.frame.size.width || imageViewHeight*i > _scrollView.frame.size.height) {
                scale = i-1;
                break;
            }
        }
        imageViewWidth *= scale;
        imageViewHeight *= scale;
    }
    else {
        for (int i = 1; i < 10; i++) {
            if (imageViewWidth/i <= _scrollView.frame.size.width && imageViewHeight/i <= _scrollView.frame.size.height) {
                scale = i;
                break;
            }
        }
        imageViewWidth /= scale;
        imageViewHeight /= scale;
    }
    
    //关闭手势
    UITapGestureRecognizer *closeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close:)];
    [_scrollView addGestureRecognizer:closeTap];
    //长按手势
    UILongPressGestureRecognizer *saveImage = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(saveImage:)];
    [_scrollView addGestureRecognizer:saveImage];
    //双击缩放
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(transformImage:)];
    [_scrollView addGestureRecognizer:doubleTap];
    doubleTap.numberOfTapsRequired = 2;
    [closeTap requireGestureRecognizerToFail:doubleTap];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(_scrollView.frame.size.width/2-imageViewWidth/2, _scrollView.frame.size.height/2-imageViewHeight/2, imageViewWidth, imageViewHeight)];
    imageView.image = image;
    imageView.tag = 9997;
    [_scrollView addSubview:imageView];
}

#pragma mark - 头像关闭

- (void)close:(UITapGestureRecognizer *)tap {
    [UIView animateWithDuration:0.3 animations:^{
        tap.view.alpha = 0;
        //状态栏改为黑色
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    } completion:^(BOOL finished) {
        [tap.view removeFromSuperview];
        _scrollView = nil;
    }];
}

#pragma mark - 头像缩放

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    [self _resetViewFrame];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
//返回需要zoom的view
{
    //如果想要scrollview 实现缩放 则需要给scrollview.delegate 对一个UIScrollViewDelegate 对象
    //且 此对象需要覆写viewForZoomingInScrollView 方法。
    //总结:只有 scrollview的delegate复写了viewForZoomingInScrollView scrollview才会缩放。
    return [[UIApplication sharedApplication].keyWindow viewWithTag:9997];
    
}
//根据图像的大小重设图像的frame,使得图像的最左和最右边框一直是屏幕的边框
- (void)_resetViewFrame {
    UIView *view = [_scrollView viewWithTag:9997];
    if (view.frame.size.width > _scrollView.frame.size.width && view.frame.size.height > _scrollView.frame.size.height) {
        
        view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    }
    else if (view.frame.size.width > _scrollView.frame.size.width && view.frame.size.height < _scrollView.frame.size.height){
        view.frame = CGRectMake(0, _scrollView.frame.size.height/2-view.frame.size.height/2, view.frame.size.width, view.frame.size.height);
    }
    else {
        view.frame = CGRectMake(_scrollView.frame.size.width/2-view.frame.size.width/2, _scrollView.frame.size.height/2-view.frame.size.height/2, view.frame.size.width, view.frame.size.height);
    }
}

#pragma mark - 头像双击放大/缩小

- (void)transformImage:(UITapGestureRecognizer *)doubleTap {
    if (_scrollView.zoomScale > 1) {
        [_scrollView setZoomScale:1 animated:YES];
    }
    else {
        [_scrollView setZoomScale:2 animated:YES];
    }
    
}

#pragma mark - 头像长按保存

- (void)saveImage:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存照片", nil];
        [sheet showInView:gesture.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (!buttonIndex) {
        UIImageView *imageView = [_scrollView viewWithTag:9997];
        UIImageWriteToSavedPhotosAlbum(imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo {
    NSString *str = error ? @"保存失败" : @"保存成功";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:str message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
