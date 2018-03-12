unit FindFileUnt;

interface

uses SysUtils,TntClasses,TntSysUtils;

procedure FindFile(const filespec: WideString;TmpList:TTntStringList;bSubDirectory:boolean);


implementation

//------------------------------------------------------------------------------
// 寻找文件,及子文件
//------------------------------------------------------------------------------
procedure FindFile(const filespec: WideString;TmpList:TTntStringList;bSubDirectory:boolean);
  procedure RFindFile(const folder: WideString);
  var
    SearchRec: TSearchRecW;
  begin
  if WideFindFirst(folder +'*.*' , faAnyFile , SearchRec)=0 then
    begin
      try
        repeat
          if (SearchRec.Attr and faDirectory = 0) or (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
          if widefileexists(folder + SearchRec.Name) then
            TmpList.Add(folder + SearchRec.Name);
        until wideFindNext(SearchRec) <> 0;
      except
        WideFindClose(SearchRec);
        raise;
      end;
    WideFindClose(SearchRec);
    end;

  if bSubDirectory then
    begin
    if WideFindFirst(folder + '*.*', faAnyFile Or faDirectory, SearchRec) = 0 then
      begin
      try
        repeat
          if ((SearchRec.Attr and faDirectory) <> 0) and (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
            RFindFile(folder + SearchRec.Name + '\');
        until WideFindNext(SearchRec) <> 0;
      except
        WideFindClose(SearchRec);
        raise;
      end;
      WideFindClose(SearchRec);
      end;
    end;
  end;

begin
  try
    RFindFile(WideExtractFilePath(filespec));
  except
    raise;
  end;
end;

end.


