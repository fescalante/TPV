//
//  TicketsDetallesCell.m
//  TPVFacil
//
//  Created by Flavio on 10/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TicketsDetallesCell.h"


@implementation TicketsDetallesCell

@synthesize lblCantidad, lblArticulo, lblPrecio, lblImporte;

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
    [lblArticulo release];
    [lblArticulo release];
    [lblPrecio release];
    [lblImporte release];
    
    [super dealloc];
}

@end
