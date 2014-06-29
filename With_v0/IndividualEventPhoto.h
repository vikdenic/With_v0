//
//  IndividualEventPhoto.h
//  With_v0
//
//  Created by Blake Mitchell on 6/21/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface IndividualEventPhoto : NSObject

@property NSMutableArray *likes;
@property PFFile *photo;
@property NSMutableArray *comments;
@property PFObject *object;
@property PFFile *photographerPhoto;
@property NSString *username;
@property PFObject *photographer;

@end
