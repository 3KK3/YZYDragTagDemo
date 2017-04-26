//
//  BGImgeEditorViewController.m
//  Bugoo
//
//  Created by 杨志勇 on 2016/11/24.
//  Copyright © 2016年 YZY. All rights reserved.
//

#import "BGImgeEditorViewController.h"
#import "BGImageEditorCell.h"
#import "BGTagInfoEditView.h"
//#import "YZYPhotoDataManager.h"
#import "UIView+Addition.h"

@interface BGImgeEditorViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
{
    UICollectionView *_collectionView;
    NSMutableArray *_editorItems;
    NSUInteger _showIndex;
    UILabel *_titleLabel;
}
@end

@implementation BGImgeEditorViewController

- (void)dealloc {
    NSLog(@"dealloc controller");
}
- (instancetype)initWithImages:(NSArray <BGImageEditorItem *>*)images showIndex:(NSUInteger)showIndex {
    self = [super initWithNibName: nil bundle: nil];
    if (self) {
        _showIndex = showIndex;
        for (BGImageEditorItem *item in images) {
            
            item.backdropSize = [BGImageEditorCell actualDisplayImageSizeWithItem: item];
        }
        
        _editorItems = [NSMutableArray arrayWithArray: images];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self.navigationController setNavigationBarHidden: YES animated: NO];
}

- (void)createUI {
    
    UIView *fakeNav = [[UIView alloc] initWithFrame: CGRectMake(0, 0, kScreenSize.width, 64)];
    [self.view addSubview: fakeNav];
    fakeNav.backgroundColor = [UIColor whiteColor];
    {
        UIButton *leftRetrunBtn = [UIButton buttonWithType: UIButtonTypeCustom];
        leftRetrunBtn.frame = CGRectMake(0, 20 , 46, 44);
        UIImage *image = [UIImage imageNamed: @"btn_back"];
        [leftRetrunBtn setImage: image forState: UIControlStateNormal];
        [fakeNav addSubview: leftRetrunBtn];
        [leftRetrunBtn addTarget: self action: @selector(leftReturnBtnClick) forControlEvents: UIControlEventTouchUpInside];
    }
    
    {
        UIButton *finishBtn = [UIButton buttonWithType: UIButtonTypeCustom];
        [finishBtn setTitle: @"完成" forState: UIControlStateNormal];
        finishBtn.titleLabel.font = [UIFont systemFontOfSize: 16];
        [finishBtn setTitleColor: UIColorFromRGB(0xF6A623, 1) forState: UIControlStateNormal];
        finishBtn.frame = CGRectMake(fakeNav.width - 46 - 10, 20, 46, 44);
        [fakeNav addSubview: finishBtn];
        [finishBtn addTarget: self action: @selector(finishBtnClick) forControlEvents: UIControlEventTouchUpInside];
    }
    
    {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame: CGRectMake(fakeNav.width / 2 - 100 / 2,  20, 100, 44)];
        _titleLabel = titleLabel;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = [NSString stringWithFormat: @"%ld/%ld",_showIndex + 1, _editorItems.count];
        titleLabel.font = [UIFont systemFontOfSize: 18];
        [fakeNav addSubview: titleLabel];
     }
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kScreenSize.width, kScreenSize.height - 64);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;

    _collectionView = [[UICollectionView alloc] initWithFrame: CGRectMake(0, 64,self.view.width, kScreenSize.height - 64) collectionViewLayout: layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self.view addSubview: _collectionView];
    [_collectionView registerClass: [BGImageEditorCell class] forCellWithReuseIdentifier: NSStringFromClass([BGImageEditorCell class])];
    _collectionView.pagingEnabled = YES;
    
    [_collectionView reloadData];

    [_collectionView setContentOffset: CGPointMake(kScreenSize.width * _showIndex, 0) animated: NO];
}

- (void)leftReturnBtnClick {
    [self.navigationController popViewControllerAnimated: YES];
}

- (void)finishBtnClick {
    
    //防止恶意点击
    [[self class]cancelPreviousPerformRequestsWithTarget:self selector:@selector(preventFinish) object:nil];
    
    //在0.25内多次点击,只会执行最后一次方法
    [self performSelector:@selector(preventFinish) withObject:nil afterDelay:0.25];

    
    
}

- (void)preventFinish
{
    self.editCompletion(_editorItems);
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark --- collection view delegate and datasource

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    _titleLabel.text = [NSString stringWithFormat: @"%ld/%ld",[self currentIndex] + 1, _editorItems.count];
}

- (NSInteger)currentIndex {
    NSInteger currentP = _collectionView.contentOffset.x / _collectionView.width;
    return currentP;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _editorItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    BGImageEditorCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: NSStringFromClass([BGImageEditorCell class]) forIndexPath: indexPath];
    
    WEAKSELF;
    cell.tagDeleteCompletion =^(BGImageEditorItem *newEidtorItem){
        
        [weakSelf longPressGesActionWithIndexPath: indexPath editItem: newEidtorItem];
    };

    cell.editorItem = _editorItems[indexPath.item];
    
    cell.listTapCompletion = ^(BGImageEditorItem *item){
        [weakSelf showTagEditPopViewWithIndexPath: indexPath];
    };
    
    cell.tagTapCompletion = ^(BGImageEditorItem *item) {
        [weakSelf showTagEditPopViewWithIndexPath: indexPath];
    };
    
    cell.tagEditCompletion =^(BGImageEditorItem *newEidtorItem){
        [weakSelf handleTagEditedWithIndexPath: indexPath Item: newEidtorItem];
    };
    
    return cell;
}

- (void)handleTagEditedWithIndexPath:(NSIndexPath *)indexPath Item:(BGImageEditorItem *)newEidtorItem {
    [_editorItems replaceObjectAtIndex: indexPath.item withObject: newEidtorItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)showTagEditPopViewWithIndexPath:(NSIndexPath *)indexPath {
    
    BGTagInfoEditView *editView = [[BGTagInfoEditView alloc] initWithEditorItem: _editorItems[indexPath.row] defaultInfoItem: [self allLastContentItem]];
    
    [editView showTagInfoEditView];
    
    editView.saveCompletion = ^(BGImageEditorItem *editedItem) {
        [self finishEditWithIndexPath: indexPath editedItem: editedItem];
    };
    
    editView.cancelCompletion = ^(BGImageEditorItem *editedItem){
        [self finishEditWithIndexPath: indexPath editedItem: editedItem];
    };
}

- (BGImageEditorItem *)allLastContentItem {
    
    BGImageEditorItem *lastContentItem = [[BGImageEditorItem alloc] init];
    
    NSArray *tempArray = [_editorItems subarrayWithRange: NSMakeRange(0, [self currentIndex])];
    tempArray = [[tempArray reverseObjectEnumerator] allObjects];
    
    if (tempArray.count <= 0) {
        return _editorItems[[self currentIndex]];
    }
    
    lastContentItem.shopAddress = [self contentWitnItemIndex: 0 array: tempArray contentIndex: 0];
    lastContentItem.phoneNum = [self contentWitnItemIndex: 0 array: tempArray contentIndex: 1];
    lastContentItem.shopHours = [self contentWitnItemIndex: 0 array: tempArray contentIndex: 2];
    lastContentItem.brand = [self contentWitnItemIndex: 0 array: tempArray contentIndex: 3];
    lastContentItem.currency = [self contentWitnItemIndex: 0 array: tempArray contentIndex: 4];
    
    return lastContentItem;
}

- (id)contentWitnItemIndex:(NSInteger)itemIndex array:(NSArray *)tempArray contentIndex:(NSInteger)contentIndex {
    
    if (itemIndex == tempArray.count - 1) {
        return [tempArray[itemIndex] displayInfoArray][contentIndex];
    }
    
    BGImageEditorItem *item = tempArray[itemIndex];

    if ([item displayInfoArray][contentIndex] != [NSNull null]) {
        
        return [item displayInfoArray][contentIndex];
    } else {
        
        return [self contentWitnItemIndex:itemIndex + 1 array: tempArray contentIndex: contentIndex];
    }
}

- (void)finishEditWithIndexPath:(NSIndexPath *)indexPath editedItem:(BGImageEditorItem *)editedItem {
    [_editorItems replaceObjectAtIndex: indexPath.item withObject: editedItem];
    [_collectionView reloadData];
}

- (void)longPressGesActionWithIndexPath:(NSIndexPath*)indexPath editItem:(BGImageEditorItem*)editItem {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle: @"确定要删除此吊牌吗" message: nil preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle: @"确定" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        editItem.hasTag = NO;
        [_editorItems replaceObjectAtIndex: indexPath.item withObject: editItem];
        [_collectionView reloadItemsAtIndexPaths: @[indexPath]];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction: sureAction];
    [alertController addAction: cancelAction];
    
    [self presentViewController: alertController animated: YES completion: nil];
}

@end















