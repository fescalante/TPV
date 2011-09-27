//
//  SecondViewController.m
//  TPV
//
//  Created by Flavio on 12/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SecondViewController.h"
#import "TPVAppDelegate.h"
#import "Tickets.h"
#import "ResumenVentas.h"
#import "ResumenVentasCell.h"
#import <QuartzCore/QuartzCore.h>


@implementation SecondViewController

@synthesize miMOC=_miMOC;
@synthesize miFRCTickets=_miFRCTickets;
@synthesize tableResumenViewTickets=_tableViewResumenTickets;
@synthesize arrayDetalles=_arrayDetalles, filaTotales=_filaTotales;
@synthesize tblCell=_tblCell;
@synthesize vistaDetallada=_vistaDetallada;
@synthesize barraNavegacion=_barraNavegacion;
@synthesize btnResumenDiario=_btnResumenDiario, btnImprimirParteDiarioCaja=_btnImprimirParteDiarioCaja;
@synthesize lblColumna1=_lblColumna1, lblColumna2=_lblColumna2, lblColumna3=_lblColumna3, lblColumna4=_lblColumna4, lblColumna5=_lblColumna5, lblColumna6=_lblColumna6;
@synthesize lblColPie1=_lblColPie1, lblColPie2=_lblColPie2, lblColPie3=_lblColPie3, lblColPie4=_lblColPie4, lblColPie5=_lblColPie5, lblColPie6=_lblColPie6;
@synthesize imgVisa=_imgVisa, imgEuroCF=_imgEuroCF, imgEuroSF=_imgEuroSF, imgEuroVisaCF=_imgEuroVisaCF;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Iniciamos las utilidades
    cajaHerramientas = [[Utilidades alloc] init];
}

-(IBAction)activarResumenDiario:(id)sender{
    _vistaDetallada = nil;
    [self viewWillAppear:TRUE];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:TRUE];
    
    //Implementamos KVO a este objeto para controlar si la vista está en modo resumen o detallada
    _vistaDetallada = [ResumenVentas alloc];
    [_vistaDetallada addObserver:self forKeyPath:@"detallado" options:NSKeyValueObservingOptionNew |
     NSKeyValueObservingOptionOld context:nil];
    
    //Forzamos un refresco del Resumen
    _vistaDetallada.detallado = [NSNumber numberWithBool:NO];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
     if ([keyPath isEqual:@"detallado"]){
         //Refrescamos los datos del resumen de ventas
         [self performSelector:(@selector(refrescarResumenVentas))];
         
         //Cambios en los controles
         NSString *tituloBarra;
         if ([_vistaDetallada.detallado boolValue]) {
             tituloBarra =  [@"Detalle de Ventas del día " stringByAppendingString:[cajaHerramientas formateaFechaAString:filtroFechaInicio:FALSE]];
             _lblColumna1.text = @"Nº Ticket";
             _lblColumna2.text = @"Hora";
             _lblColumna3.text = @"Tipo";
             _lblColumna4.text = @"";
             _lblColumna5.text = @"";
             _lblColumna6.text = @"IMPORTE";
             
             _imgVisa.hidden = TRUE;
             _imgEuroCF.hidden = TRUE;
             _imgEuroSF.hidden = TRUE;
             _imgEuroVisaCF.hidden = TRUE;
             
             _lblColPie1.text = @"";
             _lblColPie2.text = @"";
             _lblColPie3.text = @"TOTALES";
             _lblColPie4.text = @"";
             _lblColPie5.text = @"";
             _lblColPie6.text = [cajaHerramientas formateaDecimalAString:_filaTotales.importeFinal :FALSE];
             
             _btnResumenDiario.enabled = TRUE;
             _btnImprimirParteDiarioCaja.enabled = TRUE;
         }else{
             tituloBarra = [[[@"Resumen Diario de Ventas: " stringByAppendingString:[cajaHerramientas formateaFechaAString:filtroFechaInicio :FALSE]] stringByAppendingString:@" al "] stringByAppendingString:[cajaHerramientas formateaFechaAString:filtroFechaFin :FALSE]];
             _lblColumna1.text = @"FECHA";
             _lblColumna2.text = @"";
             _lblColumna3.text = @"";
             _lblColumna4.text = @"";
             _lblColumna5.text = @"";
             _lblColumna6.text = @"TOTAL";
             
             _imgVisa.hidden = FALSE;
             _imgEuroCF.hidden = FALSE;
             _imgEuroSF.hidden = FALSE;
             _imgEuroVisaCF.hidden = FALSE;
             
             _lblColPie1.text = @"TOTALES";
             _lblColPie2.text = [cajaHerramientas formateaDecimalAString:_filaTotales.importeB :FALSE];
             _lblColPie3.text = [cajaHerramientas formateaDecimalAString:_filaTotales.importeA :FALSE];
             _lblColPie4.text = [cajaHerramientas formateaDecimalAString:_filaTotales.importeVisa :FALSE];
             _lblColPie5.text = [cajaHerramientas formateaDecimalAString:_filaTotales.importeFinalA :FALSE];
             _lblColPie6.text = [cajaHerramientas formateaDecimalAString:_filaTotales.importeFinal :FALSE];
                                 
             _btnResumenDiario.enabled = FALSE;
             _btnImprimirParteDiarioCaja.enabled = FALSE;
         }
        _barraNavegacion.topItem.title = tituloBarra;
         
         //Recargamos el TableView
         [self performSelector:(@selector(reloadTableView:)) withObject:(_tableViewResumenTickets) afterDelay:0.5];
         
         //Aplicamos una animación
         [cajaHerramientas aplicarTransicionLayer:_tableViewResumenTickets.layer :kCATransitionPush :kCATransitionFromBottom];
     }
}


-(void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:TRUE];
    
    //Quitamos KVO
    [_vistaDetallada removeObserver:self forKeyPath:@"detallado"];
    
    //Anulamos la vista detallada
    _vistaDetallada = nil;
}

-(void) reloadTableView:(UITableView *) tableView{
    [_tableViewResumenTickets reloadData];
}

-(void) refrescarResumenVentas{
    NSError *error;
    NSMutableArray *tmpArrayResumenTickets = [[[NSMutableArray alloc] init] autorelease];
    ResumenVentas *tmpFilaTotales = [[[ResumenVentas alloc] init] autorelease];
    
    if (![_vistaDetallada.detallado boolValue]){
        //Vista de Resumen del último mes
        NSDate *hoy = [NSDate date];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *weekdayComponents = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:hoy];
        [weekdayComponents setHour:8];
        [weekdayComponents setMinute:0];
        [weekdayComponents setSecond:0];
        
        //Fecha Inicio
        [weekdayComponents setDay:1];
        filtroFechaInicio = [gregorian dateFromComponents:weekdayComponents];
        
        //Fecha Fin
        NSRange diasDelMes = [gregorian rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:hoy];
        [weekdayComponents setDay:diasDelMes.length];
        filtroFechaFin = [gregorian dateFromComponents:weekdayComponents];
        
        [gregorian release];        

        _miFRCTickets = nil;
        if (![[self miFRCTickets] performFetch:&error]) {
            //Error en la Carga
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            exit(-1);  // Fail
        }
       
        //Creamos un array con todas las fechas de los tickets, sin repetir
        NSDate *tmpFecha = [[[NSDate alloc] init] autorelease];
        NSMutableArray *tmpArrayFechas = [[[NSMutableArray alloc] init] autorelease];
        for (Tickets *tmpTicket in [_miFRCTickets fetchedObjects]) {
            if ([tmpFecha compare:tmpTicket.fechaNormalizada] != NSOrderedSame){
                tmpFecha = tmpTicket.fechaNormalizada;
                [tmpArrayFechas addObject:tmpTicket];
            }
        }
        
        
        NSDate *tmpFiltroFechaInicio = filtroFechaInicio;
        NSDate *tmpFiltroFechaFin = filtroFechaFin;
        
        //Recorremos el array anterior sacando totales por fecha
        for (Tickets *tmpFechaMaestra in tmpArrayFechas){
            filtroFechaInicio = tmpFechaMaestra.fechaNormalizada;
            filtroFechaFin = filtroFechaInicio;
            _miFRCTickets = nil;
            if ([[self miFRCTickets] performFetch:&error]) {
                ResumenVentas *resumenVentas = [[ResumenVentas alloc] init];
                resumenVentas.fecha = filtroFechaInicio;
                for (Tickets *tmpTicket in [_miFRCTickets fetchedObjects]) {
                    //Acumulamos importes
                    resumenVentas.importeFinal = [resumenVentas.importeFinal decimalNumberByAdding:tmpTicket.importeFinal];
                    if ([tmpTicket.pagoVisa boolValue] == TRUE) {
                        resumenVentas.importeVisa = [resumenVentas.importeVisa decimalNumberByAdding:tmpTicket.importeFinal];
                    }else{
                        if ([tmpTicket.conFactura boolValue] == TRUE) {
                            resumenVentas.importeA = [resumenVentas.importeA decimalNumberByAdding:tmpTicket.importeFinal];
                        }else{
                            resumenVentas.importeB = [resumenVentas.importeB decimalNumberByAdding:tmpTicket.importeFinal];
                        }
                    }
                }
                resumenVentas.importeFinalA = [resumenVentas.importeA decimalNumberByAdding:resumenVentas.importeVisa];
                [tmpArrayResumenTickets addObject:resumenVentas];
                
                //Acumulo totales
                tmpFilaTotales.importeA = [tmpFilaTotales.importeA decimalNumberByAdding:resumenVentas.importeA];
                tmpFilaTotales.importeVisa = [tmpFilaTotales.importeVisa decimalNumberByAdding:resumenVentas.importeVisa];
                tmpFilaTotales.importeB = [tmpFilaTotales.importeB decimalNumberByAdding:resumenVentas.importeB];
                tmpFilaTotales.importeFinalA = [tmpFilaTotales.importeFinalA decimalNumberByAdding:resumenVentas.importeFinalA];
                tmpFilaTotales.importeFinal = [tmpFilaTotales.importeFinal decimalNumberByAdding:resumenVentas.importeFinal];
                
                [resumenVentas release];
            }
        }
        
        filtroFechaInicio = tmpFiltroFechaInicio;
        filtroFechaFin = tmpFiltroFechaFin;
    }else{
        //Vista Detallada
        filtroFechaInicio = _vistaDetallada.fecha;
        filtroFechaFin = _vistaDetallada.fecha;
        _miFRCTickets = nil;
        NSError *error;
        if (![[self miFRCTickets] performFetch:&error]) {
            //Error en la Carga
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            exit(-1);  // Fail
        }
        
        //Cargamos el Array con los registros seleccionados
        for (Tickets *tmpTicket in [_miFRCTickets fetchedObjects]) {
            ResumenVentas *resumenVentas = [[ResumenVentas alloc] init];
            
            resumenVentas.numero = tmpTicket.numero;
            resumenVentas.fecha = tmpTicket.fecha;
            resumenVentas.importeFinal = tmpTicket.importeFinal;
            
            if ([tmpTicket.pagoVisa boolValue] == TRUE) {
                resumenVentas.tipoDetalle = @"CFV";
            }else{
                if ([tmpTicket.conFactura boolValue] == TRUE) {
                    resumenVentas.tipoDetalle = @"CFM";
                }else{
                    resumenVentas.tipoDetalle = @"SF";
                }
            }
            
            [tmpArrayResumenTickets addObject:resumenVentas];
            
            tmpFilaTotales.fecha = tmpTicket.fecha;
            tmpFilaTotales.importeFinal = [tmpFilaTotales.importeFinal decimalNumberByAdding:tmpTicket.importeFinal];
            
            [resumenVentas release];
        }
        
    }
    
    self.filaTotales = tmpFilaTotales;
    self.arrayDetalles = tmpArrayResumenTickets;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_arrayDetalles == nil) {
        return 0;
    }else{
        return [_arrayDetalles count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *MyIdentifier = @"MyIdentifier";
    MyIdentifier = @"tblCellView";
    
    ResumenVentasCell *cell = (ResumenVentasCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if(cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"ResumenVentasCell" owner:self options:nil];
        cell = _tblCell;
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

-(void)configureCell:(UITableViewCell *) cell atIndexPath:(NSIndexPath *)indexPath{
    ResumenVentas *resumenVentas = (ResumenVentas*)[_arrayDetalles objectAtIndex:[indexPath row]];
    
    UILabel *lblCol1 = (UILabel *) [cell viewWithTag:1];
    if ([_vistaDetallada.detallado boolValue]) {
        lblCol1.text = [cajaHerramientas formateaEnteroAString:resumenVentas.numero];
    }else{
        lblCol1.text = [cajaHerramientas formateaFechaAString:resumenVentas.fecha :FALSE];
    }
    CGRect labelPosition = lblCol1.frame;
    labelPosition.origin.x = _lblColumna1.frame.origin.x - 8;
    labelPosition.size.width = _lblColumna1.frame.size.width;
    lblCol1.frame = labelPosition;
    
    UILabel *lblCol2 = (UILabel *) [cell viewWithTag:2];
    if ([_vistaDetallada.detallado boolValue]) {
        lblCol2.text = [cajaHerramientas formateaFechaAString:resumenVentas.fecha :TRUE];
    }else{
        lblCol2.text = [cajaHerramientas formateaDecimalAString:resumenVentas.importeB :FALSE];
    }
    labelPosition = lblCol2.frame;
    labelPosition.origin.x = _lblColumna2.frame.origin.x - 8;
    labelPosition.size.width = _lblColumna2.frame.size.width;
    lblCol2.frame = labelPosition;
    
    
    UIImageView *imgCol3 = (UIImageView *) [cell.contentView viewWithTag:666];
    UILabel *lblCol3 = (UILabel *) [cell viewWithTag:3];
    if ([_vistaDetallada.detallado boolValue]) {
        //Vista Detallada, Mostramos Imagen
        if (imgCol3 == nil) {
            UIImageView *tmpImage = [[ [UIImageView alloc] initWithFrame:CGRectMake(0, 0, 31, 31)] autorelease];
            tmpImage.tag = 666;
            [cell.contentView addSubview:tmpImage];
            imgCol3 = tmpImage;
            labelPosition = imgCol3.frame;
            labelPosition.origin.x = _lblColumna3.frame.origin.x + _lblColumna3.frame.size.width - 50;
            labelPosition.origin.y = _lblColumna3.frame.origin.y;
            imgCol3.frame  = labelPosition;
        }

        if (resumenVentas.tipoDetalle == @"CFM") {
            imgCol3.image = [UIImage imageNamed:@"EuroCF.png"];
        }else{
            if (resumenVentas.tipoDetalle == @"CFV") {
                imgCol3.image = [UIImage imageNamed:@"Visa.png"];
            }else{
                imgCol3.image = [UIImage imageNamed:@"EuroSF.png"];
            }
        }
        
        imgCol3.hidden = FALSE;
        lblCol3.hidden = TRUE;
    }else{
        //Vista Resumen. Mostramos Label
        imgCol3.hidden = TRUE;
        lblCol3.hidden = FALSE;
        lblCol3.text = [cajaHerramientas formateaDecimalAString:resumenVentas.importeA :FALSE];
        labelPosition = lblCol3.frame;
        labelPosition.origin.x = _lblColumna3.frame.origin.x - 8;
        labelPosition.size.width = _lblColumna3.frame.size.width;
        lblCol3.frame = labelPosition;
    }
    
    
    UILabel *lblCol4 = (UILabel *) [cell viewWithTag:4];
    if ([_vistaDetallada.detallado boolValue]) {
        lblCol4.text = @"";
    }else{
        lblCol4.text = [cajaHerramientas formateaDecimalAString:resumenVentas.importeVisa :FALSE];
    }
    labelPosition = lblCol4.frame;
    labelPosition.origin.x = _lblColumna4.frame.origin.x - 8;
    labelPosition.size.width = _lblColumna4.frame.size.width;
    lblCol4.frame = labelPosition;
    
    UILabel *lblCol5 = (UILabel *) [cell viewWithTag:5];
    if ([_vistaDetallada.detallado boolValue]){
        lblCol5.text = @"";
    }else{
        lblCol5.text = [cajaHerramientas formateaDecimalAString:resumenVentas.importeFinalA :FALSE];
    }
    labelPosition = lblCol5.frame;
    labelPosition.origin.x = _lblColumna5.frame.origin.x - 8;
    labelPosition.size.width = _lblColumna5.frame.size.width;
    lblCol5.frame = labelPosition;
    
    UILabel *lblCol6 = (UILabel *) [cell viewWithTag:6];
    if ([_vistaDetallada.detallado boolValue]){
        lblCol6.text = [cajaHerramientas formateaDecimalAString:resumenVentas.importeFinal :FALSE];
    }else{
        lblCol6.text = [cajaHerramientas formateaDecimalAString:resumenVentas.importeFinal :FALSE];
    }
    labelPosition = lblCol6.frame;
    labelPosition.origin.x = _lblColumna6.frame.origin.x - 8;
    labelPosition.size.width = _lblColumna6.frame.size.width;
    lblCol6.frame = labelPosition;
}

-(NSFetchedResultsController *)miFRCTickets{
    if (_miFRCTickets != nil) {
        return _miFRCTickets;
    }
    
    NSFetchRequest *miFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *miEntidad = [NSEntityDescription entityForName:@"Tickets" inManagedObjectContext:_miMOC];
    [miFetchRequest setEntity:miEntidad];
    
    NSSortDescriptor *orderDescriptor = [[NSSortDescriptor alloc] initWithKey:@"fecha" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:orderDescriptor, nil];
    [miFetchRequest setSortDescriptors:sortDescriptors];
    

    //Predicado por fecha
    NSPredicate *miPredicado = [NSPredicate predicateWithFormat:@"fechaNormalizada >= %@ AND fechaNormalizada <= %@", filtroFechaInicio, filtroFechaFin];
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


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_vistaDetallada.detallado == [NSNumber numberWithBool:NO]) {
        //Mostramos los detalles del día seleccionado
        ResumenVentas *tmpRV = (ResumenVentas*)[_arrayDetalles objectAtIndex:[indexPath row]];
        _vistaDetallada.fecha = tmpRV.fecha;
        _vistaDetallada.detallado = [NSNumber numberWithBool:YES];
    }
}

- (IBAction)printContent:(id)sender {
    //Leemos el fichero HTML para generar el informe final, haciendo los cambios oportunos
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ResumenDiarioCaja" ofType:@"html"];  
    NSArray *lineasHTML = [[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];
    
    NSString *lineaLeida;
    if (lineasHTML) {  
        // do something useful 
        NSEnumerator *nselineasHTML = [lineasHTML objectEnumerator];
        NSMutableString *htmlText = [[[NSMutableString alloc] init] autorelease];
        
        //BOOL match = ([aString rangeOfString:@"" options:NSCaseInsensitiveSearch].location != NSNotFound);
        
        NSDate *hoy = _filaTotales.fecha;
        NSString *tmpLineaLeida, *tr1, *tr2, *tr3;
        while(lineaLeida = [nselineasHTML nextObject]) {
            tmpLineaLeida = lineaLeida;
            
            //Fecha de Procesado
            if ([tmpLineaLeida rangeOfString:@"##FechaProcesado"].location != NSNotFound){
                lineaLeida = [tmpLineaLeida stringByReplacingOccurrencesOfString:@"##FechaProcesado" withString:[cajaHerramientas formateaFechaAString:hoy :FALSE]];
            }

            //Totales
            if ([tmpLineaLeida rangeOfString:@"##TotalImporte"].location != NSNotFound){
                lineaLeida = [tmpLineaLeida stringByReplacingOccurrencesOfString:@"###TotalImporte" withString:[cajaHerramientas formateaDecimalAString:_filaTotales.importeFinalA :FALSE]];
            }
            
            [htmlText appendFormat:@"%@", lineaLeida];
            
            //Controlamos si se va a comenzar la tabla
            if ([lineaLeida rangeOfString:@"##BodyTablaDetalles"].location != NSNotFound){
                //Aquí comienza la tabla. Bucle Hasta que termine
                //Leemos el formato de cada columna de la línea. La primera la leo 2 veces para evitar el <tr>
                [nselineasHTML nextObject]; 
                tr1 = [nselineasHTML nextObject];
                tr2 = [nselineasHTML nextObject];
                tr3 = [nselineasHTML nextObject];
                for (ResumenVentas *tmpResumenVentas in _arrayDetalles) {
                    
                    if (tmpResumenVentas.tipoDetalle != @"SF"){
                        [htmlText appendFormat:@"<tr>"];
                        
                        [htmlText appendFormat:@"%@", [tr1 stringByReplacingOccurrencesOfString:@"##Ticket" withString:[cajaHerramientas formateaEnteroAString:tmpResumenVentas.numero]]];
                        [htmlText appendFormat:@"%@", [tr2 stringByReplacingOccurrencesOfString:@"##Hora" withString:[cajaHerramientas formateaFechaAString:tmpResumenVentas.fecha :TRUE]]];
                        [htmlText appendFormat:@"%@", [tr3 stringByReplacingOccurrencesOfString:@"##Importe" withString:[cajaHerramientas formateaDecimalAString:tmpResumenVentas.importeFinal :FALSE]]];

                        [htmlText appendFormat:@"<\tr>"];
                    }
                }
            }
        }
        
        
        UIMarkupTextPrintFormatter *htmlFormatter = [[UIMarkupTextPrintFormatter alloc] initWithMarkupText:htmlText];
        
        htmlFormatter.startPage = 0;
        htmlFormatter.contentInsets = UIEdgeInsetsMake(40.0, 40.0, 40.0, 40.0);
        htmlFormatter.maximumContentWidth = 6 * 72.0;

        
        UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
        pic.delegate = self;
        
        UIPrintInfo *printInfo = [UIPrintInfo printInfo];
        printInfo.outputType = UIPrintInfoOutputGeneral;
        printInfo.jobName = @"pruebasTPV";
        pic.printInfo = printInfo;
        
        pic.printFormatter = htmlFormatter;
        [htmlFormatter release];
        pic.showsPageRange = YES;
        
        void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
        ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
            if (!completed && error) {
                NSLog(@"Printing could not complete because of error: %@", error);
            }
        };
        
        //if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //    [pic presentFromFromBarButtonItem:sender animated:YES completionHandler:completionHandler];
        //} else {
        [pic presentAnimated:YES completionHandler:completionHandler];
        //}
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
    [super viewDidUnload];
}


- (void)dealloc
{
    [cajaHerramientas release];
    [_miFRCTickets release];
    [_miMOC release];
    [_tableViewResumenTickets release];
    [_arrayDetalles release];
    [_filaTotales release];
    [_vistaDetallada release];
    [_tblCell release];
    [_barraNavegacion release];
    [_btnResumenDiario release];
    [_btnImprimirParteDiarioCaja release];
    [_lblColumna1 release];
    [_lblColumna2 release];
    [_lblColumna3 release];
    [_lblColumna4 release];
    [_lblColumna5 release];
    [_lblColumna6 release];
    [_lblColPie1 release];
    [_lblColPie2 release];
    [_lblColPie3 release];
    [_lblColPie4 release];
    [_lblColPie5 release];
    [_lblColPie6 release];
    [_imgVisa release];
    [_imgEuroCF release];
    [_imgEuroSF release];
    [_imgEuroVisaCF release];
    [super dealloc];
}

@end
