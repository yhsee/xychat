unit frmFileTransferUnt;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms,
  StdCtrls,ComCtrls,ExtCtrls,IdSocketHandle,Math,
  constunt,structureunt,compress,UDPStreamUnt,
  EventCommonUnt,EventUnt,
    {Frame}
  FileTransfer,
  {Tnt Control}
  TntSystem,
  TntClasses, TntSysUtils, TntStdCtrls, TntComCtrls, TntGraphics, TntForms,
  TntExtCtrls, TntMenus;

type
  TfrmFileTransfer = class(TFreame_FileTrans)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FServer:boolean;                           //��־ģʽ

    FileTransferEvent:Pointer;
    FUserSign,FIdentifier:String;                     // firendid

    sFileinfor,                     //�����ļ�������Ϣ
    sSendFilePath,                  //����·��
    sRecvFilePath:Widestring;      //����·��


    iCurFileBlock:LongWord;

    iListCount,
    iSumSize:int64;    //�������ļ��ߴ��С

    InitiativeClose,
    bDirectoryTrans:boolean;                       //���ڴ���

    SendFileList:TTntstringlist;                      //�����ļ��б�

    UDPFile:TUDPStream;

    procedure CloseTrans;
    procedure InitializeFrame;
    procedure UpdateFileInfor(sFileName:WideString;iSize:Int64);
    procedure cancelbtnClick(Sender: TObject);
    procedure okbtnClick(Sender: TObject);
    procedure savebtnClick(Sender: TObject);
    procedure InitialUDPConnect(Params:WideString);
    procedure UDPFileonSendComplete(Sender:TObject);
    procedure UDPFileonRecvReady(Sender:TObject;var sNewFileName:WideString; iSize:Int64);
    procedure UDPFileProcessEvent(Sender:TObject;iPosition,iCount:LongWord;iSize:Int64);
    function GetTransCompleteInfor(sTitle:WideString;const bComplete:Boolean=False):Widestring;
    //--------------------------------------------------------------------------
    //�����Զ�����Ϣ.
    procedure EventProcess(Sender:TObject;TmpEvent:TEventData);
    //--------------------------------------------------------------------------
    procedure filetran_accept;
    procedure filetran_start;
    procedure filetran_cancel;
    procedure filetran_refuse;
    procedure filetran_complete;
    procedure filetran_update(sParams:WideString);
    procedure filetran_process(sParams:WideString);
    procedure UserStatusChange;
    { Private declarations }
  public
    procedure CreateComplete(sUserSign:String;Params:WideString;const bServer:boolean=false);
    { Public declarations }
  end;

implementation
uses ShareUnt, udpcores,SimpleXmlUnt,userunt;
{$R *.DFM}

procedure TfrmFileTransfer.EventProcess(Sender:TObject;TmpEvent:TEventData);
begin
  Application.ProcessMessages;
  case TmpEvent.iEvent of
  //------------------------------------------------------------------------------
  // ˢ��Ҫ�ı�״̬���û�
  //------------------------------------------------------------------------------
    Refresh_UserStatus_Event:
      UserStatusChange;

    File_Accept_Event: InitialUDPConnect(TmpEvent.UserParams);
    File_Start_Event: filetran_start;
    File_Refuse_Event: FileTran_refuse;
    File_Cancel_Event: FileTran_cancel;
    File_Complete_Event: filetran_complete;
    File_UpdateInfor_Event: filetran_update(TmpEvent.UserParams);
    File_UpdateProcess_Event:filetran_process(TmpEvent.UserParams);

    Close_Form_Event:Close;
  end;
end;

procedure TfrmFileTransfer.UserStatusChange;
var TmpInfor:tfirendinfo;
begin
  if user.find(FUserSign,TmpInfor) then
  if TmpInfor.status=3 then //�û�������..
     begin
     InitiativeClose:=false;
     udpcore.InsertFirendHintMessage(FUserSign,WideString(' �Է�������ǿ����ֹ�����ļ� ')+sFileinfor+FormatSize(iSumSize));
     event.CreateFileEvent(File_Complete_Event,UDPFile.Identifier,'');
     end;
end;

procedure TfrmFileTransfer.InitialUDPConnect(Params:WideString);
var
  TmpInforr:Tfirendinfo;
begin
  if not user.find(FUserSign,TmpInforr) then exit;
  FIdentifier:=GetNoteFromValue(Params,'MyIdentifier');
  UDPFile.Connect(TmpInforr.Lanip,GetNoteFromValue(Params,'FilePort'));
  Sleep(100);
end;

//��ʼ�����ļ�����...
procedure TfrmFileTransfer.okbtnClick(Sender: TObject);
begin
  filetran_accept;
end;

procedure TfrmFileTransfer.savebtnClick(Sender: TObject);
begin
  if SelectPath(sRecvFilePath) then
    begin
    DefaultSaveDir:=sRecvFilePath;
    filetran_accept;
    end;
end;

//------------------------------------------------------------------------------
// ��ʼ�ļ������ļ�
//------------------------------------------------------------------------------
procedure TfrmFileTransfer.filetran_accept;
var
  sParams:WideString;
begin
  if bDirectoryTrans then
    begin
    sFileinfor:=sRecvFilePath;
    delete(sFileinfor,Length(sFileinfor),1);
    end;

  Lab_Yes.Visible:=False;
  Lab_SaveAs.Visible:=False;
  Lab_Cancel.Caption:='ȡ��';
  Lab_State.Caption:='���ڽ����ļ�...';

  iCurFileBlock:=0;

  AddValueToNote(sParams,'function',File_Function);
  AddValueToNote(sParams,'operation',File_Start_Operation);
  AddValueToNote(sParams,'UserSign',LoginUserSign);
  AddValueToNote(sParams,'Identifier',FIdentifier);
  udpcore.SendServertransfer(sParams,FUserSign);
end;

procedure TfrmFileTransfer.filetran_start;
var
  sFileName,
  sFixPath:WideString;
begin
  Lab_Yes.Visible:=False;
  Lab_Cancel.Caption:='ȡ��';
  Lab_State.Caption:='���ڷ����ļ�...';
  
  iCurFileBlock:=0;
  //----------------------------------------------------------------------------
  //��ʼ���͵�һ���ļ�
  //----------------------------------------------------------------------------
  sFileName:=SendFileList.Strings[iCurFileBlock];
  sFixPath:=WideExtractFilePath(sFileName);
  sFixPath:=Tnt_WideStringReplace(sFixPath,sSendFilePath,'',[rfReplaceAll, rfIgnoreCase]);

  UpdateFileInfor(sFileName,Getfilesize(sFileName));
  UDPFile.SendFile(sFileName,sFixPath);
end;

function TfrmFileTransfer.GetTransCompleteInfor(sTitle:WideString;const bComplete:Boolean=False):Widestring;
begin
  Result:=sFileInfor;
  if not bDirectoryTrans then
  if FServer then
    Result:=ConCat(sSendFilePath,Result)
    else Result:=ConCat(sRecvFilePath,Result);

  if bComplete then
    Result:=ConCat('<a>',Result,'</a>',FormatSize(iSumSize),' ')
    else Result:=ConCat(Result,FormatSize(iSumSize),' ');
    
  if bDirectoryTrans then
    Result:=ConCat(sTitle,'Ŀ¼ ',Result,Format('(%.d ���ļ�������ɣ��� %.d ���ļ�)', [iCurFileBlock,iListCount]))
    else Result:=ConCat(sTitle,'�ļ� ',Result);
end;

procedure TfrmFileTransfer.filetran_cancel;
begin
 InitiativeClose:=false;
 if FServer then
    udpcore.InsertFirendHintMessage(FUserSign,GetTransCompleteInfor(' �Է�ȡ���˽���'))
    else udpcore.InsertFirendHintMessage(FUserSign,GetTransCompleteInfor(' �Է�ȡ���˷���'));
    event.CreateDialogEvent(File_Complete_Event,FUserSign,IntToStr(Handle));
end;

procedure TfrmFileTransfer.filetran_refuse;
begin
  InitiativeClose:=false;
  udpcore.InsertFirendHintMessage(FUserSign,GetTransCompleteInfor(' �Է��ܾ�����'));
  event.CreateDialogEvent(File_Complete_Event,FUserSign,IntToStr(Handle));
end;

procedure TfrmFileTransfer.filetran_update(sParams:WideString);
var
  sFileName:WideString;
  iSize:Int64;
begin
  sFileName:=GetNoteFromValue(sParams,'sFileName');
  iSize:=GetNoteFromValue(sParams,'iSize');
  ChangeIconImage(WideExtractFileName(sFileName));
  lab_Filename.Caption:=GetShortFilename(WideExtractFileName(sFileName),lab_Filename.Width);
  lab_Filesize.Caption:=FormatSize(iSize,false);
  lab_Filename.Hint:=sFileName;
end;

procedure TfrmFileTransfer.filetran_process(sParams:WideString);
var
  iPosition,iCount:LongWord;
  iSize:Int64;
  iTmpCount:LongWord;
begin
  iTmpCount:=iCurFileBlock;
  if iTmpCount>0 then
  if not FServer then dec(iTmpCount);

  iCount:=GetNoteFromValue(sParams,'iCount');
  iPosition:=GetNoteFromValue(sParams,'iPosition');
  iSize:=GetNoteFromValue(sParams,'iSize');
  Lab_speed.Caption:=WideFormat('%s/s (����� %d%%)',[FormatSize(iSize,false),Round(iTmpCount*100/iListCount)]);
  UpdateProcess(iCount,iPosition);
end;

procedure TfrmFileTransfer.filetran_complete;
begin
  InitiativeClose:=false;
  if FServer then
    udpcore.InsertFirendHintMessage(FUserSign,GetTransCompleteInfor(' �ɹ�����',True))
    else udpcore.InsertFirendHintMessage(FUserSign,GetTransCompleteInfor(' �ɹ�����',True));
  event.CreateDialogEvent(File_Complete_Event,FUserSign,IntToStr(Handle));
end;


procedure TfrmFileTransfer.cancelbtnClick(Sender: TObject);
begin
  event.CreateDialogEvent(File_Complete_Event,FUserSign,IntToStr(Handle));
end;

procedure TfrmFileTransfer.UDPFileonRecvReady(Sender:TObject;var sNewFileName:WideString; iSize:Int64);
begin
  inc(iCurFileBlock);
  sNewFileName:=ConCat(sRecvFilePath,UTF8Decode(UDPFile.sReserve));
  ForceCreateDirectorys(WideExtractFilePath(sNewFileName));
  UpdateFileInfor(sNewFileName,iSize);
end;

procedure TfrmFileTransfer.UDPFileProcessEvent(Sender:TObject;iPosition,iCount:LongWord;iSize:Int64);
var
  sParams:WideString;
begin
  AddValueToNote(sParams,'iPosition',iPosition);
  AddValueToNote(sParams,'iCount',iCount);
  AddValueToNote(sParams,'iSize',iSize);
  event.CreateFileEvent(File_UpdateProcess_Event,UDPFile.Identifier,sParams);
end;

procedure TfrmFileTransfer.UDPFileonSendComplete(Sender:TObject);
var
  sParams,
  sFileName,
  sFixPath:WideString;
begin
  inc(iCurFileBlock);
  if iCurFileBlock<iListCount then  //���û����ɼ���������һ���ļ�.
    begin
    sFileName:=SendFileList.Strings[iCurFileBlock];
    sFixPath:=WideExtractFilePath(sFileName);
    sFixPath:=Tnt_WideStringReplace(sFixPath,sSendFilePath,'',[rfReplaceAll, rfIgnoreCase]);
    UpdateFileInfor(sFileName,Getfilesize(sFileName));
    UDPFile.SendFile(sFileName,sFixPath);
    end else begin
    AddValueToNote(sParams,'function',File_Function);
    AddValueToNote(sParams,'operation',File_Complete_Operation);
    AddValueToNote(sParams,'UserSign',LoginUserSign);
    AddValueToNote(sParams,'Identifier',FIdentifier);
    udpcore.SendServertransfer(sParams,FUserSign);
    event.CreateFileEvent(File_Complete_Event,UDPFile.Identifier,'');
    end;
end;


procedure TfrmFileTransfer.UpdateFileInfor(sFileName:WideString;iSize:Int64);
var
  sParams:WideString;
begin
  AddValueToNote(sParams,'sFileName',sFileName);
  AddValueToNote(sParams,'iSize',iSize);
  event.CreateFileEvent(File_UpdateInfor_Event,UDPFile.Identifier,sParams);
end;

//******************************************************************************
procedure TfrmFileTransfer.CloseTrans;
var
  sParams:WideString;
begin
  if InitiativeClose then
    begin
    if FServer then
      begin
      udpcore.InsertFirendHintMessage(FUserSign,GetTransCompleteInfor('��ȡ���˷���'));
      AddValueToNote(sParams,'operation',File_Cancel_Operation);
      end else begin
      udpcore.InsertFirendHintMessage(FUserSign,GetTransCompleteInfor('���ܾ��˽���'));
      AddValueToNote(sParams,'operation',File_Refuse_Operation);
      end;
    AddValueToNote(sParams,'function',File_Function);
    AddValueToNote(sParams,'UserSign',LoginUserSign);
    AddValueToNote(sParams,'Identifier',FIdentifier);
    udpcore.SendServertransfer(sParams,FUserSign);
    end;
end;


procedure TfrmFileTransfer.FormCreate(Sender: TObject);
begin
  inherited;
  DoubleBuffered:=True;
  InitiativeClose:=true;

  SendFileList:=TTntStringList.Create;

  UDPFile:=TUDPStream.Create;
  UDPFile.InitialUdpTransfers('0.0.0.0');
  UDPFile.OnUDPSendComplete:=UDPFileonSendComplete;
  UDPFile.OnUDPRecvReady:=UDPFileonRecvReady;
  FileTransferEvent:=Event.CreateEventProcess(EventProcess,Event_File,UDPFile.Identifier);
end;

//��ʾ���
procedure TfrmFileTransfer.InitializeFrame;
begin
  if sFileinfor='*' then
     begin
     bDirectoryTrans:=True;
     if FServer then sFileinfor:=sSendFilePath
        else sFileinfor:=sRecvFilePath;
     delete(sFileinfor,length(sFileinfor),1);
     end;

  Lab_Cancel.Visible:=True;
  Lab_SaveAs.Visible:=not FServer;
  Lab_Yes.Visible:=not FServer;
  if not FServer then Lab_Cancel.Caption:='�ܾ�'
                 else Lab_Cancel.Caption:='ȡ��';
  if FServer then
     Lab_State.Caption:='�ȴ��Է�ȷ�Ͻ���'
     else Lab_State.Caption:='�Է����ڵȴ�����ȷ��';
  lab_Filename.Caption:=GetShortFilename(sFileinfor,lab_Filename.Width);
  lab_FileSize.Caption:=FormatSize(iSumSize,false);
  lab_Filename.Hint:=sFileinfor;
  ChangeIconImage(sFileinfor);
end;

procedure TfrmFileTransfer.CreateComplete(sUserSign:String;Params:WideString;const bServer:boolean=false);
var
  TmpInfor,MyInfo:Tfirendinfo;
  sParams:WideString;
begin
  FServer:=bServer;
  FUserSign:=sUserSign;
  if not user.find(LoginUserSign,MyInfo) then exit;
  if not user.find(FUserSign,TmpInfor) then exit;

  if FServer then
    UDPFile.OnSendProcessEvent:=UDPFileProcessEvent
    else UDPFile.OnRecvProcessEvent:=UDPFileProcessEvent;

  InitializeBox(FServer);//��ʼ��
  Lab_Yes.OnClick:=Okbtnclick;
  Lab_Cancel.OnClick:=CancelbtnClick;
  Lab_SaveAs.OnClick:=savebtnClick;
  if FServer then
    begin
    iSumSize:=GetNoteFromValue(params,'iSumSize');
    sSendFilePath:=GetNoteFromValue(params,'sDirectory');
    SendFileList.Text:=GetNoteFromValue(params,'sFileList');
    DefaultOpenDir:=sSendFilePath;

    iListCount:=SendFileList.count;
    sFileinfor:=WideString('*');
    if iListCount=1 then
      sFileinfor:=WideExtractFileName(SendFileList.Strings[0]);
      
    AddValueToNote(sParams,'function',File_Function);
    AddValueToNote(sParams,'operation',File_Request_Operation);
    AddValueToNote(sParams,'UserSign',LoginUserSign);
    AddValueToNote(sParams,'iSumSize',iSumSize);
    AddValueToNote(sParams,'iListCount',iListCount);
    AddValueToNote(sParams,'sFileList',sFileinfor);
    AddValueToNote(sParams,'MyIdentifier',UDPFile.Identifier);
    InitializeFrame;
    udpcore.SendServertransfer(sParams,FUserSign);
    end else begin
    sRecvFilePath:=DefaultSaveDir;
    FIdentifier:=GetNoteFromValue(params,'MyIdentifier');
    iSumSize:=GetNoteFromValue(params,'iSumSize');
    iListCount:=GetNoteFromValue(params,'iListCount');

    AddValueToNote(sParams,'function',File_Function);
    AddValueToNote(sParams,'operation',File_Accept_Operation);
    AddValueToNote(sParams,'UserSign',LoginUserSign);
    AddValueToNote(sParams,'FilePort',UDPFile.LocalPort);
    AddValueToNote(sParams,'Identifier',FIdentifier);
    AddValueToNote(sParams,'MyIdentifier',UDPFile.Identifier);

    sFileinfor:=WideString('*');
    if iListCount=1 then
      sFileinfor:=WideExtractFileName(GetNoteFromValue(params,'sFileList'));
    InitializeFrame;

    udpcore.SendServertransfer(sParams,FUserSign);
    end;
end;

procedure TfrmFileTransfer.FormDestroy(Sender: TObject);
begin
  if FServer then
    UDPFile.OnSendProcessEvent:=nil
    else UDPFile.OnRecvProcessEvent:=nil;
  CloseTrans;
  Event.RemoveEventProcess(FileTransferEvent);
  if assigned(UDPFile) then
    freeandnil(UDPFile);
  if assigned(SendFileList) then
    freeandnil(SendFileList);
  inherited;
end;

end.
