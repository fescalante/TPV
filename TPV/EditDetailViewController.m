//
//  EditDetailViewController.m
//  TPV
//
//  Created by Flavio Escalante Puente on 02/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EditDetailViewController.h"
#import "TecladoNumerico.h"

@implementation EditDetailViewController

@synthesize txtCantidad=_txtCantidad;
@synthesize txtArticulo=_txtArticulo;
@synthesize txtPrecio=_txtPrecio;
@synthesize txtImporte=_txtImporte;
@synthesize detalleSeleccionado=_detalleSeleccionado;
@synthesize btnActualizaDetalleSeleccionado=_btnActualizaDetalleSeleccionado;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    _txtPrecio.inputView = tecladoPrecio.view;
    tecladoPrecio.textFieldAsignado = _txtPrecio;
    
    _txtCantidad.delegate = self;
    _txtArticulo.delegate = self;
    _txtPrecio.delegate = self;
    
    if (_detalleSeleccionado != nil){
        _txtCantidad.text = [cajaHerramientas formateaEnteroAString:_detalleSeleccionado.cantidad];
        _txtArticulo.text = _detalleSeleccionado.articulo;
        _txtPrecio.text = [cajaHerramientas formateaDecimalAString:_detalleSeleccionado.precio :FALSE];
        _txtImporte.text = [cajaHerramientas formateaDecimalAString:_detalleSeleccionado.importe :FALSE];
    }
    
    [_txtCantidad becomeFirstResponder];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [_txtCantidad release];
    [_txtArticulo release];
    [_txtPrecio release];
    [_txtImporte release];
    [_btnActualizaDetalleSeleccionado release];
    [_detalleSeleccionado release];
    [popOver release];
    [cajaHerramientas release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationLandscapeRight || interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        return YES;
    }else{
        return NO;  
    }
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
        if (textField == _txtPrecio) {
            textField.placeholder = @"0,00";
        }
    }
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //Cuando dejamos de editar el campo hay que tener en cuenta si trae valor, en caso negativo le ponemos el del PlaceHolder a excepción del artículo
    activeField = nil;
    bool calculamosImporte = TRUE;
    
    //Unidades
    if (textField == _txtCantidad) {
        if ([textField.text length] == 0) {
            textField.text = textField.placeholder;
        }else{
            NSNumber *tmpUdsLinea = [cajaHerramientas enteroDesdeStringFormateado:_txtCantidad.text];
            textField.text = [cajaHerramientas formateaEnteroAString:tmpUdsLinea];
        }
    }
    
    //Artículo
    if (textField == _txtArticulo) {
        calculamosImporte = FALSE;
        if ([textField.text length] == 0) {
            textField.text = textField.placeholder;
        }
    }
    
    //Precio
    if (textField == _txtPrecio) {
        if ([textField.text length] == 0) {
            textField.text = textField.placeholder;
        }else{
            NSDecimalNumber *tmpPvpLinea = [cajaHerramientas decimalDesdeStringFormateado:_txtPrecio.text];
            textField.text = [cajaHerramientas formateaDecimalAString:tmpPvpLinea :FALSE];
        }
    }    
    
    
    //Calculamos el importe
    if (calculamosImporte == TRUE) {
        NSDecimalNumber *tmpUdsLinea = [cajaHerramientas decimalDesdeStringFormateado:_txtCantidad.text];
        NSDecimalNumber *tmpPvpLinea = [cajaHerramientas decimalDesdeStringFormateado:_txtPrecio.text];
        
        NSDecimalNumber *tmpImporteLinea = [tmpUdsLinea decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithDecimal:[tmpPvpLinea decimalValue]]];
        
        _txtImporte.text = [cajaHerramientas formateaDecimalAString:tmpImporteLinea :FALSE];
        
    }
}


- (IBAction)actualizaDetalleSeleccionado:(id)sender{
    //Actualizamos valores del detalle seleccionado
    
    //Truco para que se recalcule el importe
    if (activeField != nil) [self textFieldDidEndEditing: activeField];
    
    //Cantidad
    _detalleSeleccionado.cantidad = [cajaHerramientas enteroDesdeStringFormateado:_txtCantidad.text];
    //Articulo
    _detalleSeleccionado.articulo = _txtArticulo.text;
    //Precio
    _detalleSeleccionado.precio = [cajaHerramientas decimalDesdeStringFormateado:_txtPrecio.text];
    //Importe
    _detalleSeleccionado.importe = [cajaHerramientas decimalDesdeStringFormateado:_txtImporte.text];
    
    //Ocultamos el popOver y forzamos la ejecución de su método delegado.
    [popOver dismissPopoverAnimated:YES];
    [popOver.delegate popoverControllerDidDismissPopover:popOver];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [activeField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField==_txtCantidad)
    {
        [_txtArticulo becomeFirstResponder];
    }
    else if (textField==_txtArticulo)
    {
        [_txtPrecio becomeFirstResponder];
    }
    else if (textField==_txtPrecio)
    {
        [_btnActualizaDetalleSeleccionado sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    
    return NO;
}

-(void) edicionFinalizada:(UITextField *)parTextField{
    [self textFieldShouldReturn:parTextField];
}

-(void)setPopover: (UIPopoverController *)aPopover{
    popOver = aPopover;     
}
@end
