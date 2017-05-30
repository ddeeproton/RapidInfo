object Form2: TForm2
  Left = 269
  Top = 132
  BorderStyle = bsDialog
  Caption = 'Veuillez entrter le mots de passe'
  ClientHeight = 159
  ClientWidth = 312
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label3: TLabel
    Left = 8
    Top = 2
    Width = 69
    Height = 13
    Caption = 'Mots de passe'
  end
  object Label1: TLabel
    Left = 8
    Top = 42
    Width = 248
    Height = 13
    Caption = 'Le mots de passe sera utilisé comme clé d'#39'encodage'
  end
  object Label2: TLabel
    Left = 8
    Top = 58
    Width = 234
    Height = 13
    Caption = 'et doit comporter 1 à 16 lettres (vide = non crypté)'
  end
  object Edit1: TEdit
    Left = 8
    Top = 18
    Width = 295
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    MaxLength = 16
    PasswordChar = '*'
    TabOrder = 0
    Text = 'Edit1'
    OnKeyDown = Edit1KeyDown
  end
  object ButtonOK: TButton
    Left = 73
    Top = 124
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 3
    OnClick = ButtonOKClick
  end
  object ButtonAnnuler: TButton
    Left = 156
    Top = 124
    Width = 75
    Height = 25
    Caption = 'Annuler'
    TabOrder = 4
    OnClick = ButtonAnnulerClick
  end
  object CheckBox1: TCheckBox
    Left = 8
    Top = 76
    Width = 257
    Height = 17
    Caption = 'Se souvenir du mots de passe (non recommandé)'
    TabOrder = 1
  end
  object CheckBox2: TCheckBox
    Left = 8
    Top = 100
    Width = 297
    Height = 17
    Caption = 'Ne pas afficher cette fenêtre au démarrage de l'#39'application'
    TabOrder = 2
  end
end
