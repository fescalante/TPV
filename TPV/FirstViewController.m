//
//  FirstViewController.m
//  TPVFacil
//
//  Created by Flavio on 10/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FirstViewController.h"
#import "TpvAppDelegate.h"
#import "TicketsDetallesCell.h"
#import "EditDetailViewController.h"
#import "DropboxSDK.h"
#import <QuartzCore/QuartzCore.h>
#import "TecladoNumerico.h"


@implementation FirstViewController

@synthesize numeroOrden=_numeroOrden, numeroTicket=_numeroTicket, fechaTicket=_fechaTicket;
@synthesize switchCF=_switchCF, switchVisa=_switchVisa, importeFinal=_importeFinal, indicadorTicketActivo=_indicadorTicketActivo;
@synthesize txtCantidad=_txtCantidad, artLinea=_artLinea, pvpLinea=_pvpLinea, impLinea=_impLinea;
@synthesize btnInsertaLinea=_btnInsertaLinea, btnCambiaTicketAnterior=_btnCambiaTicketAnterior, btnCambiaTicketSiguiente=_btnCambiaTicketSiguiente, btnCambiaTicketUltimo=_btnCambiaTicketUltimo, btnCambiaTicketPrimero=_btnCambiaTicketPrimero;

@synthesize tableViewDetalles=_tableViewDetalles, tblCell=_tblCell;
@synthesize miFRCTickets=_miFRCTickets, miFRCTicketsDetalles=_miFRCTicketsDetalles, miMOC=_miMOC;
@synthesize primeraCarga=_primeraCarga;
@synthesize ticketActivo=_ticketActivo;

@synthesize editDetailView=_editDetailView, popOverController=_popOverController, detalleAEditar=_detalleAEditar;

@synthesize vistaSuperior=_vistaSuperior;

@synthesize programadorBackUp=_programadorBackUp;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
   
    _primeraCarga = @"S";
    heightOriginalTableViewDetalles = 551.f;
    heightReducidaTableViewDetalles = 250.f;
    
    //Iniciamos las utilidades
    cajaHerramientas = [[Utilidades alloc] init];
    
    //Asignamos el teclado numérico a los UIText que lo necesiten
    TecladoNumerico *tecladoCantidad = [[TecladoNumerico alloc] initWithNibName:@"TecladoNumerico" bundle:nil];
    tecladoCantidad.esDecimal = FALSE;
    tecladoCantidad.delegate = self;
    _txtCantidad.inputView = tecladoCantidad.view;
    tecladoCantidad.textFieldAsignado = _txtCantidad;
    
    TecladoNumerico *tecladoPrecio = [[TecladoNumerico alloc] initWithNibName:@"TecladoNumerico" bundle:nil];
    tecladoPrecio.delegate = self;
    _pvpLinea.inputView = tecladoPrecio.view;
    tecladoPrecio.textFieldAsignado = _pvpLinea;
    
    //Cargamos el último ticket.
    NSError *error;
	if (![[self miFRCTickets] performFetch:&error]) {
		//Error en la Carga
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}else{
        _ticketActivo = [Tickets alloc];
        
        //Comprobamos si existe algun ticket. Si no existe creamos automáticamente el primero
        if ([_miFRCTickets.fetchedObjects count] == 0){
            //No existe ningún ticket. Creamos el primero.
            [self crearNuevoTicket];
            
            //Regeneramos el FRC
            [[self miFRCTickets] performFetch:nil];
        }
        
        //Nos posicionamos en el último ticket
        [self actionCambiaTicketActivo:_btnCambiaTicketUltimo];
        
        _primeraCarga = @"N";
        
        //Inicializamos el programador de BackUp
        _programadorBackUp = [NSTimer scheduledTimerWithTimeInterval:3600 target:self selector:@selector(backupToDropbox:) userInfo:nil repeats:YES];
    }
}


- (void) keyboardWillHide:(NSNotification*)notification {
    //[_tableViewDetalles setFrame:CGRectMake(8, 723, 1010, 584)];
}

- (IBAction)actionInsertaTicket:(id)sendr {    
    //Creamos y grabamos un nuevo ticket siempre que el activo no esté vacio
    if (_miFRCTicketsDetalles.fetchedObjects.count > 0) {
        [self crearNuevoTicket];
        
        //Regeneramos el FRC
        [[self miFRCTickets] performFetch:nil];
        
        //Lo Mostramos
        [self actionCambiaTicketActivo:_btnCambiaTicketUltimo];
    }
    
    //Nos situamos para insertar las unidades
    [_txtCantidad becomeFirstResponder];
}

-(void) crearNuevoTicket{
    //Creamos el nuevo ticket
    Tickets *tmpNuevoTicket = [NSEntityDescription insertNewObjectForEntityForName:@"Tickets" inManagedObjectContext:_miMOC];
    
    //Número de Orden
    NSNumber *miNuevoNumeroOrden = [[[NSNumber alloc] initWithInt:[self calcularNuevoOrdenticket]] autorelease];
    tmpNuevoTicket.numeroOrden = miNuevoNumeroOrden;
    
    //Número de Ticket
    NSNumber *miNuevoNumeroTicket = [[[NSNumber alloc] initWithInt:[self calcularNuevoNumeroTicket:YES]] autorelease];    
    tmpNuevoTicket.numero = miNuevoNumeroTicket;
    
    //Fecha
    tmpNuevoTicket.fecha = [NSDate date];
    
    //Con Factura
    tmpNuevoTicket.conFactura = [NSNumber numberWithBool:YES];
    
    //Pago Visa
    tmpNuevoTicket.pagoVisa = [NSNumber numberWithBool:NO];
    
    //Porcentaje Descuento
    tmpNuevoTicket.tpcDTO = [NSDecimalNumber decimalNumberWithString:@"0.074"];
    
    //Porcentaje de IVA
    tmpNuevoTicket.tpcIVA = [NSDecimalNumber decimalNumberWithString:@"0.08"];
    
    //Suma de Importes
    tmpNuevoTicket.sumaImporteLineas = [NSDecimalNumber decimalNumberWithString:@"0.0"];   
    
    NSError *error = nil;
    if (![_miMOC save:&error]) {
        NSString *tmpMensaje = [error localizedDescription];
        UIAlertView *tmpAlerta = [[[UIAlertView alloc] initWithTitle: @"Error Creando Ticket" message: tmpMensaje delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil] autorelease];
        [tmpAlerta show];
    }
}   

- (void) crearNuevoDetalleTicket{
    //Solamente para el último ticket:
    //Comprobamos si existe alguna linea. En caso afirmativo comprobamos si la fecha del ticket coincide con la fecha actual.
    //En caso de que no coincida la tenemos que igualar al dia de hoy, ya que este ticket quedó abierto del día anterior y asignariamos
    //la venta a un día que no le corresponde
   
    NSIndexPath *indexActual = [_miFRCTickets indexPathForObject:_ticketActivo];
    if ([indexActual row] == [_miFRCTickets.fetchedObjects count] -1) {
        NSDate *hoy = [cajaHerramientas normalizaFecha:[NSDate date]];
        if ([_miFRCTicketsDetalles.fetchedObjects count] == 0){
            if ([hoy compare:_ticketActivo.fechaNormalizada] != NSOrderedSame){
                _ticketActivo.fecha = hoy;
                [_miMOC save:nil];
            }
        }
    }
    
    //Creamos el nuevo ticket
    TicketsDetalles *tmpTicketDetalle;
    tmpTicketDetalle = [NSEntityDescription insertNewObjectForEntityForName:@"TicketsDetalles" inManagedObjectContext:_miMOC];
    
    //Cantidad
    tmpTicketDetalle.cantidad = [cajaHerramientas enteroDesdeStringFormateado:_txtCantidad.text];
    
    //Articulo
    tmpTicketDetalle.articulo = _artLinea.text;
    
    //Precio
    tmpTicketDetalle.precio = [cajaHerramientas decimalDesdeStringFormateado:_pvpLinea.text];
    
    //Importe
    tmpTicketDetalle.importe = [cajaHerramientas decimalDesdeStringFormateado:_impLinea.text];
    
    //Relaciones
    tmpTicketDetalle.cabeceraTickets = _ticketActivo;
    NSMutableSet *newTicketDetalle = [_ticketActivo mutableSetValueForKey:@"detalles"];
    [newTicketDetalle addObject:tmpTicketDetalle];
    
    //Grabamos
    [_miMOC save:nil];
}


-(int)calcularNuevoOrdenticket{
    int tmpNuevoOrdenTicket = 1;
    
    NSFetchRequest *miFRNOT = [[[NSFetchRequest alloc] init] autorelease];
    
    NSEntityDescription *miEntidad = [NSEntityDescription entityForName:@"Tickets" inManagedObjectContext:_miMOC];
    [miFRNOT setEntity:miEntidad];
    
    NSSortDescriptor *orderDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"numeroOrden" ascending:NO] autorelease];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:orderDescriptor, nil];
    [miFRNOT setSortDescriptors:sortDescriptors];
    [sortDescriptors release];
    
    NSError *error;
    
    NSArray *tmpUltimoOrdenTicket = [_miMOC executeFetchRequest:miFRNOT error:&error];
    
    
    if ([tmpUltimoOrdenTicket count] > 0){
        Tickets *tmpUltimoTicketOrden = [tmpUltimoOrdenTicket objectAtIndex:0];
        
        tmpNuevoOrdenTicket = [tmpUltimoTicketOrden.numeroOrden intValue]+1;
        
    }
    
    return  tmpNuevoOrdenTicket;
}


- (int) calcularNuevoNumeroTicket: (BOOL) parCF{
    int tmpNuevoNumeroTicket = 1;
    
    NSFetchRequest *miFRNNT = [[[NSFetchRequest alloc] init] autorelease];
    [miFRNNT setFetchLimit:1];
    
    NSEntityDescription *miEntidad = [NSEntityDescription entityForName:@"Tickets" inManagedObjectContext:_miMOC];
    [miFRNNT setEntity:miEntidad];
    
    
    NSSortDescriptor *orderDescriptor = [[NSSortDescriptor alloc] initWithKey:@"numero" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:orderDescriptor, nil];
    [orderDescriptor release];
    [miFRNNT setSortDescriptors:sortDescriptors];
    [sortDescriptors release];
    
    NSPredicate *miPredicado = [NSPredicate predicateWithFormat:@"conFactura = %d AND numero <> -1", parCF];
    [miFRNNT setPredicate:miPredicado];
    
    
    NSError *error;
    
    NSArray *tmpUltimoNumeroTicket = [_miMOC executeFetchRequest:miFRNNT error:&error];
    
    
    if ([tmpUltimoNumeroTicket count] > 0){
        Tickets *tmpUltimoTicket = [tmpUltimoNumeroTicket objectAtIndex:0];
        
        tmpNuevoNumeroTicket = [tmpUltimoTicket.numero intValue]+1;
        
    }
    
    return tmpNuevoNumeroTicket;
}

-(NSFetchedResultsController *)miFRCTickets{
    NSFetchRequest *miFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *miEntidad = [NSEntityDescription entityForName:@"Tickets" inManagedObjectContext:_miMOC];
    [miFetchRequest setEntity:miEntidad];
    
    NSSortDescriptor *orderDescriptor = [[NSSortDescriptor alloc] initWithKey:@"numeroOrden" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:orderDescriptor, nil];
    [miFetchRequest setSortDescriptors:sortDescriptors];
    
    //Comprobamos si hay filtro o seleccionamos el último
    NSPredicate *miPredicado = [NSPredicate predicateWithFormat:@"fechaNormalizada = %@", [cajaHerramientas normalizaFecha:[NSDate date]]];
    [miFetchRequest setPredicate:miPredicado];
    
    NSFetchedResultsController *aFetchedResultsController = 
    [[NSFetchedResultsController alloc] initWithFetchRequest:miFetchRequest managedObjectContext:_miMOC
                                          sectionNameKeyPath:nil cacheName:@"Root"];
    
    self.miFRCTickets = aFetchedResultsController;

    [orderDescriptor release];
    [sortDescriptors release];
    [miFetchRequest release];
    [aFetchedResultsController release];
    
    return _miFRCTickets;
}

- (NSFetchedResultsController *)miFRCTicketsDetalles {
    if (_miFRCTicketsDetalles == nil) {
        NSFetchRequest *miFetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *miEntidad = [NSEntityDescription entityForName:@"TicketsDetalles" inManagedObjectContext:_miMOC];
        [miFetchRequest setEntity:miEntidad];
        
        NSSortDescriptor *orderDescriptor = [[NSSortDescriptor alloc] initWithKey:@"articulo" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:orderDescriptor, nil];
        [miFetchRequest setSortDescriptors:sortDescriptors];
        
        NSPredicate *miPredicado = [NSPredicate predicateWithFormat:@"cabeceraTickets = %@", _ticketActivo];
        [miFetchRequest setPredicate:miPredicado];
        
        NSFetchedResultsController *aFetchedResultsController = 
        [[NSFetchedResultsController alloc] initWithFetchRequest:miFetchRequest managedObjectContext:_miMOC
                                              sectionNameKeyPath:nil cacheName:@"Root"];
        
        self.miFRCTicketsDetalles = aFetchedResultsController;
        
        [sortDescriptors release];
        [orderDescriptor release];
        [aFetchedResultsController release];
        [miFetchRequest release];
    }
	
	return _miFRCTicketsDetalles;
} 


-(float)calculoImporteFinalTicket{
    float valorDevuelto;
    valorDevuelto = 0;
    if (_ticketActivo != nil) {
        NSFetchRequest *miFetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *miEntidad = [NSEntityDescription entityForName:@"TicketsDetalles" inManagedObjectContext:_miMOC];
        [miFetchRequest setEntity:miEntidad];
        
        // Especificamos que la request debe devolver dictionaries.
        [miFetchRequest setResultType:NSDictionaryResultType];
        
        // Expresión para el key path.
        NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"importe"];
        
        // Expresión para representar la suma de los importes
        NSExpression *sumExpression = [NSExpression expressionForFunction:@"sum:" arguments:[NSArray arrayWithObject:keyPathExpression]];
        
        // Creamos la expression description.
        NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
        [expressionDescription setName:@"sumImporte"];
        [expressionDescription setExpression:sumExpression];
        [expressionDescription setExpressionResultType:NSDecimalAttributeType];
        
        NSPredicate *miPredicado = [NSPredicate predicateWithFormat:@"cabeceraTickets = %@", _ticketActivo];
        [miFetchRequest setPredicate:miPredicado];
        
        // Set the request's properties to fetch just the property represented by the expressions.
        [miFetchRequest setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
        
        [expressionDescription release];
        
        // Ejecutamos la consulta.
        NSError *error = nil;
        NSArray *objects = [_miMOC executeFetchRequest:miFetchRequest error:&error];
        [miFetchRequest release];
        if (objects != nil) {
            if ([objects count] > 0) {
                valorDevuelto = [[[objects objectAtIndex:0] valueForKey:@"sumImporte"] floatValue];;
            }
        }
    }
    
    return valorDevuelto;
}

-(void)implementarKVO{
    //Iniciamos KVO
    [_ticketActivo addObserver:self forKeyPath:@"numero" options:NSKeyValueObservingOptionNew |
     NSKeyValueObservingOptionOld context:nil];
    [_ticketActivo addObserver:self forKeyPath:@"fecha" options:NSKeyValueObservingOptionNew |
     NSKeyValueObservingOptionOld context:nil];
    [_ticketActivo addObserver:self forKeyPath:@"conFactura" options:NSKeyValueObservingOptionNew |
     NSKeyValueObservingOptionOld context:nil];
    [_ticketActivo addObserver:self forKeyPath:@"pagoVisa" options:NSKeyValueObservingOptionNew |
     NSKeyValueObservingOptionOld context:nil];
    [_ticketActivo addObserver:self forKeyPath:@"importeFinal" options:NSKeyValueObservingOptionNew |
     NSKeyValueObservingOptionOld context:nil];
    [_ticketActivo addObserver:self forKeyPath:@"refrescarTicket" options:NSKeyValueObservingOptionNew |
     NSKeyValueObservingOptionOld context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if ([keyPath isEqual:@"refrescarTicket"]){
        _numeroOrden.text = [cajaHerramientas formateaEnteroAString:_ticketActivo.numeroOrden];
        _numeroTicket.text = [cajaHerramientas formateaEnteroAString:_ticketActivo.numero];
        _fechaTicket.text = [cajaHerramientas formateaFechaAString:_ticketActivo.fecha :FALSE];
        _switchCF.on = [_ticketActivo.conFactura boolValue];
        _switchVisa.on = [_ticketActivo.pagoVisa boolValue];
        _importeFinal.text = [cajaHerramientas formateaDecimalAString:_ticketActivo.importeFinal :true];
    } else if ([keyPath isEqual:@"numeroOrden"] &&  _primeraCarga == @"N"){
        _numeroOrden.text = [cajaHerramientas formateaEnteroAString:_ticketActivo.numero];
    } else if ([keyPath isEqual:@"numero"] &&  _primeraCarga == @"N"){
        _numeroTicket.text = [cajaHerramientas formateaEnteroAString:_ticketActivo.numero];
    } else if ([keyPath isEqual:@"fecha"] &&  _primeraCarga == @"N") {
        _fechaTicket.text = [cajaHerramientas formateaFechaAString:_ticketActivo.fecha :FALSE];
    } else if ([keyPath isEqual:@"conFactura"] &&  _primeraCarga == @"N") {
        //Modificamos el UISwitch
        _switchCF.on = [_ticketActivo.conFactura boolValue];
        
        //Al cambiar el tipo del Ticket tenemos que recalcular su nuevo nº
        _ticketActivo.numero = [NSNumber numberWithInt:-1];
        NSNumber *miNuevoNumeroTicket = [[[NSNumber alloc] initWithInt:[self calcularNuevoNumeroTicket:_switchCF.on]] autorelease];    
        _ticketActivo.numero = miNuevoNumeroTicket;
        
        //Aplicamos una animación
        if ([_ticketActivo.conFactura boolValue]) {
            [cajaHerramientas aplicarTransicionLayer:_numeroTicket.layer :kCATransitionPush :kCATransitionFromLeft];
        }else{
            [cajaHerramientas aplicarTransicionLayer:_numeroTicket.layer :kCATransitionPush :kCATransitionFromRight];
        }
        
    }else if ([keyPath isEqual:@"pagoVisa"] &&  _primeraCarga == @"N") {
        _switchVisa.on = [_ticketActivo.pagoVisa boolValue];
    }else if ([keyPath isEqual:@"importeFinal"] &&  _primeraCarga == @"N") {
        _importeFinal.text = [cajaHerramientas formateaDecimalAString:_ticketActivo.importeFinal :TRUE];
    }
}


-(IBAction)actionCambiaTicketActivo:(id)sender{
    
    if (_ticketActivo != nil) {
        //Calculamos las nueva posición en función del número de fila en la que nos encontramos
        int rowActual = [[_miFRCTickets indexPathForObject:_ticketActivo] row];
        if (sender == _btnCambiaTicketAnterior) {
            //Atrás
            rowActual = rowActual - 1;
        } else{
            if (sender == _btnCambiaTicketSiguiente) {
                //Adelante
                rowActual = rowActual + 1;
            }else{
                if (sender == _btnCambiaTicketUltimo) {
                    //Final
                    rowActual = [_miFRCTickets.fetchedObjects count] - 1;
                }else{
                    //Comienzo
                    rowActual = 0;
                }
            }
        }
        
        if (rowActual >= 0 && rowActual < [_miFRCTickets.fetchedObjects count]) {
            //--------------------------------------------------------------------------------------------------------------------
            //Actualizamos el indicardor de Ticket Activo
            _indicadorTicketActivo.text =  [NSString stringWithFormat: @"%d / %d", rowActual + 1, [_miFRCTickets.fetchedObjects count]];
            
            //Asignamos el nuevo ticket activo
            _ticketActivo = nil;
            _ticketActivo = (Tickets*)[_miFRCTickets objectAtIndexPath:[NSIndexPath indexPathForRow:rowActual inSection:0]];
            
            //Implementamos KVO
            [self implementarKVO];
            
            //Refrescamos en Pantalla los valores del Nuevo Ticket
            _primeraCarga = @"S";
            _ticketActivo.refrescarTicket = [NSNumber numberWithBool:YES];
            _primeraCarga = @"N";
            
            //Aplicamos una animación
            [cajaHerramientas aplicarTransicionLayer:_vistaSuperior.layer :kCATransitionPush :kCATransitionFromTop];
  
            //Vaciamos las líneas de detalle
            self.miFRCTicketsDetalles = nil;
            [[self miFRCTicketsDetalles] performFetch:nil];
            _miFRCTicketsDetalles.delegate = self;
            
            //Volvemos a recargar las lineas de detalle
            [[self tableViewDetalles] reloadData];
            
            //Vaciamos los campos de inserción
            _txtCantidad.text = @"0"; _txtCantidad.placeholder = @"";
            _artLinea.text = @""; _artLinea.placeholder = @"";
            _pvpLinea.text = @"0,00"; _pvpLinea.placeholder = @"";
            _impLinea.text = @"0,00"; _impLinea.placeholder = @"";
        }
    }
}

-(IBAction)actionInsertaLinea:(id)sendr{
    //Hacemos un truquillo para forzar a que se recalcule la línea y nos colocamos en las unidades
    if (activeField != nil) [self textFieldDidEndEditing: activeField];
    
    //Grabamos la nueva línea del ticket
    [self crearNuevoDetalleTicket];
    
    //Nos situamos en unidades para seguir añadiendo
    [_txtCantidad becomeFirstResponder];
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
    
    //Si el campo tiene algún valor ponemos ese valor como PlaceHolder
    if ([textField.text length] > 0){
        //El textField tiene contenido, lo ponemos como PlaceHolder y, posteriormente, ponemos el Contenido a 0
        textField.placeholder = textField.text;
        textField.text = @"";
    }else{
        //El textField viene vacio, dependiendo del textField ponemos el PlaceHolder de una u otra forma
        if (textField == _txtCantidad){
            textField.placeholder = @"0";
        }
        if (textField == _pvpLinea) {
            textField.placeholder = @"0,00";
        }
    }
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //Cuando dejamos de editar el campo hay que tener en cuenta si trae valor, en caso negativo le ponemos el del PlaceHolder a excepción del artículo
    activeField = nil;
    bool calculamosImporte = TRUE;
    bool aplicamosDescuento = FALSE;
            
    //Unidades
    if (textField == _txtCantidad) {
        if ([textField.text length] == 0) {
            textField.text = textField.placeholder;
        }else{
            //Comprobamos si tenemos el símbolo del %. En caso afirmativo lo tratamos de una manera especial ya que se trata de un descuento
            NSRange range = [_txtCantidad.text rangeOfString:@"%"];
            
            //Leemos el importe introducido
            NSNumber *tmpUdsLinea = [cajaHerramientas enteroDesdeStringFormateado:_txtCantidad.text];
            
            if(range.length  == 0){
                //SIN Descuento
                _txtCantidad.text = [cajaHerramientas formateaEnteroAString:tmpUdsLinea];
            }else{
                //CON Descuento. Lo Calculamos.
                float sumaImportes = [_ticketActivo.sumaImporteLineas floatValue];
                float tpcAplicar = [tmpUdsLinea floatValue];
                if (tpcAplicar > 100.0f){
                    tpcAplicar = 100.0f;
                    tmpUdsLinea = [NSNumber numberWithFloat:tpcAplicar];
                }
                float dtoAplicar = ((tpcAplicar / 100.0f) * sumaImportes) * -1.0f;
                
                //Actualizamos los txt
                _txtCantidad.text = @"1";
                _artLinea.text = [NSString stringWithFormat: @"→ Descuento del %@%% sobre %@", tmpUdsLinea, _importeFinal.text];
                NSDecimalNumber *dtoAplicarDec =[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", dtoAplicar]];
                _pvpLinea.text = [cajaHerramientas formateaDecimalAString:dtoAplicarDec :FALSE];
                
                aplicamosDescuento = TRUE;
            }
            
        }
    }
    
    //Artículo
    if (textField == _artLinea) {
        calculamosImporte = FALSE;
        if ([textField.text length] == 0) {
            textField.text = textField.placeholder;
        }
    }
    
    //Precio
    if (textField == _pvpLinea) {
        if ([textField.text length] == 0) {
            textField.text = textField.placeholder;
        }else{
            NSDecimalNumber *tmpPvpLinea = [cajaHerramientas decimalDesdeStringFormateado:_pvpLinea.text];
            textField.text = [cajaHerramientas formateaDecimalAString:tmpPvpLinea :FALSE];
        }
    }    
    
    //Calculamos el importe
    if (calculamosImporte == TRUE) {
        NSDecimalNumber *tmpUdsLinea = [cajaHerramientas decimalDesdeStringFormateado:_txtCantidad.text];
        NSDecimalNumber *tmpPvpLinea = [cajaHerramientas decimalDesdeStringFormateado:_pvpLinea.text];
        
        NSDecimalNumber *tmpImporteLinea = [tmpUdsLinea decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithDecimal:[tmpPvpLinea decimalValue]]];
        
        _impLinea.text = [cajaHerramientas formateaDecimalAString:tmpImporteLinea :FALSE];
        
    }
    
    //Acciones adicionales posteriores al descuento
    if (aplicamosDescuento == TRUE) {
        //Añadimos las línea de detalles
        [_btnInsertaLinea sendActionsForControlEvents:UIControlEventTouchUpInside];
        
        //Vaciamos los campos de inserción
        _txtCantidad.text = @"0"; _txtCantidad.placeholder = @"";
        _artLinea.text = @""; _artLinea.placeholder = @"";
        _pvpLinea.text = @"0,00"; _pvpLinea.placeholder = @"";
        _impLinea.text = @"0,00"; _impLinea.placeholder = @"";
    }
}
 

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [activeField resignFirstResponder];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField==_txtCantidad)
    {
        [_artLinea becomeFirstResponder];
    }
    else if (textField==_artLinea)
    {
        [_pvpLinea becomeFirstResponder];
    }
    else if (textField==_pvpLinea)
    {
        [_btnInsertaLinea sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    
    return NO;

}

-(void) edicionFinalizada:(UITextField *)parTextField{
    [self textFieldShouldReturn:parTextField];
}


-(IBAction)cambioCF:(id)sendr{
    _ticketActivo.conFactura = [NSNumber numberWithBool:_switchCF.on];
    
    //Guardamos el cambio
    [_miMOC save:nil];
}

-(IBAction)cambioVisa:(id)sendr{
    _ticketActivo.pagoVisa = [NSNumber numberWithBool:_switchVisa.on];
    
    NSError *error = nil;
    if (![_miMOC save:&error]) {
        // Handle the error...
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationLandscapeRight || interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        return YES;
    }else{
        
        return NO;  
    }
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload
{
    _miFRCTickets = nil;
    _miFRCTicketsDetalles = nil;
    
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return [[[self miFRCTicketsDetalles] sections] count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[[self miFRCTicketsDetalles] fetchedObjects] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *MyIdentifier = @"MyIdentifier";
    MyIdentifier = @"tblCellView";
    
    TicketsDetallesCell *cell = (TicketsDetallesCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if(cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"TicketsDetallesCell" owner:self options:nil];
        cell = _tblCell;
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

-(void)configureCell:(UITableViewCell *) cell atIndexPath:(NSIndexPath *)indexPath{
    TicketsDetalles *tmpDetalle = (TicketsDetalles*)[_miFRCTicketsDetalles objectAtIndexPath:[NSIndexPath indexPathForRow:[indexPath row] inSection:0]];
    
    UIColor *colorCeldas;
    if ([tmpDetalle.importe floatValue] >= 0){
        colorCeldas = [UIColor blackColor];
    }else{
        colorCeldas = [UIColor redColor];
    }
    
    UILabel *lblCantidad = (UILabel *) [cell viewWithTag:1];
    lblCantidad.text = [cajaHerramientas formateaEnteroAString:tmpDetalle.cantidad];
    CGRect labelPosition = lblCantidad.frame;
    labelPosition.origin.x = _txtCantidad.frame.origin.x - 8;
    labelPosition.size.width = _txtCantidad.frame.size.width;
    lblCantidad.frame = labelPosition;
    lblCantidad.textColor = colorCeldas;
    
    UILabel *lblArticulo = (UILabel *) [cell viewWithTag:2];
    lblArticulo.text = tmpDetalle.articulo;
    labelPosition = lblArticulo.frame;
    labelPosition.origin.x = _artLinea.frame.origin.x - 8;
    labelPosition.size.width = _artLinea.frame.size.width;
    lblArticulo.frame = labelPosition;
    lblArticulo.textColor = colorCeldas;
    
    UILabel *lblPrecio = (UILabel *) [cell viewWithTag:3];
    lblPrecio.text = [cajaHerramientas formateaDecimalAString:tmpDetalle.precio :FALSE];
    labelPosition = lblPrecio.frame;
    labelPosition.origin.x = _pvpLinea.frame.origin.x - 14;
    labelPosition.size.width = _pvpLinea.frame.size.width;
    lblPrecio.frame = labelPosition;
    lblPrecio.textColor = colorCeldas;
    
    UILabel *lblImporte = (UILabel *) [cell viewWithTag:4];
    lblImporte.text = [cajaHerramientas formateaDecimalAString:tmpDetalle.importe :FALSE];
    labelPosition = lblImporte.frame;
    labelPosition.origin.x = _impLinea.frame.origin.x - 14;
    labelPosition.size.width = _impLinea.frame.size.width;
    lblImporte.frame = labelPosition;
    lblImporte.textColor = colorCeldas;
}   


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(![_popOverController isPopoverVisible]){
        // Popover is not visible
        _editDetailView = [[EditDetailViewController alloc] initWithNibName:@"EditDetailViewController" bundle:nil];
        
        _detalleAEditar = (TicketsDetalles*)[_miFRCTicketsDetalles objectAtIndexPath:[NSIndexPath indexPathForRow:[indexPath row] inSection:0]];
        
        _editDetailView.detalleSeleccionado = _detalleAEditar;
        
        _popOverController = [[UIPopoverController alloc] initWithContentViewController:_editDetailView];
    
        
        CGRect selectedRect = [tableView rectForRowAtIndexPath:indexPath];
        
        //Comprobamos si la fila seleccionada está oculta por el teclado. En ese caso hacemos scrool hasta que sea visible
        if (selectedRect.origin.y >= 260) {
            CGRect tmpRect = _tableViewDetalles.frame;
            tmpRect.size.height = heightReducidaTableViewDetalles;
            
            
            [_tableViewDetalles setFrame:tmpRect];
            [_tableViewDetalles scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:TRUE];
            selectedRect.origin.y = 220;
        }
        
        //Dimensionamos el Popover
        [_popOverController setPopoverContentSize:CGSizeMake(selectedRect.size.width, selectedRect.size.height) animated:YES];
        
        //Establecemos su ubicación
        selectedRect.origin.y = selectedRect.origin.y + 160;
        [_popOverController presentPopoverFromRect:selectedRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
        
        [_editDetailView setPopover:_popOverController];
        

        //Dimensionamos y colocamos los controles de edición
        CGRect controlPosition = _editDetailView.txtCantidad.frame;
        controlPosition.origin.x = _txtCantidad.frame.origin.x;
        controlPosition.size.width = _txtCantidad.frame.size.width;
        _editDetailView.txtCantidad.frame = controlPosition;
        
        controlPosition = _editDetailView.txtArticulo.frame;
        controlPosition.origin.x = _artLinea.frame.origin.x;
        controlPosition.size.width = _artLinea.frame.size.width;
        _editDetailView.txtArticulo.frame = controlPosition;        
        
        controlPosition = _editDetailView.txtPrecio.frame;
        controlPosition.origin.x = _pvpLinea.frame.origin.x;
        controlPosition.size.width = _pvpLinea.frame.size.width;
        _editDetailView.txtPrecio.frame = controlPosition; 
        
        controlPosition = _editDetailView.txtImporte.frame;
        controlPosition.origin.x = _impLinea.frame.origin.x;
        controlPosition.size.width = _impLinea.frame.size.width;
        _editDetailView.txtImporte.frame = controlPosition;
        
        controlPosition = _editDetailView.btnActualizaDetalleSeleccionado.frame;
        controlPosition.origin.x = _btnInsertaLinea.frame.origin.x - 35;
        _editDetailView.btnActualizaDetalleSeleccionado.frame = controlPosition; 
        
        _popOverController.delegate = self;
    }else{
        [_popOverController dismissPopoverAnimated:YES];
    }
}


- (void)popoverControllerDidDismissPopover: (UIPopoverController *)popoverController {    
    //Salvamos los cambios
    NSError *error = nil;
    if (![_miMOC save:&error]) {
        NSString *tmpMensaje = [error localizedDescription];
        UIAlertView *tmpAlerta = [[[UIAlertView alloc] initWithTitle: @"Error Actualizando Detalle del Ticket" message: tmpMensaje delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil] autorelease];
        [tmpAlerta show];
    } else{
        //Edición finalizada. Sumamos el importe del detalle al importe del Ticket
        _ticketActivo.sumaImporteLineas = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", [self calculoImporteFinalTicket]]];
        
        //Volvemos a guardar los cambios.
        if (![_miMOC save:&error]) {
            NSString *tmpMensaje = [error localizedDescription];
            UIAlertView *tmpAlerta = [[[UIAlertView alloc] initWithTitle: @"Error Actualizando Importe Final del Ticket" message: tmpMensaje delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil] autorelease];
            [tmpAlerta show];
        }
        
        //Si se ha redimensionado el TableView, lo dejamos en su estado original
        if (_tableViewDetalles.frame.size.height != heightOriginalTableViewDetalles) {
            CGRect tmpRect = _tableViewDetalles.frame;
            tmpRect.size.height = heightOriginalTableViewDetalles;
            [_tableViewDetalles setFrame:tmpRect];
        }
    }
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{    
    //Si borramos una fila, tenemos que borrar el objeto asociado
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {          
        //Borramos el objeto
        [_miMOC deleteObject:[_miFRCTicketsDetalles objectAtIndexPath:indexPath]];
        
        //Guardamos los cambios
        NSError *error = nil;
        if (![_miMOC save:&error]) {
            NSString *tmpMensaje = [error localizedDescription];
            UIAlertView *tmpAlerta = [[[UIAlertView alloc] initWithTitle: @"Error Eliminando Detalle del Ticket" message: tmpMensaje delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil] autorelease];
            [tmpAlerta show];
        } else{
            //Edición finalizada. Sumamos el importe del detalle al importe del Ticket
            _ticketActivo.sumaImporteLineas = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", [self calculoImporteFinalTicket]]];
            
            //Volvemos a guardar los cambios.
            if (![_miMOC save:&error]) {
                NSString *tmpMensaje = [error localizedDescription];
                UIAlertView *tmpAlerta = [[[UIAlertView alloc] initWithTitle: @"Error Actualizando Importe Final del Ticket" message: tmpMensaje delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil] autorelease];
                [tmpAlerta show];
            }
        }
    }
}


#pragma mark NSFetchedResultsControllerDelegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    //[self.tableViewDetalles beginUpdates];
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    //[self.tableViewDetalles endUpdates];
}


-(void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type{
    
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:sectionIndex];
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [[self tableViewDetalles] insertSections:set withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [[self tableViewDetalles] deleteSections:set withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

-(void) controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath{
    
    UITableView *tv = [self tableViewDetalles];
    

    switch (type) {
        case NSFetchedResultsChangeInsert:
            
            [tv insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            NSError * error = nil;
            if (![_miMOC save:&error]) {
                NSString *tmpMensaje = [error localizedDescription];
                UIAlertView *tmpAlerta = [[[UIAlertView alloc] initWithTitle: @"Error Añadiendo Detalle del Ticket" message: tmpMensaje delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil] autorelease];
                [tmpAlerta show];
            } else{
                //Edición finalizada. Sumamos el importe del detalle al importe del Ticket
                _ticketActivo.sumaImporteLineas = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", [self calculoImporteFinalTicket]]];
                
                //Volvemos a guardar los cambios.
                if (![_miMOC save:&error]) {
                    NSString *tmpMensaje = [error localizedDescription];
                    UIAlertView *tmpAlerta = [[[UIAlertView alloc] initWithTitle: @"Error Actualizando Importe Final del Ticket" message: tmpMensaje delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil] autorelease];
                    [tmpAlerta show];
                }
            }
            
            break;
        case NSFetchedResultsChangeDelete:
            [tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tv cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tv insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
}


-(IBAction)backupToDropbox:(id)sender{
    if (![[DBSession sharedSession]isLinked]) {
		DBLoginController *controller = [[DBLoginController new]autorelease];
		controller.delegate = self;
		[controller presentFromController:self];
	}
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"TPV.sqlite"];
    
    UIDevice *tmpDevice = [UIDevice currentDevice];
    NSString *deviceName = [[tmpDevice name] stringByAppendingString:@" "];
    
    NSString *fb = [[cajaHerramientas formateaFechaAString:[NSDate date] :FALSE] stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSString *uf = [deviceName stringByAppendingString:[fb stringByAppendingString:@" TPV.sqlite"]];
    [self.restClient uploadFile:uf toPath:@"/BackUps" fromPath:path];
}

#pragma mark -
#pragma mark Dropbox Delegate


- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata *)metadata {
    
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error{
    
	NSLog(@"Error, %@, \n, %@", [error localizedDescription], [error userInfo]);
	
}

- (DBRestClient *)restClient {
    
	if (restClient == nil) {
        
		restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
		restClient.delegate = self;
	}
    
	return restClient;
}


- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)srcPath{
	/*
	NSString *filename = [[srcPath pathComponents] lastObject];
	
	NSString *msg = [NSString stringWithFormat:@"Uploaded File: %@",filename];
	[[[[UIAlertView alloc]initWithTitle:@"Success" 
								message:msg
							   delegate:nil 
					  cancelButtonTitle:@"OK" 
					  otherButtonTitles:nil]autorelease]show];
    */
}

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)destPath{
    
    
}

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error{
	/*
	NSLog(@"loadFileFailedWithError, %@, %@.", [error localizedDescription], [error userInfo]);
	
	NSString *errorMsg = [NSString stringWithFormat:@"%@. %@",[error localizedDescription],[error userInfo]];
	
	[[[[UIAlertView alloc]initWithTitle:@"Error in Loading Files" 
								message:errorMsg 
							   delegate:nil
					  cancelButtonTitle:@"OK" 
					  otherButtonTitles:nil]autorelease]show];
    */
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error{
    /*
	NSLog(@"uploadFileFailedWithError, %@, %@.", [error localizedDescription], [error userInfo]);
	
	NSString *errorMsg = [NSString stringWithFormat:@"%@. %@",[error localizedDescription],[error userInfo]];
	
	[[[[UIAlertView alloc]initWithTitle:@"Error in Uploading Files" 
								message:errorMsg 
							   delegate:nil
					  cancelButtonTitle:@"OK" 
					  otherButtonTitles:nil]autorelease]show];
     */
}

- (void)loginControllerDidLogin:(DBLoginController*)controller {
    
}

- (void)loginControllerDidCancel:(DBLoginController*)controller {
	
}
- (void)dealloc
{
    [_vistaSuperior release];
    [cajaHerramientas release];
    [_editDetailView release];
    [_popOverController release];
    [_ticketActivo release];
    [_tableViewDetalles release];
    [_tblCell release];
    [_miMOC release];
    [_miFRCTickets release];
    [_miFRCTicketsDetalles release];
    [_numeroOrden release];
    [_numeroTicket release];
    [_fechaTicket release];
    [_txtCantidad release];
    [_artLinea release];
    [_pvpLinea release];
    [_impLinea release];
    [_switchVisa release];
    [_switchCF release];
    [_importeFinal release];
    [_primeraCarga release];
    [_detalleAEditar release];
    [_btnCambiaTicketAnterior release];
    [_btnCambiaTicketSiguiente release];
    [_btnCambiaTicketUltimo release];
    [_btnCambiaTicketPrimero release];
    [_btnInsertaLinea release];
    [_indicadorTicketActivo release];
    [_programadorBackUp release];
    [super dealloc];
}
@end
