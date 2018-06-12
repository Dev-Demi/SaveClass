unit USaveClass;

interface

uses
 zlib,Classes;
type
 TClassItem = class;
 TClassItemEnumerator = class;

  TClassItems = class(TCollection)
  Private
   ParentItem:TClassItem;
   function GetItem(Index: Integer): TClassItem;
   procedure SetItem(Index: Integer; Value: TClassItem);
  public
    function AddOrGet(Name:String): TClassItem;
    procedure Remove(Name:String);
    function ItemExists(Name:String):Boolean;
    property Items[Index: Integer]: TClassItem read GetItem  write SetItem;
  end;

  TClassItem = class(TCollectionItem)
  private
    FName:String;
    FProperty: TStringList;
    FStorage: TClassItems;
    FPrt:Integer;
  public
    ParentItem: TClassItem;
    constructor Create(Collection: TCollection); override;
    function GetPropAsHTML: String;
    function GetAddress(separator:char): String;
    destructor Destroy; override;
  published


    property Name:String  read FName write FName;
    property Parent: Integer read FPrt write FPrt;
    property Prop: TStringList read FProperty write FProperty;
    property Storage: TClassItems read FStorage write FStorage;
      // обслуживание перечислител€, не дл€ внешнего использовани€!
    function ForInStorage:TClassItemEnumerator;


  end;

  TSaveClass = class(TComponent)
  private
    FStorage: TClassItems;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    Procedure SaveToFile(FileName:String);
    Procedure LoadFromFile(FileName:String);

    procedure LoadFromTextFile(FileName: String);
    procedure LoadFromText(Text: String);
    procedure SaveToText(var Text: String);

    procedure SaveToTextFile(FileName: String);

    Procedure SaveToCompressFile(FileName:String);
    Procedure LoadFromCompressFile(FileName:String);

    Function GetItemFromAddress(Adr:String;separator:char):TClassItem;

  published
    property Storage: TClassItems read FStorage write FStorage;
  end;

  TClassItemEnumerator=class
    private
     ForInIndex:integer;
     fEnumItem:TClassItem;
     function GetCurrentItem:TClassItem;
    public
    // обслуживание перечислител€, не дл€ внешнего использовани€!
    property Current:TClassItem read GetCurrentItem;
    function MoveNext:boolean;
    function GetEnumerator:TClassItemEnumerator;{$IFDEF SUPPORTS_INLINE}inline;{$ENDIF}
    // генерировать перечень файлов
    Constructor Create(EnumItem:TClassItem);
    Destructor Destroy;override;
  end;

  { TClassItemEnumerator }

implementation
 const
  fmOpenRead       = $0000;
  fmOpenWrite      = $0001;
  fmOpenReadWrite  = $0002;

constructor TClassItemEnumerator.Create(EnumItem: TClassItem);
begin
 fEnumItem:= EnumItem;
 ForInIndex:=-1;
end;

destructor TClassItemEnumerator.Destroy;
begin

  inherited;
end;

function TClassItemEnumerator.GetCurrentItem: TClassItem;
begin
 result:=nil;

 if ForInIndex<0 then exit;
  if fEnumItem.storage.Count>0 then
   if ForInIndex<fEnumItem.storage.Count then
    result:= fEnumItem.Storage.GetItem(ForInIndex);
end;

function TClassItemEnumerator.GetEnumerator: TClassItemEnumerator;
begin
 result:=self;
end;

function TClassItemEnumerator.MoveNext: boolean;
begin
 result:=true;
 if ForInIndex>=fEnumItem.storage.Count-1 then
  result:=false;

 if result then
  ForInIndex:=ForInIndex+1;
end;


constructor TClassItem.Create(Collection: TCollection);
begin
 inherited;
 FProperty := TStringList.Create;
 FStorage:=TClassItems.Create(TClassItem);
 FStorage.ParentItem:=self;
end;

destructor TClassItem.Destroy;
begin
 FProperty.Free;
 FStorage.Free;
 inherited;
end;



function TClassItems.AddOrGet(Name:String): TClassItem;
var
 i:integer;
 Item:TClassItem;
begin
 For i:=0 to Count-1 do
  if Items[i].Name=Name then
   begin
    result:=TClassItem(Items[i]);
    exit;
   end;
 Item := TClassItem(inherited Add);
 Item.ParentItem:=ParentItem;
 Item.Parent:=Integer(ParentItem);
 Item.Name:=Name;
 result:=Item;

end;

function TClassItems.GetItem(Index: Integer): TClassItem;
begin
 Result := TClassItem(inherited Items[Index]);
end;

function TClassItems.ItemExists(Name: String): Boolean;
var
 i:integer;
begin
 result:=false;
 For i:=0 to Count-1 do
  if Items[i].Name=Name then
   begin
    result:=true;
    exit;
   end;
end;

procedure TClassItems.Remove(Name: String);
var
 i:integer;
begin
 For i:=0 to Count-1 do
  if Items[i].Name=Name then
   begin
     Delete(i);
     exit;
   end;
end;

procedure TClassItems.SetItem(Index: Integer; Value: TClassItem);
begin
 Items[Index].Assign(Value);
end;

constructor TSaveClass.Create(AOwner: TComponent);
begin
 inherited Create(AOwner);
 Storage := TClassItems.Create(TClassItem);
end;

destructor TSaveClass.Destroy;
begin
 Storage.Free;
 inherited;
end;

function TSaveClass.GetItemFromAddress(Adr: String;
  separator: char): TClassItem;
var
 i,n:integer;
 st,ItemName:string;
 Item:TClassItem;
begin
 i:=1;
 n:=1;
 st:=adr;
 result:=nil;
 if FStorage.Count>0 then
  Item:=FStorage.Items[0]
 else
  exit;
 while i<= length(st)+1 do
 begin
  If (st[i]=separator)or(i= length(st)+1) then
   begin
    ItemName:=Copy(st,n,i-n);
    n:=i+1;
    If Item.Storage.ItemExists(ItemName) then
     Item:=Item.Storage.AddOrGet(ItemName)
//    else
//     exit;
   end;
  i:=i+1;
 end;
 result:=item;
end;

procedure TSaveClass.LoadFromCompressFile(FileName: String);
var
 SourceFile : TFileStream;
 ms :TMemoryStream;
 decompr : TDecompressionStream;
 bytecount : Integer;
begin
 SourceFile := TFileStream.Create(FileName, fmOpenRead);
 ms := TMemoryStream.Create;
 try
  SourceFile.Read(bytecount,SizeOf(bytecount));
  if bytecount > 0 then
   begin
    decompr := TDecompressionStream.Create(SourceFile);
    try
     ms.CopyFrom(decompr,bytecount);
    finally
     decompr.Free;
    end;
    ms.position := 0;
    ms.ReadComponent(self);
   end;
 finally
  SourceFile.Free;
  ms.Free;
 end;
end;

procedure TSaveClass.LoadFromFile(FileName: String);
 var
  ms: TMemoryStream;
begin
  ms := TMemoryStream.Create;
  try
   ms.LoadFromFile(FileName);
   ms.position := 0;
   ms.ReadComponent(self);
  finally
   ms.Free;
  end;
end;

procedure TSaveClass.LoadFromText(Text: String);
 var
  ms1: TMemoryStream;
  SS:TStringStream;
begin

  ms1:= TMemoryStream.Create;
  SS:=TStringStream.Create;
  SS.WriteString(Text);
  SS.Position:=0;

  try
    ObjectTextToBinary(ss, ms1);
    ms1.position := 0;
    ms1.ReadComponent(self);
  finally
    ss.Free;
    ms1.Free;
  end;

end;

procedure TSaveClass.LoadFromTextFile(FileName: String);
 var
  ms: TMemoryStream;
  fs: TFileStream;
begin
  fs := TFileStream.Create(FileName, fmOpenRead);
  ms := TMemoryStream.Create;
  try
    ObjectTextToBinary(fs, ms);
    ms.position := 0;
    ms.ReadComponent(self);
  finally
    ms.Free;
    fs.free;
  end;
end;

procedure TSaveClass.SaveToCompressFile(FileName: String);
var
 ms: TMemoryStream;
 DestFile : TFileStream;
 compr : TCompressionStream;
 bytecount : Integer;
begin
 ms := TMemoryStream.Create;
 DestFile := TFileStream.Create(FileName,fmCreate);
 try
  ms.WriteComponent(Self);
  ms.position := 0;
  bytecount:= ms.Size;
  DestFile.Write(bytecount, SizeOf(bytecount));
  compr := TCompressionStream.Create(clMax, DestFile);
   try
    compr.CopyFrom(ms,bytecount);
   finally
    compr.Free;
   end;
 finally
  ms.Free;
  DestFile.Free;
 end;
end;

procedure TSaveClass.SaveToFile(FileName: String);
var
 ms: TMemoryStream;
begin
 ms := TMemoryStream.Create;
 try
  ms.WriteComponent(Self);
  ms.position := 0;
  ms.SaveToFile(FileName);
 finally
  ms.Free;
 end;
end;

procedure TSaveClass.SaveToText(var Text: String);
var
 ms: TMemoryStream;
 fs: TStringStream;
begin
 fs := TStringStream.Create;
 ms := TMemoryStream.Create;
 try
  ms.WriteComponent(Self);
  ms.position := 0;
  ObjectBinaryToText(ms, fs);
  fs.Position:=0;
  text:=fs.ReadString(fs.Size);
 finally
  ms.Free;
  fs.free;
 end;

end;

procedure TSaveClass.SaveToTextFile(FileName: String);
var
 ms: TMemoryStream;
 fs: TFileStream;
begin
 fs := TFileStream.Create(FileName, fmCreate or fmOpenWrite);
 ms := TMemoryStream.Create;
 try
  ms.WriteComponent(Self);
  ms.position := 0;
  ObjectBinaryToText(ms, fs);
 finally
  ms.Free;
  fs.free;
 end;
end;

function TClassItem.GetAddress(separator: char): String;
//var
// item:TClassItem;
begin
 result:='';
// Item:=self;
// while Item.
end;

function TClassItem.ForInStorage: TClassItemEnumerator;
begin
 result:= TClassItemEnumerator.Create(self);
end;

function TClassItem.GetPropAsHTML: String;
var
 HTMLStr:TStringList;
 i:integer;
begin
 HTMLStr:=TstringList.Create;
 HTMLStr.Clear;
 HTMLStr.Add('<HTML>');
 HTMLStr.Add('<HEAD>');
 HTMLStr.Add('<TITLE>'+Name+'</TITLE>');
 HTMLStr.Add('</HEAD>');
 HTMLStr.Add('<BODY BGCOLOR="#FFFFFF">');
 HTMLStr.Add('<H1><CENTER> '+Name+'</CENTER></H1>');
 HTMLStr.Add('<HR ALIGN="centr" WIDTH="80%" SIZE="3">');

 HTMLStr.Add('<CENTER>');
 HTMLStr.Add('<table border><CENTER>');
 i:=0;
 While i<=Prop.Count-1 do
 begin
  HTMLStr.Add('<tr>');
  HTMLStr.Add('<th BGCOLOR="#A0A0A0">'+ Prop.Names[i] + '</th>');
  HTMLStr.Add('<th>'+Prop.ValueFromIndex[i]+ '</th>');
  HTMLStr.Add('</tr>');
  i:=i+1;
 end;

 HTMLStr.Add('</TABLE>');
 HTMLStr.Add('</CENTER>');
 HTMLStr.Add('<HR ALIGN="centr" WIDTH="80%" SIZE="3">');
 HTMLStr.Add('<p align="left"> —писок дочерних объектов: </p>');
 HTMLStr.Add('<ul type=square>');
 i:=0;
 While i<=Storage.Count-1 do
 begin
  HTMLStr.Add('<li> <a align="left" href= "'+Storage.Items[i].Name+'">  '+Storage.Items[i].Name+'</a></li>');
  i:=i+1;
 end;
 HTMLStr.Add('</ul>');
 HTMLStr.Add('</BODY>');
 HTMLStr.Add('</HTML>');
 result:= HTMLStr.Text;
 HTMLStr.Free;
end;



end.
