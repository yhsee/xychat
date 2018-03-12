unit SimpleXmlUnt;

interface

uses SysUtils,Classes,ActiveX,XMLIntf,XMLDoc,Variants,Base64Unt;

const
  XML_ROOT_NODE = 'Request';

//------------------------------------------------------------------------------
// дXML
//------------------------------------------------------------------------------
procedure AddValueToNote(var sParams:WideString;NoteName:WideString;Value:OleVariant); overload;
procedure AddValueToNote(var sParams:WideString;NoteName,AttributeName:WideString;Value:OleVariant); overload;
procedure AddValueToNote(var sParams:WideString;NoteName:WideString;Value:TStream); overload;
procedure AddValueToNote(var sParams:WideString;NoteName:WideString;Value:TComponent); overload;
procedure AddValueToNote(var sParams:WideString;NoteName:WideString;var buf;iBufLen:Integer); overload;
//------------------------------------------------------------------------------
// ��XML
//------------------------------------------------------------------------------
function GetNoteFromValue(sParams:WideString;NoteName:WideString):OleVariant; overload;
function GetNoteFromValue(sParams:WideString;NoteName,AttributeName:WideString):OleVariant; overload;
function GetNoteFromValue(sParams:WideString;NoteName:WideString;TmpStream:TStream):Boolean; overload;
function GetNoteFromValue(sParams:WideString;NoteName:WideString;TmpObject:TComponent):Boolean; overload;
function GetNoteFromValue(sParams:WideString;NoteName:WideString;pBuffer:Pointer):Integer; overload;
//------------------------------------------------------------------------------
// ���ڵ��Ƿ���Чֵ
//------------------------------------------------------------------------------
function CheckValueExists(sParams:WideString;NoteName:String):Boolean;
//------------------------------------------------------------------------------
// �����ڵ��Ƿ����
//------------------------------------------------------------------------------
function CheckNoteExists(sParams:WideString;NoteName:String):Boolean;
//------------------------------------------------------------------------------
// ���ؽڵ��б�  �� ֵ�б�
//------------------------------------------------------------------------------
procedure GetXmlTitleList(sParams:WideString;TmpList:TStrings;const bValue:Boolean=False);
//------------------------------------------------------------------------------
// ����ֵ��Ӧ�Ľڵ�����
//------------------------------------------------------------------------------
function GetValueFromValue(sParams:WideString;NoteValue:OleVariant):WideString;
//------------------------------------------------------------------------------
// ɾ���ڵ�
//------------------------------------------------------------------------------
procedure DeleteNodeFromValue(var sParams:WideString;sNodeName:String);
//------------------------------------------------------------------------------
// ���ļ�װ��Xml
//------------------------------------------------------------------------------
function LoadFileToXml(sFileName:WideString;var sParams:WideString):Boolean;
//------------------------------------------------------------------------------
// ����XML��ָ���ļ�
//------------------------------------------------------------------------------
procedure SaveXmlToFile(sFileName:WideString;sParams:WideString);

implementation
//------------------------------------------------------------------------------
// ��ʼ��XMLDocument
//------------------------------------------------------------------------------
function InitialXMLDocument(sParams:WideString;const bNew:Boolean=False):IXMLDocument;
begin
  try
  Result:=nil;
  if Length(Trim(sParams))>0 then
    begin
    Result:=LoadXMLData(Trim(sParams));
    exit;
    end;

  if bNew then
    begin
    Result:=NewXMLDocument;
    Result.AddChild(XML_ROOT_NODE);
    end;
    
  except
  Result:=nil;
  end;
end;

//------------------------------------------------------------------------------
// ��ѯ�����ؽڵ����
//------------------------------------------------------------------------------
function FindNoteFromValue(var XmlValue:IXMLDocument;sParams:WideString;NoteName:WideString;bNew:Boolean=false):IXMLNode;
begin
  Result:=nil;
  XmlValue:=InitialXMLDocument(sParams,bNew);
  if assigned(XmlValue) then
    try
    NoteName:=LowerCase(Trim(NoteName));
    if XmlValue.IsEmptyDoc then exit;
    Result:=XmlValue.DocumentElement.ChildNodes.FindNode(NoteName);
    if not assigned(Result) and bNew then
      Result:=XmlValue.DocumentElement.AddChild(NoteName);
    except
    Result:=nil;
    end;
end;

//------------------------------------------------------------------------------
// ����ָ��·���Ľڵ�
//------------------------------------------------------------------------------
function FindNodeFormValue(var UserNode:IXMLNode;sPath:WideString):Boolean;
var
  n:Integer;
  sNode:WideString;
begin
  Result:=False;
  sPath:=LowerCase(Trim(sPath));
  while Length(sPath)>0 do
    try
    sNode:=sPath;
    n:=Pos('\',sPath);
    if n>0 then
      begin
      sNode:=Copy(sPath,1,n-1);
      Delete(sPath,1,n);
      end else sPath:='';
    UserNode:=UserNode.ChildNodes.FindNode(sNode);
    if not Assigned(UserNode) then
      begin
      Result:=False;
      break;
      end else Result:=True;
    except
    Result:=False;
    break;
    end;
end;
//------------------------------------------------------------------------------
// д��OleVariant �������ݵ��ڵ�
//------------------------------------------------------------------------------
procedure AddValueToNote(var sParams:WideString;NoteName:WideString;Value:OleVariant);
var
  node:IXMLNode;
  XmlValue:IXMLDocument;
begin
  try
    node:=FindNoteFromValue(XmlValue,sParams,NoteName,True);
    if assigned(XmlValue) and assigned(node) then
      begin
      node.NodeValue:=value;
      sParams:=XmlValue.Node.XML;
      end;
  finally
    node:=nil;
    XmlValue:=nil;
  end;
end;

//------------------------------------------------------------------------------
// д��OleVariant �������ݵ��ڵ�� Attribute
//------------------------------------------------------------------------------
procedure AddValueToNote(var sParams:WideString;NoteName,AttributeName:WideString;Value:OleVariant); overload;
var
  node:IXMLNode;
  XmlValue:IXMLDocument;
begin
  try
    node:=FindNoteFromValue(XmlValue,sParams,NoteName,True);
    if assigned(XmlValue) and assigned(node) then
      begin
      AttributeName:=LowerCase(Trim(AttributeName));
      node.SetAttributeNS(AttributeName,'',Value);
      sParams:=XmlValue.Node.XML;
      end;
  finally
    node:=nil;
    XmlValue:=nil;
  end;
end;

//------------------------------------------------------------------------------
// д�� TStream �������ݵ��ڵ�
//------------------------------------------------------------------------------
procedure AddValueToNote(var sParams:WideString;NoteName:WideString;Value:TStream);
begin
  AddValueToNote(sParams,NoteName,EnCodeStreamBase64(value));
end;

//------------------------------------------------------------------------------
// д�� TComponent �������ݵ��ڵ�
//------------------------------------------------------------------------------
procedure AddValueToNote(var sParams:WideString;NoteName:WideString;Value:TComponent);
begin
  AddValueToNote(sParams,NoteName,EnCodeObjectBase64(value));
end;

//------------------------------------------------------------------------------
// д�� ������ ���ݵ��ڵ�
//------------------------------------------------------------------------------
procedure AddValueToNote(var sParams:WideString;NoteName:WideString;var buf;iBufLen:Integer);
begin
  AddValueToNote(sParams,NoteName,EnCodeBufferBase64(buf,ibufLen));
end;
//------------------------------------------------------------------------------
// ��ȡ�ڵ�����
//------------------------------------------------------------------------------
function GetNoteFromValue(sParams:WideString;NoteName:WideString):OleVariant;
var
  node:IXMLNode;
  XmlValue:IXMLDocument;
begin
  try
    Result:='';
    node:=FindNoteFromValue(XmlValue,sParams,NoteName);
    if assigned(XmlValue) and assigned(node) and (not VarIsNull(node.NodeValue)) then
      Result:=node.NodeValue;
  finally
    node:=nil;
    XmlValue:=nil;
  end;
end;

//------------------------------------------------------------------------------
// ��ȡ�ڵ���������
//------------------------------------------------------------------------------
function GetNoteFromValue(sParams:WideString;NoteName,AttributeName:WideString):OleVariant;
var
  node:IXMLNode;
  XmlValue:IXMLDocument;
begin
  try
    Result:='';
    node:=FindNoteFromValue(XmlValue,sParams,NoteName);
    AttributeName:=LowerCase(Trim(AttributeName));
    if assigned(XmlValue) and assigned(node) and (not VarIsNull(node.Attributes[AttributeName])) then
      Result:=node.Attributes[AttributeName];
  finally
    node:=nil;
    XmlValue:=nil;
  end;
end;

//------------------------------------------------------------------------------
// ��ȡ�ڵ����� �� TStream
//------------------------------------------------------------------------------
function GetNoteFromValue(sParams:WideString;NoteName:WideString;TmpStream:TStream):Boolean;
var
  node:IXMLNode;
  XmlValue:IXMLDocument;
begin
  try
    Result:=False;
    node:=FindNoteFromValue(XmlValue,sParams,NoteName);
    if assigned(XmlValue) and assigned(node) and (not VarIsNull(node.NodeValue)) then
      begin
      DeCodeStreamBase64(node.NodeValue,TmpStream);
      TmpStream.Seek(0,0);
      Result:=True;
      end;
  finally
    node:=nil;
    XmlValue:=nil;
  end;
end;

//------------------------------------------------------------------------------
// ��ȡ�ڵ����� �� TComponent
//------------------------------------------------------------------------------
function GetNoteFromValue(sParams:WideString;NoteName:WideString;TmpObject:TComponent):Boolean;
var
  node:IXMLNode;
  XmlValue:IXMLDocument;
begin
  try
    Result:=False;
    node:=FindNoteFromValue(XmlValue,sParams,NoteName);
    if assigned(XmlValue) and assigned(node) and (not VarIsNull(node.NodeValue)) then
      begin
      DeCodeObjectBase64(node.NodeValue,TmpObject);
      Result:=True;
      end;
  finally
    node:=nil;
    XmlValue:=nil;
  end;
end;

//------------------------------------------------------------------------------
// ��ȡ�ڵ����� �� ������
//------------------------------------------------------------------------------
function GetNoteFromValue(sParams:WideString;NoteName:WideString;pBuffer:Pointer):Integer;
var
  node:IXMLNode;
  XmlValue:IXMLDocument;
begin
  try
    Result:=-1;
    node:=FindNoteFromValue(XmlValue,sParams,NoteName);
    if assigned(XmlValue) and assigned(node) and (not VarIsNull(node.NodeValue)) then
      Result:=DeCodeBufferBase64(node.NodeValue,pBuffer);
  finally
    node:=nil;
    XmlValue:=nil;
  end;
end;

//------------------------------------------------------------------------------
// ���ڵ��Ƿ���Чֵ
//------------------------------------------------------------------------------
function CheckValueExists(sParams:WideString;NoteName:String):Boolean;
var
  node:IXMLNode;
  XmlValue:IXMLDocument;
begin
  try
    node:=FindNoteFromValue(XmlValue,sParams,NoteName);
    Result:=assigned(node) and (not VarIsNull(node.NodeValue));
  finally
    node:=nil;
    XmlValue:=nil;
  end;
end;

//------------------------------------------------------------------------------
// �����ڵ��Ƿ����
//------------------------------------------------------------------------------
function CheckNoteExists(sParams:WideString;NoteName:String):Boolean;
var
  node:IXMLNode;
  XmlValue:IXMLDocument;
begin
  try
    node:=FindNoteFromValue(XmlValue,sParams,NoteName);
    Result:=assigned(node);
  finally
    node:=nil;
    XmlValue:=nil;
  end;
end;

//------------------------------------------------------------------------------
// ���ؽڵ��б�  �� ֵ�б�
//------------------------------------------------------------------------------
procedure GetXmlTitleList(sParams:WideString;TmpList:TStrings;const bValue:Boolean=False);
var
  XmlValue:IXMLDocument;
  node:IXMLNode;
  i,iCount:integer;
begin
  try
    XmlValue:=InitialXMLDocument(sParams);
    if not assigned(XmlValue) then exit;
    TmpList.Clear;
    if XmlValue.IsEmptyDoc then exit;
    iCount:=XmlValue.DocumentElement.ChildNodes.Count;
    for i:=1 to iCount do
      begin
      node:=XmlValue.DocumentElement.ChildNodes.Get(i-1);
      if bValue then
        begin
        if not VarIsNull(Node.NodeValue) then
          TmpList.Add(Node.NodeValue);
        end else TmpList.Add(node.NodeName);
      end;
  finally
    node:=nil;
    XmlValue:=nil;
  end;
end;

//------------------------------------------------------------------------------
// ����ֵ��Ӧ�Ľڵ�����
//------------------------------------------------------------------------------
function GetValueFromValue(sParams:WideString;NoteValue:OleVariant):WideString;
var
  XmlValue:IXMLDocument;
  node:IXMLNode;
  i,iCount:integer;
begin
  try
    Result:='';
    XmlValue:=InitialXMLDocument(sParams);
    if not assigned(XmlValue) then exit;
    if XmlValue.IsEmptyDoc then exit;
    iCount:=XmlValue.DocumentElement.ChildNodes.Count;
    for i:=1 to iCount do
      begin
       node:=XmlValue.DocumentElement.ChildNodes.Get(i-1);
       if Assigned(Node) then
       if CompareText(Trim(Node.NodeValue),Trim(NoteValue))=0 then
         begin
         Result:=node.NodeName;
         Break;
         end;
      end;
  finally
    node:=nil;
    XmlValue:=nil;
  end;
end;
//------------------------------------------------------------------------------
// ɾ���ڵ�
//------------------------------------------------------------------------------
procedure DeleteNodeFromValue(var sParams:WideString;sNodeName:String);
var
  node:IXMLNode;
  XmlValue:IXMLDocument;
begin
  try
    node:=FindNoteFromValue(XmlValue,sParams,sNodeName);
    if assigned(XmlValue) and assigned(node) then
      begin
      XmlValue.DocumentElement.ChildNodes.Remove(node);
      sParams:=XmlValue.Node.XML;
      end;
  finally
    node:=nil;
    XmlValue:=nil;
  end;
end;

//------------------------------------------------------------------------------
// ���ļ�װ��Xml
//------------------------------------------------------------------------------
function LoadFileToXml(sFileName:WideString;var sParams:WideString):Boolean;
var
  XmlValue:IXMLDocument;
begin
  try
    Result:=False;
    if FileExists(sFileName) then
      try
      XmlValue:=LoadXMLDocument(sFileName);
      if assigned(XmlValue) then
        sParams:=XmlValue.Node.XML;
      Result:=True;
      except
      Result:=False;
      end;
  finally
    XmlValue:=nil;
  end;
end;

//------------------------------------------------------------------------------
// ����XML��ָ���ļ�
//------------------------------------------------------------------------------
procedure SaveXmlToFile(sFileName:WideString;sParams:WideString);
var
  XmlValue:IXMLDocument;
begin
  try
    XmlValue:=InitialXMLDocument(sParams);
    if assigned(XmlValue) then
      XmlValue.SaveToFile(sFileName);
  finally
    XmlValue:=nil;
  end;
end;

initialization
  CoInitialize(nil);
  
finalization
  CoUninitialize;

end.