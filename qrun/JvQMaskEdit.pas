{**************************************************************************************************}
{  WARNING:  JEDI preprocessor generated unit. Manual modifications will be lost on next release.  }
{**************************************************************************************************}

{-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JvMaskEdit.PAS, released on 2001-02-28.

The Initial Developer of the Original Code is Sébastien Buysse [sbuysse@buypin.com]
Portions created by Sébastien Buysse are Copyright (C) 2001 Sébastien Buysse.
All Rights Reserved.

Contributor(s): Michael Beck [mbeck@bigfoot.com],
                Rob den Braasem [rbraasem@xs4all.nl],
                Oliver Giesen [ogware@gmx.net],
                Peter Thornqvist [peter3@peter3.com].

Last Modified: 2002-12-27

You may retrieve the latest version of this file at the Project JEDI's JVCL home page,
located at http://jvcl.sourceforge.net

Known Issues:
-----------------------------------------------------------------------------}

{$I jvcl.inc}

unit JvQMaskEdit;

interface

uses
  {$IFDEF MSWINDOWS}
  Windows, Messages,
  {$ENDIF MSWINDOWS}
  SysUtils, Classes,
  
  
  Types, QGraphics, QControls, QMask, QForms, QWindows, QTypes,
  
  JvQComponent, JvQTypes, JvQCaret, JvQToolEdit, JvQExMask;

type
  TJvCustomMaskEdit = class(TJvExPubCustomMaskEdit)
  private
    FOnEnabledChanged: TNotifyEvent;
    FOnSetFocus: TJvFocusChangeEvent;
    FOnKillFocus: TJvFocusChangeEvent;
    FHotTrack: Boolean;
    FCaret: TJvCaret;
    FEntering: Boolean;
    FLeaving: Boolean;
    FGroupIndex: Integer;
    FDisabledColor: TColor;
    FDisabledTextColor: TColor;
    FProtectPassword: Boolean;
    FLastNotifiedText: String;
    procedure SetHotTrack(Value: Boolean);
    
  protected
    procedure UpdateEdit;
    procedure CaretChanged(Sender: TObject); dynamic;
    function DoPaintBackground(Canvas: TCanvas; Param: Integer): Boolean; override;
    procedure DoKillFocus(FocusedWnd: HWND); override;
    procedure DoSetFocus(FocusedWnd: HWND); override;
    procedure DoKillFocusEvent(const ANextControl: TWinControl); virtual;
    procedure DoSetFocusEvent(const APreviousControl: TWinControl); virtual;
    procedure DoClipboardPaste; override;
    
    function GetText: TCaption; override;
    procedure SetText(const Value: TCaption); override;
    procedure Paint; override;
    
    procedure EnabledChanged; override;
    procedure MouseEnter(Control :TControl); override;
    procedure MouseLeave(Control :TControl); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure SetCaret(const Value: TJvCaret);
    procedure SetDisabledColor(const Value: TColor); virtual;
    procedure SetDisabledTextColor(const Value: TColor); virtual;
    procedure SetClipboardCommands(const Value: TJvClipboardCommands); override;
    procedure SetGroupIndex(const Value: Integer);
    procedure NotifyIfChanged;
    procedure Change; override;
  public
    
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Entering: Boolean read FEntering;
    property Leaving: Boolean read FLeaving;
  protected
    property Text: TCaption read GetText write SetText;
    
    // set to True to disable read/write of PasswordChar and read of Text
    property ProtectPassword: Boolean read FProtectPassword write FProtectPassword default False;
    property HotTrack: Boolean read FHotTrack write SetHotTrack default False;
    property Caret: TJvCaret read FCaret write SetCaret;

    property DisabledTextColor: TColor read FDisabledTextColor write
      SetDisabledTextColor default clGrayText;
    property DisabledColor: TColor read FDisabledColor write SetDisabledColor default clWindow;
    property GroupIndex: Integer read FGroupIndex write SetGroupIndex default -1;

    property OnEnabledChanged: TNotifyEvent read FOnEnabledChanged write FOnEnabledChanged;
    property OnSetFocus: TJvFocusChangeEvent read FOnSetFocus write FOnSetFocus;
    property OnKillFocus: TJvFocusChangeEvent read FOnKillFocus write FOnKillFocus;
  end;

  TJvMaskEdit = class(TJvCustomMaskEdit)
  published
    property Caret;
    property ClipboardCommands;
    property DisabledTextColor;
    property DisabledColor;
    property GroupIndex;
    property HintColor;
    property HotTrack;
    property ProtectPassword;
    property OnEnabledChanged;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnParentColorChange;

    property Anchors;
    property AutoSelect;
    property AutoSize;
    property BorderStyle;
    property CharCase;
    property Color;
    property Constraints;
    property DragMode;
    property Enabled;
    property EditMask;
    property Font;
    
    property MaxLength;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Text;
    property Visible;

    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    
    property OnStartDrag;
  end;

implementation

constructor TJvCustomMaskEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHotTrack := False;
  FCaret := TJvCaret.Create(Self);
  FCaret.OnChanged := CaretChanged;
  FDisabledColor := clWindow;
  FDisabledTextColor := clGrayText;
  FGroupIndex := -1;
  FEntering := False;
  FLeaving := False;
end;

destructor TJvCustomMaskEdit.Destroy;
begin
  FCaret.OnChanged := nil;
  FreeAndNil(FCaret);
  inherited Destroy;
end;

procedure TJvCustomMaskEdit.EnabledChanged;
begin
  inherited EnabledChanged;
  Invalidate;
  if Assigned(FOnEnabledChanged) then
    FOnEnabledChanged(Self);
end;

procedure TJvCustomMaskEdit.MouseEnter(Control: TControl);
begin
  if csDesigning in ComponentState then
    Exit;
  if not MouseOver then
  begin
    if HotTrack then
      
      
      BorderStyle := bsSingle;
      
    inherited MouseEnter(Control);
  end;
end;

procedure TJvCustomMaskEdit.MouseLeave(Control: TControl);
begin
  if MouseOver then
  begin
    if FHotTrack then
      
      
      BorderStyle := bsSingle; // maybe bsNone
      
    inherited MouseLeave(Control);
  end;
end;

procedure TJvCustomMaskEdit.SetHotTrack(Value: Boolean);
begin
  FHotTrack := Value;
  if Value then
  begin
    
    
    BorderStyle := bsSingle; // maybe bsNone
    
  end
  else
  begin
    
    
    BorderStyle := bsSingle;
    
  end;
end;

procedure TJvCustomMaskEdit.CaretChanged(Sender: TObject);
begin
  FCaret.CreateCaret;
end;

procedure TJvCustomMaskEdit.SetCaret(const Value: TJvCaret);
begin
  FCaret.Assign(Value);
end;

procedure TJvCustomMaskEdit.SetClipboardCommands(const Value: TJvClipboardCommands);
begin
  if ClipboardCommands <> Value then
  begin
    inherited SetClipboardCommands(Value);
    ReadOnly := ClipboardCommands <= [caCopy];
  end;
end;

procedure TJvCustomMaskEdit.SetGroupIndex(const Value: Integer);
begin
  FGroupIndex := Value;
  UpdateEdit;
end;

procedure TJvCustomMaskEdit.UpdateEdit;
var
  I: Integer;
begin
  if Assigned(Owner) then
    for I := 0 to Owner.ComponentCount - 1 do
      if (Owner.Components[i] is TJvCustomMaskEdit) then
        with TJvCustomMaskEdit(Owner.Components[i]) do
          if (Name <> Self.Name) and (GroupIndex <> -1) and
            (GroupIndex = Self.GroupIndex) then
            Clear;
end;

procedure TJvCustomMaskEdit.SetDisabledColor(const Value: TColor);
begin
  if FDisabledColor <> Value then
  begin
    FDisabledColor := Value;
    if not Enabled then
      Invalidate;
  end;
end;

procedure TJvCustomMaskEdit.SetDisabledTextColor(const Value: TColor);
begin
  if FDisabledTextColor <> Value then
  begin
    FDisabledTextColor := Value;
    if not Enabled then
      Invalidate;
  end;
end;

procedure TJvCustomMaskEdit.DoClipboardPaste;
begin
  inherited DoClipboardPaste;
  UpdateEdit;
end;




procedure TJvCustomMaskEdit.Paint;
begin
  with Canvas do
  begin
   // Paint
    if Enabled then
      inherited Paint
    else
    begin
      if not PaintEdit(Self, Text, taLeftJustify, False, {0,}
         FDisabledTextColor, Focused, false, Canvas) then
        inherited Paint;
    end;
  end;
end;


function TJvCustomMaskEdit.DoPaintBackground(Canvas: TCanvas; Param: Integer): Boolean;
begin
  Result := False;
  if csDestroying in ComponentState then
    Exit;
  if Enabled then
    Result := inherited DoPaintBackground(Canvas, Param)
  else
  begin
    Canvas.Brush.Color := FDisabledColor;
    Canvas.Brush.Style := bsSolid;
    Canvas.FillRect(ClientRect);
    Result := True;
  end;
end;

procedure TJvCustomMaskEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  UpdateEdit;
  inherited KeyDown(Key, Shift);
end;



function TJvCustomMaskEdit.GetText: TCaption;
var
  Tmp: Boolean;
begin
  Tmp := ProtectPassword;
  try
    ProtectPassword := False;
    
    
    Result := inherited GetText;
    
  finally
    ProtectPassword := Tmp;
  end;
end;


procedure TJvCustomMaskEdit.SetText(const Value: TCaption);
begin
  
  
  inherited SetText(Value);
  
end;



procedure TJvCustomMaskEdit.DoKillFocus(FocusedWnd: HWND);
begin
  FLeaving := True;
  try
    FCaret.DestroyCaret;
    inherited DoKillFocus(FocusedWnd);
    DoKillFocusEvent(FindControl(FocusedWnd));
  finally
    FLeaving := False;
  end;
end;

procedure TJvCustomMaskEdit.DoSetFocus(FocusedWnd: HWND);
begin
  FEntering := True;
  try
    inherited DoSetFocus(FocusedWnd);
    FCaret.CreateCaret;
    DoSetFocusEvent(FindControl(FocusedWnd));
  finally
    FEntering := False;
  end;
end;

procedure TJvCustomMaskEdit.DoKillFocusEvent(const ANextControl: TWinControl);
begin
  NotifyIfChanged;
  if Assigned(FOnKillFocus) then
    FOnKillFocus(Self, ANextControl);
end;

procedure TJvCustomMaskEdit.DoSetFocusEvent(const APreviousControl: TWinControl);
begin
  NotifyIfChanged;
  if Assigned(FOnSetFocus) then
    FOnSetFocus(Self, APreviousControl);
end;

procedure TJvCustomMaskEdit.Change;
begin
  FLastNotifiedText := Text;
  inherited Change;
end;

procedure TJvCustomMaskEdit.NotifyIfChanged;
begin
  if FLastNotifiedText <> Text then
  begin
    { (ahuser) same code as in Change()
    FLastNotifiedText := Text;
    inherited Change;}
    Change;
  end;
end;

end.

