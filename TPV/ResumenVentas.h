//
//  ResumenVentas.h
//  TPV
//
//  Created by Flavio Escalante Puente on 18/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResumenVentas : NSObject{
    NSDate * fecha;
    NSNumber *resumenDetallado;
    NSDecimalNumber * importeFinal, *importeA, *importeB, *importeVisa, *importeFinalA;
    NSString *tipoDetalle;
}

@property (nonatomic, retain) NSNumber * numero;
@property (nonatomic, retain) NSDate *fecha;
@property (nonatomic, retain) NSNumber *detallado;
@property (nonatomic, retain) NSDecimalNumber *importeA;
@property (nonatomic, retain) NSDecimalNumber *importeB;
@property (nonatomic, retain) NSDecimalNumber *importeFinal;
@property (nonatomic, retain) NSDecimalNumber *importeFinalA;
@property (nonatomic, retain) NSDecimalNumber *importeVisa;

@property (nonatomic, retain) NSString *tipoDetalle;

@end
