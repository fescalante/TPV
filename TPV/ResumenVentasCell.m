//
//  ResumenVentasCell.m
//  TPVFacil
//
//  Created by Flavio on 10/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ResumenVentasCell.h"


@implementation ResumenVentasCell

@synthesize lblCol1=_lblCol1, lblCol2=_lblCol2, lblCol3=_lblCol3, lblCol4=_lblCol4, lblCol5=_lblCol5, lblCol6=_lblCol6;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    [_lblCol1 release];
    [_lblCol2 release];
    [_lblCol3 release];
    [_lblCol4 release];
    [_lblCol5 release];
    [_lblCol6 release];
    
    [super dealloc];
}

@end
