object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 566
  ClientWidth = 1121
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnMouseDown = FormMouseDown
  OnPaint = FormPaint
  TextHeight = 15
  object Memo1: TMemo
    Left = 784
    Top = 0
    Width = 337
    Height = 566
    Align = alRight
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
    ExplicitLeft = 780
    ExplicitHeight = 565
  end
  object Button1: TButton
    Left = 688
    Top = 384
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 1
    OnClick = Button1Click
  end
end
