unit MainFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, JvListBox, JvCtrls, JvComponent, JvBaseDlg, JvSHFileOp,
  JvButton, JvToolEdit, Mask, JvCheckBox, JvGroupBox, JvLabel, JvMemo,
  ExtCtrls, JvBevel;

type
  TfrmMain = class(TForm)
    JvSHFileOperation1: TJvSHFileOperation;
    btnCopy: TButton;
    btnMove: TButton;
    btnRename: TButton;
    btnDelete: TButton;
    memSource: TMemo;
    JvLabel1: TLabel;
    JvLabel2: TLabel;
    memDest: TMemo;
    JvGroupBox1: TGroupBox;
    chkUndo: TCheckBox;
    chkFiles: TCheckBox;
    chkMulti: TCheckBox;
    chkNoConfirm: TCheckBox;
    chkNoDirCreate: TCheckBox;
    chkRename: TCheckBox;
    chkSilent: TCheckBox;
    chkSimple: TCheckBox;
    chkMappings: TCheckBox;
    chkNoErrors: TCheckBox;
    JvBevel1: TBevel;
    JvLabel3: TLabel;
    memMessages: TMemo;
    Label1: TLabel;
    edTitle: TEdit;
    procedure JvSHFileOperation1FileMapping(Sender: TObject;
      const OldFileName, NewFilename: String);
    procedure btnCopyClick(Sender: TObject);
    procedure btnMoveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnRenameClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
  private
    { Private declarations }
    procedure DoIt(AType: TJvSHFileOpType;const OKMsg:string);
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.JvSHFileOperation1FileMapping(Sender: TObject;
  const OldFileName, NewFilename: String);
begin
  memMessages.Lines.Add(Format('"%s" renamed as "%s"',[OldFileName,NewFileName]));
end;

procedure TfrmMain.DoIt(AType:TJvSHFileOpType;const OKMsg:string);
var AOptions:TJvShFileOptions;
begin
  memMessages.Lines.Clear;
  JvSHFileOperation1.Operation := AType;
  JvSHFileOperation1.SourceFiles := memSource.Lines;
  JvSHFileOperation1.DestFiles := memDest.Lines;
  JvSHFileOperation1.Title := edTitle.Text;
  AOptions := [];
  if chkUndo.Checked then
    Include(AOptions,fofAllowUndo);
  if chkFiles.Checked then
    Include(AOptions,fofFilesOnly);
  if chkMulti.Checked then
    Include(AOptions,fofMultiDestFiles);
  if chkNoConfirm.Checked then
    Include(AOptions,fofNoConfirmation);
  if chkNoDirCreate.Checked then
    Include(AOptions,fofNoConfirmMkDir);
  if chkRename.Checked then
    Include(AOptions,fofRenameOnCollision);
  if chkSilent.Checked then
    Include(AOptions,fofSilent);
  if chkSimple.Checked then
    Include(AOptions,fofSimpleProgress);
  if chkMappings.Checked then
    Include(AOptions,fofWantMappingHandle);
  if chkNoErrors.Checked then
    Include(AOptions,fofNoErrorUI);
  JvSHFileOperation1.Options := AOptions;
  if not JvSHFileOperation1.Execute then
    memMessages.Lines.Add(SysErrorMessage(GetLastError))
  else
    memMessages.Lines.Add(OkMsg);
end;  

procedure TfrmMain.btnCopyClick(Sender: TObject);
begin
  DoIt(foCopy,'Copy finished');
end;

procedure TfrmMain.btnMoveClick(Sender: TObject);
begin
  DoIt(foMove,'Move finished');
end;

procedure TfrmMain.btnRenameClick(Sender: TObject);
begin
  DoIt(foRename,'Rename finished');
end;

procedure TfrmMain.btnDeleteClick(Sender: TObject);
begin
  DoIt(foDelete,'Delete finished');
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Application.HintHidePause := 5000;
end;



end.
