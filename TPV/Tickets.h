//
//  Tickets.h
//  TPV
//
//  Created by Flavio on 12/07/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TicketsDetalles;

@interface Tickets : NSManagedObject {
@private
}
@property (nonatomic, retain) NSDecimalNumber * importeDescuento;
@property (nonatomic, retain) NSDecimalNumber * importeFinal;
@property (nonatomic, retain) NSDecimalNumber * sumaImporteLineas;
@property (nonatomic, retain) NSNumber * pagoVisa;
@property (nonatomic, retain) NSNumber * conFactura;
@property (nonatomic, retain) NSDecimalNumber * tpcDTO;
@property (nonatomic, retain) NSNumber * numeroOrden;
@property (nonatomic, retain) NSDecimalNumber * tpcIVA;
@property (nonatomic, retain) NSNumber * numero;
@property (nonatomic, retain) NSNumber * refrescarTicket;
@property (nonatomic, retain) NSDecimalNumber * importeIVA;
@property (nonatomic, retain) NSDecimalNumber * baseImponible;
@property (nonatomic, retain) NSDate * fecha;
@property (nonatomic, retain) NSDate * fechaNormalizada;
@property (nonatomic, retain) NSSet* detalles;

@end
