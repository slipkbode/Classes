unit Custom.Helper;

interface

uses
  FMX.Graphics;

type
  THelperCanvas = class helper for TCanvas
  public
    function TextHeight(const AText: string; const AWidth: Single): Single; overload;
  public

  end;
implementation

uses
  System.Types, FMX.Types;

function THelperCanvas.TextHeight(const AText: string; const AWidth: Single): Single;
var
  R: TRectF;
begin
  R := RectF(0, 0, AWidth, 10000);
  MeasureText(R, AText, True, [], TTextAlign.Leading, TTextAlign.Leading);
  Result := R.Bottom;
end;

end.
