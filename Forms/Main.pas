unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, ShellApi, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage, Vcl.CheckLst,filectrl, Vcl.Mask, Vcl.OleServer,
  Vcl.CmAdmCtl, Vcl.Imaging.jpeg, Vcl.ComCtrls, INIFiles;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    Background: TImage;
    Footer: TImage;
    Header: TImage;
    Maximizar: TImage;
    Fechar: TImage;
    Minimizar: TImage;
    Version: TLabel;
    ComboBox1: TComboBox;
    HWIDBox: TMaskEdit;
    TB_HWID: TCheckBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Tip1: TLabel;
    Tip2: TLabel;
    GroupBox3: TGroupBox;
    Name: TLabel;
    CMD: TMemo;
    BTN_HWID: TButton;
    HideCMD: TButton;
    BTN_Reiniciar: TButton;
    Icon: TImage;
    Logo: TImage;
    Comando: TEdit;
    Tip3: TLabel;
    ChangeAll: TButton;
    ComboBox2: TComboBox;
    procedure Timer1Timer(Sender: TObject);
    procedure FecharClick(Sender: TObject);
    procedure MinimizarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BTN_HWIDClick(Sender: TObject);
    procedure HideCMDClick(Sender: TObject);
    procedure BTN_ReiniciarClick(Sender: TObject);
    procedure ComandoKeyPress(Sender: TObject; var Key: Char);
    procedure HWIDBoxKeyPress(Sender: TObject; var Key: Char);
    procedure ChangeAllClick(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses UFormBG, UConfirm;

//=== Função para simular o DOS no Delphi ======================================
function GetDosOutput(CommandLine: string; Work: string): string;
var
  SA: TSecurityAttributes;
  SI: TStartupInfo;
  PI: TProcessInformation;
  StdOutPipeRead, StdOutPipeWrite: THandle;
  WasOK: Boolean;
  Buffer: array[0..255] of AnsiChar;
  BytesRead: Cardinal;
  WorkDir: string;
  Handle: Boolean;
begin
  Result := '';
  with SA do begin
    nLength := SizeOf(SA);
    bInheritHandle := True;
    lpSecurityDescriptor := nil;
  end;
  CreatePipe(StdOutPipeRead, StdOutPipeWrite, @SA, 0);
  try
    with SI do
    begin
      FillChar(SI, SizeOf(SI), 0);
      cb := SizeOf(SI);
      dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
      wShowWindow := SW_HIDE;
      hStdInput := GetStdHandle(STD_INPUT_HANDLE); // don't redirect stdin
      hStdOutput := StdOutPipeWrite;
      hStdError := StdOutPipeWrite;
    end;
    WorkDir := Work;
    Handle := CreateProcess(nil, PChar('cmd.exe /C ' + CommandLine),
                            nil, nil, True, 0, nil,
                            PChar(WorkDir), SI, PI);
    CloseHandle(StdOutPipeWrite);
    if Handle then
      try
        repeat
          WasOK := ReadFile(StdOutPipeRead, Buffer, 255, BytesRead, nil);
          if BytesRead > 0 then
          begin
            Buffer[BytesRead] := #0;
            Result := Result + Buffer;
          end;
        until not WasOK or (BytesRead = 0);
        WaitForSingleObject(PI.hProcess, INFINITE);
      finally
        CloseHandle(PI.hThread);
        CloseHandle(PI.hProcess);
      end;
  finally
    CloseHandle(StdOutPipeRead);
  end;
end;
//==============================================================================

//=== Função de Listar as Letras das unidades ==================================
 function ListaDrives: TStringList;
var Lista: TStringList;
DriveNum: Integer;
LetraDrive: Char;
DriveBits: set of 0..25;
TipoDrive: TDriveType;
begin
Lista:=TStringList.Create;
Integer(DriveBits):=GetLogicalDrives;
For DriveNum:=0 to 25 do

begin
if not (DriveNum in DriveBits) then
Continue;
LetraDrive:=UpCase(Char(DriveNum+ord('a')));
TipoDrive := TDriveType (GetDriveType (PChar (LetraDrive + ':\')));
Case TipoDrive of
dtFloppy: Lista.Add(LetraDrive+': - Floppy');
dtFixed: Lista.Add(LetraDrive+': - Hard Disk');
dtCDROM: Lista.Add(LetraDrive+': - CD-ROM');
dtRAM: Lista.Add(LetraDrive+': - RAM Disk');
dtNetwork: Lista.Add(LetraDrive+': - Network Drive');
end;
end;
Result:=Lista;
end;
//==============================================================================

//== Função da Versão do Aplicativo ============================================
Function VersaoExe: String;
type
   PFFI = ^vs_FixedFileInfo;
var
   F       : PFFI;
   Handle  : Dword;
   Len     : Longint;
   Data    : Pchar;
   Buffer  : Pointer;
   Tamanho : Dword;
   Parquivo: Pchar;
   Arquivo : String;
begin
   Arquivo  := Application.ExeName;
   Parquivo := StrAlloc(Length(Arquivo) + 1);
   StrPcopy(Parquivo, Arquivo);
   Len := GetFileVersionInfoSize(Parquivo, Handle);
   Result := '';
   if Len > 0 then
   begin
      Data:=StrAlloc(Len+1);
      if GetFileVersionInfo(Parquivo,Handle,Len,Data) then
      begin
         VerQueryValue(Data, '',Buffer,Tamanho);
         F := PFFI(Buffer);
         Result := Format('%d.%d.%d.%d',
                          [HiWord(F^.dwFileVersionMs),
                           LoWord(F^.dwFileVersionMs),
                           HiWord(F^.dwFileVersionLs),
                           Loword(F^.dwFileVersionLs)]
                         );
      end;
      StrDispose(Data);
   end;
   StrDispose(Parquivo);
end;
//==============================================================================

//=== Função para Criar um HWID Com base na hora atual =========================
type
  TVolumeId = record
    case byte of
      0: (Id: DWORD);
      1: (
        Lo: WORD;
        Hi: WORD;
      );
  end;

function GetVolumeID: DWORD;
var
  dtNow: TDateTime;
  vlid: TVolumeId;
  st: SYSTEMTIME;
begin
  GetLocalTime(st);
  vlid.Lo := st.wDay + (st.wMonth shl 8);
  vlid.Lo := vlid.Lo + (st.wMilliseconds div 10 + (st.wSecond shl 8));

  vlid.Hi := st.wMinute + (st.wHour shl 8);
  vlid.Hi := vlid.Hi + st.wYear;

  Result := vlid.Id
end;
//==============================================================================

//=== Função para verificar o HWID Atual =======================================
 function GetHDDVolSerial(const DriveLetter: Char): string;
var
  NotUsed:     DWORD;
  VolumeFlags: DWORD;
  VolumeInfo:  array[0..MAX_PATH] of Char;
  VolumeSerialNumber: DWORD;
begin
  GetVolumeInformation(PChar(DriveLetter + ':\'),
    nil, SizeOf(VolumeInfo), @VolumeSerialNumber, NotUsed,
    VolumeFlags, nil, 0);
  Result := Format('%8.8X',[VolumeSerialNumber])
end;
//==============================================================================

//=== Função para Listar os Arquivos no Combobox ===============================
function GetFileList(const Path: string): TStringList;
var
   I: Integer;
   SearchRec: TSearchRec;
begin
   Result := TStringList.Create;
   try
     I := FindFirst(Path, 0, SearchRec);
     while I = 0 do
     begin
       Result.Add(copy(SearchRec.Name,1,Pos('.',SearchRec.Name)-1));
       I := FindNext(SearchRec);
     end;
   except
     Result.Free;
     raise;
   end;
end;
//==============================================================================

//=== Trocar o HWID ============================================================
procedure TForm1.BTN_HWIDClick(Sender: TObject);
begin
  CMD.Text := GetDosOutput('VolumeID '+ComboBox1.text[1]+': '+HWIDBox.Text,
        copy(ExtractFileDir(ParamStr(0)),0,2));
FormBG.Show;
Confirm.ShowModal;
end;
//=== Reiniciar PC =============================================================
procedure TForm1.BTN_ReiniciarClick(Sender: TObject);
begin
  CMD.Text := GetDosOutput('shutdown -r -t 0',copy(ExtractFileDir(ParamStr(0)),0,2));
end;
//=== Trocar todos os HWID com um botão ========================================
procedure TForm1.ChangeAllClick(Sender: TObject);
var I: integer;
begin
for I := 0 to Combobox1.Items.Count-1 do
  begin
    ComboBox1.ItemIndex:=I;
    CMD.Text := GetDosOutput('VolumeID '+ComboBox1.text[1]+': '+HWIDBox.Text,
        copy(ExtractFileDir(ParamStr(0)),0,2));
  end;
ComboBox1.ItemIndex:=0;
FormBG.Show;
Confirm.ShowModal;
end;
//=== Comando ==================================================================
procedure TForm1.ComandoKeyPress(Sender: TObject; var Key: Char);
begin
if (Key in [#13]) then
begin
  CMD.Text := GetDosOutput(Comando.Text,copy(ExtractFileDir(ParamStr(0)),0,2));
  Comando.Text:='';
end;
end;
//=== Ler o arquivo da tradução ================================================
procedure TForm1.ComboBox2Change(Sender: TObject);
var
  Ini1: TIniFile;
begin
  Ini1 := TIniFile.Create(ExtractFileDir(ParamStr(0))+'\Languages\'+Combobox2.Text+'.txt');
  BTN_HWID.Caption := Ini1.ReadString('Translation','BTN_HWID','<HWID>');
  ChangeAll.Caption := Ini1.ReadString('Translation','ChangeAll','<ChangeAll>');
  TB_HWID.Caption := Ini1.ReadString('Translation','TB_HWID','<TBHWID>');
  Tip1.Caption := Ini1.ReadString('Translation','Tip1','<Tip1>');
  Tip2.Caption := Ini1.ReadString('Translation','Tip2','<Tip2>');
  Tip3.Caption := Ini1.ReadString('Translation','Tip3','<Tip3>');
  Confirm.Message1.Caption := Ini1.ReadString('Translation','Message1','<Message1>');
  Confirm.Message2.Caption := Ini1.ReadString('Translation','Message2','<Message2>');
  Confirm.Yes.Caption := Ini1.ReadString('Translation','Yes','<Yes>');
  Confirm.No.Caption := Ini1.ReadString('Translation','No','<No>');
  Ini1.Free;
end;

//=== Fechar Form ==============================================================
procedure TForm1.FecharClick(Sender: TObject);
begin
Application.Terminate;
end;
//=== Fechar o Form ============================================================
procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var
  Ini1: TIniFile;
begin
  Ini1 := TIniFile.Create(ExtractFileDir(ParamStr(0))+'\config.ini');
  Ini1.WriteInteger('Translate','Lang',Combobox2.ItemIndex);
  Ini1.Free;
end;
//=== Criar o Form =============================================================
procedure TForm1.FormCreate(Sender: TObject);
var
  Ini1: TIniFile;
begin
//Listar Drivers
ComboBox1.Items:=ListaDrives;
ComboBox1.ItemIndex:=0;
//Background
Background.Height:=Form1.Height;
Background.Width :=Form1.Width;
Background.Left  :=0;
Background.Top   :=0;
//Verificar arquivos de tradução
Combobox2.Items := GetFileList(ExtractFileDir(ParamStr(0))+'\Languages\*.txt');
Combobox2.ItemIndex := 0;
//Desativar Vcl Style
Form1.StyleElements:=[];
CMD.StyleElements:=[seFont,seBorder];
end;
//=== Quando mostrar o Form ====================================================
procedure TForm1.FormShow(Sender: TObject);
var
  Ini1: TIniFile;
begin
  Ini1 := TIniFile.Create(ExtractFileDir(ParamStr(0))+'\config.ini');
  Combobox2.ItemIndex := Ini1.ReadInteger('Translate','Lang',0);
  Ini1.Free;
ComboBox2Change(self);
end;

//=== Esconder e mostrar o CMD =================================================
procedure TForm1.HideCMDClick(Sender: TObject);
begin
if (Form1.Height=274) and (Form1.Width=495) then
  begin
    Form1.Height:=459;
    Form1.Width :=1022;
    HideCMD.Caption:='<';
  end else begin
    Form1.Height:=274;
    Form1.Width :=495;
    HideCMD.Caption:='>';
  end;
Background.Height:=Form1.Height;
Background.Width :=Form1.Width;
Background.Left  :=0;
Background.Top   :=0;
end;

procedure TForm1.HWIDBoxKeyPress(Sender: TObject; var Key: Char);
begin
if not (Key in ['0'..'9','a'..'f','A'..'F',#8,#13]) then Key := #0;
if (Key in [#13]) then BTN_HWID.Click;
end;

//=== Minimizar Form ===========================================================
procedure TForm1.MinimizarClick(Sender: TObject);
begin
Application.Minimize;
end;
//== Timer 1 ===================================================================
procedure TForm1.Timer1Timer(Sender: TObject);
var HWIDHex: String;
begin
if TB_HWID.Checked=True then
  Begin
    HWIDHex:=IntToHex(GetVolumeID,8); //Converter Cardial em Hexadecimal
    Insert('-',HWIDHex,5);            //Adicionar - depois de 4 letras
    HWIDBox.Text:=HWIDHex;
  End;

HWIDHex:=GetHDDVolSerial(ComboBox1.text[1]);
Insert('-',HWIDHex,5);
Version.Caption:=ComboBox1.text[1]+':\ '+HWIDHex+'  | ['+VersaoExe+' ]';;
end;
end.
