//
//  Tickets.m
//  TPV
//
//  Created by Flavio on 12/07/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Tickets.h"
#import "TicketsDetalles.h"


@implementation Tickets
@dynamic importeDescuento;
@dynamic importeFinal;
@dynamic sumaImporteLineas;
@dynamic pagoVisa;
@dynamic conFactura;
@dynamic tpcDTO;
@dynamic numeroOrden;
@dynamic tpcIVA;
@dynamic numero;
@dynamic refrescarTicket;
@dynamic importeIVA;
@dynamic baseImponible;
@dynamic fecha;
@dynamic fechaNormalizada;
@dynamic detalles;


-(void) setConFactura:(NSNumber *)conFactura{
    [self willChangeValueForKey:@"conFactura"];
    [self setPrimitiveValue:conFactura forKey:@"conFactura"];
    [self didChangeValueForKey:@"conFactura"];
    
    //Si ponemos el Ticket en B y el Pago Visa está activado lo desactivamos.
    if (![self.conFactura boolValue]){
        if ([self.pagoVisa boolValue]){
            self.pagoVisa = [NSNumber numberWithBool:NO];                
        }
    } 
}

-(void) setPagoVisa:(NSNumber *)pagoVisa{
    [self willChangeValueForKey:@"pagoVisa"];
    [self setPrimitiveValue:pagoVisa forKey:@"pagoVisa"];
    [self didChangeValueForKey:@"pagoVisa"];
    
    if ([self.pagoVisa boolValue]){
        if (![self.conFactura boolValue]){
            self.conFactura = [NSNumber numberWithBool:YES];                            
        }
    }   
}

-(void) setFecha:(NSDate *)fecha{
    [self willChangeValueForKey:@"fecha"];
    [self setPrimitiveValue:fecha forKey:@"fecha"];
    [self didChangeValueForKey:@"fecha"];
    
    
    //Fecha del Ticket. Hay que hacer toda esta movida para poder guardar la fecha de una forma normalizada.
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:self.fecha];
    [weekdayComponents setHour:8];
    [weekdayComponents setMinute:0];
    [weekdayComponents setSecond:0];
    
    self.fechaNormalizada = [gregorian dateFromComponents:weekdayComponents];
    
    [gregorian release];

}

- (void)setSumaImporteLineas:(NSDecimalNumber *)sumaImporteLineas{
    if ([self.sumaImporteLineas compare:sumaImporteLineas] != NSOrderedSame){
        [self willChangeValueForKey:@"sumaImporteLineas"];
        [self setPrimitiveValue:sumaImporteLineas forKey:@"sumaImporteLineas"];
        [self didChangeValueForKey:@"sumaImporteLineas"];
        
        //Calculamos el descuento
        NSDecimalNumber *tmpSumaImporteLineas = [[[NSDecimalNumber alloc] initWithDecimal:[self.sumaImporteLineas decimalValue]] autorelease];
        NSDecimalNumber *tmpTpcDTO = [[[NSDecimalNumber alloc] initWithDecimal:[self.tpcDTO decimalValue]] autorelease];
        NSDecimalNumber *tmpImporteDTO = [tmpSumaImporteLineas decimalNumberByMultiplyingBy:tmpTpcDTO];
        self.importeDescuento = tmpImporteDTO;
        
        //Calculamos la Base Imponible
        NSDecimalNumber *tmpBaseImponible = [tmpSumaImporteLineas decimalNumberBySubtracting:tmpImporteDTO];
        self.baseImponible = tmpBaseImponible;
        
        //Calculamos el IVA
        NSDecimalNumber *tmpTpcIVA = [[[NSDecimalNumber alloc] initWithDecimal:[self.tpcIVA decimalValue]] autorelease];
        NSDecimalNumber *tmpImporteIVA = [tmpBaseImponible decimalNumberByMultiplyingBy:tmpTpcIVA];
        self.importeIVA = tmpImporteIVA;
        
        //Calculamos el Importe Final, reondeándolo
        NSDecimalNumber *tmpImporteFinal = [tmpBaseImponible decimalNumberByAdding:tmpImporteIVA];
        float tmpImporteFinalRedondeado = floor([tmpImporteFinal floatValue] * 100)/100;
        NSDecimalNumber *importeFinalRedondeadoNSDN =[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", tmpImporteFinalRedondeado]];
        
        NSDecimalNumber *diferenciaControl = [importeFinalRedondeadoNSDN decimalNumberBySubtracting:tmpSumaImporteLineas];
        if (diferenciaControl == 0){
            //Cálculos OK. La suma coincide con el importe final
            self.importeFinal = importeFinalRedondeadoNSDN;             
        } else if (diferenciaControl > 0){
            //Cálculos NO OK. El importe final es mayor que la suma. En este caso restamos la diferencia al IVA
            tmpImporteIVA = [tmpImporteIVA decimalNumberBySubtracting:diferenciaControl];
            self.importeIVA = tmpImporteIVA;
        }else{
            //Cálculos NO OK. El importe final es menor que la suma. En este caso sumamos la diferencia al IVA
            tmpImporteIVA = [tmpImporteIVA decimalNumberByAdding:diferenciaControl];
            self.importeIVA = tmpImporteIVA;
        }
        self.importeFinal = sumaImporteLineas;
    }    
}

- (void)addDetallesObject:(TicketsDetalles *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"detalles" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"detalles"] addObject:value];
    [self didChangeValueForKey:@"detalles" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeDetallesObject:(TicketsDetalles *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"detalles" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"detalles"] removeObject:value];
    [self didChangeValueForKey:@"detalles" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addDetalles:(NSSet *)value {    
    [self willChangeValueForKey:@"detalles" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"detalles"] unionSet:value];
    [self didChangeValueForKey:@"detalles" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeDetalles:(NSSet *)value {
    [self willChangeValueForKey:@"detalles" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"detalles"] minusSet:value];
    [self didChangeValueForKey:@"detalles" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
