program HWIDChanger;



uses
  Vcl.Forms,
  Main in 'Forms\Main.pas' {Form1},
  UFormBG in 'Forms\UFormBG.pas' {FormBG},
  UConfirm in 'Forms\UConfirm.pas' {Confirm},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}
{$R HWIDChanger.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows10');
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TFormBG, FormBG);
  Application.CreateForm(TConfirm, Confirm);
  Application.Run;
end.
