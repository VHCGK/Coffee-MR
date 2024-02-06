codeunit 70032 CoffeDemoDataGenerator
{
    var
        InvalidItemTemplateErr: Label 'We tried to create some sample items, but we could not apply the template "%1". Make sure you are running in an evaluation company with a valid item template.';

    procedure GenerateDemoData()
    var
        itemRecord: Record Item;
        itemImageCodeUnit: Codeunit CoffeeMachineImages;
        itemimageCodeUnitExtra: Codeunit CoffeeExtrasImages;
    begin

        // Add item catagories
        AddItemCatagories('Finished goods', 'finishedGoods');
        AddItemCatagories('Consumables', 'consumables');
        AddItemCatagories('Maintenance', 'maintenance');
        AddItemCatagories('Accessory', 'accessory');

        // Add Coffee machines
        AddItem('CM001', 'Contoso SLIM 2018 San Diego', 'Contoso SLIM 2018 San Diego', 'finishedGoods', 699, itemImageCodeUnit.C0001_2018SandiagoSlim(), 40, 15, 23);
        AddItem('CM002', 'Contoso SLIM 2019 Las Vegas', 'Contoso SLIM 2019 Las Vegas', 'finishedGoods', 850, itemImageCodeUnit.C0002_2019LasVegaSlim(), 20, 20, 26);
        AddItem('CM003', 'Contoso MINI 2018 San Diego', 'Contoso MINI 2018 San Diego', 'finishedGoods', 499, itemImageCodeUnit.C0003_2018SandiagoMini(), 30, 35, 20);
        AddItem('CM004', 'Contoso MINI 2022 Orlando', 'Contoso MINI 2022 Orlando', 'finishedGoods', 499, itemImageCodeUnit.C0004_2022OrlandoMini(), 15, 20, 15);
        AddItem('CM005', 'Contoso MINI 2023 Orlando', 'Contoso MINI 2023 Orlando', 'finishedGoods', 699, itemImageCodeUnit.C0005_2023OrlandoMini(), 32, 20, 18);
        AddItem('CM006', 'Contoso PRO SLIM 2023 Orlando', 'Contoso PRO SLIM 2023 Orlando', 'finishedGoods', 699, itemImageCodeUnit.C0006_2023OrlandoProSlim(), 10, 9, 40);
        AddItem('CM007', 'Contoso MINI 2019 Las Vegas', 'Contoso MIINI 2019 Las Vegas', 'finishedGoods', 699, itemImageCodeUnit.C0007_2019LasVegasMini(), 14, 7, 60);

        // Add extras items for coffee machines
        AddItem('E0001', 'Coffee beans', 'Freshly roasted beans for brewing coffee', 'consumables', 12, itemimageCodeUnitExtra.E0001_beans(), 3, 6, 2);
        AddItem('E0002', 'Paper filters', 'Disposable filters for drip or pour-over coffee makers', 'consumables', 6, itemimageCodeUnitExtra.E0002_paperFilters(), 2, 6, 6);
        AddItem('E0003', 'Descaling solution', 'Solution for removing mineral buildup from the coffee machine', 'consumables', 10, itemimageCodeUnitExtra.E0003_descaling(), 8, 4, 4);
        AddItem('E0004', 'Milk frothing pitcher', 'Stainless steel pitcher for steaming and frothing milk', 'consumables', 15, itemimageCodeUnitExtra.E0004_milkFrothePither(), 5, 4, 4);
        AddItem('E0005', 'Tamper', 'Tool used to compress ground coffee in the portafilter', 'accessory', 20, itemimageCodeUnitExtra.E0005_tamper(), 4, 2, 2);
        AddItem('E0006', 'Milk frother attachment', 'Attachment for making frothed milk for cappuccinos and lattes', 'accessory', 25, itemimageCodeUnitExtra.E0006_milkFrother(), 5, 3, 3);
        AddItem('E0007', 'Portafilter basket', 'Replacement or additional basket for the portafilter', 'accessory', 12, itemimageCodeUnitExtra.E0007_portaFilterBasket(), 4, 4, 2);
        AddItem('E0008', 'Knock box for used coffee grounds', 'Container for discarding used coffee grounds', 'accessory', 30, itemimageCodeUnitExtra.E0008_box(), 6, 6, 6);
        AddItem('E0009', 'Replacement water filter cartridge', 'Replacement cartridge for the water filtration system in the machine', 'accessory', 8, itemimageCodeUnitExtra.E0009_waterFilter(), 3, 3, 3);
        AddItem('E0010', 'Cleaning brush', 'Small brush for cleaning the grouphead, portafilter, and steam wand', 'maintenance', 7, itemimageCodeUnitExtra.E0010_CleaningBrush(), 8, 2, 1);
        AddItem('E0011', 'Grouphead cleaning powder', 'Powder for removing coffee oils and residue from the grouphead', 'maintenance', 9, itemimageCodeUnitExtra.E0011_CleaningPowder(), 6, 3, 3);
        AddItem('E0012', 'Steam wand cleaning solution', 'Solution for removing milk residue from the steam wand', 'maintenance', 12, itemimageCodeUnitExtra.E0012_SteamWandcleaningSolution(), 8, 4, 4);
        AddItem('E0013', 'Drip tray liners', 'Disposable liners for collecting drips and spills from the machine', 'maintenance', 5, itemimageCodeUnitExtra.E0013_DripTrayLiners(), 5, 5, 0.1);

    end;

    procedure AddItem(ItemNumber: Text; ItemName: Text; description: Text; itemCategory: Text; unitPrice: Decimal; itemPicture: Text; itemheight: Decimal; itemWidth: Decimal; itemDepth: Decimal);
    var
        ItemTempl: Record "Item Templ.";
        ItemRecord: Record Item;
        ItemTemplMgt: Codeunit "Item Templ. Mgt.";
        ItemCreated: Boolean;
        IsHandled: Boolean;
    begin
        // Create item with manual primary key
        ItemRecord.Init();
        ItemRecord.Validate("No.", ItemNumber);

        // Apply item template for physical items
        ItemTempl.SetFilter("Inventory Posting Group", '<>%1', '');
        ItemTempl.FindFirst();
        ItemCreated := ItemTemplMgt.CreateItemFromTemplate(ItemRecord, IsHandled, ItemTempl.Code);
        if not ItemCreated or not IsHandled then
            Error(InvalidItemTemplateErr, ItemTempl.Code);

        // Update the item information
        ItemRecord.Get(ItemNumber);
        ItemRecord.Validate(Description, ItemName);
        ItemRecord.Validate("Unit Price", UnitPrice);
        ItemRecord.Validate("Item Category Code", itemCategory);
        ItemRecord.Validate(ShowInCoffeeMRApp, true);
        ItemRecord.Validate(LongDescription, description);
        ItemRecord.Validate(itemheight, itemheight);
        ItemRecord.Validate(itemWidth, itemWidth);
        ItemRecord.Validate(itemDepth, itemDepth);
        ItemRecord.Modify(true);

        AddImageToItem(ItemPicture, ItemRecord);
        AddItemUnitOfMeasure(ItemNumber);
    end;

    procedure AddItemCatagories(description: Text; code: Text)
    var
        itemCatagory: Record "Item Category";
    begin
        if itemCatagory.Get(code) then
            exit;

        itemCatagory.Init();
        itemCatagory.Validate(description, description);
        itemCatagory.Validate(Code, code);
        itemCatagory.Insert(true);
    end;

    procedure AddItemUnitOfMeasure(itemNumber: Text)
    var
        itemUnitOfMeasure: Record "Item Unit of Measure";
        itemRecord: Record Item;
    begin
        itemUnitOfMeasure.SetRange("Item No.", itemNumber);
        itemUnitOfMeasure.SetRange(Code, 'PCS');
        if itemUnitOfMeasure.FindFirst() then
            exit;

        itemUnitOfMeasure.Init();
        itemUnitOfMeasure.Validate("Item No.", itemNumber);
        itemUnitOfMeasure.Validate(Code, 'PCS');
        itemUnitOfMeasure.Insert(true);

        itemRecord.Get(itemNumber);
        itemRecord.validate("Base Unit of Measure", 'PCS');
        itemRecord.Modify(true);
    end;

    procedure AddImageToItem(Base64Img: Text; var itemRecord: Record Item)
    var
        Base64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
    begin
        Outstr := TempBlob.CreateOutStream();
        Base64Convert.FromBase64(Base64Img, Outstr);
        itemRecord.Picture.ImportStream(TempBlob.CreateInStream(), 'Image demo data for Item');
        ItemRecord.Modify(true);
    end;
}