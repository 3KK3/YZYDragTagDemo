//
//  BGImageTagView.m
//  Bugoo
//
//  Created by 杨志勇 on 2016/11/24.
//  Copyright © 2016年 YZY. All rights reserved.
//

#import "BGImageTagView.h"
#import "UIImage+SizeScale.h"
#import "UIView+Addition.h"

#define kBubblyHeight 24  // point大小为正方形

#define kTextFrontPadding 0
#define kTextBackPadding 5

#define kArroWidth 18

@implementation BGImageTagView{
    CGRect _limitRect;
    BGImageEditorItem *_editorItem;
    UIImageView *_pointImgView;
    UIImageView *_bubbleRectImageView;
    UIImageView *_bubbleArrowImgView;
    UILabel *_contentLabel;
}

- (instancetype)initWithLimitRect:(CGRect)limitRect editorItem:(BGImageEditorItem *)editorItem {
    
    self = [super init];
    if (self) {
        
        _limitRect = limitRect;
        _editorItem = editorItem;
        
        CGFloat width = kArroWidth + kBubblyHeight + kTextFrontPadding + kTextBackPadding;
        
        CGPoint location = editorItem.tagLocation;
        
        if (location.x == -1 && location.y == -1) {
            location = CGPointMake(_limitRect.size.width / 2, _limitRect.size.height / 2);
            _editorItem.tagLocation = location;
            _editorItem.tagDirection = BGTagDirectionRight;
        }
        
        CGFloat selfX = location.x - kBubblyHeight / 2 + _limitRect.origin.x;
        
        CGRect extraRect = CGRectMake(selfX, location.y - kBubblyHeight / 2 + _limitRect.origin.y, width, kBubblyHeight );
        self.frame = extraRect;
        
        [self createUI];
    }
    return self;
}

- (void)createUI {
    
    UILongPressGestureRecognizer *longPressGes = [[UILongPressGestureRecognizer alloc] initWithTarget: self action: @selector(longPressGesAction:)];
    [self addGestureRecognizer: longPressGes];
    
    //默认right
    _pointImgView = [[UIImageView alloc] initWithFrame: CGRectZero];
    [self addSubview: _pointImgView];
    _pointImgView.image = [UIImage imageNamed: @"Label"];
    _pointImgView.userInteractionEnabled = YES;
    [_pointImgView addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(pointTapGesAction)]];
    _pointImgView.contentMode = UIViewContentModeCenter;
    
    _bubbleArrowImgView = [[UIImageView alloc] initWithFrame: CGRectZero];
    _bubbleArrowImgView.image = [UIImage imageNamed: @"biaoqian01"];
    [self addSubview: _bubbleArrowImgView];
    
    _bubbleRectImageView = [[UIImageView alloc] initWithFrame: CGRectZero];
    [self addSubview: _bubbleRectImageView];
    
    _contentLabel = [[UILabel alloc] initWithFrame: CGRectMake(kBubblyHeight + kArroWidth + kTextFrontPadding, 0, 0, kBubblyHeight)];
    _contentLabel.textAlignment = NSTextAlignmentCenter;
    _contentLabel.font = [UIFont systemFontOfSize: 12];
    [self addSubview: _contentLabel];
    _contentLabel.textColor = [UIColor whiteColor];
    
    NSString *content = nil;
    
    if (_editorItem.brand) {
        if (_editorItem.price) {
            content = [NSString stringWithFormat: @"%@ · %@%@", _editorItem.brand , _editorItem.price,[self checkStr: _editorItem.currency]];
        } else {
            content = [NSString stringWithFormat: @"%@", _editorItem.brand];
        }
        
    } else {
        content = [NSString stringWithFormat: @"%@%@", _editorItem.price,[self checkStr: _editorItem.currency]];
    }
    
    _contentLabel.text = content;
    
    [self addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(tapGesAction)]];

    [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget: self action: @selector(panGesAction:)]];
    
    [self resetUI];
    
    if (_editorItem.tagDirection == BGTagDirectionLeft) {
        [self changeTagToDirection: BGTagDirectionLeft];
    }
}

- (void)tapGesAction {
    self.tagTapCompletion(_editorItem);
}

- (void)setEditEnable:(BOOL)editEnable {
    _editEnable = editEnable;
    self.userInteractionEnabled = editEnable;
}

- (NSString *)checkStr:(NSString *)str {
    if (str.length > 0) {
        return str;
    }
    return @"";
}

- (void)changeTagToDirection:(BGTagDirection)direction {

    _editorItem.tagDirection = direction;
    
    [self resetUI];
    
    switch (_editorItem.tagDirection) {
        case BGTagDirectionRight:
        {
            self.x = self.maxX - kBubblyHeight;
        }
            break;
            
        case BGTagDirectionLeft:
        {
            self.x = self.x - self.width + kBubblyHeight;
        }
            break;
            
        default:
            break;
    }
}

- (void)resetUI {
    [_contentLabel sizeToFit];
    
    _bubbleArrowImgView.transform = CGAffineTransformIdentity;
    _bubbleRectImageView.transform = CGAffineTransformIdentity;
    
    self.width = kBubblyHeight + kArroWidth + _contentLabel.width + kTextFrontPadding + kTextBackPadding;
    
    switch (_editorItem.tagDirection) {
        case BGTagDirectionRight:
        {
            _pointImgView.frame = CGRectMake(0, 0, kBubblyHeight, kBubblyHeight);
            
            _bubbleArrowImgView.frame = CGRectMake(_pointImgView.maxX, 0, kArroWidth, kBubblyHeight);
            _bubbleArrowImgView.transform = CGAffineTransformMakeRotation(M_PI);
            
            _contentLabel.frame = CGRectMake(_bubbleArrowImgView.maxX, 0, _contentLabel.width, kBubblyHeight);
            
            _bubbleRectImageView.frame = CGRectMake(_contentLabel.x, 0, _contentLabel.width + kTextBackPadding, kBubblyHeight);
            _bubbleRectImageView.image = [UIImage resizableBackAreaImage: @"biaoqian02"];
            _bubbleRectImageView.transform = CGAffineTransformMakeRotation(M_PI);
            
        }
            break;
            
        case BGTagDirectionLeft:
        {
            _pointImgView.frame = CGRectMake(self.width - kBubblyHeight, 0, kBubblyHeight, kBubblyHeight);

            _bubbleArrowImgView.frame = CGRectMake(_pointImgView.x - kArroWidth, 0, kArroWidth, kBubblyHeight);
            
            _contentLabel.frame = CGRectMake(_bubbleArrowImgView.x - _contentLabel.width - kTextFrontPadding, 0, _contentLabel.width, kBubblyHeight);
            
            _bubbleRectImageView.frame = CGRectMake(0, 0, _contentLabel.width + kTextBackPadding, kBubblyHeight);
            _bubbleRectImageView.image = [UIImage resizableBackAreaImage: @"biaoqian02"];
        }
            break;
            
        default:
            break;
    }
    
////    _editorItem.tagLocation = CGPointMake(self.x, self.y);
//    
////    NSLog(@"point frame : %@, self frame: %@",NSStringFromCGRect(_pointImgView.frame), NSStringFromCGRect(self.frame));
//    
//    CGPoint pointCenter = [self.superview convertPoint: _pointImgView.center fromView: self];
////
//    NSLog(@"dir:%ld , pointcC: %@",_editorItem.tagDirection , NSStringFromCGPoint(pointCenter));
}

//- (void)changeUIToDirection:(BGTagDirection)direction {
//    
//    _bubbleImgView.transform = CGAffineTransformIdentity;
//    
//    switch (direction) {
//        case BGTagDirectionRight:
//        {
//            _pointImgView.frame = CGRectMake(0, 0, kBubblyHeight, kBubblyHeight);
//            _bubbleImgView.frame = CGRectMake(_pointImgView.maxX, 0, kBubblyWidth, kBubblyHeight);
//            _bubbleImgView.transform = CGAffineTransformMakeRotation(M_PI);
//            _contentLabel.frame = CGRectMake(kBubblyHeight + kContentPadding, 0, self.width - kBubblyHeight - kContentPadding, kBubblyHeight);
//            self.frame = CGRectMake(self.maxX - kBubblyHeight, self.y, self.width, self.height);
//        }
//            break;
//            
//        case BGTagDirectionLeft:
//        {
//            _pointImgView.frame = CGRectMake(self.width - kBubblyHeight, 0, kBubblyHeight, kBubblyHeight);
//            _bubbleImgView.frame = CGRectMake(0, 0, kBubblyWidth, kBubblyHeight);
//            _contentLabel.frame = CGRectMake(0, 0, self.width - kBubblyHeight - kContentPadding, kBubblyHeight);
//            self.frame = CGRectMake(self.x - self.width + kBubblyHeight, self.y, self.width, self.height);
//        }
//            break;
//            
//        default:
//            break;
//    }
//}

- (void)pointTapGesAction {
    switch (_editorItem.tagDirection) {
        case BGTagDirectionLeft: {
            
            [self changeTagToDirection: BGTagDirectionRight];
            self.tagEditCompletion(_editorItem);
        }
            break;
            
        case BGTagDirectionRight: {
            
            [self changeTagToDirection: BGTagDirectionLeft];
            self.tagEditCompletion(_editorItem);
        }
            break;
        default:
            break;
    }
}

- (void)longPressGesAction:(UILongPressGestureRecognizer *)longGes {
    
    switch (longGes.state) {
        case UIGestureRecognizerStateBegan: {
            self.tagDeleteCompletion(_editorItem);
        }
            break;
            
        default:
            break;
    }
}

- (void)panGesAction:(UIPanGestureRecognizer *)panGes {
    
    CGPoint transP = [panGes translationInView: self.superview];
    
    CGFloat minX = _limitRect.origin.x - kBubblyHeight / 2;
    
    CGFloat minY = _limitRect.origin.y - kBubblyHeight / 2;
    
    CGFloat maxX = _limitRect.size.width - kBubblyHeight / 2 + _limitRect.origin.x;
    
    CGFloat maxY = _limitRect.size.height - kBubblyHeight / 2 + _limitRect.origin.y;
    
    switch (_editorItem.tagDirection) {
        case BGTagDirectionLeft: {
            
            minX = kBubblyHeight / 2 - self.width + _limitRect.origin.x;
            
            maxX = _limitRect.origin.x + _limitRect.size.width - self.width + kBubblyHeight / 2;
        }
            break;
            
        default:
            break;
    }
    
    switch (panGes.state) {
            
        case UIGestureRecognizerStateChanged: {
            CGRect newFrame = self.frame;

            if (transP.x > 0 ) { //👉
                newFrame.origin.x = MIN(maxX, transP.x + self.x);
            } else { //👈
                newFrame.origin.x = MAX(minX, transP.x + self.x);
            }
            
            if (transP.y > 0) { //👇
                newFrame.origin.y = MIN(maxY, transP.y + self.y);
            } else { //👆
                newFrame.origin.y = MAX(minY, transP.y + self.y);
            }
            self.frame = newFrame;
            [panGes setTranslation:CGPointZero inView:self.superview];
        }
            break;
            
        case UIGestureRecognizerStateEnded: {
            
            CGPoint pointCenter = [self.superview convertPoint: _pointImgView.center fromView: self];

//            CGPoint pointCenter = [_pointImgView convertPoint: _pointImgView.center toView: self.superview];
            pointCenter.x -= _limitRect.origin.x;
            pointCenter.y -= _limitRect.origin.y;
            _editorItem.tagLocation = pointCenter;
            self.tagEditCompletion(_editorItem);
        }
            break;
            
        default:
            break;
    }
}

@end







