unit Controls.Hack;

interface
uses
  Vcl.Controls
  ;

type
  TControl = class(Vcl.Controls.TControl)
  private
    function Get_Text: TCaption;
    procedure Set_Text(const aValue: TCaption); // To Access Protected Control Text Property..
  public
    property LText: TCaption read Get_Text write Set_Text;
  end;

implementation

{ TControl }


{ TControl }

function TControl.Get_Text: TCaption;
begin
  Result := Text;
end;

procedure TControl.Set_Text(const aValue: TCaption);
begin
  Text := aValue;
end;

end.
