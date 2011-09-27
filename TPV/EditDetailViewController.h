//
//  EditDetailViewController.h
//  TPV
//
//  Created by Flavio Escalante Puente on 02/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TicketsDetalles.h"
#import "Tickets.h"
#import "Utilidades.h"
#import "TecladoNumerico.h"

@interface EditDetailViewController : UIViewController <UITextFieldDelegate, TecladoNumericoDelegate>{
    UITextField *_txtCantidad, *_txtArticulo, *_txtPrecio, *_txtImporte, *activeField;
    UIButton *_btnActualizaDetalleSeleccionado;

    TicketsDetalles *_detalleSeleccionado;
    
    UIPopoverController *popOver;
    
    Utilidades *cajaHerramientas;
}

@property (nonatomic, retain) IBOutlet UITextField *txtCantidad;
@property (nonatomic, retain) IBOutlet UITextField *txtArticulo;
@property (nonatomic, retain) IBOutlet UITextField *txtPrecio;
@property (nonatomic, retain) IBOutlet UITextField *txtImporte;

@property (nonatomic, retain) IBOutlet UIButton *btnActualizaDetalleSeleccionado;

@property (nonatomic, retain) TicketsDetalles *detalleSeleccionado;

-(IBAction)actualizaDetalleSeleccionado:(id)sender;

-(void)setPopover:(UIPopoverController*)aPopover;

@end
