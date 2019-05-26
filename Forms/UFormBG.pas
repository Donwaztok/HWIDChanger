unit UFormBG;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TFormBG = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormBG: TFormBG;

implementation

{$R *.dfm}

uses Main;

procedure TFormBG.Button1Click(Sender: TObject);
begin
FormBG.Hide;
end;

procedure TFormBG.FormCreate(Sender: TObject);
begin
FormBG.StyleElements:=[];
end;

procedure TFormBG.FormShow(Sender: TObject);
begin
Button1.Left := (Form1.Width - Button1.Width) div 2;
Button1.Top := (Form1.Height - Button1.Height) div 2;
FormBG.Top := Form1.Top;
FormBG.Left:= Form1.Left;
FormBG.Height:= Form1.Height;
FormBG.Width := Form1.Width;
end;

end.
