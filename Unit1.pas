unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, DBGrids, Buttons, ExtCtrls, Generics.Collections, ComCtrls, Spin;

type

  TForm1 = class(TForm)
    StringGrid1: TStringGrid;
    Memo1: TMemo;
    Panel1: TPanel;
    Button2: TButton;
    Clear: TButton;
    Label1: TLabel;
    ComboBox1: TComboBox;
    procedure StringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ClearClick(Sender: TObject);
  private
    { Private declarations }
    Matriz : array of array of Integer;
    pontoA, pontoB :TPoint;

    function pointToClick(linha, coluna: integer): TPoint;
    procedure preenchePontoAB(linha, coluna: integer);
    procedure zeraMatriz;
    procedure limpaTudo;
  public
    { Public declarations }
  end;

const
  TAMANHO_CELULA = 50;
  TAMANHO_LINHA = 0.5;

var
  Form1: TForm1;

implementation

{$R *.dfm}

function GetMousePos(janela:tform):TPoint;
var
 ponto: Tpoint;
begin
  ponto:=janela.ClientOrigin;
  ponto.x:=mouse.CursorPos.x-ponto.x - 5;
  ponto.y:=mouse.CursorPos.y-ponto.y - 5;
    {
  if (ponto.x<0) or (ponto.x>janela.Width) or (ponto.y<0) or (ponto.y>janela.Height) then
   begin
     ponto.y:=-1;
     ponto.x:=-1;
   end;
   }
  result:=ponto;
end;

function ABS(x : integer) : integer;
begin
  if x < 0 then
    result := -x
  else
    result := x;
end;

function SIGN(x : Integer) : integer;
begin
  if x < 0 then
    result := -1
  else
    result := 1;
end;

function Bresenham2(point1, point2 : Tpoint) : TList<TPoint> ;
var list : TList<TPoint> ;
    deltax, deltay, signalx, signaly : integer;
    x1, y1, x2, y2 : integer;
    x, y, erro, tmp, i : integer;
    interchange : boolean;
begin
  list := TList<TPoint>.Create;

  x1 := point1.X;
  y1 := point1.Y;

  x2 := point2.X;
  y2 := point2.Y;

  deltax := ABS( (x2 - x1) );
  deltay := ABS( (y2 - y1) );
  signalx := SIGN( (x2 - x1) );
  signaly := SIGN( (y2 - y1) );

  x := x1;
  y := y1;

//  if (signalx < 0) then
//    x := x -1;
//  if (signaly < 0 ) then
//    y := y -1;

  // trocar deltax com deltay dependendo da inclinacao da reta
  interchange := false;

  if ( deltay > deltax) then
  begin
    tmp := deltax;
    deltax := deltay;
    deltay := tmp;
    interchange := true;
  end;

  erro := (2 * deltay - deltax);

  i := 0;
  while(i < deltax) do // for i := 0 to (i < deltax do
  begin

    list.Add(Point(x, y));

    while (erro >= 0) do
    begin
      if (interchange) then
        x := x + signalx
      else
        y := y + signaly;

      erro := (erro - 2 * deltax);
    end; // while

    if (interchange) then
      y := y + signaly
    else
      x := x + signalx;

    erro := (erro + 2 * deltay);

    inc(i);
  end; // for

  result := list;
end;

procedure TForm1.StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var i, j : Integer;
    pt1, pt2 : tPoint;
begin
  if Matriz[ARow,ACol] = 1 then
    TDBGrid(Sender).Canvas.Brush.Color := clBlack
  else
    TDBGrid(Sender).Canvas.Brush.Color := clWindow;

  TDBGrid(Sender).Canvas.FillRect(Rect);

  if (pontoA.X <> -1) and (pontoB.X <> -1) then
  begin
    with TControlCanvas.Create do
    begin
      Control := StringGrid1;
      Pen.Style := psSolid;
      Pen.Color := clBlue;
      Pen.Width := 2;
      pt1 := pointToClick(pontoA.X, pontoA.Y);
      MoveTo(pt1.X+2, pt1.Y+5);
      pt2 := pointToClick(pontoB.X, pontoB.Y);
      LineTo(pt2.X+2, pt2.Y+5);
    end;
  end;

end;

procedure TForm1.StringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  preenchePontoAB(ARow, ACol);

  zeraMatriz;

  if pontoA.X <> -1 then
    Matriz[pontoA.X, pontoA.Y] := 1;

  if pontoB.X <> -1 then
    Matriz[pontoB.X, pontoB.Y] := 1;

  StringGrid1.Repaint;

end;

procedure TForm1.zeraMatriz;
var i, j : Integer;
begin
  for i := 0 to 9 do
  begin
    for j := 0 to 9 do
    begin
      Matriz[i,j] := 0;
    end;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var l : TList<TPoint>;
    i : Integer;
    ponto : TPoint;
    linha, coluna : Integer;
begin
  l := Bresenham2(pontoA, pontoB);

  Memo1.Lines.Add(' -------inicio-------') ;
  i := 0;
  while i < l.Count do
  begin
    ponto := l.Items[i];
    if not ((ponto.X = pontoA.X) and (ponto.Y = pontoA.Y)) then
    begin

      Sleep(100);
      Memo1.Lines.Add('X=' + IntToStr(ponto.X) + ' Y=' + IntToStr(ponto.Y) );
      Matriz[ponto.X,ponto.Y] := 1;
      StringGrid1.Repaint;
    end;
    Inc(i);
  end;

  StringGrid1.Repaint;
end;

procedure TForm1.ClearClick(Sender: TObject);
begin
  limpaTudo;
  StringGrid1.Repaint;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  SetLength(Matriz,10,10);
  limpaTudo;
end;

function TForm1.pointToClick(linha, coluna: integer): TPoint;
var pt : tPoint;
begin
  pt.x := (coluna * TAMANHO_CELULA) + (TAMANHO_CELULA div 2) + trunc(coluna * TAMANHO_LINHA ) -1;
  pt.y := (linha * TAMANHO_CELULA) + (TAMANHO_CELULA div 2) + trunc(linha * TAMANHO_LINHA ) -1;

  result := pt;
end;

procedure TForm1.limpaTudo;
begin
  zeraMatriz;
  Memo1.Clear;

  pontoA.X := -1;
  pontoA.Y := -1;
  pontoB.X := -1;
  pontoB.Y := -1;
end;

procedure TForm1.preenchePontoAB(linha, coluna : integer);
var ponto : TPoint;
begin
  ponto.X := linha;
  ponto.Y := Coluna;

  if pontoA.X = -1 then
  begin
    pontoA := ponto;
    Memo1.Lines.Add('pontoA.x='+IntToStr(pontoA.X)+' pontoA.y='+IntToStr(pontoA.Y));
  end
  else if pontoB.X = -1 then
  begin
    pontoB := ponto;
    Memo1.Lines.Add('pontoB.x='+IntToStr(pontoB.X)+' pontoB.y='+IntToStr(pontoB.Y));
  end
  else
  begin
    pontoA := ponto;
    memo1.Lines.Add('');
    Memo1.Lines.Add('pontoA.x='+IntToStr(pontoA.X)+' pontoA.y='+IntToStr(pontoA.Y));
    pontoB.X := -1;
    pontoB.Y := -1;
  end;
end;

end.
