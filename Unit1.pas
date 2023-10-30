unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Generics.Collections, Vcl.StdCtrls;

type


{
  https://github.com/daancode/a-star/blob/master/source/AStar.cpp
  https://ru.wikibooks.org/wiki/%D0%A0%D0%B5%D0%B0%D0%BB%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D0%B8_%D0%B0%D0%BB%D0%B3%D0%BE%D1%80%D0%B8%D1%82%D0%BC%D0%BE%D0%B2/%D0%90%D0%BB%D0%B3%D0%BE%D1%80%D0%B8%D1%82%D0%BC_%D0%BF%D0%BE%D0%B8%D1%81%D0%BA%D0%B0_A*
  https://www.geeksforgeeks.org/a-search-algorithm/


}

  TAStarNode = class
    private
      FParent: TAStarNode;
      FPos: TPoint;
      FWeight: Integer;
      FF, FG, FH: Extended;
    public
    	property Parent: TAStarNode read FParent write FParent;
      property Pos: TPoint read FPos write FPos;
      property Weight: Integer read FWeight write FWeight;

      property F: Extended read FF write FF;
      property G: Extended read FG write FG;
      property H: Extended read FH write FH;
  end;

  TForm1 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
    FPosList: TList<TPoint>;
    function FindMinNodeF(AOpenList: TObjectList<TAStarNode>): TAStarNode;
    procedure FindPath(AStart, AGoal: TPoint; APathList: TList<TPoint>);
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

const
	{$J+}
  Map: Array [0..9, 0..9] of Integer = (

	// 0  1  2  3  4  5  6  7  8  9
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0), 	// 0
		(0, 0, 0, 0, 0, 0, 0, 0, 0, 0),   // 1
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0),   // 2
    (0, 0, 7, 0, 0, 0, 0, 0, 0, 0),   // 3
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0),   // 4
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0),   // 5
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0),   // 6
    (0, 0, 0, 0, 0, 0, 0, 8, 0, 0),   // 7
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0),   // 8
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0));  // 9
	{$J-}
  // 0 allow to go
  // ...
  // 7 Start
  // 8 goal


implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  FPosList.Clear;
  FindPath(Point(2, 3), Point(7, 7), FPosList);

  Repaint;
end;

function TForm1.FindMinNodeF(AOpenList: TObjectList<TAStarNode>): TAStarNode;
var FMin: Extended;
    Q: TAStarNode;
begin

	FMin := 1000000;
  Result := nil;

  for Q in AOpenList do
    begin
      if FMin >= Q.F then
      	begin
        	FMin := Q.F;
          Result := Q;
        end;
    end;
end;

procedure TForm1.FindPath(AStart, AGoal: TPoint; APathList: TList<TPoint>);
var OpenList: TObjectList<TAStarNode>;
    ClosedList: TObjectList<TAStarNode>;

    Complete: Boolean;
    CurrNode: TAStarNode;

    Q, NewNode: TAStarNode;

    IsOpen, IsClosed: Boolean;

    i, j, k: Integer;
begin
	OpenList := TObjectList<TAStarNode>.Create(False);
  ClosedList := TObjectList<TAStarNode>.Create(False);

  NewNode := TAStarNode.Create;
  NewNode.Parent := nil;
  NewNode.Pos := AStart;
  NewNode.Weight := 0;
  NewNode.G := 0;
  NewNode.H := Sqrt(Sqr(AGoal.X - AStart.X) + Sqr(AGoal.Y - AStart.Y));
  NewNode.F := NewNode.G + NewNode.H;
  OpenList.Add(NewNode);

  Complete := False;
  CurrNode := nil;
  IsOpen := False;

  while (OpenList.Count > 0) and not Complete do
  	begin
      CurrNode := FindMinNodeF(OpenList);

      ClosedList.Add(CurrNode);
      OpenList.Remove(CurrNode);

      for i := CurrNode.Pos.X - 1 to CurrNode.Pos.X + 1 do
      	begin
          for j := CurrNode.Pos.Y - 1 to CurrNode.Pos.Y + 1 do
            begin

              if Map[j, i] = 3 then Continue;

              if (i = CurrNode.Pos.X) and (j = CurrNode.Pos.Y) then
              	Continue

              else if not Complete then
                Complete := (i = AGoal.X) and (j = AGoal.Y)

              else
              	Break;

              IsClosed := False;

              for k := ClosedList.Count - 1 downto 0 do
                begin
                  if (ClosedList[k].Pos.X = i) and (ClosedList[k].Pos.Y = j) then
                  	begin
                      IsClosed := True;
                      Break;
                    end;
                end;

              if IsClosed then Continue;

              IsOpen := False;

              for k := OpenList.Count - 1 downto 0 do
                begin
                  if (OpenList[k].Pos.X = i) and (OpenList[k].Pos.Y = j) then
                    begin
                      IsOpen := True;

                      if OpenList[k].G > (CurrNode.G + OpenList[k].Weight) then
                      	begin
                          OpenList[k].Parent := CurrNode;
                          OpenList[k].G := CurrNode.G + OpenList[k].Weight;
                          OpenList[k].F := OpenList[k].G + OpenList[k].H;
                        end;

                      Break;
                    end;
                end;

              if not IsOpen then
                begin
                  NewNode := TAStarNode.Create;
                  NewNode.Parent := CurrNode;
                  NewNode.Pos := Point(i, j);
                  NewNode.G := CurrNode.Weight; //???
                  NewNode.H := Sqrt(Sqr(AGoal.X - i) + Sqr(AGoal.Y - j));
                  NewNode.F := NewNode.G + NewNode.H;
                  OpenList.Add(NewNode);
                end;

            end;

        end;

    end;

  for i := OpenList.Count - 1 downto 0 do
    begin
      if (OpenList[i].Pos.X = AGoal.X) and (OpenList[i].Pos.Y = AGoal.Y) then
        begin
          CurrNode := OpenList[i];

          while CurrNode <> nil do
          	begin
              FPosList.Add(CurrNode.Pos);
              Memo1.Lines.Add(IntToStr(CurrNode.Pos.X) + ' : ' + IntToStr(CurrNode.Pos.Y));
              CurrNode := CurrNode.Parent;
            end;
        end;
    end;

  for i := ClosedList.Count - 1 downto 0 do
    begin
      Q := ClosedList[i];
      FreeAndNil(Q);
    end;

  for i := OpenList.Count - 1 downto 0 do
    begin
      Q := OpenList[i];
      FreeAndNil(Q);
    end;

  Memo1.Lines.Add('C: ' + IntToStr(ClosedList.Count));
  Memo1.Lines.Add('O: ' + IntToStr(OpenList.Count));

  FreeAndNil(OpenList);
  FreeAndNil(ClosedList);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
	FPosList := TList<TPoint>.Create;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FPosList);
end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var X0, Y0: Integer;
    W, H: Integer;
    R, C: Integer;
begin

  w := 20;
  h := 20;

  x0 := 30;
  y0 := 30;

  if (X >= X0) and (Y >= Y0) then
  	begin

      C := (X - X0) div w;
      R := (Y - Y0) div h;

      if (C < 0) or (R < 0) then Exit;
      if (C >= 10) or (R >= 10) then Exit;

      //ShowMessage(IntToStr(C) + ' ' + IntToStr(R));

      if Button = TMouseButton.mbLeft then
        begin
          Map[R, C] := 3;
          Button1.Click;
          Repaint;
        end

      else if Button = TMouseButton.mbRight then
        begin

        end;

  	end;
end;

procedure TForm1.FormPaint(Sender: TObject);
var i, j: Integer;
    w, h: Integer;
    x0, y0: Integer;
    P: TPoint;
begin

  w := 20;
  h := 20;

  x0 := 30;
  y0 := 30;

  Canvas.Brush.Color := clSkyBlue;
  for i := 0 to 9 do
  	begin
      for j := 0 to 9 do
      	begin

          case Map[j, i] of
          	7: Canvas.Brush.Color := clGreen;
            8: Canvas.Brush.Color := clBlue;
            3: Canvas.Brush.Color := clGray;

            else
              Canvas.Brush.Color := clSkyBlue;
          end;

          Canvas.FillRect(Rect(
          	x0 + i * w + 2,
            y0 + j * h + 2,
            x0 + (i + 1) * w - 2,
            y0 + (j + 1) * h - 2));
        end;
    end;

  Canvas.Brush.Color := clWebOrange;
  for i := 1 to FPosList.Count - 2 do
    begin
      Canvas.FillRect(Rect(
        x0 + FPosList[i].X * w + 2,
        y0 + FPosList[i].Y * h + 2,
        x0 + FPosList[i].X * w + w - 2,
        y0 + FPosList[i].Y * h + h - 2));
    end;

end;

initialization
  ReportMemoryLeaksOnShutdown := True

//procedure SearchPath(x0, y0, x, y: Integer; PrintProc: TCurrentPoint);
//type
//  pNode = ^TNode;
//  TNode = record
//    Parent: pNode;
//    Pos: TPoint;
//    Weight: Integer;
//    G: LongInt;
//    H, F: Extended;
//  end;
//var
//  i, j, k: Integer;
//  OpenList, ClosedList: TList;
//  NewNode, Current: pNode;
//  FMin: Extended;
//  isClosed, isOpen, Complete: Boolean;
//begin
//  OpenList := TList.Create;
//  ClosedList := TList.Create;
//  New(NewNode);
//  NewNode^.Parent := nil;
//  NewNode^.Pos := Point(x0, y0);
//  NewNode^.G := 0;
//  NewNode^.H := Sqrt(Sqr(x - x0) + Sqr(y - y0));
//  NewNode^.F := NewNode^.G + NewNode^.H;
//  OpenList.Add(NewNode);
//  Complete := False;
//  while (OpenList.Count > 0) and not Complete do
//  begin
//    FMin := 77000;
//    Current := nil;
//    for i := 0 to OpenList.Count - 1 do
//      if pNode(OpenList[i])^.F < FMin then
//      begin
//        FMin := pNode(OpenList[i])^.F;
//        Current := pNode(OpenList[i]);
//      end;
//    ClosedList.Add(Current);
//    OpenList.Remove(Current);
//    for i := Current^.Pos.X - 1 to Current^.Pos.X + 1 do
//      for j := Current^.Pos.Y - 1 to Current^.Pos.Y + 1 do
//      begin
//        if (i = Current^.Pos.X) and (j = Current^.Pos.Y) then
//          Continue
//        else if not Complete then
//          Complete := (i = x) and (j = y)
//        else
//          Break;
//        isClosed := False;
//        for k := ClosedList.Count - 1 downto 0 do //ищем в закрытом списке
//          if (pNode(ClosedList[k])^.Pos.X = i) and (pNode(ClosedList[k])^.Pos.Y = j) then
//          begin
//            isClosed := True; //в закрытом списке
//            Break;
//          end;
//        if isClosed then
//          Continue;
//        isOpen := False;
//        for k := OpenList.Count - 1 downto 0 do //ищем в открытом списке
//          if (pNode(OpenList[k])^.Pos.X = i) and (pNode(OpenList[k])^.Pos.Y = j) then
//          begin
//            isOpen := True; //в открытом списке
//            if pNode(OpenList[k])^.G > (Current^.G + pNode(OpenList[k])^.Weight) then
//            begin
//              pNode(OpenList[k])^.Parent := Current;
//              pNode(OpenList[k])^.G := Current^.G + pNode(OpenList[k])^.Weight;
//              pNode(OpenList[k])^.F := pNode(OpenList[k])^.G + pNode(OpenList[k])^.H;
//            end;
//            Break;
//          end;
//        if not isOpen then //если еще не открыта
//        begin
//          //добавляем в открытый список
//          New(NewNode);
//          NewNode^.Parent := Current;
//          NewNode^.Pos := Point(i, j);
//          NewNode^.Weight := Weights[i, j];
//          NewNode^.G := Current^.G + NewNode^.Weight;
//          NewNode^.H := Sqrt(Sqr(x - i) + Sqr(y - j));
//          NewNode^.F := NewNode^.G + NewNode^.H;
//          OpenList.Add(NewNode);
//        end;
//      end;
//  end;
//  for i := OpenList.Count - 1 downto 0 do
//    if (pNode(OpenList[i])^.Pos.X = x) and (pNode(OpenList[i])^.Pos.Y = y) then
//    begin
//      Current := OpenList[i];
//      while Current <> nil do
//      begin
//        PrintProc(Current^.Pos.X, Current^.Pos.Y);
//        Current := Current^.Parent;
//      end;
//    end;
//  for i := OpenList.Count - 1 downto 0 do
//    Dispose(OpenList[i]);
//  OpenList.Free;
//  for i := ClosedList.Count - 1 downto 0 do
//    Dispose(ClosedList[i]);
//  ClosedList.Free;
//end;

end.
