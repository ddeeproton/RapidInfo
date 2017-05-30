unit Unit5;

interface

uses
  Windows, SysUtils,  Forms,  Dialogs, ShellApi,
   Unit3, Classes,  Controls, ExtCtrls, ComCtrls, StdCtrls;

type
  TForm5 = class(TForm)
    Timer1: TTimer;
    ButtonAnnuler: TButton;
    ProgressBar1: TProgressBar;
    ProgressBar2: TProgressBar;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ButtonPause: TButton;
    RadioButton2: TRadioButton;
    RadioButton1: TRadioButton;
    Label4: TLabel;
    StatusBar1: TStatusBar;
    procedure Initialisation();
    procedure NbrCaracteresAConvertirTotal();
    procedure SelectionnePremierFichier();
    procedure OuvreFichier();
    procedure Lecture();
    procedure VitesseRapideOuLente();
    procedure Analyse(Caractere:string);
    procedure Convertit();
    procedure Enregistre();
    procedure FichierSuivant();
    procedure FermerFichiers();
    procedure MiseAJourAffichage();
    procedure MiseAJourAffichageForm1();
    procedure ChangeVitesseClick();
    procedure ToutFermer();
    procedure RemplaceLesFichiers();
    procedure VideDossierTemporaire();
    procedure Timer1LectureLente(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ButtonAnnulerClick(Sender: TObject);
    procedure ButtonPauseClick(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
  private
    { Private declarations }
  public                                     
    { Public declarations }

  end;

  TConversion = class(TThread)
  private
    { Déclarations privées }
  protected
    procedure Execute; override;
  end;

var
  Form5: TForm5;
  FileStreamLecture,
  FileStreamEcriture: TFileStream;
  SelectFichier: integer; // si vaut zéro alors on peux lire un nouveau fichier
  Texte: string;

  SearchRec: TSearchRec; // Contient les fichiers à convertir
  BoutonAnnulerClicked: boolean;
  NbrCaracteresTotaux,
  NbrCaracteresConvertis: integer;
  LitQueUnFichier,
  BouttonSauvegarderClicked: boolean;

const
  Attributs = faHidden + faSysFile+ faVolumeID + faArchive;

implementation

{$R *.DFM}

uses Unit1, Unit2, Crypting;

// Initialisation avant la conversion de tous les documents
procedure TForm5.Initialisation();
begin
  Unit5.FileStreamLecture := nil;
  Unit5.FileStreamEcriture := nil;
  if not Form1.DirectoryExists(Form1.GetCurrentDir+'\Temp') then mkdir(Form1.GetCurrentDir+'\Temp');
  BoutonAnnulerClicked := False;
  LitQueUnFichier:= False;
  NbrCaracteresAConvertirTotal();
  NbrCaracteresConvertis := 0;       
  SelectionnePremierFichier();
  OuvreFichier();
end;


procedure TForm5.NbrCaracteresAConvertirTotal();
var
  Resultat: integer;
  SearchFile: TSearchRec;
begin
  NbrCaracteresTotaux := 1;
  Resultat := FindFirst(Unit1.DataDir+'\*.*',Attributs,SearchFile);
  while Resultat = 0 do begin
    NbrCaracteresTotaux := NbrCaracteresTotaux + SearchFile.Size;
    Resultat := FindNext(SearchFile);
  end;
  FindClose(SearchFile);
end;


procedure TForm5.SelectionnePremierFichier();
begin
  SelectFichier := FindFirst(Unit1.DataDir+'/*.*',Attributs,SearchRec);
end;


procedure TForm5.OuvreFichier();
var
  Fichier: string;
begin
  // Ouvre le fichier en Lecture
  Fichier := Unit1.DataDir+'\'+SearchRec.Name;
  FileStreamLecture := TFileStream.Create(Fichier, fmOpenRead or fmShareDenyWrite);
  //Ouvre un second fichier en Ecriture
  Fichier := Form1.GetCurrentDir+'\Temp\'+SearchRec.Name+'.tmp';
  FileStreamEcriture := TFileStream.Create(Fichier, fmCreate or fmOpenWrite or fmShareDenyWrite);
end;


procedure TForm5.VitesseRapideOuLente();
begin
    // Conversion rapide
    if RadioButton1.Checked = True then TConversion.Create(False)
    // Conversion lente
    else Timer1.Enabled := True;
end;



// Conversion rapide à l'aide d'un thread
procedure TConversion.Execute;
begin
  while (SelectFichier = 0)
    and (BoutonAnnulerClicked = False)
    and (Form5.RadioButton1.Checked = True) do
      Form5.Lecture();
  if Form5.RadioButton2.Checked = True then Form5.Timer1.Enabled := True;
end;


// Conversion Lente à l'aide d'un Timer (plus lent mais allège le processeur)
procedure TForm5.Timer1LectureLente(Sender: TObject);
begin
  Timer1.Enabled := False;
  if (BoutonAnnulerClicked = True) then exit;
  if SelectFichier = 0 then Lecture();
  VitesseRapideOuLente;
end;



// Lecture, conversion et écriture
procedure TForm5.Lecture();
var
   Lettre: String;
   TextDeTailleMax: integer; // Caractères
begin
  if LitQueUnFichier = False then MiseAJourAffichage()
  else MiseAJourAffichageForm1();

   // Si on n'est pas à la fin du fichier
  if (FileStreamEcriture = nil) or (FileStreamLecture = nil) then exit;
  if (FileStreamLecture.Position < FileStreamLecture.Size) then begin
    // On lit un fichier crypté
    if Form3.Edit1.Text <> '' then begin
       //messagebox(0, ' On lit un fichier crypté ', '', MB_OK);
      // Lecture lettre par lettre
      inc(NbrCaracteresConvertis);
      SetLength(Lettre, 1);
      FileStreamLecture.ReadBuffer(Lettre[1], 1);
      Analyse(Lettre[1]);
    end
    // On lit un fichier non crypté
    else begin
      // On coupe le texte de façon aléatoire
      TextDeTailleMax := random(1000)+1000; // entre 500 et 1000
      // Si on prend trop par rapport à ce qu'il reste
      if TextDeTailleMax > FileStreamLecture.Size - FileStreamLecture.Position then
        // on prend pile le reste
        TextDeTailleMax := FileStreamLecture.Size - FileStreamLecture.Position;

      SetLength(Lettre, TextDeTailleMax);
      FileStreamLecture.ReadBuffer(Lettre[1], TextDeTailleMax);
      SetLength(Texte, TextDeTailleMax);
      Texte := Lettre;
      NbrCaracteresConvertis := NbrCaracteresConvertis + TextDeTailleMax;
      Convertit();
      Enregistre();
    end;
  end
  // Fin du fichier
  else begin
    if Texte <> '' then begin
      Convertit();
      Enregistre();
    end;
    FermerFichiers();

    if LitQueUnFichier = False then begin
      // S'il reste un dernier texte à convertir
      FichierSuivant()
    end
    else begin
      BoutonAnnulerClicked := True;

      Form1.RichEdit1.Lines.LoadFromFile(Form1.GetCurrentDir+'\Temp.txt');
      DeleteFile(PAnsiChar(Form1.GetCurrentDir+'\Temp.txt'));

      Unit1.DocumentAEteModifie := False;
      Form1.RafraichirTitreDuContenu();
    end;
  end;
end;


procedure TForm5.Analyse(Caractere:string);
begin
  // Le texte séparé est délimité par un ';'
  if Caractere[1] <> ';' then
    Texte := Texte + Caractere[1]
  else begin
    Convertit();
    Enregistre();
  end;
end;


procedure TForm5.Convertit();
begin
  With Form3 do begin
    // S'il y a un mots de passe pour le décryptage
    if Edit1.Text <> '' then
      Texte := Cryptage.LanceDecodage(Texte, Edit1.Text);
    // S'il y a un mots de passe pour le cryptage
    if Edit2.Text <> '' then
      Texte := Cryptage.LanceCodage(Texte, Edit2.Text)+';'; // on sépare le texte par un ;
  end;
end;




procedure TForm5.FichierSuivant();
begin
  // Remet à zéro
  Texte := '';
  SetLength(Texte, 0);
  // Passe au fichier suivant
  SelectFichier := FindNext(SearchRec);
  // S'il reste des fichiers à convertir
  if SelectFichier = 0 then
    OuvreFichier()
  else begin
    Timer1.Enabled := False;
    // On arrête la lecture
    Form1.Annulerlechangement1.Enabled := True;
    // On mémorise le nouveau password
    Config.Password := Form3.Edit2.Text;
    Form2.Edit1.Text := Form3.Edit2.Text;
    // On mémorise l'ancien password
    Unit1.AncienPassword := Form3.Edit1.Text;
    // Sauvegarde le nouveau password sur le disque dur
    Form1.SauvegarderConfig();
    // On remplace les fichiers avec l'ancien password par les nouveaux
    RemplaceLesFichiers();
    // On supprime le dossier temporaire
    VideDossierTemporaire();
    // Affiche la fenêtre principal
    Form1.Show;
    Form5.Hide;
  end;
end;





procedure TForm5.FermerFichiers();
begin
  if FileStreamLecture <> nil then begin
    FileStreamLecture.Free;
    FileStreamLecture := nil;
  end;
  if FileStreamEcriture <> nil then begin
    FileStreamEcriture.Free;
    FileStreamEcriture := nil;
  end;
end;


procedure TForm5.RemplaceLesFichiers();
var
  Resultat  : integer;        // Si = 0 : On a trouvé un fichier correspondant
  SearchFile     : TSearchRec; // Répertorie les caract. du fichier en cours                                // (ex: Nom)
begin
  Resultat := FindFirst(Unit1.DataDir+'\*.*',Attributs,SearchFile);
  while Resultat = 0 do begin
    MoveFileEx(pchar(Form1.GetCurrentDir+'\Temp\'+SearchFile.Name+'.tmp'),
                     pchar(Unit1.DataDir+'\'+SearchFile.Name),
                     MOVEFILE_REPLACE_EXISTING);
    Resultat := FindNext(SearchFile);
  end;
  FindClose(SearchFile);// libération de la mémoire
end;



procedure TForm5.VideDossierTemporaire();
var
    Resultat  : integer;        // Si = 0 : On a trouvé un fichier correspondant
    SearchFile     : TSearchRec; // Répertorie les caract. du fichier en cours
begin
  if FileExists(Form1.GetCurrentDir+'\Save.tmp') then
    DeleteFile(PAnsiChar(Form1.GetCurrentDir+'\Save.tmp'));
  if Form1.DirectoryExists(Form1.GetCurrentDir+'\Temp') = True then begin
    Resultat := FindFirst(Form1.GetCurrentDir+'\Temp\*.*',Attributs,SearchFile);
    while Resultat = 0 do begin
      DeleteFile(PAnsiChar(Form1.GetCurrentDir+'\Temp\'+SearchFile.Name));
      Resultat := FindNext(SearchFile);
    end;
    FindClose(SearchFile);// libération de la mémoire
    RemoveDirectory(pchar(Form1.GetCurrentDir+'\Temp'));
  end;
end;


procedure TForm5.Enregistre();
begin
  if (FileStreamEcriture <> nil) and (Texte <> '') then
    FileStreamEcriture.WriteBuffer(PChar(Texte)^, Length(Texte));
  Texte := '';
end;


procedure TForm5.MiseAJourAffichage();
begin
  if FileStreamLecture.Size > 0 then ProgressBar1.Position := (FileStreamLecture.Position*100) div (FileStreamLecture.Size);
  if NbrCaracteresTotaux > 0 then ProgressBar2.Position := (NbrCaracteresConvertis*100) div NbrCaracteresTotaux;
  Label1.Caption := pchar('Fichier: '+inttostr(ProgressBar1.Position)+'%');
  Label2.Caption := pchar('Total: '+inttostr(ProgressBar2.Position)+'%');
  Label3.Caption := pchar(SearchRec.Name);
end;


procedure TForm5.MiseAJourAffichageForm1();
begin
  if FileStreamLecture.Size > 0 then Form1.ProgressBar1.Position := (FileStreamLecture.Position*100) div (FileStreamLecture.Size);
  Form1.Label4.Caption := pchar(inttostr(Form1.ProgressBar1.Position)+'%');
end;

procedure TForm5.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  Form1.ToutFermer;
end;

procedure TForm5.ButtonAnnulerClick(Sender: TObject);
var
  txt: string;
begin
    BoutonAnnulerClicked := True;
    txt := 'Voulez-vous annuler la conversion?';
    MessageBeep(MB_ICONQUESTION);
    if MessageDlg(txt,  mtConfirmation, [mbYes, mbCancel], 0) = IDYES then
      Form1.ToutFermer
    else
      ButtonPauseClick(Self);
end;


procedure TForm5.ToutFermer();
begin
  BoutonAnnulerClicked := True;
  FindClose(SearchRec);
  FileStreamEcriture.free;
  VideDossierTemporaire();
  Form1.Show;
  Form5.Hide;
end;

procedure TForm5.ButtonPauseClick(Sender: TObject);
begin
  if BoutonAnnulerClicked = False then begin
    ButtonPause.Caption := 'Recommencer';
    BoutonAnnulerClicked := True;
  end
  else begin
    ButtonPause.Caption := 'Pause';
    BoutonAnnulerClicked := False;
    VitesseRapideOuLente;
  end;
end;

procedure TForm5.ChangeVitesseClick();
begin
  if BoutonAnnulerClicked = True then begin
    BoutonAnnulerClicked := False;
    VitesseRapideOuLente;
  end;
end;

procedure TForm5.RadioButton1Click(Sender: TObject);
begin
  ChangeVitesseClick();
end;

procedure TForm5.RadioButton2Click(Sender: TObject);
begin
  ChangeVitesseClick();
end;

end.
