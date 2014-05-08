//
//  WaterFlowView.m
//  eCity
//
//  Created by xuchuanyong on 11/21/12.
//  Copyright (c) 2012 q mm. All rights reserved.
//

#import "WaterFlowView.h"
#import <objc/runtime.h>

#define PRELOAD_HEIGHT      0

static const char *identifier = "identifier";
static const char *mark = "mark";

@implementation UIView (UIExtView)
@dynamic identifier;
@dynamic mark;

- (id)initWithIdentifier:(NSString*)identifier {
    self = [super init];
    if (self) {
        self.identifier = identifier;
    }
    return self;
}

- (void)setIdentifier:(NSString *)viewIdentifier {
    //使用associative来扩展属性
    objc_setAssociatedObject(self, &identifier, viewIdentifier, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString*)identifier {
    //获取属性
    return objc_getAssociatedObject(self, &identifier);
}

- (void)setMark:(id)viewMark {
    objc_setAssociatedObject(self, &mark, viewMark, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)mark {
    return objc_getAssociatedObject(self, &mark);
}

@end

@implementation NSValue (Sort)
-(NSComparisonResult) compareUpLine:(NSValue*) anotherItem {
    CGRect selfRect = self.CGRectValue;
    CGRect anotherRect = anotherItem.CGRectValue;
    if (selfRect.origin.y <= anotherRect.origin.y) {
        return NSOrderedAscending;
    }else {
        return NSOrderedDescending;
    }
}

-(NSComparisonResult) compareDownLine:(NSValue*) anotherItem {
    CGRect selfRect = self.CGRectValue;
    CGRect anotherRect = anotherItem.CGRectValue;
    if (selfRect.origin.y+selfRect.size.height <= anotherRect.origin.y+anotherRect.size.height) {
        return NSOrderedAscending;
    }else {
        return NSOrderedDescending;
    }
}

@end

//@implementation MScrollView
//
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    [self.nextResponder touchesBegan:touches withEvent:event];
//}
//
//@end

@interface WaterFlowView (private)

//将视图添加到缓存队列
- (void)addViewInPool:(UIView*)view;
//将视图添加到字典
- (void)addViewInDic:(UIView*)view withRow:(NSInteger)row;
//根据行数向容器中添加视图
- (void)addSubviewsWithRow:(NSInteger)row;
//根据行列计算视图位置
- (CGPoint)calculateViewCenter:(NSInteger)row andColumn:(NSInteger)column;
//根据当前触摸的视图来确定选中视图的索引
- (void)itemSelected:(UIView*)obj;
@end

//UIScrollView私有扩展，消除警告
@interface UIScrollView (private)

- (void)scrollViewDidScroll:(UIScrollView*)scrollView;

@end


@implementation ScrollInterceptor
@synthesize receiver;
@synthesize scrollView;

//快速转发函数，在此实现函数拦截，实现自己功能后再转发给原代理
- (id)forwardingTargetForSelector:(SEL)aSelector {
    NSString *selectorName = NSStringFromSelector(aSelector);
    
    if ([selectorName isEqualToString:NSStringFromSelector(@selector(scrollViewDidScroll:))]) {
        [scrollView scrollViewDidScroll:scrollView];
    }
    //拖拽放开根据位置进行是否刷新操作
    if ([selectorName isEqualToString:NSStringFromSelector(@selector(scrollViewDidEndDragging:willDecelerate:))]) {
        
    }
    
    if ([receiver respondsToSelector:aSelector]) {
        return receiver;
    }
    if ([scrollView respondsToSelector:aSelector]) {
        return scrollView;
    }
    return [super forwardingTargetForSelector:aSelector];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([receiver respondsToSelector:aSelector]) {
        return YES;
    }
    if ([scrollView respondsToSelector:aSelector]) {
        return YES;
    }
    return [super respondsToSelector:aSelector];
}

@end


@implementation WaterFlowView
@synthesize headerHeight;
@synthesize footerHeight;
@synthesize siderWidth;
@synthesize viewDelegate;
@synthesize viewDataSource;

@dynamic headerView;
@dynamic footerView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        headerHeight = 0;
        footerHeight = 0;
        siderWidth = 0;
        
        onScreenViews = [[NSMutableDictionary alloc] init];
        viewPool = [[NSMutableDictionary alloc] init];

        viewHeights = [[NSMutableDictionary alloc] init];
        
        viewFrames = [[NSMutableArray alloc] init];
        
        viewFrameDic = [[NSMutableDictionary alloc] init];
        
        interceptor = [[ScrollInterceptor alloc] init];
        [self setDelegate:nil];
    }
    return self;
}

//- (void)setFrame:(CGRect)frame {
//    scrollView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
//    [super setFrame:frame];
//}

- (id)delegate {
    return interceptor.receiver;
}

- (void)setDelegate:(id<WaterFlowViewDelegate>)waterDelegate {
    [super setDelegate:nil];
    interceptor.receiver = waterDelegate;
    interceptor.scrollView = self;
    [super setDelegate:interceptor];
}

- (UIView*)headerView {
    return headerView;
}

- (void)setHeaderView:(UIView *)hdView {
    if (headerView != hdView) {
        [headerView removeFromSuperview];
        headerView = hdView;
        CGRect frame = headerView.frame;
        headerView.frame = CGRectMake(frame.origin.x, 0, frame.size.width, frame.size.height);
        [self addSubview:headerView];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTaped:)];
        [headerView addGestureRecognizer:tapGesture];
        [tapGesture release];
    }
}

- (UIView*)footerView {
    return footerView;
}

- (void)setFooterView:(UIView *)ftView {
    if (footerView != ftView) {
        [footerView removeFromSuperview];
        footerView = ftView;
        CGRect frame = footerView.frame;
        footerView.frame = CGRectMake(frame.origin.x, self.contentSize.height-frame.size.height, frame.size.width, frame.size.height);
        [self addSubview:footerView];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTaped:)];
        [footerView addGestureRecognizer:tapGesture];
        [tapGesture release];
    }
}

- (UIView*)dequeueReusableViewWithIdentifier:(NSString*)identifier {
    NSMutableSet *set = [viewPool objectForKey:identifier];
    UIView *view = [set anyObject];
    return view;
}

- (void)addViewInPool:(UIView*)view {
    if (view&&view.identifier) {
        NSMutableSet *set = [viewPool objectForKey:view.identifier];
        if (!set) {
            set = [[NSMutableSet alloc] init];
            [viewPool setObject:set forKey:view.identifier];
            [set release];
        }
        [set addObject:view];
    }
}


- (void)loadData {
    for (NSArray *array in onScreenViews.allValues) {
        for (UIView *tmpView in array) {
            [self addViewInPool:tmpView];
            [tmpView removeFromSuperview];
        }
    }
    for (UIView *view in self.subviews) {
        if (view.identifier) {
            [view removeFromSuperview];
        }
    }
    [onScreenViews removeAllObjects];
    [viewFrames removeAllObjects];
    [viewHeights removeAllObjects];
    [viewFrameDic removeAllObjects];
    
    headerHeight = [viewDataSource respondsToSelector:@selector(heightForHeaderInWaterFlowView:)]?[viewDataSource heightForHeaderInWaterFlowView:self]:headerHeight;
    footerHeight = [viewDataSource respondsToSelector:@selector(heightForFooterInWaterFlowView:)]?[viewDataSource heightForFooterInWaterFlowView:self]:footerHeight;
    siderWidth = [viewDataSource respondsToSelector:@selector(widthForSiderInWaterFlowView:)]?[viewDataSource widthForSiderInWaterFlowView:self]:siderWidth;

    //获取每页多少列
    numberOfColums = viewDataSource == nil ? 1:[viewDataSource numberOfColumsInWaterFlowView:self];
    
    for (int i = 0; i<numberOfColums; i++) {
        NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithFloat:0], nil];
        [viewHeights setObject:[NSNumber numberWithFloat:headerHeight] forKey:[NSNumber numberWithInt:i]];
        [array release];
        NSMutableArray *frames = [[NSMutableArray alloc] init];
        [viewFrameDic setObject:frames forKey:[NSNumber numberWithInt:i]];
        [frames release];
        
        NSMutableArray *views = [[NSMutableArray alloc] init];
        [onScreenViews setObject:views forKey:[NSNumber numberWithInt:i]];
        [views release];
    }
    
    numberOfViews = viewDataSource == nil ? 0: [viewDataSource numberOfViewsInWaterFlowView:self];
    
    for (int index = 0; index < numberOfViews; index ++) {
        NSInteger lowColumn = 0;
        CGFloat lowHeight = [[viewHeights objectForKey:[NSNumber numberWithInt:lowColumn]] floatValue];
        //按升序的次序对viewHeights字典进行 key-value的读取
        for (int i=0; i<numberOfColums; i++) {
            NSNumber *number = [NSNumber numberWithInt:i];
            CGFloat height = [[viewHeights objectForKey:number] floatValue];
            if (lowHeight > height) {
                lowHeight = height;
                lowColumn = [number intValue];
            }
        }
        CGFloat viewWidth = (self.frame.size.width-siderWidth*2)/numberOfColums;
        CGRect rect = CGRectMake(siderWidth+lowColumn*viewWidth, lowHeight, viewWidth, [viewDataSource respondsToSelector:@selector(waterFlowView:heightForIndex:)]?[viewDataSource waterFlowView:self heightForIndex:index]:0);
        
        NSMutableArray *array = [viewFrameDic objectForKey:[NSNumber numberWithInt:lowColumn]];
        [array addObject:[NSValue valueWithCGRect:rect]];
        
        lowHeight = rect.origin.y + rect.size.height;
        [viewHeights setObject:[NSNumber numberWithFloat:lowHeight] forKey:[NSNumber numberWithInt:lowColumn]];
        [viewFrames addObject:[NSValue valueWithCGRect:rect]];
    }
    NSArray *frames = [viewFrames sortedArrayUsingSelector:@selector(compareDownLine:)];
    if (frames!= downFrames) {
        [downFrames release];
        downFrames = [frames retain];
    }
    
    CGRect rect = [((NSValue*)[downFrames lastObject]) CGRectValue];
    self.contentSize = CGSizeMake(0, rect.origin.y+rect.size.height + footerHeight);
    if (self.contentOffset.y>self.contentSize.height) {
        [self setContentOffset:CGPointMake(0, self.contentSize.height-self.frame.size.height)];
    }
    if (footerView) {
        CGRect frame = footerView.frame;
        footerView.frame = CGRectMake(frame.origin.x, self.contentSize.height-frame.size.height, frame.size.width, frame.size.height);
    }
    for (int i = 0; i< numberOfColums; i++) {
        [self addViewOnScreenWithColumn:i];
    }
}

- (void)addViewOnScreenWithColumn:(NSInteger)column {
    NSArray *frames = [viewFrameDic objectForKey:[NSNumber numberWithInt:column]];
    
    frames = [frames sortedArrayUsingSelector:@selector(compareUpLine:)];
    for (int index = 0; index < [frames count]; index ++) {
        NSValue *rectValue = [frames objectAtIndex:index];
        CGRect rect = [rectValue CGRectValue];
        if ([self rect:CGRectMake(0, self.contentOffset.y-PRELOAD_HEIGHT, self.frame.size.width, self.frame.size.height+PRELOAD_HEIGHT*2) ContainRect:rect]){
            [self addViewWithIndex:index andColumn:column];
        }
    }
}

//判断rect是否再containRect中
- (BOOL)rect:(CGRect)containRect ContainRect:(CGRect)rect {
    if (rect.origin.y > containRect.origin.y+containRect.size.height || rect.origin.y+rect.size.height < containRect.origin.y) {
        return NO;
    }
    return YES;
}

//向容器中添加视图
- (void)addViewWithIndex:(NSInteger)index andColumn:(NSInteger)column{
    NSMutableArray *frames = [viewFrameDic objectForKey:[NSNumber numberWithInt:column]];
    
    UIView *tmpView;
    NSInteger viewIndex = [viewFrames indexOfObject:[frames objectAtIndex:index]];
    tmpView = viewDataSource&&[viewDataSource respondsToSelector:@selector(waterFlowView:viewAtIndex:)]?[viewDataSource waterFlowView:self viewAtIndex:viewIndex]:nil;
    for (UIGestureRecognizer *gesture in tmpView.gestureRecognizers) {
        if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
            [tmpView removeGestureRecognizer:gesture];
        }
    }
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTaped:)];
    tapGesture.cancelsTouchesInView = NO;
    tapGesture.delegate = self;
    [tmpView addGestureRecognizer:tapGesture];
    [tapGesture release];
    tmpView.exclusiveTouch = YES;
    tmpView.mark = [NSNumber numberWithInt:index];
    CGRect rect = [[frames objectAtIndex:index] CGRectValue];
    CGPoint point = CGPointMake(rect.origin.x + rect.size.width/2, rect.origin.y+rect.size.height/2);
    tmpView.center = point;
//    tmpView.alpha = 0.0f;
    [self insertSubview:tmpView atIndex:0];
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.4];
//    [UIView setAnimationDelay:0.2];
//    tmpView.alpha = 1.0f;
//    [UIView commitAnimations];
    NSMutableSet *set = [viewPool objectForKey:tmpView.identifier];
    if ([set containsObject:tmpView]) {
        [set removeObject:tmpView];
    }
    NSMutableArray *array = [onScreenViews objectForKey:[NSNumber numberWithInt:column]];

    if ([array count]>0) {
        UIView *view = [array objectAtIndex:0];
        NSInteger upIndex = [view.mark intValue];
        view = [array lastObject];
        NSInteger downIndex = [view.mark intValue];
        if (index < upIndex) {
            [array insertObject:tmpView atIndex:0];
        }
        else if (index > downIndex) {
            [array addObject:tmpView];
        }
    }
    else {
        [array addObject:tmpView];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 过滤掉UIButton，也可以是其他类型
    if ( [touch.view isKindOfClass:[UIButton class]])
    {
        return NO;
    }
    
    return YES;
}

//从容器中移除视图
- (void)removeViewWithIndex:(NSInteger)index andColumn:(NSInteger)column{
    NSMutableArray *views = [onScreenViews objectForKey:[NSNumber numberWithInt:column]];
    if ([views count]>0) {
        UIView *view = [views objectAtIndex:0];
        if (index == [view.mark intValue]) {
            [self addViewInPool:view];
            [view removeFromSuperview];
            [views removeObject:view];
        }
        view = [views lastObject];
        if (index == [view.mark intValue]) {
            [self addViewInPool:view];
            [view removeFromSuperview];
            [views removeObject:view];
        }
    }
    else {
        
    }
    
}


- (UIView*)selectViewWithIndex:(NSInteger)index {
    UIView *view = [onScreenViews objectForKey:[NSNumber numberWithInt:index]];
    return view;
}


- (void)scrollViewDidScroll:(UIScrollView *)scView {
    CGRect contentRect = CGRectMake(0, self.contentOffset.y-PRELOAD_HEIGHT, self.frame.size.width, self.frame.size.height+PRELOAD_HEIGHT*2);
    for (int i = 0; i<numberOfColums; i++) {
        NSMutableArray *frames = [viewFrameDic objectForKey:[NSNumber numberWithInt:i]];
        NSMutableArray *views = [onScreenViews objectForKey:[NSNumber numberWithInt:i]];
        if ([views count]>0) {
            UIView  *view = [views objectAtIndex:0];
            NSInteger upIndex = [view.mark intValue];
            view = [views lastObject];
            NSInteger downIndex = [view.mark intValue];
            if (upIndex-1>=0) {
                CGRect rect = [[frames objectAtIndex:upIndex-1] CGRectValue];
                if ([self rect:contentRect ContainRect:rect]) {
                    [self addViewWithIndex:upIndex-1 andColumn:i];
                }
            }
            if (downIndex+1<[frames count]) {
                CGRect rect = [[frames objectAtIndex:downIndex+1] CGRectValue];
                if ([self rect:contentRect ContainRect:rect]) {
                    [self addViewWithIndex:downIndex+1 andColumn:i];
                }
            }
            CGRect rect = [[frames objectAtIndex:upIndex] CGRectValue];
            if (![self rect:contentRect ContainRect:rect]) {
                [self removeViewWithIndex:upIndex andColumn:i];
            }
            rect = [[frames objectAtIndex:downIndex] CGRectValue];
            if (![self rect:contentRect ContainRect:rect]) {
                [self removeViewWithIndex:downIndex andColumn:i];
            }
        }
        else {
            [self addViewOnScreenWithColumn:i];
        }
    }
    
//    NSLog(@"subViews:%d onScreenViews:%d viewPool:%d",[self.subviews count],[onScreenViews count],[[[viewPool allValues] lastObject] count]);

}

- (void)itemSelected:(UIView*)obj {
    NSInteger index = [obj.mark intValue];
    NSInteger globalIndex = 0;
    for (NSInteger i = 0 ; i< [onScreenViews.allKeys count];i++) {
        NSMutableArray *array = [onScreenViews objectForKey:[NSNumber numberWithInt:i]];
        if ([array containsObject:obj]) {
            NSMutableArray *frames = [viewFrameDic objectForKey:[NSNumber numberWithInt:i]];
            globalIndex = [viewFrames indexOfObject:[frames objectAtIndex:index]];
        }
    }
    NSLog(@"item %d",globalIndex);
    if (viewDelegate && [viewDelegate respondsToSelector:@selector(waterFlowView:selectItemAtIndex:)]) {
        [viewDelegate waterFlowView:self selectItemAtIndex:globalIndex];
    }
}

- (void)viewTaped:(UIGestureRecognizer*)gesture {
    UIView *view = gesture.view;
    BOOL touchHeader = view == headerView;
    BOOL touchFooter = view == footerView;
    if (!touchHeader && !touchFooter) {
        [self itemSelected:view];
    }
    else if (touchHeader) {
        if (viewDelegate && [viewDelegate respondsToSelector:@selector(headerClickedInGridView:)]) {
            [viewDelegate headerClickedInWaterFlowView:self];
        }
    }
    else if (touchFooter) {
        if (viewDelegate && [viewDelegate respondsToSelector:@selector(footerClickedInGridView:)]) {
            [viewDelegate footerClickedInWaterFlowView:self];
        }
    }

}
/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    BOOL touchHeader = touch.view == headerView || [headerView.subviews containsObject:touch.view];
    BOOL touchFooter = touch.view == footerView || [footerView.subviews containsObject:touch.view];
    if (touch.view!=self && !touchHeader && !touchFooter && touch.tapCount == 1) {
        [self itemSelected:touch.view];
    }
    else if (touchHeader) {
        if (viewDelegate && [viewDelegate respondsToSelector:@selector(headerClickedInGridView:)]) {
            [viewDelegate headerClickedInWaterFlowView:self];
        }
    }
    else if (touchFooter) {
        if (viewDelegate && [viewDelegate respondsToSelector:@selector(footerClickedInGridView:)]) {
            [viewDelegate footerClickedInWaterFlowView:self];
        }
    }
}*/

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void)dealloc {
    [onScreenViews release];
    [viewPool release];
    [viewHeights release];
    [viewFrames release];
    [viewFrameDic release];
    [downFrames release];
    [interceptor release];
    interceptor = nil;
    [super dealloc];
}

@end
