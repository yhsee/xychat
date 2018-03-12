unit frmPMessageUnt;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Buttons,constunt, TntStdCtrls;

type
  TfrmPMessage = class(TForm)
    myimg: TImage;
    Msgtxts: TLabel;
    close_button: TLabel;
    Timer1: TTimer;
    StartDialog: TLabel;
    Lab_Title: TTntLabel;
    procedure FormCreate(Sender: TObject);
    procedure close_buttonClick(Sender: TObject);
    procedure myimgMouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure StartDialogClick(Sender: TObject);
    procedure myimgMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    procedure ChangeFromBackground(iType:Integer);
    { Private declarations }
  public
    iType:word;
    autoclose:boolean;
    { Public declarations }
  end;

procedure ShowPopupMessage(UserSign:String;sMessage:WideString;Const iType:Integer=0;const bAutoClose:boolean=True);

implementation
uses ShareUnt,frmMessageUnt;
{$R *.DFM}

procedure ShowPopupMessage(UserSign:String;sMessage:WideString;Const iType:Integer=0;const bAutoClose:boolean=True);
var
  frmPMessage:TfrmPMessage;
begin
  SetForegroundWindow(main_hwnd);
  frmPMessage:=TfrmPMessage.Create(nil);
  frmPMessage.autoclose:=bAutoClose;
  frmPMessage.StartDialog.Hint:=UserSign;
  frmPMessage.iType:=iType;
  frmPMessage.Msgtxts.Caption:='  '+sMessage;
  frmPMessage.show;
end;

procedure RoundForm(fForm:TForm);
Var
  rgnRGN : HRGN;
begin
  rgnRGN := CreateRoundRectRgn(0, 0, fForm.Width, fForm.Height, 4, 4);
  SetWindowRgn(fForm.Handle, rgnRGN, True);
end;

procedure TfrmPMessage.FormCreate(Sender: TObject);
begin
  left:=screen.Width-width-10;
  top:=screen.Height-height-30;
  timer1.Enabled:=true;
  RoundForm(Self);
end;

procedure TfrmPMessage.close_buttonClick(Sender: TObject);
begin
  DefWindowProc(Handle, WM_SYSCOMMAND, SC_CLOSE, 0);
end;

procedure TfrmPMessage.myimgMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  timer1.Enabled:=false;
end;

procedure TfrmPMessage.Timer1Timer(Sender: TObject);
begin
  timer1.Enabled:=false;
  if autoclose then
    DefWindowProc(Handle, WM_SYSCOMMAND, SC_CLOSE, 0);
end;

procedure TfrmPMessage.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:=cafree;
  TfrmPMessage(self):=nil;
end;

procedure TfrmPMessage.ChangeFromBackground(iType:Integer);
var
  TmpStr:String;
begin
{  case iType of
    xy_popup_type_info:
       begin
       Lab_Title.Caption:='提示信息';
       TmpStr:='Info.jpg';
       end;
    xy_popup_type_Question:
       begin
       Lab_Title.Caption:='提示信息';
       TmpStr:='Question.jpg';
       end;
    xy_popup_type_Waring:
       begin
       Lab_Title.Caption:='警告';
       TmpStr:='Waring.jpg';
       end;
    xy_popup_type_Error:
       begin
       Lab_Title.Caption:='错误';
       TmpStr:='Error.jpg';
       end;
    xy_popup_type_Pass:
       begin
       autoclose:=false;
       Lab_Title.Caption:='提示信息';
       TmpStr:='Pass.jpg';
       StartDialog.Visible:=true;
       end;
    end;      }
  myimg.Picture.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\'+TmpStr);
end;

procedure TfrmPMessage.FormShow(Sender: TObject);
begin
  ChangeFromBackground(iType);
end;

procedure TfrmPMessage.FormResize(Sender: TObject);
begin
  RoundForm(Self);
end;

procedure TfrmPMessage.StartDialogClick(Sender: TObject);
begin
  DefWindowProc(Handle, WM_SYSCOMMAND, SC_CLOSE, 0);
  CreateUserDialog(StartDialog.Hint);
end;

procedure TfrmPMessage.myimgMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  Perform(WM_SYSCOMMAND, $F012, 0);
end;

end.
