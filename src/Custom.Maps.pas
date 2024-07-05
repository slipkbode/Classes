unit Custom.Maps;

interface

uses System.Sensors;

type
  TMaps = class sealed
  private
    function OpenURL(const AURL: string; const ADisplayError: Boolean = False): Boolean;
  public
    function OpenNavigation(const AQuery: string): Boolean; overload;
    function OpenNavigation(const AQuery: string; const ACoord: TLocationCoord2D): Boolean; overload;
  end;

implementation

uses
  IdURI,
  SysUtils,
  Classes,
  FMX.Dialogs
{$IFDEF ANDROID}
  , FMX.Helpers.Android
  , Androidapi.JNI.GraphicsContentViewText
  , Androidapi.JNI.Net
  , Androidapi.JNI.JavaTypes
  , Androidapi.Helpers;
{$ELSE}
{$IFDEF IOS}
  , iOSapi.Foundation
  , FMX.Helpers.iOS
  , Macapi.Helpers;
{$ELSE}
{$IFDEF MSWINDOWS}
  , Winapi.ShellAPI
  , Winapi.Windows;
{$ELSE}
{$IFDEF MACOS}
  , Macapi.AppKit
  , Macapi.Foundation
  , Macapi.Helpers;
{$ELSE};
{$ENDIF MACOS}
{$ENDIF MSWINDOWS}
{$ENDIF IOS}
{$ENDIF ANDROID}

{TMaps}

function TMaps.OpenURL(const AURL: string; const ADisplayError: Boolean = False): Boolean;
{$IFDEF ANDROID}
var
  LIntent: JIntent;
begin
  LIntent := TJIntent.JavaClass.init(TJIntent.JavaClass.ACTION_VIEW,
    TJnet_Uri.JavaClass.parse(StringToJString(URL)));
  try
    SharedActivity.startActivity(LIntent);
    Result := True;
  except
    on e: Exception do
    begin
      if DisplayError then
        ShowMessage('Error: ' + e.Message);
      Result := False;
    end;
  end;
end;
{$ELSE}
{$IFDEF IOS}
var
  NSU: NSUrl;
begin
  NSU := StrToNSUrl(URL);
  if SharedApplication.canOpenURL(NSU) then
    Result := SharedApplication.openUrl(NSU)
  else
  begin
    if DisplayError then
      ShowMessage('Error: Opening "' + URL + '" not supported.');
    Result := False;
  end;
end;
{$ELSE}
{$IFDEF MSWINDOWS}
begin
  ShellExecute(0, 'OPEN', PChar(AURL), '', '', SW_SHOWNORMAL);
  Result := True;
end;
{$ELSE}
{$IFDEF MACOS}
begin
  TNSWorkspace
           .Wrap(TNSWorkspace.OCClass.sharedWorkspace)
           .openURL(
             TNSURL.Wrap(TNSURL.OCClass.URLWithString(StrToNSStr(AURL))
             )
  );
  Result := True;
end;
{$ELSE}
begin
  raise Exception.Create('Not supported!');
end;
{$ENDIF MACOS}
{$ENDIF MSWINDOWS}
{$ENDIF IOS}
{$ENDIF ANDROID}



function TMaps.OpenNavigation(const AQuery: string): Boolean;
var
  LCoord: TLocationCoord2D;
begin
  LCoord.Latitude := 0.0;
  LCoord.Longitude := 0.0;
  OpenNavigation(AQuery, LCoord);
end;


function TMaps.OpenNavigation(const AQuery: string; const ACoord: TLocationCoord2D): Boolean;
var
  LCoordString: String;
begin
  {$IFDEF ANDROID}
  Result := OpenURL('http://maps.google.com/?q=' + Q);
  {$ELSE}
  if (ACoord.Latitude <> 0.0) or (ACoord.Longitude <> 0.0) then
  begin
    LCoordString := ACoord.Latitude.ToString + ',' + ACoord.Longitude.ToString;
  end
  else begin
    LCoordString := '';
  end;
  if not OpenURL('comgooglemaps://?daddr=' + AQuery) then
  begin
    if (0.0 < LCoordString.Length) then
    begin
      Result := OpenURL('http://maps.apple.com/?daddr=' + AQuery + '&saddr=loc:' + LCoordString);
    end
    else begin
      Result := OpenURL('http://maps.apple.com/?daddr=' + AQuery);
    end;
  end
  else begin
    Result := True;
  end;
  {$ENDIF}
end;

end.
