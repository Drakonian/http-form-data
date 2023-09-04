codeunit 81851 "FOD API Mgt"
{
    //Universal codeunit to send http requests
    procedure SendRequest(RequestMethod: enum "Http Request Type"; requestUri: Text; var ResponseValue: Codeunit "Temp Blob")
    var
        DictionaryDefaultHeaders: Codeunit "Dictionary Wrapper";
        DictionaryContentHeaders: Codeunit "Dictionary Wrapper";
        ContentType: Text;
    begin
        SendRequest('', RequestMethod, requestUri, ContentType, 0, ResponseValue, DictionaryContentHeaders, DictionaryDefaultHeaders);
    end;

    procedure SendRequest(contentToSend: Variant; RequestMethod: enum "Http Request Type"; requestUri: Text; ContentType: Text; var ResponseValue: Codeunit "Temp Blob")
    var
        DictionaryDefaultHeaders: Codeunit "Dictionary Wrapper";
        DictionaryContentHeaders: Codeunit "Dictionary Wrapper";
    begin
        SendRequest(contentToSend, RequestMethod, requestUri, ContentType, 0, ResponseValue, DictionaryContentHeaders, DictionaryDefaultHeaders);
    end;

    procedure SendRequest(contentToSend: Variant; RequestMethod: enum "Http Request Type"; requestUri: Text; ContentType: Text; var ResponseValue: Codeunit "Temp Blob"; DictionaryDefaultHeaders: Codeunit "Dictionary Wrapper")
    var
        DictionaryContentHeaders: Codeunit "Dictionary Wrapper";
    begin
        SendRequest(contentToSend, RequestMethod, requestUri, ContentType, 0, ResponseValue, DictionaryContentHeaders, DictionaryDefaultHeaders);
    end;

    procedure SendRequest(contentToSend: Variant; RequestMethod: enum "Http Request Type"; requestUri: Text; ContentType: Text; HttpTimeout: integer; var ResponseValue: Codeunit "Temp Blob"; DictionaryContentHeaders: Codeunit "Dictionary Wrapper"; DictionaryDefaultHeaders: Codeunit "Dictionary Wrapper")
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        ContentHeaders: HttpHeaders;
        Content: HttpContent;
        ErrorBodyContent: Text;
        TextContent: Text;
        InStreamContent: InStream;
        InStreamRepsonse: InStream;
        OutStreamResponse: OutStream;
        i: Integer;
        KeyVariant: Variant;
        ValueVariant: Variant;
        HasContent: Boolean;
    begin
        case true of
            contentToSend.IsText():
                begin
                    TextContent := contentToSend;
                    if TextContent <> '' then begin
                        Content.WriteFrom(TextContent);
                        HasContent := true;
                    end;
                end;
            contentToSend.IsInStream():
                begin
                    InStreamContent := contentToSend;
                    Content.WriteFrom(InStreamContent);
                    HasContent := true;
                end;
            else
                Error(UnsupportedContentToSendErr);
        end;

        if HasContent then
            Request.Content := Content;

        if ContentType <> '' then begin
            ContentHeaders.Clear();
            Request.Content.GetHeaders(ContentHeaders);
            if ContentHeaders.Contains(ContentTypeKeyLbl) then
                ContentHeaders.Remove(ContentTypeKeyLbl);

            ContentHeaders.Add(ContentTypeKeyLbl, ContentType);
        end;

        for i := 0 to DictionaryContentHeaders.Count() do
            if DictionaryContentHeaders.TryGetKeyValue(i, KeyVariant, ValueVariant) then
                ContentHeaders.Add(Format(KeyVariant), Format(ValueVariant));

        Request.SetRequestUri(requestUri);
        Request.Method := Format(RequestMethod);

        for i := 0 to DictionaryDefaultHeaders.Count() do
            if DictionaryDefaultHeaders.TryGetKeyValue(i, KeyVariant, ValueVariant) then
                Client.DefaultRequestHeaders.Add(Format(KeyVariant), Format(ValueVariant));

        if HttpTimeout <> 0 then
            Client.Timeout(HttpTimeout);

        Client.Send(Request, Response);

        ResponseValue.CreateInStream(InStreamRepsonse);
        ResponseValue.CreateOutStream(OutStreamResponse);

        Response.Content().ReadAs(InStreamRepsonse);
        if not Response.IsSuccessStatusCode() then begin
            Response.Content().ReadAs(ErrorBodyContent);
            Error(RequestErr, Response.HttpStatusCode(), ErrorBodyContent);
        end;

        CopyStream(OutStreamResponse, InStreamRepsonse); //Save data to TempBlob
    end;

    var
        RequestErr: Label 'Request failed with HTTP Code:: %1 Request Body:: %2', Comment = '%1 = HttpCode, %2 = RequestBody';
        UnsupportedContentToSendErr: Label 'Unsuportted content to sned.';
        ContentTypeKeyLbl: Label 'Content-Type', Locked = true;
}