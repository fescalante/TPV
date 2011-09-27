//
//  ResumenVentas.m
//  TPV
//
//  Created by Flavio Escalante Puente on 18/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ResumenVentas.h"

@implementation ResumenVentas

@synthesize fecha;
@synthesize importeFinal, importeA, importeB, importeVisa, detallado, importeFinalA, numero, tipoDetalle;


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.numero = [NSNumber numberWithInt:1];
        self.importeFinal = [NSDecimalNumber decimalNumberWithString:@"0"];
        self.importeFinalA = [NSDecimalNumber decimalNumberWithString:@"0"];
        self.importeA = [NSDecimalNumber decimalNumberWithString:@"0"];
        self.importeB = [NSDecimalNumber decimalNumberWithString:@"0"];
        self.importeVisa = [NSDecimalNumber decimalNumberWithString:@"0"];
        self.detallado = [NSNumber numberWithBool:NO];
        self.tipoDetalle = @"";
    }
    
    return self;
}


@end
