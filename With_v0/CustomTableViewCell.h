
//  Created by AE on 6/16/14.
//  Copyright (c) 2014 Aaron Eckhart. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageInCell;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabelInCell;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (weak, nonatomic) IBOutlet UILabel *commentTextLabel;

@end
