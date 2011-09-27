//
//  Utilidades.m
//  TPV
//
//  Created by Flavio Escalante Puente on 26/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Utilidades.h"
#import <QuartzCore/QuartzCore.h>

@implementation Utilidades

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        //Iniciamos los formateadores de controles
        formateadorFechas = [[NSDateFormatter alloc] init];
        [formateadorFechas setDateFormat:@"dd/MM/YYYY"];
        formateadorTPCs = [[NSNumberFormatter alloc] init];
        [formateadorTPCs setNumberStyle:NSNumberFormatterPercentStyle];
        formateadorEnteros = [[NSNumberFormatter alloc] init];
        [formateadorEnteros setNumberStyle:NSNumberFormatterNoStyle];
        
        formateadorDecimales = [[NSNumberFormatter alloc] init];
        [formateadorDecimales setNumberStyle:NSNumberFormatterCurrencyStyle];
        NSLocale *tmpLocale1 = [[NSLocale alloc] initWithLocaleIdentifier:@"es_ES"];
        [formateadorDecimales setLocale:tmpLocale1];
        [tmpLocale1 release];
        [formateadorDecimales setCurrencySymbol:@""];
        
        formateadoMoneda = [[NSNumberFormatter alloc] init];
        [formateadoMoneda setNumberStyle:NSNumberFormatterCurrencyStyle];
        NSLocale *tmpLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"es_ES"];
        [formateadoMoneda setLocale:tmpLocale];
        [tmpLocale release];
        
        [formateadorHoras = [NSDateFormatter alloc] init];
        [formateadorHoras setDateFormat:@"hh:mm:ss"];
    }
    
    return self;
}

-(void) aplicarTransicionLayer: (CALayer *) parLayer: (NSString *) parTipo: (NSString *) parSubTipo{
    CATransition* trans = [CATransition animation];
    [trans setType:parTipo];
    [trans setDuration:0.5];
    [trans setSubtype:parSubTipo];
    
    [parLayer addAnimation:trans forKey:@"Transition"];
}

-(NSString *) formateaFechaAString: (NSDate *) parFecha: (BOOL) parFormatoHora{
    if (parFormatoHora) {
        return [formateadorHoras stringFromDate:parFecha];
    }else{
        return [formateadorFechas stringFromDate:parFecha];
    }
}

-(NSString *) formateaEnteroAString: (NSNumber *) parNumber{
    return[formateadorEnteros stringFromNumber:[NSNumber numberWithInt:[parNumber intValue]]];
}

-(NSString *) formateaDecimalAString: (NSDecimalNumber *) parDecimal: (BOOL) parMoneda{
    if (parMoneda) {
        return [formateadoMoneda stringFromNumber:[NSNumber numberWithFloat:[parDecimal floatValue]]];
    }else{
        return [formateadorDecimales stringFromNumber:[NSNumber numberWithFloat:[parDecimal floatValue]]];
    }
}

-(NSNumber *) enteroDesdeStringFormateado: (NSString *) parString{
    NSString *strTmp = [parString stringByReplacingOccurrencesOfString:@"." withString:@""];
    strTmp = [strTmp stringByReplacingOccurrencesOfString:@"%" withString:@""];
    return [NSNumber numberWithInteger: [strTmp integerValue]];  
}


-(NSDecimalNumber *) decimalDesdeStringFormateado: (NSString *) parString{
    NSString *strTmp = [parString stringByReplacingOccurrencesOfString:@"." withString:@""];
    strTmp = [strTmp stringByReplacingOccurrencesOfString:@"," withString:@"."];
    
    //Comprobamos si el valor es negativo
    NSRange range = [strTmp rangeOfString:@"-"];
    if (range.length == 0) {
        return [NSDecimalNumber decimalNumberWithString:strTmp];
    }else{
        //Valor negativo. Quitamos el signo menos
        strTmp = [strTmp stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSDecimalNumber *valorADevolver = [NSDecimalNumber decimalNumberWithString:strTmp];
        
        return [valorADevolver decimalNumberByMultiplyingBy: [NSDecimalNumber decimalNumberWithMantissa: 1 exponent: 0 isNegative: YES]];
    }
}

-(NSDate *) normalizaFecha:(NSDate *)parFecha{
    NSDate *retFecha = [[[NSDate alloc] init] autorelease];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:parFecha];
    [weekdayComponents setHour:8];
    [weekdayComponents setMinute:0];
    [weekdayComponents setSecond:0];
    
    retFecha = [gregorian dateFromComponents:weekdayComponents];
    
    [gregorian release];
    
    return retFecha;
}

@end
