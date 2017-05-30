unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Crypting, ComCtrls;


type
  TForm3 = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    ButtonConvertir: TButton;
    ButtonAnnuler: TButton;
    Label2: TLabel;
    Label3: TLabel;
    CheckBox1: TCheckBox;
    Edit3: TEdit;
    Label5: TLabel;
    GroupBox1: TGroupBox;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
   // procedure Convertir();
    procedure CheckBox1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ButtonAnnulerClick(Sender: TObject);
    procedure ButtonConvertirClick(Sender: TObject);
    procedure CacherLesMotsDePasse();
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.DFM}

uses Unit1, Unit2, Unit5;

procedure TForm3.CacherLesMotsDePasse();
begin
  if CheckBox1.Checked = True then begin
    Edit1.PasswordChar := '*';
    Edit2.PasswordChar := '*';
    Edit3.PasswordChar := '*';
  end
  else begin
    Edit1.PasswordChar := #0;
    Edit2.PasswordChar := #0;
    Edit3.PasswordChar := #0;
  end;
end;


procedure TForm3.CheckBox1Click(Sender: TObject);
begin
  CacherLesMotsDePasse();
end;

procedure TForm3.FormCreate(Sender: TObject);
begin
  Edit1.Text := '';
  Edit2.Text := '';
  Edit3.Text := '';

  CheckBox1.Checked := True; // par défaut on cache les mots de passe
  CacherLesMotsDePasse();
end;

procedure TForm3.ButtonAnnulerClick(Sender: TObject);
begin
  Form3.Hide;
  Form1.Show;
end;


procedure TForm3.ButtonConvertirClick(Sender: TObject);
var
  txt: string;
begin
  if Edit2.Text <> Edit3.Text then begin
    txt := 'Le mots de passe de confirmation est différent du nouveau mot de passe. '
          +'La convertion est annulé.';
    MessageBeep(MB_ICONEXCLAMATION);
    MessageDlg(txt,  mtInformation, [mbOK], 0);
    exit;
  end;

  if Config.Password <> Form3.Edit1.Text then begin
    txt := 'Attention! L''ancien mots de passe est différent de celui qui est en mémoire. La conversion risque d''échouer. Voulez-vous continuer?';
    if MessageDlg(txt,  mtConfirmation, [mbYes, mbNo], 0) = IDNO then
      Exit;
  end;
  
  txt := 'Vous allez changer de clé de cryptage pour vos documents. '
        +'Ceci risque de prendre un certains temps en fonction du volume à traiter. '
        +'Vous pouvez annuler l''action si l''ancien mots de passe que vous avez entré est faux '
        +'et que vos documents sont illisibles. Voulez-vous continuer? ';
  if MessageDlg(txt,  mtConfirmation, [mbYes, mbNo], 0) = IDNO then
    Exit;

  Form5.Show;
  Form3.Hide;
  Unit5.LitQueUnFichier := False;
  Form5.Initialisation();
  Unit5.TConversion.Create(False);

end;

procedure TForm3.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  Form1.Show;
end;

end.
