//
//  LLHierarchyInfoView.m
//
//  Copyright (c) 2018 LLDebugTool Software Foundation (https://github.com/HDB-Li/LLDebugTool)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "LLHierarchyInfoView.h"

#import "LLConst.h"
#import "LLDebugConfig.h"
#import "LLFactory.h"
#import "LLImageNameConfig.h"
#import "LLInternalMacros.h"
#import "LLThemeManager.h"
#import "LLToastUtils.h"
#import "LLTool.h"

#import "NSObject+LL_Hierarchy.h"
#import "UIColor+LL_Utils.h"
#import "UIView+LL_Utils.h"

@interface LLHierarchyInfoView ()

@property (nonatomic, strong, nullable) UIView *selectedView;

@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) UILabel *frameLabel;

@property (nonatomic, strong) UILabel *backgroundColorLabel;

@property (nonatomic, strong) UILabel *textColorLabel;

@property (nonatomic, strong) UILabel *fontLabel;

@property (nonatomic, strong) UILabel *tagLabel;

@property (nonatomic, strong) UIView *actionContentView;

@property (nonatomic, strong) UIButton *moreButton;

@property (nonatomic, strong) UIButton *parentViewsButton;

@property (nonatomic, strong) UIButton *subviewsButton;

@property (nonatomic, assign) CGFloat actionContentViewHeight;

@end

@implementation LLHierarchyInfoView

@dynamic delegate;

- (void)updateSelectedView:(UIView *)selectedView {
    UIView *view = selectedView;

    if (!view) {
        return;
    }

    if (self.selectedView == view) {
        return;
    }

    self.moreButton.enabled = YES;
    self.parentViewsButton.enabled = view.superview != nil;
    self.subviewsButton.enabled = view.subviews.count;

    self.selectedView = view;

    self.contentLabel.attributedText = [self attributedStringWithText:@"Name: " detail:NSStringFromClass(view.class)];

    self.frameLabel.attributedText = [self attributedStringWithText:@"Frame: " detail:[LLTool stringFromFrame:view.frame]];

    if (view.backgroundColor) {
        self.backgroundColorLabel.attributedText = [self attributedStringWithText:@"Background: " detail:view.backgroundColor.LL_description];
    } else {
        self.backgroundColorLabel.attributedText = nil;
    }

    if ([view isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)view;
        self.textColorLabel.attributedText = [self attributedStringWithText:@"Text Color: " detail:label.textColor.LL_description];
        self.fontLabel.attributedText = [self attributedStringWithText:@"Font: " detail:[NSString stringWithFormat:@"%0.2f", label.font.pointSize]];
    } else {
        self.textColorLabel.attributedText = nil;
        self.fontLabel.attributedText = nil;
    }

    if (view.tag != 0) {
        self.tagLabel.attributedText = [self attributedStringWithText:@"Tag: " detail:[NSString stringWithFormat:@"%ld", (long)view.tag]];
    } else {
        self.tagLabel.attributedText = nil;
    }

    [self.contentLabel sizeToFit];
    [self.frameLabel sizeToFit];
    [self.backgroundColorLabel sizeToFit];
    [self.textColorLabel sizeToFit];
    [self.fontLabel sizeToFit];
    [self.tagLabel sizeToFit];

    [self updateHeightIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.actionContentView.frame = CGRectMake(0, self.LL_height - self.actionContentViewHeight - kLLGeneralMargin, self.LL_width, self.actionContentViewHeight);

    self.parentViewsButton.frame = CGRectMake(kLLGeneralMargin, 0, self.actionContentView.LL_width / 2.0 - kLLGeneralMargin * 1.5, (self.actionContentView.LL_height - kLLGeneralMargin) / 2.0);

    self.subviewsButton.frame = CGRectMake(self.actionContentView.LL_width / 2.0 + kLLGeneralMargin * 0.5, self.parentViewsButton.LL_top, self.parentViewsButton.LL_width, self.parentViewsButton.LL_height);

    self.moreButton.frame = CGRectMake(kLLGeneralMargin, self.parentViewsButton.LL_bottom + kLLGeneralMargin, self.actionContentView.LL_width - kLLGeneralMargin * 2, self.parentViewsButton.LL_height);

    self.contentLabel.frame = CGRectMake(kLLGeneralMargin, kLLGeneralMargin, self.closeButton.LL_x - kLLGeneralMargin - kLLGeneralMargin, self.contentLabel.LL_height);

    self.frameLabel.frame = CGRectMake(self.contentLabel.LL_x, self.contentLabel.LL_bottom, self.contentLabel.LL_width, self.frameLabel.LL_height);

    self.backgroundColorLabel.frame = CGRectMake(self.contentLabel.LL_x, self.frameLabel.LL_bottom, self.contentLabel.LL_width, self.backgroundColorLabel.LL_height);

    self.textColorLabel.frame = CGRectMake(self.contentLabel.LL_x, self.backgroundColorLabel.LL_bottom, self.contentLabel.LL_width, self.textColorLabel.LL_height);

    self.fontLabel.frame = CGRectMake(self.contentLabel.LL_x, self.textColorLabel.LL_bottom, self.contentLabel.LL_width, self.fontLabel.LL_height);

    self.tagLabel.frame = CGRectMake(self.contentLabel.LL_x, self.fontLabel.LL_bottom, self.contentLabel.LL_width, self.tagLabel.LL_height);
}

#pragma mark - Over write
- (void)initUI {
    [super initUI];
    self.actionContentViewHeight = 80;

    [self addSubview:self.contentLabel];
    [self addSubview:self.frameLabel];
    [self addSubview:self.backgroundColorLabel];
    [self addSubview:self.textColorLabel];
    [self addSubview:self.fontLabel];
    [self addSubview:self.tagLabel];
    [self addSubview:self.actionContentView];
    [self.actionContentView addSubview:self.parentViewsButton];
    [self.actionContentView addSubview:self.subviewsButton];
    [self.actionContentView addSubview:self.moreButton];

    [self updateHeightIfNeeded];
}

#pragma mark - Event responses
- (void)buttonClicked:(UIButton *)sender {
    [self.delegate LLHierarchyInfoView:self didSelectAt:sender.tag];
}

- (void)frameLabelTapGestureRecognizer:(UITapGestureRecognizer *)sender {
    [self.selectedView LL_showFrameAlertAndAutomicSetWithKeyPath:@"frame"];
}

- (void)backgroundColorLabelTapGestureRecognizer:(UITapGestureRecognizer *)sender {
    [self.selectedView LL_showColorAlertAndAutomicSetWithKeyPath:@"backgroundColor"];
}

- (void)textColorLabelTapGestureRecognizer:(UITapGestureRecognizer *)sender {
    [self.selectedView LL_showColorAlertAndAutomicSetWithKeyPath:@"textColor"];
}

- (void)fontLabelTapGestureRecognizer:(UITapGestureRecognizer *)sender {
    [self.selectedView LL_showFontAlertAndAutomicSetWithKeyPath:@"font"];
}

- (void)tagLabelTapGestureRecognizer:(UITapGestureRecognizer *)sender {
    [self.selectedView LL_showIntAlertAndAutomicSetWithKeyPath:@"tag"];
}

#pragma mark - Primary
- (void)updateHeightIfNeeded {
    CGFloat contentHeight = self.contentLabel.LL_height + self.frameLabel.LL_height + self.backgroundColorLabel.LL_height + self.textColorLabel.LL_height + self.fontLabel.LL_height + self.tagLabel.LL_height;
    CGFloat height = kLLGeneralMargin + MAX(contentHeight, self.closeButton.LL_height) + kLLGeneralMargin + self.actionContentViewHeight + kLLGeneralMargin;
    if (height != self.LL_height) {
        self.LL_height = height;
        if (!self.isMoved) {
            if (self.LL_bottom != LL_SCREEN_HEIGHT - kLLGeneralMargin * 2) {
                self.LL_bottom = LL_SCREEN_HEIGHT - kLLGeneralMargin * 2;
            }
        }
    }
}

- (NSAttributedString *)attributedStringWithText:(NSString *)text detail:(NSString *)detail {
    NSDictionary *boldAttri = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:17]};
    NSDictionary *attri = @{NSFontAttributeName: [UIFont systemFontOfSize:14]};

    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:text attributes:boldAttri];
    [str appendAttributedString:[[NSAttributedString alloc] initWithString:detail attributes:attri]];

    return [str copy];
}

#pragma mark - Getters and setters
- (void)setDelegate:(id<LLHierarchyInfoViewDelegate>)delegate {
    [super setDelegate:delegate];
}

- (id<LLHierarchyInfoViewDelegate>)delegate {
    return (id<LLHierarchyInfoViewDelegate>)[super delegate];
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [LLFactory getLabel:nil frame:CGRectZero text:nil font:14 textColor:[LLThemeManager shared].primaryColor];
        _contentLabel.numberOfLines = 0;
        _contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    }
    return _contentLabel;
}

- (UILabel *)frameLabel {
    if (!_frameLabel) {
        _frameLabel = [LLFactory getLabel:nil frame:CGRectZero text:nil font:14 textColor:[LLThemeManager shared].primaryColor];
        _frameLabel.numberOfLines = 0;
        _frameLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [_frameLabel LL_addClickListener:self action:@selector(frameLabelTapGestureRecognizer:)];
    }
    return _frameLabel;
}

- (UILabel *)backgroundColorLabel {
    if (!_backgroundColorLabel) {
        _backgroundColorLabel = [LLFactory getLabel:nil frame:CGRectZero text:nil font:14 textColor:[LLThemeManager shared].primaryColor];
        _backgroundColorLabel.numberOfLines = 0;
        _backgroundColorLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [_backgroundColorLabel LL_addClickListener:self action:@selector(backgroundColorLabelTapGestureRecognizer:)];
    }
    return _backgroundColorLabel;
}

- (UILabel *)textColorLabel {
    if (!_textColorLabel) {
        _textColorLabel = [LLFactory getLabel:nil frame:CGRectZero text:nil font:14 textColor:[LLThemeManager shared].primaryColor];
        _textColorLabel.numberOfLines = 0;
        _textColorLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [_textColorLabel LL_addClickListener:self action:@selector(textColorLabelTapGestureRecognizer:)];
    }
    return _textColorLabel;
}

- (UILabel *)fontLabel {
    if (!_fontLabel) {
        _fontLabel = [LLFactory getLabel:nil frame:CGRectZero text:nil font:14 textColor:[LLThemeManager shared].primaryColor];
        _fontLabel.numberOfLines = 0;
        _fontLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [_fontLabel LL_addClickListener:self action:@selector(fontLabelTapGestureRecognizer:)];
    }
    return _fontLabel;
}

- (UILabel *)tagLabel {
    if (!_tagLabel) {
        _tagLabel = [LLFactory getLabel:nil frame:CGRectZero text:nil font:14 textColor:[LLThemeManager shared].primaryColor];
        _tagLabel.numberOfLines = 0;
        _tagLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [_tagLabel LL_addClickListener:self action:@selector(tagLabelTapGestureRecognizer:)];
    }
    return _tagLabel;
}

- (UIView *)actionContentView {
    if (!_actionContentView) {
        _actionContentView = [LLFactory getView];
    }
    return _actionContentView;
}

- (UIButton *)parentViewsButton {
    if (!_parentViewsButton) {
        _parentViewsButton = [LLFactory getButton:nil frame:CGRectZero target:self action:@selector(buttonClicked:)];
        [_parentViewsButton setTitle:LLLocalizedString(@"hierarchy.parent") forState:UIControlStateNormal];
        [_parentViewsButton setTitleColor:[LLThemeManager shared].primaryColor forState:UIControlStateNormal];
        _parentViewsButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _parentViewsButton.backgroundColor = [LLThemeManager shared].backgroundColor;
        [_parentViewsButton LL_setBorderColor:[LLThemeManager shared].primaryColor borderWidth:1];
        [_parentViewsButton LL_setCornerRadius:5];
        _parentViewsButton.tintColor = [LLThemeManager shared].primaryColor;
        _parentViewsButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, kLLGeneralMargin);
        [_parentViewsButton setImage:[[UIImage LL_imageNamed:kParentImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _parentViewsButton.tag = LLHierarchyInfoViewActionShowParent;
        _parentViewsButton.enabled = NO;
    }
    return _parentViewsButton;
}

- (UIButton *)subviewsButton {
    if (!_subviewsButton) {
        _subviewsButton = [LLFactory getButton:nil frame:CGRectZero target:self action:@selector(buttonClicked:)];
        [_subviewsButton setTitle:LLLocalizedString(@"hierarchy.subview") forState:UIControlStateNormal];
        [_subviewsButton setTitleColor:[LLThemeManager shared].primaryColor forState:UIControlStateNormal];
        _subviewsButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _subviewsButton.backgroundColor = [LLThemeManager shared].backgroundColor;
        [_subviewsButton LL_setBorderColor:[LLThemeManager shared].primaryColor borderWidth:1];
        [_subviewsButton LL_setCornerRadius:5];
        _subviewsButton.tintColor = [LLThemeManager shared].primaryColor;
        _subviewsButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, kLLGeneralMargin);
        [_subviewsButton setImage:[[UIImage LL_imageNamed:kSubviewImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _subviewsButton.tag = LLHierarchyInfoViewActionShowSubview;
        _subviewsButton.enabled = NO;
    }
    return _subviewsButton;
}

- (UIButton *)moreButton {
    if (!_moreButton) {
        _moreButton = [LLFactory getButton:nil frame:CGRectZero target:self action:@selector(buttonClicked:)];
        [_moreButton setTitle:LLLocalizedString(@"hierarchy.more") forState:UIControlStateNormal];
        [_moreButton setTitleColor:[LLThemeManager shared].primaryColor forState:UIControlStateNormal];
        _moreButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _moreButton.backgroundColor = [LLThemeManager shared].backgroundColor;
        [_moreButton LL_setBorderColor:[LLThemeManager shared].primaryColor borderWidth:1];
        [_moreButton LL_setCornerRadius:5];
        _moreButton.tintColor = [LLThemeManager shared].primaryColor;
        _moreButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, kLLGeneralMargin);
        [_moreButton setImage:[[UIImage LL_imageNamed:kInfoImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _moreButton.tag = LLHierarchyInfoViewActionShowMoreInfo;
        _moreButton.enabled = NO;
    }
    return _moreButton;
}

@end
