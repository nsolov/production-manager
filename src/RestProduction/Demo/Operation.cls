Class RestProduction.Demo.Operation Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.File.OutboundAdapter";

Property Adapter As EnsLib.File.OutboundAdapter;

Property FileName As %String [ InitialExpression = "out.txt" ];

Parameter SETTINGS = "FileName:MySettings";

Method WriteToFile(pRequest As RestProduction.Demo.Message, Output pResponse As Ens.Response) As %Status
{
    Set tSC = $$$OK
    Set tSC = ..Adapter.PutLine(..FileName, pRequest.AsString())
    Return tSC
}

XData MessageMap
{
<MapItems>
  <MapItem MessageType="RestProduction.Demo.Message">
    <Method>WriteToFile</Method>
  </MapItem>
</MapItems>
}

}
