//
//  TecladoNumerico.h
//  TPV
//
//  Created by Flavio Escalante Puente on 27/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TecladoNumericoDelegate <NSObject>
@required
-(void) edicionFinalizada: (UITextField *) parTextField;

@end

@interface TecladoNumerico : UIViewController <UITextFieldDelegate>{
    id <TecladoNumericoDelegate> delegate;
    
    UITextField *_textFieldAsignado;
    UIButton *_btn0, *_btn1, *_btn2, *_btn3, *_btn4, *_btn5, *_btn6, *_btn7, *_btn8, *_btn9, *_btnComa, *_btnOk, *_btnExit, *_btnBack, *_btnTpc;
    BOOL _esDecimal;
}

@property(nonatomic,retain) UITextField *textFieldAsignado;

@property(nonatomic, retain) IBOutlet UIButton *btn0;
@property(nonatomic, retain) IBOutlet UIButton *btn1;
@property(nonatomic, retain) IBOutlet UIButton *btn2;
@property(nonatomic, retain) IBOutlet UIButton *btn3;
@property(nonatomic, retain) IBOutlet UIButton *btn4;
@property(nonatomic, retain) IBOutlet UIButton *btn5;
@property(nonatomic, retain) IBOutlet UIButton *btn6;
@property(nonatomic, retain) IBOutlet UIButton *btn7;
@property(nonatomic, retain) IBOutlet UIButton *btn8;
@property(nonatomic, retain) IBOutlet UIButton *btn9;

@property(nonatomic, retain) IBOutlet UIButton *btnComa;
@property(nonatomic, retain) IBOutlet UIButton *btnOk;
@property(nonatomic, retain) IBOutlet UIButton *btnExit;
@property(nonatomic, retain) IBOutlet UIButton *btnBack;
@property(nonatomic, retain) IBOutlet UIButton *btnTpc;

@property(nonatomic) BOOL esDecimal;

@property (retain) id delegate;

-(IBAction) teclaNumericaPulsada:(id)sendr;
-(IBAction) teclaBackPulsada:(id)sendr;
-(IBAction) teclaOkPulsada:(id)sender;
-(IBAction) teclaComaPulsada:(id)sender;
-(IBAction) teclaTpcPulsada:(id)sender;
-(IBAction) teclaExitPulsada:(id)sender;

@end
