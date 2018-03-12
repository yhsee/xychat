unit frmTest;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls,RichEditOleUnt,TntDialogs;

type
  TRichedit=class(TRichEditOle);
  TForm1 = class(TForm)
    Button1: TButton;
    RichEdit1: TRichEdit;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure PicturePaste(Sender :TObject; const URL: Widestring);
    procedure DropFile(Sender :TObject; const URL: Widestring);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation
uses ComObj,md5unt;
{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  RichEdit1.InsertImageFile('a.jpg','1234567890753452');
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  RichEdit1.ReplaceObject('xxx','b.jpg');
end;

function MD5TOGUID(sTmpStr:String):String;
begin
  sTmpStr:=UpperCase(sTmpStr);
  Insert('-',sTmpStr,21);
  Insert('-',sTmpStr,17);
  Insert('-',sTmpStr,13);
  Insert('-',sTmpStr,9);
  Result:=ConCat('{',sTmpStr,'}');
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  RichEdit1.OnPasteImage:=PicturePaste;
  RichEdit1.OnDropFile:=DropFile;
end;

procedure TForm1.PicturePaste(Sender :TObject; const URL: Widestring);
begin
  RichEdit1.InsertImageFile(URL);
end;

procedure TForm1.DropFile(Sender :TObject; const URL: Widestring);
begin
  ShowMessage(URL);
end;

end.
