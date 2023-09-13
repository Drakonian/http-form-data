codeunit 81852 "FOD Form Data Example"
{
    procedure CallTextFormDataRequest() Result: Text
    var
        APIMgt: Codeunit "FOD API Mgt";
        ResponseData: Codeunit "Temp Blob";
        FormData: TextBuilder;
        Boundary: Text;
        TextBuffer: Text;
    begin
        Boundary := Format(CreateGuid(), 0, 3);

        FormData.AppendLine(StrSubstNo('--%1', Boundary));
        FormData.AppendLine('Content-Disposition: form-data; name=foo1;');
        FormData.AppendLine('Content-Type: text/plain');
        FormData.AppendLine('');
        FormData.AppendLine('bar1');

        FormData.AppendLine(StrSubstNo('--%1', Boundary));
        FormData.AppendLine('Content-Disposition: form-data; name=foo2;');
        FormData.AppendLine('Content-Type: text/plain');
        FormData.AppendLine('');
        FormData.AppendLine('bar2');

        FormData.AppendLine(StrSubstNo('--%1--', Boundary));
        FormData.AppendLine('');

        APIMgt.SendRequest(FormData.ToText(), Enum::"Http Request Type"::POST, 'https://postman-echo.com/post', StrSubstNo('multipart/form-data; boundary=%1', Boundary), ResponseData);

        ResponseData.CreateInStream(FileInStream, TextEncoding::UTF8);

        while not FileInStream.EOS() do begin
            FileInStream.Read(TextBuffer);
            Result += TextBuffer;
        end;
    end;

    procedure CallBinaryFormDataRequest() Result: Text
    var
        APIMgt: Codeunit "FOD API Mgt";
        Base64Convert: Codeunit "Base64 Convert";
        ResponseData: Codeunit "Temp Blob";
        FileInStream: InStream;
        FormData: TextBuilder;
        TextBuffer: Text;
        Boundary: Text;
        DummyPdf: Text;
    begin
        APIMgt.SendRequest(Enum::"Http Request Type"::GET, 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf', ResponseData);
        ResponseData.CreateInStream(FileInStream);

        DummyPdf := Base64Convert.ToBase64(FileInStream);

        Boundary := Format(CreateGuid(), 0, 3);

        FormData.AppendLine(StrSubstNo('--%1', Boundary));
        FormData.AppendLine('Content-Disposition: form-data; name=foo1;');
        FormData.AppendLine('Content-Type: text/plain');
        FormData.AppendLine('');
        FormData.AppendLine('bar1');

        FormData.AppendLine(StrSubstNo('--%1', Boundary));
        FormData.AppendLine('Content-Disposition: form-data; name=pdf;');
        FormData.AppendLine('Content-Type: application/pdf');
        FormData.AppendLine('');
        FormData.AppendLine(DummyPdf);

        FormData.AppendLine(StrSubstNo('--%1--', Boundary));
        FormData.AppendLine('');

        Clear(ResponseData);
        APIMgt.SendRequest(FormData.ToText(), Enum::"Http Request Type"::POST, 'https://postman-echo.com/post', StrSubstNo('multipart/form-data; boundary=%1', Boundary), ResponseData);

        ResponseData.CreateInStream(FileInStream, TextEncoding::UTF8);
        FileInStream.ResetPosition();
        while not FileInStream.EOS() do begin
            FileInStream.Read(TextBuffer);
            Result += TextBuffer;
        end;
    end;

}
