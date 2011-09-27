//
//  ResumenVentasCell.h
//  TPVFacil
//
//  Created by Flavio on 10/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ResumenVentasCell : UITableViewCell {
    UILabel *_lblCol1, *_lblCol2, *_lblCol3, *_lblCol4, *_lblCol5, *_lblCol6;
}

@property (nonatomic, retain) IBOutlet UILabel *lblCol1;
@property (nonatomic, retain) IBOutlet UILabel *lblCol2;
@property (nonatomic, retain) IBOutlet UILabel *lblCol3;
@property (nonatomic, retain) IBOutlet UILabel *lblCol4;
@property (nonatomic, retain) IBOutlet UILabel *lblCol5;
@property (nonatomic, retain) IBOutlet UILabel *lblCol6;


@end
