//
//  RecordButton.m
//  _idx_MPPGraphGPUData_D1DD1207_ios_min10.0
//
//  Created by Yee Ching Ng on 30/1/2020.
//

#import "RecordButton.h"
#import "math.h"

@implementation RecordButton {
    CGFloat x;
    CGFloat y;
    CGFloat width;
    CGFloat height;
}

-(instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    
    self.titleLabel.text = @"";
    
    UIImage *btnImage = [UIImage imageNamed:@"shutter"];
    [self setImage:btnImage forState:UIControlStateNormal];
    
    btnImage = [UIImage imageNamed:@"recording"];
    [self setImage:btnImage forState:UIControlStateHighlighted];
    
    x = self.frame.origin.x + self.frame.size.width/2 - 150/2;
    y = self.frame.origin.y + self.frame.size.height/2 - 150/2;
    width = 150;
    height = 150;
    
    self.layer.frame = CGRectMake(x, y, width, height);
    self.layer.cornerRadius = width/2;
    
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if(highlighted) {
        UIColor *bgColor = [UIColor colorWithRed:245/255 green:51/255 blue:51/255 alpha:0.5];
        self.backgroundColor = bgColor;
        //[self startButtonAnimation];
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void) startButtonAnimation {
    if(self.frame.origin.x == x) {
        [UIView animateWithDuration:0.5 animations:^{
            [self setFrame:CGRectMake(x-10, y-10, width+20, height+20)];
            self.layer.cornerRadius = (width+20) / 2;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                [self setFrame:CGRectMake(x, y, width, height)];
                self.layer.cornerRadius = width / 2;
            }];
        }];
    }
}

@end
