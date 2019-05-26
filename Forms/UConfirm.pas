unit UConfirm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TConfirm = class(TForm)
    Yes: TButton;
    No: TButton;
    Message1: TLabel;
    Message2: TLabel;
    procedure FormShow(Sender: TObject);
    procedure YesClick(Sender: TObject);
    procedure NoClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Confirm: TConfirm;

implementation

{$R *.dfm}

uses Main, UFormBG;

procedure TConfirm.FormShow(Sender: TObject);
begin
Confirm.Width := Form1.Width;
Confirm.Height:= Form1.Height div 2;
Confirm.Left := Form1.left;
Confirm.Top := Form1.top + (Confirm.Height div 2);
end;

procedure TConfirm.NoClick(Sender: TObject);
begin
Confirm.Close;
FormBG.Hide;
end;

procedure TConfirm.YesClick(Sender: TObject);
begin
Form1.BTN_Reiniciar.Click;
end;

end.
