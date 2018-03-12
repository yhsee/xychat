unit DBGridEx;   
    
interface
    
uses
  Windows,Classes,DBGrids,TntDBGrids;

type
  TDBGridEx=class(TTntDBGrid)
  protected
    function DoMouseWheel(Shift:TShiftState;WheelDelta:Integer;MousePos:TPoint):Boolean;override;
  end;

implementation

function TDBGridEx.DoMouseWheel(Shift:TShiftState;WheelDelta:Integer;MousePos:TPoint):Boolean;
begin
  Result := inherited DoMouseWheel(Shift,WheelDelta,MousePos);
  if WheelDelta<0 then Datasource.DataSet.Next;
  if wheelDelta>0 then DataSource.DataSet.Prior;
end;

end.