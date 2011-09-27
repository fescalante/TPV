//
//  TecladoNumerico.m
//  TPV
//
//  Created by Flavio Escalante Puente on 27/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TecladoNumerico.h"

@implementation TecladoNumerico

@synthesize delegate;
@synthesize esDecimal=_esDecimal;
@synthesize textFieldAsignado=_textFieldAsignado;
@synthesize btn0=_btn0, btn1=_btn1, btn2=_btn2, btn3=_btn3, btn4=_btn4, btn5=_btn5, btn6=_btn6, btn7=_btn7, btn8=_btn8, btn9=_btn9, btnComa=_btnComa, btnOk=_btnOk, btnExit=_btnExit, btnBack=_btnBack, btnTpc=_btnTpc;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _esDecimal = TRUE;
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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    _btnTpc.enabled = !_esDecimal;
    _btnComa.enabled = _esDecimal;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [_textFieldAsignado release];
    [_btn0 release];
    [_btn1 release];
    [_btn2 release];
    [_btn3 release];    
    [_btn4 release];
    [_btn5 release];    
    [_btn6 release];
    [_btn7 release];    
    [_btn8 release];
    [_btn9 release];
    [_btnComa release];
    [_btnOk release];
    [_btnExit release];
    [_btnBack release];
    [_btnTpc release];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationLandscapeRight || interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        return YES;
    }else{
        return NO;  
    }
}

-(IBAction) teclaExitPulsada:(id)sender{
    [_textFieldAsignado resignFirstResponder];
}

-(IBAction) teclaComaPulsada:(id)sender{
    NSRange range = [_textFieldAsignado.text rangeOfString:@","];
    if([_textFieldAsignado.text length] > 0 && range.length  == 0)
            _textFieldAsignado.text=[_textFieldAsignado.text stringByAppendingString:@","];  

}

-(IBAction) teclaTpcPulsada:(id)sender{
    NSRange range = [_textFieldAsignado.text rangeOfString:@"%"];
    if([_textFieldAsignado.text length] > 0 && range.length  == 0){
        _textFieldAsignado.text=[_textFieldAsignado.text stringByAppendingString:@"%"]; 
        [[self delegate] edicionFinalizada: _textFieldAsignado];
    }

}

-(IBAction) teclaOkPulsada:(id)sender{
    [[self delegate] edicionFinalizada: _textFieldAsignado];
}

-(IBAction) teclaBackPulsada:(id)sendr{
    if ([_textFieldAsignado.text length] > 0) {
        // set an NSString to whatever is in the textField
        NSString *backspace = _textFieldAsignado.text;
        
        //set length of string to current length
        int lengthofstring = backspace.length;
        
        //make length of string 1 less (takes off the last character)
        backspace = [backspace substringToIndex:lengthofstring - 1];
        
        //set textField to amended string
        _textFieldAsignado.text = backspace;
    }
}

-(IBAction) teclaNumericaPulsada :(id)sendr{

    UIButton *tmpBotonPulsado = sendr;
    
    NSString *myT = [[NSNumber numberWithInt:tmpBotonPulsado.tag] stringValue];
    
    
    if([_textFieldAsignado.text length] <= 0)
        _textFieldAsignado.text = myT;
    else
        _textFieldAsignado.text=[_textFieldAsignado.text stringByAppendingString:myT];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    return YES;
}

@end
