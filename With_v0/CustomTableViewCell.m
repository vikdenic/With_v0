
//  Created by AE on 6/16/14.
//  Copyright (c) 2014 Aaron Eckhart. All rights reserved.
//

#import "CustomTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation CustomTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {

    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




@end


