unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TForm2 = class(TForm)
    Edit1: TEdit;
    ButtonOK: TButton;
    ButtonAnnuler: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Label3: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ButtonOKClick(Sender: TObject);
    procedure ButtonAnnulerClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

uses Unit1;

{$R *.DFM}


procedure TForm2.FormCreate(Sender: TObject);
begin
  Application.BringToFront;
  Edit1.Text := Config.Password;
  CheckBox1.Checked := Config.MemorisePassword;
  CheckBox2.Checked := Config.PasDemanderPassword;
end;


procedure TForm2.Edit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ord(Key) = 13 then begin // Touche Enter
    ButtonOKClick(Sender); // alors executer bouton OK
  end;
end;


procedure TForm2.ButtonOKClick(Sender: TObject);
begin
  // Enregistre la config
  Config.Password := Edit1.Text;
  Config.MemorisePassword := CheckBox1.Checked;
  Config.PasDemanderPassword := CheckBox2.Checked;
  Form1.SauvegarderConfig();
  // Cache la fenetre Password et affiche la principale
  Form2.hide;
  Form1.Show;
  // Rafraichit le menu de gauche et le contenu
  Form1.LitDossier();
  Form1.ListBox1Click(Sender);
end;


procedure TForm2.ButtonAnnulerClick(Sender: TObject);
begin
  Form1.Show;
  Form2.hide;
end;


procedure TForm2.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  Form1.Show;
end;

end.
