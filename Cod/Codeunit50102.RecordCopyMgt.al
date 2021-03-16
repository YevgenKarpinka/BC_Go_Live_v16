codeunit 50102 "Record Copy Mgt."
{
    // Version BCGOLIVE -- DELETE TABLES FOR GO-LIVE (TRANSACTIONAL,ASSIGN YOUR TABLES)
    Permissions = TableData "Item Ledger Entry" = rimd, TableData "Value Entry" = rimd,
    TableData "G/L Entry" = rimd, TableData "Cust. Ledger Entry" = rimd,
    TableData "Vendor Ledger Entry" = rimd, TableData "Item Vendor" = rimd,
    TableData "G/L Register" = rimd, TableData "Item Register" = rimd,
    TableData "Sales Shipment Header" = rimd, TableData "Sales Shipment Line" = rimd,
    TableData "Sales Invoice Header" = rimd, TableData "Sales Invoice Line" = rimd,
    TableData "Sales Cr.Memo Header" = rimd, TableData "Sales Cr.Memo Line" = rimd,
    TableData "Purch. Rcpt. Header" = rimd, TableData "Purch. Rcpt. Line" = rimd,
    TableData "Purch. Inv. Header" = rimd, TableData "Purch. Inv. Line" = rimd,
    TableData "Purch. Cr. Memo Hdr." = rimd, TableData "Purch. Cr. Memo Line" = rimd,
    TableData "Reservation Entry" = rimd, TableData "Entry Summary" = rimd,
    TableData "Detailed Cust. Ledg. Entry" = rimd, TableData "Detailed Vendor Ledg. Entry" = rimd,
    TableData "Deferral Header" = rimd, TableData "Deferral Line" = rimd,
    TableData "Item Application Entry" = rimd,
    TableData "Production Order" = rimd, TableData "Prod. Order Line" = rimd,
    TableData "Prod. Order Component" = rimd, TableData "Prod. Order Routing Line" = rimd,
    TableData "Posted Deferral Header" = rimd, TableData "Posted Deferral Line" = rimd,
    TableData "Item Variant" = rimd, TableData "Unit of Measure Translation" = rimd,
    TableData "Item Unit of Measure" = rimd,
    TableData "Transfer Header" = rimd, TableData "Transfer Line" = rimd,
    TableData "Transfer Route" = rimd, TableData "Transfer Shipment Header" = rimd,
    TableData "Transfer Shipment Line" = rimd, TableData "Transfer Receipt Header" = rimd,
    TableData "Transfer Receipt Line" = rimd,
    TableData "Capacity Ledger Entry" = rimd, TableData "Lot No. Information" = rimd,
    TableData "Serial No. Information" = rimd, TableData "Item Entry Relation" = rimd,
    TableData "Return Shipment Header" = rimd, TableData "Return Shipment Line" = rimd,
    TableData "Return Receipt Header" = rimd, TableData "Return Receipt Line" = rimd,
    TableData "G/L Budget Entry" = rimd, TableData "Res. Capacity Entry" = rimd,
    TableData "Job Ledger Entry" = rimd, TableData "Res. Ledger Entry" = rimd,
    TableData "VAT Entry" = rimd, TableData "Document Entry" = rimd,
    TableData "Bank Account Ledger Entry" = rimd, TableData "Phys. Inventory Ledger Entry" = rimd,
    TableData "Approval Entry" = rimd, TableData "Posted Approval Entry" = rimd,
    TableData "Cost Entry" = rimd, TableData "Employee Ledger Entry" = rimd,
    // TableData "Detailed Employee Ledger Entry" = rimd, 
    TableData "FA Ledger Entry" = rimd,
    TableData "Maintenance Ledger Entry" = rimd, TableData "Service Ledger Entry" = rimd,
    TableData "Warranty Ledger Entry" = rimd, TableData "Item Budget Entry" = rimd,
    TableData "Production Forecast Entry" = rimd, TableData "Location" = rimd, TableData "Bin" = rimd,
    TableData "Customer" = rimd, TableData "Vendor" = rimd, TableData "Item" = rimd,
    TableData "Warehouse Entry" = rimd;
    //... ADD COUNTRY LOCALIZATION TABLES, FA, SERVICE etc. etc.

    trigger OnRun()
    begin
    end;

    var
        Text0001: Label 'Copy Records to All Holding?';
        Text0002: Label 'Copying Records!\Company: #2########\Table: #1#######';

    procedure CopyRecords(var RecordCopyTable: Record "Record Copy Table")
    var
        Window: Dialog;
        RecRefFrom: RecordRef;
        RecRefTo: RecordRef;
        IntegrationCompany: Record "Company Integration";
    begin
        CheckCompanyFrom();

        if not Confirm(Text0001, false) then
            exit;

        Window.Open(Text0002);

        IntegrationCompany.SetRange("Copy Items To", true);
        if IntegrationCompany.FindSet(false, false) then
            repeat
                Window.Update(2, IntegrationCompany."Company Name");
                if RecordCopyTable.FindSet(false, false) then
                    repeat
                        Window.Update(1, Format(RecordCopyTable."Table ID"));
                        RecRefFrom.Open(RecordCopyTable."Table ID", false, CompanyName);
                        RecRefTo.Open(RecordCopyTable."Table ID", false, IntegrationCompany."Company Name");
                        if RecRefFrom.FindSet(false, false) then
                            repeat
                                CopyRecord(RecRefTo, RecRefFrom);
                                if RecRefTo.Insert() then RecRefTo.Modify();
                            until RecRefFrom.Next() = 0;
                        // RecRef.DeleteAll;  //** DELETE DATA FROM TABLES
                        RecRefTo.Close();
                        RecRefFrom.Close;
                    until RecordCopyTable.Next = 0;
            until IntegrationCompany.Next() = 0;

        Window.Close;
    end;

    local procedure CheckCompanyFrom()
    var
        IntegrationCompany: Record "Company Integration";
    begin
        IntegrationCompany.SetRange("Company Name", CompanyName);
        IntegrationCompany.FindFirst();
        IntegrationCompany.TestField("Copy Items From", true);
    end;

    local procedure CopyRecord(var RecRefTo: RecordRef; var RecRefFrom: RecordRef)
    var
        Field: Record Field;
    begin
        Field.Reset();
        Field.SetRange(TableNo, RecRefFrom.NUMBER);
        Field.SetRange(Enabled, TRUE);
        Field.SetRange(Class, Field.Class::Normal);
        Field.SetFilter(Type, '<>%1', Field.Type::BLOB);
        IF Field.FINDSET THEN
            REPEAT
                RecRefTo := RecRefFrom;
                RecRefTo.Field("No.") := RecRefFrom.Field(Field."No.");
                FieldRefTo.Value := FieldRefFrom.Value;
            UNTIL Field.NEXT = 0;
    end;
}