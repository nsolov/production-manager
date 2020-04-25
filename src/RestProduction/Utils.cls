Class RestProduction.Utils
{

/// helper method to run class methods in a background
ClassMethod Run(pProductionName As %String, pClass As %String, pMethod As %String, args...) As %Status
{
    Kill ^IRIS.Temp.productionmanager(pProductionName,pMethod)
    Set ^IRIS.Temp.productionmanager(pProductionName,pMethod,"job") = $Job
    Set ^IRIS.Temp.productionmanager(pProductionName,pMethod,"ts-start") = $ZDatetime($Now(6),3)
    Set tSC = $ClassMethod(pClass,pMethod,args...)
    Set ^IRIS.Temp.productionmanager(pProductionName,pMethod,"ts-stop") = $ZDatetime($Now(6),3)
    If $$$ISOK(tSC) {
        Set ^IRIS.Temp.productionmanager(pProductionName,pMethod,"status") = 1
    } Else {
        Set ^IRIS.Temp.productionmanager(pProductionName,pMethod,"status") = $System.Status.GetErrorText(tSC)
    }
    Return $$$OK
}

}
