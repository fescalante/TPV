//
//  TicketsDetallesCell.h
//  TPVFacil
//
//  Created by Flavio on 10/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TicketsDetallesCell : UITableViewCell {
    UILabel *lblCantidad, *lblArticulo, *lblPrecio, *lblImporte;
}

@property (nonatomic, retain) IBOutlet UILabel *lblCantidad;
@property (nonatomic, retain) IBOutlet UILabel *lblArticulo;
@property (nonatomic, retain) IBOutlet UILabel *lblPrecio;
@property (nonatomic, retain) IBOutlet UILabel *lblImporte;

@end
