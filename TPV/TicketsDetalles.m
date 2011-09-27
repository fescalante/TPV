//
//  TicketsDetalles.m
//  TPV
//
//  Created by Flavio on 12/07/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TicketsDetalles.h"
#import "Tickets.h"


@implementation TicketsDetalles
@dynamic importe;
@dynamic articulo;
@dynamic cantidad;
@dynamic precio;
@dynamic cabeceraTickets;


-(void) setCantidad:(NSNumber *)cantidad{
    if ([self.cantidad compare:cantidad] != NSOrderedSame){
        [self willChangeValueForKey:@"cantidad"];
        [self setPrimitiveValue:cantidad forKey:@"cantidad"];
        [self didChangeValueForKey:@"cantidad"];
        
        if (self.cantidad != nil && self.precio != nil) {
            self.importe = [self.precio decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithDecimal:[self.cantidad decimalValue]]];
        }else{
            self.importe = 0;
        }
        
    }    
}

-(void) setPrecio:(NSDecimalNumber *)precio{
    if ([self.precio compare:precio] != NSOrderedSame){
        [self willChangeValueForKey:@"precio"];
        [self setPrimitiveValue:precio forKey:@"precio"];
        [self didChangeValueForKey:@"precio"];

        if (self.cantidad != nil && self.precio != nil) {
            self.importe = [self.precio decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithDecimal:[self.cantidad decimalValue]]];
        }else{
            self.importe = 0;
        }
    }  
}

@end
