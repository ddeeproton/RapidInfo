object Form5: TForm5
  Left = 192
  Top = 140
  Width = 545
  Height = 200
  Caption = 'Conversion'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 9
    Top = 9
    Width = 32
    Height = 13
    Anchors = [akLeft]
    Caption = 'Label1'
  end
  object Label2: TLabel
    Left = 10
    Top = 61
    Width = 32
    Height = 13
    Anchors = [akLeft]
    Caption = 'Label2'
  end
  object Label3: TLabel
    Left = 12
    Top = 105
    Width = 32
    Height = 13
    Anchors = [akLeft]
    Caption = 'Label3'
  end
  object Label4: TLabel
    Left = 11
    Top = 127
    Width = 115
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Utilisation du processeur'
  end
  object ButtonAnnuler: TButton
    Left = 440
    Top = 119
    Width = 91
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Annuler'
    TabOrder = 0
    OnClick = ButtonAnnulerClick
  end
  object ProgressBar1: TProgressBar
    Left = 2
    Top = 28
    Width = 534
    Height = 18
    Anchors = [akLeft, akRight]
    Min = 0
    Max = 100
    TabOrder = 1
  end
  object ProgressBar2: TProgressBar
    Left = 2
    Top = 80
    Width = 534
    Height = 18
    Anchors = [akLeft, akRight]
    Min = 0
    Max = 100
    TabOrder = 2
  end
  object ButtonPause: TButton
    Left = 344
    Top = 119
    Width = 91
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Pause'
    TabOrder = 3
    OnClick = ButtonPauseClick
  end
  object RadioButton2: TRadioButton
    Left = 208
    Top = 127
    Width = 81
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Faible'
    TabOrder = 4
    OnClick = RadioButton2Click
  end
  object RadioButton1: TRadioButton
    Left = 144
    Top = 127
    Width = 57
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Haute'
    Checked = True
    TabOrder = 5
    TabStop = True
    OnClick = RadioButton1Click
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 147
    Width = 537
    Height = 19
    Panels = <
      item
        Width = 50
      end>
    SimplePanel = False
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 1
    OnTimer = Timer1LectureLente
    Left = 312
    Top = 115
  end
end
