program TBSNewsE;

uses Forms, IdHttp, IdSSLOpenSSL, Classes, SysUtils;

{$R *.res}

var
  http: TIdHTTP;
  ssl:  TIdSSLIOHandlerSocketOpenSSL;

  WorkList, OutList, TempList: TStringList;
  I, J: Smallint;
  WorkStr: string;
const
  HTTP_TIMEOUT = 10000;
  URL = 'https://news.tbs.co.jp/';

begin
  http := TIdHTTP.Create;
  ssl  := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  WorkList := TStringList.Create;
  OutList  := TStringList.Create;
  TempList := TStringList.Create;

  ssl.SSLOptions.Method      := sslvTLSv1;
  ssl.SSLOptions.Mode        := sslmUnassigned;
  ssl.SSLOptions.VerifyMode  := [];
  ssl.SSLOptions.VerifyDepth := 0;

  // Timeoutを設定しないとエラーになる
  http.ReadTimeout    := HTTP_TIMEOUT;
  http.ConnectTimeout := HTTP_TIMEOUT;
  http.IOHandler      := ssl;
  try
    WorkList.Text := UTF8Decode(http.Get(URL));

    OutList.Add('==========================■ TBS Newsi - News10 ■==========================');

    for I := 0 to WorkList.Count - 1 do
    begin
     if Pos('News10[', WorkList[I]) > 0 then
     begin
       J := Pos('(''', WorkList[I]) + 1;
       WorkStr := StringReplace(Copy(WorkList[I], J, Length(WorkList[I]) - J - 1), ' ', '　', [rfReplaceAll]);
       TempList.CommaText := WorkStr;
       WorkStr := Copy(TempList[1], 2, 5) + ' ' + Copy(TempList[1], 9, 5) + ' ' + TempList[0];
       WorkStr := StringReplace(WorkStr, '　', ' ', [rfReplaceAll]);
       OutList.Add(StringReplace(WorkStr, '''', '',[rfReplaceAll]));
     end;
    end;
    OutList.SaveToFile('TBSNewsi.txt');
  finally
    http.Free;
    ssl.Free;
    WorkList.Free;
    OutList.Free;
    TempList.Free;
  end;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Run;
end.
