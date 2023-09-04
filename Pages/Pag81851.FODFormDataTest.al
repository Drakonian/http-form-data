page 81851 "FOD Form Data Test"
{
    ApplicationArea = All;
    Caption = 'Form Data Test';
    PageType = Card;
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(Result; Result)
                {
                    ApplicationArea = All;
                    Caption = 'Response:';
                    ToolTip = 'Response';
                    MultiLine = true;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(TextFormData)
            {
                ApplicationArea = All;
                Caption = 'Text multipart data';
                ToolTip = 'Text multipart data';
                Image = SendTo;
                trigger OnAction()
                var
                    FormDataExample: Codeunit "FOD Form Data Example";
                begin
                    Result := FormDataExample.CallTextFormDataRequest();
                    Message(Result);
                end;
            }
            action(BinaryFormData)
            {
                ApplicationArea = All;
                Caption = 'Binary multipart data';
                ToolTip = 'Binary multipart data';
                Image = SendTo;
                trigger OnAction()
                var
                    FormDataExample: Codeunit "FOD Form Data Example";
                begin
                    Result := FormDataExample.CallBinaryFormDataRequest();
                    Message(Result);
                end;
            }
        }
    }
    var
        Result: Text;
}
