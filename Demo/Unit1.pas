unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,USaveClass, Grids, ValEdit, ComCtrls, OleCtrls,
  ActiveX, SHDocVw, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    TreeView1: TTreeView;
    ValueListEditor1: TValueListEditor;
    WebBrowser1: TWebBrowser;
    Button2: TButton;
    Edit1: TEdit;
    WebCheckBox: TCheckBox;
    Memo1: TMemo;
    Panel1: TPanel;
    procedure Button1Click(Sender: TObject);
    procedure TreeView1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure WebBrowser1BeforeNavigate2(ASender: TObject;
      const pDisp: IDispatch; const URL, Flags, TargetFrameName, PostData,
      Headers: OleVariant; var Cancel: WordBool);
  private
   procedure ViewHTML(Item: TClassItem);

    { Private declarations }
  public
    { Public declarations }
   Procedure ToTreeViev(Item: TClassItem; TreeNode:TTreeNode);
  end;
var
  Form1: TForm1;
  sc:TSaveClass;
implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
 Shkaf,Sections,Section,Polka,Item:TClassItem;
begin
 Memo1.Clear;

 // Класс для быстрой сериализации/десериализации объектов
 // Class for fast serialization / deserialization of objects

 sc:=TSaveClass.Create(nil);
 // Создание, добавляем элемент
 // Create, add item
 Shkaf:=sc.Storage.AddOrGet('Shkaf');
 // Добавляем свойства элемента
 // Add propetry to item by name
 Shkaf.Prop.Values['W']:='3000';
 Shkaf.Prop.Values['H']:='1800';
 Shkaf.Prop.Values['D']:='300';
 Sections:= Shkaf.Storage.AddOrGet('Sections');
  Section:= Sections.Storage.AddOrGet('Section1');
  Section.Prop.Values['width']:='152';
   Polka:=Section.Storage.AddOrGet('Polka1');
   Polka.Prop.Values['Position']:='450';
   Polka:=Section.Storage.AddOrGet('Polka2');
   Polka.Prop.Values['Position']:='0';

  // Пример использования For.. in
  // Exsample usage For..in
  for item  in  Section.ForInStorage do
    Memo1.Lines.Add(item.Name);

  Section:= Sections.Storage.AddOrGet('Section2');
  Section.Prop.Values['width']:='300';

  // Сохраняем в разные форматы файлов
  // Save to file
  sc.SaveToTextFile('sc.txt');
  sc.SaveToFile('sc.bin');
  sc.SaveToCompressFile('sc.z');
  sc.Free;

  //Загружаем из файла
  //Load from File
  sc := TSaveClass.Create(Form1);
  sc.LoadFromCompressFile('sc.z');
  Shkaf := sc.Storage.AddOrGet('Shkaf');

  ToTreeViev(Shkaf, Nil);
end;

procedure TForm1.ToTreeViev(Item: TClassItem; TreeNode: TTreeNode);
var
 i:integer;
 ch:TClassItem;
 chTreeNode:TTreeNode;
begin
 if TreeNode= nil then
  begin
   chTreeNode:=TTreeNode.Create(TreeView1.Items);
   chTreeNode:= TreeView1.Items.AddObjectFirst(chTreeNode,Item.Name,Item);
   ToTreeViev(Item,chTreeNode);
  end
 else
  begin
   for i:=0 to Item.Storage.Count-1 do
    begin
     ch:=Item.Storage.Items[i];
     chTreeNode:=TreeView1.Items.AddChildObject(TreeNode,ch.Name,ch);
     ToTreeViev(ch,chTreeNode);
    end;
  end;
end;

procedure TForm1.TreeView1Click(Sender: TObject);
var
 Item:TClassItem;
begin
 if TreeView1.Selected<> nil then
  begin
   Item:=TreeView1.Selected.Data;
   ValueListEditor1.Strings:=Item.Prop;
   Form1.Caption:='Parent='+ IntToStr(Item.Parent);
   if WebCheckBox.Checked then
    ViewHTML(Item);
  end;
end;

procedure TForm1.ViewHTML(Item: TClassItem);
var
  sl: TStringList;
  ms: TMemoryStream;
begin
  WebBrowser1.Navigate('about:blank');
  while WebBrowser1.ReadyState < READYSTATE_INTERACTIVE do
    Application.ProcessMessages;

  if Assigned(WebBrowser1.Document) then
  begin
    sl := TStringList.Create;
    try
      ms := TMemoryStream.Create;
      try
        sl.Text := Item.GetPropAsHTML;
        sl.SaveToStream(ms);
        ms.Seek(0, 0);
        (WebBrowser1.Document as
          IPersistStreamInit).Load(TStreamAdapter.Create(ms));
      finally
        ms.Free;
      end;
    finally
      sl.Free;
    end;
  end;
end;

procedure TForm1.WebBrowser1BeforeNavigate2(ASender: TObject;
  const pDisp: IDispatch; const URL, Flags, TargetFrameName, PostData,
  Headers: OleVariant; var Cancel: WordBool);
var
 Item:TClassItem;
 st:string;
 i:integer;
begin
 if url <> 'about:blank' then
 begin
 if TreeView1.Selected<> nil then
  begin
   st:=url;
   delete(st,1,11);
   form1.Caption:=st;
   Item:=TClassItem(TreeView1.Selected.Data);
   if item.Storage.ItemExists(st) then
    begin
     ViewHTML(item.Storage.AddOrGet(st));
     ValueListEditor1.Strings:=item.Storage.AddOrGet(st).Prop;
     for i:=0 to TreeView1.Selected.Count-1 do
      if  TClassItem(TreeView1.Selected.Item[i].data).Name=st then
      begin
       TreeView1.Selected:= TreeView1.Selected.Item[i];
       break;
      end;
    end;
  end;
  cancel:=true;
 end;

end;

procedure TForm1.Button2Click(Sender: TObject);
var
 polka:TClassItem;
begin
 polka:=sc.GetItemFromAddress(Edit1.Text,'/');
 ShowMessage(Polka.Name+#13+Polka.Prop.Text);
end;

end.
