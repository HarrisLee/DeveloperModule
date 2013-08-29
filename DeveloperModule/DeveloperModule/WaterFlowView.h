//
//  WaterFlowView.h
//  eCity
//
//  Created by xuchuanyong on 11/21/12.
//  Copyright (c) 2012 q mm. All rights reserved.
//
//应用墙视图
#import <UIKit/UIKit.h>

//扩展UIView，增加属性
@interface UIView (UIExtView)

@property (retain,nonatomic) NSString *identifier;
@property (retain,nonatomic) id mark;

@end

@interface NSValue (Sort)

//根据上线高度排序
-(NSComparisonResult) compareUpLine:(NSValue*) anotherItem;
//根据下线高度排序
-(NSComparisonResult) compareDownLine:(NSValue*) anotherItem;

@end

//函数拦截器，用于拦截UIScrollView的代理函数调用
@interface ScrollInterceptor:NSObject <UIScrollViewDelegate> {
    id reciver;
    UIScrollView *scrollView;
    
}
@property (nonatomic,assign) id receiver;
@property (nonatomic,assign) UIScrollView *scrollView;

@end

@protocol WaterFlowViewDelegate;
@protocol WaterFlowViewDataSource;
@interface WaterFlowView : UIScrollView  {
//    MScrollView    *scrollView;
    
    NSInteger   numberOfViews;               //视图总数
//    NSInteger   numberOfRows;                //行数
    NSInteger   numberOfColums;              //列数
    
    CGFloat     headerHeight;                //顶部高度
    CGFloat     footerHeight;                //底部高度
    CGFloat     siderWidth;                  //边界宽度

    NSInteger   upperRow;                   //界面显示最上一行
    NSInteger   floorRow;                   //界面显示最下一行
    
    UIView      *headerView;                //顶部视图
    UIView      *footerView;                //底部视图
    
    NSMutableDictionary         *onScreenViews;      //添加到视图中的所有数组
    NSMutableDictionary         *viewPool;           //视图缓存池
    NSMutableDictionary         *viewHeights;
    NSMutableArray              *viewFrames;         //行高数组
    
    NSMutableDictionary         *viewFrameDic;
    NSArray                     *downFrames;         //对视图下框高度重新排列过的数组，用于计算添加或移除视图
    
    
    
    id <WaterFlowViewDelegate>     viewDelegate;
    id <WaterFlowViewDataSource>   viewDataSource;
    
    ScrollInterceptor           *interceptor;
}

@property CGFloat     headerHeight;
@property CGFloat     footerHeight;
@property CGFloat     siderWidth;
@property (retain,nonatomic) UIView      *headerView;
@property (retain,nonatomic) UIView      *footerView;
@property (retain,nonatomic) NSArray                    *itemDataList;
@property (assign,nonatomic) id <WaterFlowViewDataSource>  viewDataSource;
@property (assign,nonatomic) id <WaterFlowViewDelegate>    viewDelegate;
//@property (assign,nonatomic) id <UIScrollViewDelegate>     delegate;
//重载数据
- (void)loadData;
//根据identifier从缓存队列中获取视图
- (UIView*)dequeueReusableViewWithIdentifier:(NSString*)identifier;
//根据索引选择视图
- (UIView*)selectViewWithIndex:(NSInteger)index;

@end

@protocol WaterFlowViewDelegate <UIScrollViewDelegate>
@optional
//选中某个元素
- (void)waterFlowView:(WaterFlowView*)waterFlowView selectItemAtIndex:(NSInteger)index;
- (void)headerClickedInWaterFlowView:(WaterFlowView*)waterFlowView;
- (void)footerClickedInWaterFlowView:(WaterFlowView*)waterFlowView;
//删除某个元素,未实现
//- (void)gridView:(WaterFlowView*)gridView deleteItemAtIndex:(NSInteger)index;


@end

@protocol WaterFlowViewDataSource <NSObject>
//该视图中的小视图总数
- (NSInteger)numberOfViewsInWaterFlowView:(WaterFlowView *)waterFlowView;
//该视图每页有多少列
- (NSInteger)numberOfColumsInWaterFlowView:(WaterFlowView *)waterFlowView;
//该视图每行高度
- (CGFloat)waterFlowView:(WaterFlowView *)waterFlowView heightForIndex:(NSInteger)index;
//获取视图
- (UIView*)waterFlowView:(WaterFlowView*)waterFlowView viewAtIndex:(NSInteger)index;

@optional
//获取视图顶部高度
- (CGFloat)heightForHeaderInWaterFlowView:(WaterFlowView *)waterFlowView;
//获取视图底部高度
- (CGFloat)heightForFooterInWaterFlowView:(WaterFlowView *)waterFlowView;
//获取页面宽度
- (CGFloat)widthForSiderInWaterFlowView:(WaterFlowView*)waterFlowView;

@end





