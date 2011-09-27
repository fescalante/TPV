//
//  SecondViewController.h
//  TPV
//
//  Created by Flavio on 12/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResumenVentas.h"
#import "ResumenVentasCell.h"
#import "Utilidades.h"


@interface SecondViewController : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDelegate, UIPrintInteractionControllerDelegate> {
    NSManagedObjectContext *_miMOC;
    NSFetchedResultsController *_miFRCTickets;
    
    UITableView *_tableViewResumenTickets;

    NSMutableArray *_arrayDetalles;
    
    NSDate *filtroFechaInicio, *filtroFechaFin;
    
    ResumenVentas *_vistaDetallada, *_filaTotales;
    
    UINavigationBar *_barraNavegacion;
    UIBarButtonItem *_btnResumenDiario, *_btnImprimirParteDiarioCaja;
    
    UILabel *_lblColumna1, *_lblColumna2, *_lblColumna3, *_lblColumna4, *_lblColumna5, *_lblColumna6;
    UILabel *_lblColPie1, *_lblColPie2, *_lblColPie3, *_lblColPie4, *_lblColPie5, *_lblColPie6;
    
    UIImageView *_imgVisa, *_imgEuroCF, *_imgEuroSF, *_imgEuroVisaCF;
    
    Utilidades *cajaHerramientas;
}

@property (nonatomic, retain) NSManagedObjectContext *miMOC;
@property (nonatomic, retain) NSFetchedResultsController *miFRCTickets;
@property (nonatomic, retain) IBOutlet UITableView *tableResumenViewTickets;

@property (nonatomic, retain) NSMutableArray *arrayDetalles;
@property (nonatomic, retain) ResumenVentas *filaTotales;

@property (nonatomic, retain) IBOutlet ResumenVentasCell *tblCell;

@property (nonatomic, retain) ResumenVentas *vistaDetallada;

@property (nonatomic, retain) IBOutlet UINavigationBar *barraNavegacion;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *btnResumenDiario;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *btnImprimirParteDiarioCaja;

@property (nonatomic, retain) IBOutlet UILabel *lblColumna1;
@property (nonatomic, retain) IBOutlet UILabel *lblColumna2;
@property (nonatomic, retain) IBOutlet UILabel *lblColumna3;
@property (nonatomic, retain) IBOutlet UILabel *lblColumna4;
@property (nonatomic, retain) IBOutlet UILabel *lblColumna5;
@property (nonatomic, retain) IBOutlet UILabel *lblColumna6;

@property (nonatomic, retain) IBOutlet UILabel *lblColPie1;
@property (nonatomic, retain) IBOutlet UILabel *lblColPie2;
@property (nonatomic, retain) IBOutlet UILabel *lblColPie3;
@property (nonatomic, retain) IBOutlet UILabel *lblColPie4;
@property (nonatomic, retain) IBOutlet UILabel *lblColPie5;
@property (nonatomic, retain) IBOutlet UILabel *lblColPie6;

@property (nonatomic, retain) IBOutlet UIImageView *imgVisa;
@property (nonatomic, retain) IBOutlet UIImageView *imgEuroCF;
@property (nonatomic, retain) IBOutlet UIImageView *imgEuroSF;
@property (nonatomic, retain) IBOutlet UIImageView *imgEuroVisaCF;


-(void)configureCell:(UITableViewCell *) cell atIndexPath:(NSIndexPath *)indexPath;
-(IBAction)activarResumenDiario:(id)sender;
-(IBAction)printContent:(id)sender;

@end
