unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Menus, Crypting, Unit2, Unit3, Unit5, XPMan, ToolWin,
  ComCtrls, ImgList, Buttons;


type
  TSauvegarde = class(TThread)
  protected
    procedure Execute; override;
  end;
  TForm1 = class(TForm)
    Panel1: TPanel;
    Splitter1: TSplitter;
    Panel2: TPanel;
    ListBox1: TListBox;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Timer1: TTimer;
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    MainMenu1: TMainMenu;
    Fichier1: TMenuItem;
    Edition1: TMenuItem;
    ToolButton1: TToolButton;
    ImageList1: TImageList;
    ToolButton2: TToolButton;
    ToolButton4: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    Nouveau1: TMenuItem;
    Enregistrer1: TMenuItem;
    Motsdepasse1: TMenuItem;
    Fermer1: TMenuItem;
    Outils1: TMenuItem;
    Panel3: TPanel;
    ButtonPrecedant: TButton;
    ButtonSuivant: TButton;
    ButtonNouveau: TButton;
    ButtonSauvegarder: TButton;
    ButtonPassword: TButton;
    ButtonQuitter: TButton;
    Changerdemotsdepasse1: TMenuItem;
    Annulerlechangement1: TMenuItem;
    RichEdit1: TRichEdit;
    ProgressBar1: TProgressBar;
    Label4: TLabel;
    N1: TMenuItem;
    Affichage1: TMenuItem;
    modeTexte1: TMenuItem;
    Text1: TMenuItem;
    Wordpad1: TMenuItem;
    procedure LitDossier();
    procedure ChargerConfig();
    procedure SauvegarderConfig();
    function DirectoryExists(const Name:string):boolean;
    function GetCurrentDir(): string;
    function Decode(Texte: string):string;
    procedure EcrireDansStatusBar1();
    function SiModifiedAlorsSauvegarder():boolean;
    procedure Config1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Splitter1Moved(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure RafraichirTitreDuContenu();
    procedure VerificationSiDocumentPorteUnNom();
    procedure ButtonNouveauClick(Sender: TObject);
    procedure ButtonSauvegarderClick(Sender: TObject);
    procedure ButtonQuitterClick(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure ButtonPrecedantClick(Sender: TObject);
    procedure ButtonSuivantClick(Sender: TObject);
    procedure ButtonPasswordClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Changerdemotsdepasse1Click(Sender: TObject);
    procedure Motsdepasse1Click(Sender: TObject);
    procedure Fermer1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Annulerlechangement1Click(Sender: TObject);
    procedure RichEdit1Change(Sender: TObject);
    procedure LectureDansMemo(Filename: string);
    procedure ToutFermer();
    procedure ModeDeLectureText1Click(Sender: TObject);
    procedure Wordpad1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

  end;

var
  Form1: TForm1;
  DataDir : string;
  AncienPassword : string;
  Panel2Width : integer;
  DocumentAEteModifie,
  ListBoxClicked : boolean;
  NombreDeFichiers: integer;
  FileToSave,
  PassNew,
  PassOld: string;

type // Variables de configuration
  TConfiguration=record
    Password: string[200];
    MemorisePassword: boolean;
    PasDemanderPassword: boolean;
  end;

var
  Config: TConfiguration;

const
  // Nom du fichier o� sera stoqu� la configuration
  FichierConfig = 'config.dat';

  // Cl� g�n�rique pour la sauvegarde du password dans le fichier config
  // Maximum 16 caract�res.
  ClePourLaSauvegardeDuMotsDePasse = '1q3e+*/@�#uas';

implementation

{$R *.DFM}

// Donne le dossier courant du programme
function TForm1.GetCurrentDir(): string;
const
  SIZE: cardinal = 1024;
var
  path: string;
  l: DWORD;
begin
  setcurrentdirectory(pchar(extractfiledir(application.exename)));
  SetLength(path, SIZE);
  l := GetCurrentDirectory(length(path), pchar(path));
  SetLength(path, l);
  result := path;
end;


// Charge la config
Procedure TForm1.ChargerConfig();
var
  Fichier:File of TConfiguration;
begin
  if FileExists(GetCurrentDir+'\'+FichierConfig) then begin
    AssignFile(Fichier, GetCurrentDir+'\'+FichierConfig);
    Reset(Fichier);
    read(Fichier, Config);
    CloseFile(Fichier);
    // D�code le password � l'aide de la cl� g�n�rique
    if Config.MemorisePassword = True then
      Config.Password := Cryptage.LanceDecodage(Config.Password, ClePourLaSauvegardeDuMotsDePasse)
    else
      Config.Password := '';
  end
  else begin // Si pas de config, alors charger config par d�faut
    Config.Password := '';
    Config.MemorisePassword := False;
    Config.PasDemanderPassword := False;
  end;
end;


// sauvegarde la config
Procedure TForm1.SauvegarderConfig();
var
  Fichier:File of TConfiguration;
  Password: string;
begin
  // S'il ne faut pas m�moriser le password
  // on le met dans une variable temporaire
  // et on efface le password avant de sauvegarder
  if Config.MemorisePassword = False then begin
    Password := Config.Password;
    Config.Password := 'noPasswordnoPass';
  end
  else begin// On m�morise le password
      Password := Cryptage.LanceCodage(Config.Password, ClePourLaSauvegardeDuMotsDePasse);
      Config.Password := Password;
  end;
  // Sauvegarde de la config
  AssignFile(Fichier, GetCurrentDir+'\'+FichierConfig);
  ReWrite(Fichier);
  Write(Fichier, Config);
  CloseFile(Fichier);

  // On remet le password dans la config
  if Config.MemorisePassword = False then
    Config.Password := Password
  else begin// On m�morise le password
      Password := Cryptage.LanceDecodage(Config.Password, ClePourLaSauvegardeDuMotsDePasse);
      Config.Password := Password;
  end;
end;


// Lit le dossier Sources pour remplir le menu de gauche
Procedure TForm1.LitDossier();
var
    Resultat:Integer;
    SearchRec:TSearchRec;
begin
  // compte le nombre de fichiers
  NombreDeFichiers := 0;
  // On efface le contenu de la listBox
  Form1.ListBox1.Clear;
  // On enl�ve le '\' � la fin pour �tre s�r d'�viter toute erreur
  If DataDir[length(DataDir)]='\' then DataDir:=copy(DataDir,1,length(DataDir)-1);
  // On parcourt chaques fichier du dossier Sources
  Resultat:=FindFirst(DataDir+'\*.*',0,SearchRec);
  while Resultat=0 do
  begin
    Application.ProcessMessages;
    if ((SearchRec.Attr and faDirectory)<=0)
    then
    begin
      // rempli le menu de gauche listBoX
      Form1.ListBox1.Items.Add(SearchRec.Name);
      // incr�mente le compteur de fichiers
      inc(NombreDeFichiers);
    end;
    Resultat:=FindNext(SearchRec);
  end;
  FindClose(SearchRec);
  // Refresh dans le StatusBar
  EcrireDansStatusBar1();

  Form1.Changerdemotsdepasse1.Enabled := NombreDeFichiers > 0;
end;


// V�rification si le document porte un nom avant de le sauvegarder
procedure TForm1.VerificationSiDocumentPorteUnNom();
var
  txt: string;
begin
  // On v�rifie si le document � besoin d'�tre nomm�
  if Form1.Edit1.Text = '' then begin
    MessageBeep(MB_ICONQUESTION);
    if MessageDlg('Le fichier ne contiend pas de nom, voulez-vous lui en donner?',  mtConfirmation, [mbYes, mbNo], 0) = IDYES then begin
      txt := Form1.Edit1.Text;
      if InputQuery('Donner un nom', 'Nom', txt) then begin
        ListBoxClicked := True;
        Form1.Edit1.Text := txt;
      end;
    end;
  end;
end;

// V�rification si besoin de sauvegarder
function TForm1.SiModifiedAlorsSauvegarder():boolean;
begin
  result := false;
  // On v�rifie si le document � besoin d'�tre sauvegard�
  if (DocumentAEteModifie = True ) then begin
    MessageBeep(MB_ICONQUESTION);
    if MessageDlg('Le fichier a �t� modifi�, voulez-vous le sauvegarder?',  mtConfirmation, [mbYes, mbNo], 0) = IDNO then
      Exit; // exit si on ne veut pas sauvegarder.
    VerificationSiDocumentPorteUnNom();
    if Edit1.Text <> '' then begin
      DocumentAEteModifie := False;
      // Sauvegarde du fichier
      Form1.RichEdit1.Lines.SaveToFile(Form1.GetCurrentDir+'\Save.tmp');
      Unit1.FileToSave := Form1.Edit1.Text;
      Unit1.TSauvegarde.Create(False);
      result := True;
    end;
  end;
  // On rafraichit le menu de gauche ListBoX
  Form1.LitDossier();
end;


// function permettant de savoir si un dossier existe
function TForm1.DirectoryExists(const Name:string):boolean;
var Code : integer;
begin
  Code:=GetFileAttributes(PChar(Name));
  Result:=(Code<>-1) and (FILE_ATTRIBUTE_DIRECTORY and Code<>0);
end;


// Initialisation au d�marrage
procedure TForm1.FormCreate(Sender: TObject);
begin
  ProgressBar1.Visible := False;
  Label4.Visible := False;
  DataDir :=  GetCurrentDir()+'\Source';
  if DirectoryExists(DataDir) = False then mkdir(DataDir);
  // On charge la config
  ChargerConfig();
  // On charge les autres fem�tres en m�moire sans les afficher tout de suite
  If Form2 = Nil then Form2 := TForm2.Create(Self); // fenetre demande de password
  If Form3 = Nil then Form3 := TForm3.Create(Self); // fenetre demande de password pour conversion
  If Form5 = Nil then Form5 := TForm5.Create(Self); // fen�tre de conversion
  Unit5.FileStreamLecture  := nil;
  Unit5.FileStreamEcriture := nil;
  // Si l'utilisateur veux qu'on lui demande son password au d�marrage
  if Config.PasDemanderPassword = False then begin
    // On cache la fen�tre principale et on affiche
    // la fenetre du Password apr�s une petite seconde � l'aide
    // d'un Timer (si non on ne peux plus fermer la fen�tre Password)
    Timer1.Enabled := true;
    // On cache la fen�tre principale
    Application.ShowMainForm := false;
  end;
  // Largeur du Panel2 au d�marrage
  Panel2Width := 183;
  // On rempli le menu de gauche
  LitDossier();
  // On efface le contenu dans Edit1
  Edit1.Text := '';
  // On efface le contenu dans RichEdit1
  RichEdit1.Clear;
  // Initialisation de la variable permettant de savoir si le document � besoin d'�tre sauvegard�
  DocumentAEteModifie := False;
  // On empeche de cliquer sur l'option "Annuler le changement" au d�marrage
  Annulerlechangement1.Enabled := False;
end;


procedure TForm1.Config1Click(Sender: TObject);
begin
  // Affiche la fenetre du mots de passe
  Form2.Visible := True;
end;


// Ecrit dans la barre d'�tat (en bas de la fen�tre)
procedure TForm1.EcrireDansStatusBar1();
begin
  // Affiche le nombre de fichiers
  StatusBar1.Panels[0].Text := IntToStr(NombreDeFichiers)+' fichiers';
  // Affiche le mode de lecture (s�curis� ou pas)
  if Config.Password <> '' then StatusBar1.Panels[1].Text := 'lecture s�curis�'
  else StatusBar1.Panels[1].Text := 'lecture non s�curis�';
  // Affiche le nombre de caract�res dans le memo
  StatusBar1.Panels[2].Text := IntToStr(RichEdit1.GetTextLen)+' caract�res.';
end;


procedure TForm1.ListBox1Click(Sender: TObject);
begin
  // V�rification si le document � besoin d'�tre sauvegard�
  if DocumentAEteModifie = True then SiModifiedAlorsSauvegarder();
  // On affiche le contenu sur lequel on a cliqu�
  if ListBox1.ItemIndex > -1 then begin
    Edit1.Text := ListBox1.Items.Strings[ListBox1.ItemIndex];
    LectureDansMemo(ListBox1.Items.Strings[ListBox1.ItemIndex]);
  end;
  // Initialise la detection de modification dans le document
  DocumentAEteModifie := False;
end;


procedure TForm1.FormResize(Sender: TObject);
begin
  // On redimensionne les fenetres si on bouge la fen�tre principale
  Panel1.Width := Form1.Width - Panel2Width-18;
  ListBox1.Width := Splitter1.Left - 6;
  Edit1.Width := Splitter1.Left -6;
  Splitter1Moved(self);
end;



procedure TForm1.Splitter1Moved(Sender: TObject);
begin
  // On redimensionne les fenetres si on bouge la barre de s�paration
  Panel2Width := Splitter1.Left;
end;


// function qui calcule le nombre de lettres identiques � Edit1
// elle sert � rechercher le mots le plus proche dans la ListBox
// La recherche est insensible � la case,
// c'est � dire qu'elle ne tiend pas compte des majuscules et minuscules.
function NbrLettresIdentiques(Cherche:string;txt:string):integer;
var
  i: integer;
begin
  // On est tomb� pile poile sur un nom de fichier
  if Cherche = txt then
    // On donne le max
    // Avec 1000 on est sur qu'auncun autre fichier
    // presque identique ne prendra sa place)
    result := 1000
  else begin // Compte le nombre de lettres identiques
    result := 0;
    for i:=1 to length(txt)-1 do begin
      // On transforme pour que la recherche soit insensible � la case
      if ord(txt[i]) in[65..90] then txt[i] := chr(ord(txt[i]) + ord('a') - ord('A'));
      if ord(Cherche[i]) in[65..90] then Cherche[i] := chr(ord(Cherche[i]) + ord('a')-ord('A'));
      // Si on tombe sur une lettre identique
      if txt[i] = Cherche[i] then inc(result) // incr�mente
      // On s'arr�te d�s qu'on voit une diff�rence
      else exit;
    end;
  end;
end;


procedure TForm1.Edit1Change(Sender: TObject);
var
    Resultat:Integer;
    SearchRec:TSearchRec;
    i,
    index,
    NbrLettres : integer;
begin
  // Si RichEdit1 a chang� � cause d'un clique dans le ListBox alors on sort.
  if ListBoxClicked = True then exit;

  // On a �crit dans l'RichEdit1
  // alors on recherche dans la ListBox le mots le plus proche
  if Edit1.text = '' then
    ListBox1.ItemIndex := -1
  else begin
    NbrLettres := -1;
    If DataDir[length(DataDir)]='\' then DataDir:=copy(DataDir,1,length(DataDir)-1);
    i := 0;
    index := -1;
    Resultat:=FindFirst(DataDir+'\*.*',0,SearchRec);
    // On parcourt toutes les donn�es
    while Resultat=0 do begin
      Application.ProcessMessages;
      if ((SearchRec.Attr and faDirectory)<=0) then begin
        if Edit1.text <> '' then
          // Si on tombe sur le mots qui a le plus de lettres identiques
          if NbrLettresIdentiques(Edit1.Text,SearchRec.Name) > NbrLettres then begin
            // M�morise le mots
            index := i;
            // M�morise le nombre de lettres identiques (score � battre)
            NbrLettres := NbrLettresIdentiques(Edit1.Text,SearchRec.Name);
          end;
        inc(i);
      end;
      Resultat:=FindNext(SearchRec);
    end;
    FindClose(SearchRec);
    // Mots le plus proche trouv�
    // On le selectionne
    ListBox1.ItemIndex := index;
    // Refresh dans le StatusBar
    EcrireDansStatusBar1();
    // Affiche le contenu s'il y a quelque chose � afficher
    if (ListBox1.ItemIndex > -1) and ( ListBox1.Items.Strings[ListBox1.ItemIndex] <> '' ) then begin
     LectureDansMemo(ListBox1.Items.Strings[ListBox1.ItemIndex]);
    end;
    // Positionne la fenetre du contenu au d�but
    RichEdit1.SelStart := 0;
    RichEdit1.SelLength := 0;
    // Ne pas demander de sauvegarder le changement qu'on vient de faire dans le m�mo1
    DocumentAEteModifie := False;
  end;
end;


procedure TForm1.ButtonNouveauClick(Sender: TObject);
begin
  SiModifiedAlorsSauvegarder();
  Edit1.Text := '';
  Label3.Caption := 'Contenu:';
  RichEdit1.Clear;
  DocumentAEteModifie := False;
end;


// Thread pour la sauvegarde
procedure TSauvegarde.Execute;
var
  FileLecture,
  FileEcriture: TFileStream;
  Lettre, txt: string;
  TextDeTailleMax: integer; // en caract�res
begin
  // Ouvre le fichier qui contient le texte en clair � sauvegarder
  FileLecture := TFileStream.Create(Form1.GetCurrentDir+'\Save.tmp', fmOpenRead or fmShareDenyWrite);
  // Ecrit le texte crypt�
  FileEcriture := TFileStream.Create(DataDir+'\'+Unit1.FileToSave, fmCreate or fmOpenWrite or fmShareDenyWrite);
  // Variable permettant de stoper la conversion
  BoutonAnnulerClicked := False;
  // On lit le fichier � crypter
  while (FileLecture.Position < FileLecture.Size)
   and  (BoutonAnnulerClicked = False)  do begin
    txt := '';
    // On coupe le texte de fa�on al�atoire
    TextDeTailleMax := random(1000)+1000; // entre 1000 et 2000 caract�res
    // Si on prend trop par rapport � ce qu'il reste
      if TextDeTailleMax > FileLecture.Size - FileLecture.Position then
        // on prend le reste
        TextDeTailleMax := FileLecture.Size - FileLecture.Position;
    // On lit et stoque dans txt
    SetLength(Lettre, TextDeTailleMax);
    FileLecture.ReadBuffer(Lettre[1], TextDeTailleMax);
    SetLength(txt, TextDeTailleMax);
    txt := Lettre;

    // S'il y a un mots de passe pour le cryptage
    if Config.Password <> '' then txt := Cryptage.LanceCodage(txt, Config.Password)+';'; // on s�pare le texte par un ;
    // On �crit le texte
    if txt <> '' then FileEcriture.WriteBuffer(PChar(txt)^, Length(txt));
  end;
  // Fin du fichier
  // Ferme les fichiers
  FileLecture.Free;
  FileEcriture.Free;
  // Efface le texte en clair
  DeleteFile(PAnsiChar(Form1.GetCurrentDir+'\Save.tmp'));
  // Initialise la d�tection si le document � �t� modifi�
  DocumentAEteModifie := False;
  messagebox(0, ' Le fichier a bien �t� sauvegard�! ', '', MB_OK);
  // Rafraichit le menu de gauche
  Form1.LitDossier();
end;


procedure TForm1.ButtonSauvegarderClick(Sender: TObject);
begin
  VerificationSiDocumentPorteUnNom();
  if Edit1.text <> '' then begin
    if FileExists(DataDir+'/'+Edit1.Text) then begin
      MessageBeep(MB_ICONQUESTION);
      if MessageDlg('Le fichier existe d�j�, voulez-vous le remplacer?',  mtConfirmation, [mbYes, mbNo], 0) = IDNO then
        exit;
    end;
    // Sauvegarde du contenu de RichEdit1 dans un fichier temporaire
    Form1.RichEdit1.Lines.SaveToFile(Form1.GetCurrentDir+'\Save.tmp');
    Unit1.FileToSave := Form1.Edit1.Text;
    // Lancement de la sauvegarde dans un Thread pour ne pas bloquer le reste
    Unit1.TSauvegarde.Create(False);
  end;
end;


procedure TForm1.ButtonQuitterClick(Sender: TObject);
begin
  SiModifiedAlorsSauvegarder();
  ToutFermer();
  Form5.VideDossierTemporaire;
  Application.Terminate;
end;


// On vient d'entrer une lettre dans l'Edit1
procedure TForm1.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
  // Si on a sauvegard� alors on annule la derni�re lettre entr� au clavier
  if SiModifiedAlorsSauvegarder() = True then Key := #0;
end;


procedure TForm1.ButtonPrecedantClick(Sender: TObject);
begin
 if ListBox1.ItemIndex > 0 then begin
   ListBox1.ItemIndex := ListBox1.ItemIndex - 1;
   ListBox1Click(Sender);
 end;
end;


procedure TForm1.ButtonSuivantClick(Sender: TObject);
begin

 if ListBox1.ItemIndex < ListBox1.Items.Count then begin
   ListBox1.ItemIndex := ListBox1.ItemIndex + 1;
   ListBox1Click(Sender);
 end;
end;


procedure TForm1.ButtonPasswordClick(Sender: TObject);
begin
  Unit5.LitQueUnFichier := False;
  ToutFermer();
  Form2.show;
end;


procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Form2.show;
  Timer1.enabled := False;
end;


procedure TForm1.Changerdemotsdepasse1Click(Sender: TObject);
begin
  Unit5.BoutonAnnulerClicked := True;
  ToutFermer();
  Unit5.LitQueUnFichier := False;
  Form1.hide;
  Form3.Show;
end;


procedure TForm1.Motsdepasse1Click(Sender: TObject);
begin
  ToutFermer();
  Unit5.BoutonAnnulerClicked := True;
  Unit5.LitQueUnFichier := False;  
  Form1.hide;
  Form2.Show;
end;


procedure TForm1.Fermer1Click(Sender: TObject);
begin
  SiModifiedAlorsSauvegarder();
  Unit5.BoutonAnnulerClicked := True;
  ToutFermer();
  Application.Terminate;
end;


procedure TForm1.ToutFermer();
begin
  Unit5.BoutonAnnulerClicked := (Unit5.FileStreamLecture <> nil) or (Unit5.FileStreamEcriture <> nil);
  if Unit5.FileStreamLecture <> nil then begin
    Unit5.FileStreamLecture.Free;
    Unit5.FileStreamLecture := nil;
  end;
  if Unit5.FileStreamEcriture <> nil then begin
    Unit5.FileStreamEcriture.Free;
    Unit5.FileStreamEcriture := nil;
  end;
  Form5.ToutFermer;
end;


procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  txt: string;
begin
  SiModifiedAlorsSauvegarder();
  Form5.VideDossierTemporaire;
  if Annulerlechangement1.Enabled = True then begin
    txt := 'Vous avez chang� de mots de passe. Si vous fermez cette fen�tre, '
          +'il ne sera plus possible d''annuler l''op�ration. '
          +'V�rifiez bien que vos documents sont toujours lisibles avant '
          +'de fermer l''aplication. Etes-vous s�r de vouloir quitter?';
    if MessageDlg(txt,  mtConfirmation, [mbYes, mbNo], 0) = IDNO then begin
      // Annule la fermeture
      CanClose := False;
      Exit;
    end;
  end;
  ToutFermer();
  Application.Terminate;
end;


// On effectue l'op�ration inverse du dernier changement de mots de passe
procedure TForm1.Annulerlechangement1Click(Sender: TObject);
begin
  Form3.Edit1.Text := Config.Password;
  Form3.Edit2.Text := AncienPassword;
  Form3.Edit3.Text := AncienPassword;
  Form5.Show;
  Form1.Hide;
  Form5.Initialisation();
  Unit5.TConversion.Create(False);
end;


procedure TForm1.RichEdit1Change(Sender: TObject);
begin
  // Si le changement du RichEdit ne provient pas
  // d'un click dans la ListBox
  if ListBoxClicked = False then
    // alors on m�morise que le m�mo � besoin d'�tre sauvegard�
    DocumentAEteModifie := True
  // RichEdit � chang� � cause d'un click
  else
    // Initialise pour le prochain changement
    ListBoxClicked := False;
end;


procedure TForm1.LectureDansMemo(Filename: string);
var
  f: file of byte;
  TexteEnClair: string;
  Size: integer;
begin
  // On lit un fichier crypt�
  if Config.Password <> '' then begin
    // Si on est d�j� en train de lire un fichier alors on stop la lecture
    if (Unit5.FileStreamLecture <> nil) or (Unit5.FileStreamEcriture <> nil) then begin
      Unit5.BoutonAnnulerClicked := True;
      RafraichirTitreDuContenu();
    end;
    // Ferme le fichier en cours de lecture
    if Unit5.FileStreamLecture <> nil then begin
      sleep(500); // emp�che de clicker trop vite dans la ListBox (si non plantage)
      Unit5.FileStreamLecture.Free;
      Unit5.FileStreamLecture := nil;
    end;
    // Ferme le fichier en cours d'�criture
    if Unit5.FileStreamEcriture <> nil then begin
      Unit5.FileStreamEcriture.Free;
      Unit5.FileStreamEcriture := nil;
    end;
    // M�morise l'ancien et le nouveau password
    PassOld := Form3.Edit1.Text;
    PassNew := Form3.Edit2.Text;
    // Indique qu'on veux d�crypter pour y lire
    Form3.Edit1.Text := Config.Password;
    Form3.Edit2.Text := '';
    // Regarde la taille du fichier � lire
    AssignFile(f, DataDir+'\'+Filename);
    Reset(f);
    Size := FileSize(f);
    CloseFile(f);
    // D�cryptage d'un grand fichier texte
    // On s'aide du disque dur et on lit les fichiers caract�res par caract�res
    if Size > 50000 then begin
      // Ouvre en lecture le fichier � d�coder
      Unit5.FileStreamLecture := TFileStream.Create(DataDir+'\'+Filename, fmOpenRead or fmShareDenyWrite);
      // Ouvre en �criture le fichier en clair
      Unit5.FileStreamEcriture := TFileStream.Create(Form1.GetCurrentDir+'\Temp.txt', fmCreate or fmOpenWrite or fmShareDenyWrite);
      // Met � jour le titre du contenu
      Label3.Caption := pchar('Conversion:');
      ProgressBar1.Position := 0;
      ProgressBar1.Visible := True;
      Label4.Visible := True;
      // Initialisation avant d�codage
      Unit5.LitQueUnFichier := True;
      Unit5.LitQueUnFichier := True;
      Unit5.BoutonAnnulerClicked := False;
      Form5.SelectionnePremierFichier();
      Unit5.SelectFichier := 0;
      Unit5.Texte := '';
      RichEdit1.Clear;
      // Lance le d�codage dans un Thread
      Unit5.TConversion.Create(False);
    end
    else begin
      // Lecture d'un petit fichier (d�cryptage rapide sur la m�moire Ram)
      Unit5.FileStreamLecture := TFileStream.Create(DataDir+'\'+Filename, fmOpenRead or fmShareDenyWrite);
      // On lit tout d'un coup
      try
        if Unit5.FileStreamLecture.Size = 0 then Exit;
        SetLength(TexteEnClair, Unit5.FileStreamLecture.Size);
        Unit5.FileStreamLecture.ReadBuffer(TexteEnClair[1], Unit5.FileStreamLecture.Size);
      finally
        Unit5.FileStreamLecture.Free;
        Unit5.FileStreamLecture := nil;
      end;
      // D�crypte si n�cessaire
      if Config.Password <> '' then TexteEnClair := Decode(TexteEnClair);
      // Affiche le contenu dans le RichEdit
      if TexteEnClair <> '' then RichEdit1.SetTextBuf(pchar(TexteEnClair));
      RafraichirTitreDuContenu();
    end;
  end
  // On lit un fichier non crypt�
  else begin
    RichEdit1.Lines.LoadFromFile(DataDir+'/'+Filename);
    RafraichirTitreDuContenu();
  end;
  EcrireDansStatusBar1();
end;


procedure TForm1.RafraichirTitreDuContenu();
var
  titre: string;
begin

      if ListBox1.ItemIndex > -1 then begin
        titre:= ListBox1.Items.Strings[ListBox1.ItemIndex];
        Form1.Caption := ListBox1.Items.Strings[ListBox1.ItemIndex];
      end;

      Label3.Caption := pchar(titre);
      ProgressBar1.Visible := False;
      Label4.Visible := False;
      Form3.Edit1.Text := '';
      Form3.Edit2.Text := '';
      Form3.Edit3.Text := '';
end;


function TForm1.Decode(Texte: string):string;
var
  TexteSepare: string;
  i: integer;
begin
  result := '';
  // On parcourt tout le texte lettre par lettre
  for i := 1 to Length(Texte) do begin
    if Texte[i] <> ';' then
      // On stoque la lettre tant qu'on ne trouve pas de ';'
      TexteSepare := TexteSepare + Texte[i]
    else begin
      // On a le texte en entier, on peux d�crypter
      result :=  result + Cryptage.LanceDecodage(TexteSepare, Config.password);
      TexteSepare := '';
    end;
  end;
  // Si le texte n'a pas de ';' � la fin (d�e aux anciennes versions du programme) alors d�crypte
  if Length(TexteSepare) > 0 then result := result + Cryptage.LanceDecodage(TexteSepare, Config.password);
end;

procedure TForm1.Wordpad1Click(Sender: TObject);
begin
  // Affiche en mode WordPad (gras, soulign�, etc..)
  RichEdit1.PlainText := False;
  Text1.Checked := False;
  Wordpad1.Checked := True;
end;

procedure TForm1.ModeDeLectureText1Click(Sender: TObject);
begin
  // Affichage en mode Texte (adapt� � la programmation)
  RichEdit1.PlainText := True;
  Text1.Checked := True;
  Wordpad1.Checked := False;
end;


end.
