//
//  TicketsDetalles.h
//  TPV
//
//  Created by Flavio on 12/07/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Tickets;

@interface TicketsDetalles : NSManagedObject {
@private
}
@property (nonatomic, retain) NSDecimalNumber * importe;
@property (nonatomic, retain) NSString * articulo;
@property (nonatomic, retain) NSNumber * cantidad;
@property (nonatomic, retain) NSDecimalNumber * precio;
@property (nonatomic, retain) Tickets * cabeceraTickets;

@end
