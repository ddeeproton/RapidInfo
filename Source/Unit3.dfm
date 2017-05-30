object Form3: TForm3
  Left = 244
  Top = 133
  BorderStyle = bsDialog
  Caption = 'Changer de mots de passe'
  ClientHeight = 282
  ClientWidth = 297
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
  object Label2: TLabel
    Left = 10
    Top = 29
    Width = 99
    Height = 13
    Caption = 'Ancien mot de passe'
  end
  object Label3: TLabel
    Left = 9
    Top = 69
    Width = 110
    Height = 13
    Caption = 'Nouveau mot de passe'
  end
  object Label5: TLabel
    Left = 10
    Top = 109
    Width = 191
    Height = 13
    Caption = 'Entrez une seconde fois le mot de passe'
  end
  object Edit1: TEdit
    Left = 8
    Top = 45
    Width = 281
    Height = 21
    MaxLength = 16
    PasswordChar = '*'
    TabOrder = 1
    Text = 'Edit1'
  end
  object Edit2: TEdit
    Left = 8
    Top = 85
    Width = 281
    Height = 21
    MaxLength = 16
    PasswordChar = '*'
    TabOrder = 2
    Text = 'Edit2'
  end
  object ButtonConvertir: TButton
    Left = 64
    Top = 253
    Width = 75
    Height = 25
    Caption = 'Convertir'
    TabOrder = 4
    OnClick = ButtonConvertirClick
  end
  object ButtonAnnuler: TButton
    Left = 144
    Top = 253
    Width = 75
    Height = 25
    Caption = 'Annuler'
    TabOrder = 5
    OnClick = ButtonAnnulerClick
  end
  object CheckBox1: TCheckBox
    Left = 6
    Top = 7
    Width = 257
    Height = 17
    Caption = 'Masquer avec des étoiles (***)'
    Checked = True
    State = cbChecked
    TabOrder = 0
    OnClick = CheckBox1Click
  end
  object Edit3: TEdit
    Left = 8
    Top = 125
    Width = 281
    Height = 21
    MaxLength = 16
    PasswordChar = '*'
    TabOrder = 3
    Text = 'Edit2'
  end
  object GroupBox1: TGroupBox
    Left = 4
    Top = 153
    Width = 289
    Height = 97
    Caption = ' Attention ! '
    TabOrder = 6
    object Label7: TLabel
      Left = 7
      Top = 19
      Width = 264
      Height = 13
      Caption = 'Ceci va changer  la clé de cryptage  de vos documents.'
    end
    object Label8: TLabel
      Left = 8
      Top = 35
      Width = 253
      Height = 13
      Caption = 'Vous risquez de perdre toutes vos données si l'#39'ancien'
    end
    object Label9: TLabel
      Left = 7
      Top = 51
      Width = 267
      Height = 13
      Caption = 'mots de passe est erroné. Toute fois vous pourez revenir'
    end
    object Label10: TLabel
      Left = 7
      Top = 67
      Width = 273
      Height = 13
      Caption = 'en arrière depuis le menu [Outils / Annuler le changement]'
    end
  end
end
