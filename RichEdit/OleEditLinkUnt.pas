unit OleEditLinkUnt;

interface

uses
  SysUtils, Windows,Classes,RichEditCommUnt;
  
Type
  TOleLinkMgr=class
    private
      FlinkID:Integer;
      Flinklist:TThreadlist;
      function NewlinkID:integer;
      procedure clearlinklist;
      function compareplace(P1,P2:tplace):boolean;
    protected

    Public
      constructor Create;
      destructor  Destroy;override;
      //------------------------------------------------------------------------
      function CheckOlelink(AStartPos, ALength:integer):boolean;
      procedure addolelink(ol:TOleLink);
      function LinkClick(AStartPos, ALength:integer):TOleLink;
      function GetNextOleLink(iType:TLinkType;Var Tmplink:TOleLink):Boolean;
    published
  end;

implementation

constructor TOleLinkMgr.Create;
begin
 inherited Create;
 Flinklist:=TThreadlist.Create;
end;

destructor TOleLinkMgr.Destroy;
begin
  clearlinklist;
  freeandnil(Flinklist);
  inherited Destroy;
end;

function TOleLinkMgr.compareplace(P1,P2:tplace):boolean;
begin
result:=(p1.AStartPos=p2.AStartPos) and(p1.ALength=p2.ALength); 
end;

procedure TOleLinkMgr.clearlinklist;
var i:integer;
begin
try
with Flinklist.LockList do
for i:=count downto 1 do
  begin
  dispose(POleLink(items[i-1]));
  delete(i-1);
  end;
finally
Flinklist.UnlockList;
end;
end;

function TOleLinkMgr.NewlinkID:integer;
begin
inc(FlinkID);
result:=FlinkID;
end;

function TOleLinkMgr.CheckOlelink(AStartPos, ALength:integer):boolean;
var i:integer;
    Tmplink:TOleLink;
    CurPos:Tplace;
begin
try
result:=false;
CurPos.AStartPos:=AStartPos;
CurPos.ALength:=ALength;
with Flinklist.LockList do
for i:=count downto 1 do
  begin
  Tmplink:=POleLink(items[i-1])^;
  if compareplace(Tmplink.Accept,CurPos) or
     compareplace(Tmplink.AcceptEx,CurPos)or
     compareplace(Tmplink.Cancel,CurPos) then
     begin
     result:=True;
     break;
     end;
  end;
finally
Flinklist.UnlockList;
end;
end;

procedure TOleLinkMgr.addolelink(ol:TOleLink);
var pol:POleLink;
begin
ol.LinkID:=NewlinkID;
New(pol);
pol^:=ol;
Flinklist.Add(pol);
end;

function TOleLinkMgr.GetNextOleLink(iType:TLinkType;Var Tmplink:TOleLink):Boolean;
var i:integer;
begin
try
Result:=False;
with Flinklist.LockList do
for i:=count downto 1 do
  begin
  Tmplink:=POleLink(items[i-1])^;
  if TmpLink.lType=iType then
     begin
     Tmplink.State:=0;
     dispose(POleLink(items[i-1]));
     delete(i-1);
     Result:=True;
     break;
     end;
  end;
finally
Flinklist.UnlockList;
end;
end;

function TOleLinkMgr.LinkClick(AStartPos, ALength:integer):TOleLink;
var i:integer;
    Tmplink:TOleLink;
    CurPos:Tplace;
begin
try
CurPos.AStartPos:=AStartPos;
CurPos.ALength:=ALength;
with Flinklist.LockList do
for i:=count downto 1 do
  begin
  Tmplink:=POleLink(items[i-1])^;
  if compareplace(Tmplink.Accept,CurPos) then
     begin
     Tmplink.State:=0;
     dispose(POleLink(items[i-1]));
     delete(i-1);
     result:=Tmplink;
     break;
     end else
  if compareplace(Tmplink.AcceptEx,CurPos) then
     begin
     Tmplink.State:=1;
     dispose(POleLink(items[i-1]));
     delete(i-1);
     result:=Tmplink;
     break;
     end else
  if compareplace(Tmplink.Cancel,CurPos) then
     begin
     Tmplink.State:=2;
     dispose(POleLink(items[i-1]));
     delete(i-1);
     result:=Tmplink;
     break;
     end;
  end;
finally
Flinklist.UnlockList;
end;
end;

end.