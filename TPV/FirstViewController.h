//
//  FirstViewController.h
//  TPVFacil
//
//  Created by Flavio on 10/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tickets.h"
#import "TicketsDetalles.h"
#import "TicketsDetallesCell.h"
#import "EditDetailViewController.h"
#import "DropboxSDK.h"
#import "Utilidades.h"
#import "TecladoNumerico.h"


@interface FirstViewController : UIViewController <UITextFieldDelegate, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIPopoverControllerDelegate, DBLoginControllerDelegate, DBRestClientDelegate, TecladoNumericoDelegate>{

    UISwitch *switchCF, *switchVisa;
    UITextField *artLinea, *pvpLinea, *impLinea, *activeField, *_txtCantidad;
    UILabel *numeroOrden, *numeroTicket, *fechaTicket, *importeFinal, *indicadorTicketActivo;
    UIButton *_btnInsertaLinea;
    UIBarButtonItem *_btnCambiaTicketAnterior, *_btnCambiaTicketSiguiente, *_btnCambiaTicketUltimo, *_btnCambiaTicketPrimero;

    UITableView *tableViewDetalles;
    TicketsDetallesCell *tblCell;
    
    NSFetchedResultsController *_miFRCTickets, *_miFRCTicketsDetalles;
	NSManagedObjectContext *_miMOC;
    
    Tickets *_ticketActivo;
    
    NSString *primeraCarga;
    
    EditDetailViewController *_editDetailView;
    UIPopoverController *_popOverController;
    TicketsDetalles *_detalleAEditar;
    
    DBRestClient *restClient;
    
    Utilidades *cajaHerramientas;
    
    UIView *_vistaSuperior;
    
    float heightOriginalTableViewDetalles;
    float heightReducidaTableViewDetalles;
    
    NSTimer *_programadorBackUp;

}

@property (nonatomic, retain) IBOutlet UILabel *numeroOrden;
@property (nonatomic, retain) IBOutlet UILabel *numeroTicket;
@property (nonatomic, retain) IBOutlet UILabel *fechaTicket;
@property (nonatomic, retain) IBOutlet UISwitch *switchCF;
@property (nonatomic, retain) IBOutlet UISwitch *switchVisa;
@property (nonatomic, retain) IBOutlet UITextField *txtCantidad;
@property (nonatomic, retain) IBOutlet UITextField *pvpLinea;
@property (nonatomic, retain) IBOutlet UITextField *impLinea;
@property (nonatomic, retain) IBOutlet UITextField *artLinea;
@property (nonatomic, retain) IBOutlet UIButton *btnInsertaLinea;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *btnCambiaTicketAnterior;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *btnCambiaTicketSiguiente;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *btnCambiaTicketUltimo;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *btnCambiaTicketPrimero;
@property (nonatomic, retain) IBOutlet UILabel *importeFinal;
@property (nonatomic, retain) IBOutlet UILabel *indicadorTicketActivo;

@property (nonatomic, retain) IBOutlet UITableView *tableViewDetalles;
@property (nonatomic, retain) IBOutlet TicketsDetallesCell *tblCell;

@property (nonatomic, retain) NSFetchedResultsController *miFRCTickets;
@property (nonatomic, retain) NSFetchedResultsController *miFRCTicketsDetalles;
@property (nonatomic, retain) NSManagedObjectContext *miMOC;

@property (nonatomic, retain) NSString *primeraCarga;
@property (nonatomic, retain) Tickets *ticketActivo;

@property (nonatomic, retain) EditDetailViewController *editDetailView;
@property (nonatomic, retain) UIPopoverController *popOverController;
@property (nonatomic, retain) TicketsDetalles *detalleAEditar;

@property (nonatomic, readonly) DBRestClient *restClient;

@property (nonatomic, retain) IBOutlet UIView *vistaSuperior;

@property (nonatomic, retain) NSTimer *programadorBackUp;


-(IBAction)cambioCF:(id)sendr;
-(IBAction)cambioVisa:(id)sendr;
-(IBAction)actionInsertaTicket:(id)sendr;
-(IBAction)actionInsertaLinea:(id)sendr;
-(IBAction)backupToDropbox:(id)sender;
-(IBAction)actionCambiaTicketActivo:(id)sender;

-(void) crearNuevoTicket;
-(void) crearNuevoDetalleTicket;
-(void)implementarKVO;
-(int)calcularNuevoNumeroTicket:(BOOL) parCF;
-(int)calcularNuevoOrdenticket;
-(void)configureCell:(UITableViewCell *) cell atIndexPath:(NSIndexPath *)indexPath;


@end
