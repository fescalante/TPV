//
//  Utilidades.h
//  TPV
//
//  Created by Flavio Escalante Puente on 26/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utilidades : NSObject{
    NSNumberFormatter *formateadoMoneda, *formateadorEnteros, *formateadorTPCs, *formateadorDecimales; 
    NSDateFormatter *formateadorFechas, *formateadorHoras;
}

-(NSNumber *) enteroDesdeStringFormateado: (NSString *) parString;
-(NSDecimalNumber *) decimalDesdeStringFormateado: (NSString *) parString;
-(NSString *) formateaDecimalAString: (NSDecimalNumber *) parDecimal: (BOOL) parMoneda;
-(NSString *) formateaEnteroAString: (NSNumber *) parNumber;
-(NSString *) formateaFechaAString: (NSDate *) parFecha: (BOOL) parFormatoHora;
-(void) aplicarTransicionLayer: (CALayer *) parLayer: (NSString *) parTipo: (NSString *) parSubTipo;
-(NSDate *) normalizaFecha: (NSDate *) parFecha;
  
@end
