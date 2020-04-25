Class RestProduction.Demo.Message Extends Ens.Request
{

Property currency As %String;

Property amount As %Decimal(SCALE = 4);

Property rate As %Decimal(SCALE = 4);

Property result As %Decimal(SCALE = 4);

Property ts As %String;

Method AsString() As %String
{
    Return ..ts_": "_..amount_" "_..currency_" = "_..result_" USD"
}

Storage Default
{
<Data name="MessageDefaultData">
<Subscript>"Message"</Subscript>
<Value name="1">
<Value>currency</Value>
</Value>
<Value name="2">
<Value>amount</Value>
</Value>
<Value name="3">
<Value>rate</Value>
</Value>
<Value name="4">
<Value>result</Value>
</Value>
<Value name="5">
<Value>ts</Value>
</Value>
</Data>
<DefaultData>MessageDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
