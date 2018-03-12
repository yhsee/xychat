unit SimpleXmlUnt;

interface

uses SysUtils,Classes,ActiveX,XMLIntf,XMLDoc,Variants,Base64Unt;

const
  XML_ROOT_NODE = 'Request';

//------------------------------------------------------------------------------
// 写XML
//------------------------------------------------------------------------------
procedure AddValueToNote(var sParams:WideString;NoteName:WideString;Value:OleVariant); overload;
procedure AddValueToNote(var sParams:WideString;NoteName,AttributeName:WideString;Value:OleVariant); overload;
procedure AddValueToNote(var sParams:WideString;NoteName:WideString;Value:TStream); overload;
procedure AddValueToNote(var sParams:WideString;NoteName:WideString;Value:TComponent); overload;
procedure AddValueToNote(var sParams:WideString;NoteName:WideString;var buf;iBufLen:Integer); overload;
//------------------------------------------------------------------------------
// 读XML
//------------------------------------------------------------------------------
function GetNoteFromValue(sParams:WideString;NoteName:WideString):OleVariant; overload;
function GetNoteFromValue(sParams:WideString;NoteName,AttributeName:WideString):OleVariant; overload;
function GetNoteFromValue(sParams:WideString;NoteName:WideString;TmpStream:TStream):Boolean; overload;
function GetNoteFromValue(sParams:WideString;NoteName:WideString;TmpObject:TComponent):Boolean; overload;
function GetNoteFromValue(sParams:WideString;NoteName:WideString;pBuffer:Pointer):Integer; overload;
//------------------------------------------------------------------------------
// 检查节点是否有效值
//------------------------------------------------------------------------------
function CheckValueExists(sParams:WideString;NoteName:String):Boolean;
//------------------------------------------------------------------------------
// 返检查节点是否存在
//------------------------------------------------------------------------------
function CheckNoteExists(sParams:WideString;NoteName:String):Boolean;
//------------------------------------------------------------------------------
// 返回节点列表  或 值列表
//------------------------------------------------------------------------------
procedure GetXmlTitleList(sParams:WideString;TmpList:TStrings;const bValue:Boolean=False);
//------------------------------------------------------------------------------
// 返回值对应的节点名称
//------------------------------------------------------------------------------
function GetValueFromValue(sParams:WideString;NoteValue:OleVariant):WideString;
//------------------------------------------------------------------------------
// 删除节点
//------------------------------------------------------------------------------
procedure DeleteNodeFromValue(var sParams:WideString;sNodeName:String);
//------------------------------------------------------------------------------
// 从文件装载Xml
//------------------------------------------------------------------------------
function LoadFileToXml(sFileName:WideString;var sParams:WideString):Boolean;
//------------------------------------------------------------------------------
// 保存XML到指定文件
//------------------------------------------------------------------------------
procedure SaveXmlToFile(sFileName:WideString;sParams:WideString);

implementation
//------------------------------------------------------------------------------
// 初始化XMLDocument
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
// 查询并返回节点对象
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
// 返回指定路径的节点
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
// 写入OleVariant 类型数据到节点
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
// 写入OleVariant 类型数据到节点的 Attribute
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
// 写入 TStream 类型数据到节点
//------------------------------------------------------------------------------
procedure AddValueToNote(var sParams:WideString;NoteName:WideString;Value:TStream);
begin
  AddValueToNote(sParams,NoteName,EnCodeStreamBase64(value));
end;

//------------------------------------------------------------------------------
// 写入 TComponent 类型数据到节点
//------------------------------------------------------------------------------
procedure AddValueToNote(var sParams:WideString;NoteName:WideString;Value:TComponent);
begin
  AddValueToNote(sParams,NoteName,EnCodeObjectBase64(value));
end;

//------------------------------------------------------------------------------
// 写入 缓冲区 数据到节点
//------------------------------------------------------------------------------
procedure AddValueToNote(var sParams:WideString;NoteName:WideString;var buf;iBufLen:Integer);
begin
  AddValueToNote(sParams,NoteName,EnCodeBufferBase64(buf,ibufLen));
end;
//------------------------------------------------------------------------------
// 读取节点内容
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
// 读取节点属性内容
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
// 读取节点内容 到 TStream
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
// 读取节点内容 到 TComponent
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
// 读取节点内容 到 缓冲区
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
// 检查节点是否有效值
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
// 返检查节点是否存在
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
// 返回节点列表  或 值列表
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
// 返回值对应的节点名称
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
// 删除节点
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
// 从文件装载Xml
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
// 保存XML到指定文件
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