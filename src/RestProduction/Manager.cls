Include Ensemble

Class RestProduction.Manager
{

Parameter ItemProperties = "Enabled:enabled,PoolSize:pool_size,Comment:comment,Schedule:schedule,Category:category,AlertGroups:alert_groups,DisableErrorTraps:disable_error_traps,Foreground:foreground,InactivityTimeout:inactivity_timeout,LogTraceEvents:log_trace_events";

Parameter ProductionProperties = "ActorPoolSize:actor_pool_size,Description:description,LogGeneralTraceEvents:log_general_trace_events,TestingEnabled:testing_enabled";

ClassMethod ProductionStatus(pProductionName As %String = "") As %Library.DynamicObject
{
    Set jResult = {}
    If '##class(Ens.Config.Production).%ExistsId(pProductionName) {
        Throw ##class(RestProduction.Exception).CreateException("404", "Production not found: "_pProductionName)
	}
    Set jResult.name = pProductionName
    Set stmt = ##class(%SQL.Statement).%New()
    $$$ThrowOnError(stmt.%PrepareClassQuery("Ens.Config.Production","ProductionStatus"))
    Set rset = stmt.%Execute()
    While rset.%Next() {
        If (rset.%Get("Production")=pProductionName) {
            Set jResult.status = rset.%Get("Status")
            Quit 
        }
    }

    Set key = ""
    For {
        Set key = $Order(^IRIS.Temp.productionmanager(pProductionName,key))  
        Quit:key=""
        Set jo = {
            "job":($Get(^IRIS.Temp.productionmanager(pProductionName,key,"job"))),
            "ts-start":($Get(^IRIS.Temp.productionmanager(pProductionName,key,"ts-start"))),
            "ts-stop":($Get(^IRIS.Temp.productionmanager(pProductionName,key,"ts-stop"))),
            "status":($Get(^IRIS.Temp.productionmanager(pProductionName,key,"status")))
        }
        Do jResult.%Set(key,jo)
    }

    /*$$$ThrowOnError(##class(Ens.Director).GetProductionStatus(.tProductionName, .status))
    Set jResult."production_name" = pProductionName
    If (pProductionName'=tProductionName) {
        Set jResult."status" = "Stopped"
    } Else {
        Set jResult."status" = ##class(Ens.Config.Production).ProductionStateToText(status)
    }*/
    Return jResult
}

ClassMethod ProductionStop(pProductionName As %String = "", pTimeout As %Numeric = 10, pForce As %Boolean = 0) As %Library.DynamicObject
{
    If '##class(Ens.Config.Production).%ExistsId(pProductionName) {
        Throw ##class(RestProduction.Exception).CreateException("404", "Production not found: "_pProductionName)
	}
    $$$ThrowOnError(##class(Ens.Director).GetProductionStatus(.tProductionName))
    If (tProductionName '= pProductionName) {
        Throw ##class(RestProduction.Exception).CreateException("400", "Production is not running: "_pProductionName)
    }

    Job ##class(RestProduction.Utils).Run(pProductionName,"Ens.Director", "StopProduction", pTimeout,pForce)
    Set pid = $ZCHILD

    Throw ##class(RestProduction.Exception).CreateException("202", "Production "_pProductionName_" is stopping in job:"_pid)
    Return {}
}

ClassMethod ProductionStart(pProductionName As %String = "") As %Library.DynamicObject
{
    If '##class(Ens.Config.Production).%ExistsId(pProductionName) {
        Throw ##class(RestProduction.Exception).CreateException("404", "Production not found: "_pProductionName)
	}
    $$$ThrowOnError(##class(Ens.Director).GetProductionStatus(.tProductionName))
    If (tProductionName = pProductionName) {
        Throw ##class(RestProduction.Exception).CreateException("400", "Production is already running: "_pProductionName)
    }    

    Job ##class(RestProduction.Utils).Run(pProductionName,"Ens.Director", "StartProduction", pProductionName)
    Set pid = $ZCHILD
    Throw ##class(RestProduction.Exception).CreateException("202", "Production "_pProductionName_" is starting in job "_pid)
    Return {}
}

ClassMethod AddProduction(pProductionName As %String, data As %Library.DynamicObject) As %Library.DynamicObject
{
    If (pProductionName="") {
        $$$ThrowStatus($$$ERROR($$$GeneralError, "ProductionName required"))
    }    
    Set class = ##class(%Dictionary.ClassDefinition).%New(pProductionName)
    Set class.ProcedureBlock = 1
    Set class.Super = "Ens.Production"
    Set class.GeneratedBy = $ClassName()
    Set xdata = ##class(%Dictionary.XDataDefinition).%New()
    Set xdata.Name = "ProductionDefinition"
    Do xdata.Data.Write("<Production Name="""_pProductionName_"""></Production>")  
    Do class.XDatas.Insert(xdata)
    $$$ThrowOnError(class.%Save())
    $$$ThrowOnError($system.OBJ.Compile(pProductionName,"-d"))
    Return ..UpdateProductionSettings(pProductionName, data)
}

ClassMethod DeleteItem(pProductionName As %String, pItemName As %String) As %Library.DynamicObject
{
    Set tProduction = ..GetProductionByName(pProductionName)
    Set tItem = tProduction.FindItemByConfigName(pItemName, .tSC, 1)
    If ('$IsObject(tItem)) {
        Throw ##class(RestProduction.Exception).CreateException("404", "Item not found: "_pItemName)
    }
    Do tProduction.RemoveItem(tItem)
    $$$ThrowOnError(tProduction.%Save())
    Do ..UpdateProductionIfNecessary()  
    Return ..GetProductionSettings(pProductionName, "Settings")
}

ClassMethod AddItem(pProductionName As %String, pItemName As %String, data As %Library.DynamicObject) As %Library.DynamicObject
{
    Set tProduction = ..GetProductionByName(pProductionName)
    If (pItemName = "") {
        $$$ThrowStatus($$$ERROR($$$GeneralError, "ItemName required"))
    }
    If (data."class_name" = "") {
        $$$ThrowStatus($$$ERROR($$$GeneralError, "Class name required"))
    }

    Set tItem = ##class(Ens.Config.Item).%New()
    Set tItem.Name = pItemName
    Set tItem.ClassName = data."class_name"
    Do tProduction.Items.Insert(tItem)
    //$$$ThrowOnError(tProduction.SaveToClass())
    $$$ThrowOnError(tProduction.%Save())

    Return ..UpdateItemSettings(pProductionName, pItemName, data)
}

ClassMethod UpdateItemSettings(pProductionName As %String, pItemName As %String, pSettings As %Library.DynamicObject) As %Status
{
    Set tProduction = ..GetProductionByName(pProductionName)
    Set tItem = tProduction.FindItemByConfigName(pItemName, .tSC, 1)
    If ('$IsObject(tItem)) {
        Throw ##class(RestProduction.Exception).CreateException("404", "Item not found: "_pItemName)
    }
    Do ..SetProperties(tItem, pSettings,..#ItemProperties)

    If (pSettings.%GetTypeOf("settings")="array") {
        Do ..WriteSettings(tItem, pSettings.settings)
    }
    //Do tItem.Production.SaveToClass()
    $$$ThrowOnError(tItem.%Save())
    Do ..UpdateProductionIfNecessary(pSettings.%Get("_timeout",10), pSettings.%Get("_force",0))  
    Return ..GetItemSettings(pProductionName, pItemName, "Settings")
}

ClassMethod SetProperties(pHost As %RegisteredObject, pSettings As %DynamicObject, pProperties As %String) As %Status
{
    Set props = $Listfromstring(pProperties,",")
    For i=1:1:$Listlength(props) {
        Set objProperty = $Piece($List(props,i),":",1)
        Set jsonProperty = $Piece($List(props,i),":",2)
        If ((objProperty="") || (jsonProperty="")) { Continue }
        If pSettings.%IsDefined(jsonProperty) {
            Set $PROPERTY(pHost, objProperty) = pSettings.%Get(jsonProperty)
        }
    }
    Return $$$OK
}

ClassMethod GetProductionByName(pProductionName As %String) As Ens.Config.Production [ Private ]
{
    If (pProductionName="") {
        $$$ThrowStatus($$$ERROR($$$GeneralError, "ProductionName required"))
    }
    Set tProduction = ##class(Ens.Config.Production).%OpenId(pProductionName,,.tSC)
    
	If ('$IsObject(tProduction)||$$$ISERR(tSC) ) {
        throw ##class(RestProduction.Exception).CreateException("404 Not Found","Production Not Found")
    }
    Return tProduction
}

ClassMethod UpdateProductionSettings(pProductionName As %String, pSettings As %Library.DynamicObject) As %Status
{
    Set tProduction = ..GetProductionByName(pProductionName)
    Do ..SetProperties(tProduction, pSettings,..#ProductionProperties)

    If (pSettings.%GetTypeOf("settings")="array") {
        Do ..WriteSettings(tProduction, pSettings.settings)
    }
    $$$ThrowOnError(tProduction.%Save())
    //$$$ThrowOnError(tProduction.SaveToClass())
    Do ..UpdateProductionIfNecessary(pProductionName, pSettings.%Get("_timeout",10), pSettings.%Get("_force",0))
    Return ..GetProductionSettings(pProductionName, "Settings")
}

ClassMethod UpdateProductionIfNecessary(pProductionName As %String, pTimeout As %Numeric = 10, pForce As %Boolean = 0) As %Status [ Private ]
{
    If (##class(Ens.Director).ProductionNeedsUpdate(.tNeedsUpdateReason,1)) {
        Job ##class(RestProduction.Utils).Run(pProductionName,"Ens.Director", "UpdateProduction", pTimeout,pForce)
        Set pid = $ZCHILD
        Throw ##class(RestProduction.Exception).CreateException("202", "Production "_pProductionName_" is updating in job "_pid)
    }
    return $$$OK
}

ClassMethod WriteSettings(pHost As %RegisteredObject, pSettings As %Library.DynamicArray) As %Status [ Private ]
{
    Set hostSettings = pHost.Settings
    For i=1:1:hostSettings.Count() {
        Set tOneSetting = hostSettings.GetAt(i)
        Set key = $Increment(tArray)
        Set tArray(key) = $Listbuild(tOneSetting.Target, tOneSetting.Name, tOneSetting.Value)
        Set rArray(tOneSetting.Target,tOneSetting.Name) = key
    }

    Do pHost.PopulateModifiedSettings() // to get all possible settings
    Set possibleSettings = pHost.ModifiedSettings
    
    For i=1:1:possibleSettings.Count() {
        Set tOneSetting = possibleSettings.GetAt(i)
        Set iter = pSettings.%GetIterator()
	    While iter.%GetNext(.key , .setting ) {
            If ( (setting.name = tOneSetting.Name) && (setting.target = tOneSetting.Target) ) {
                Set settingList = $Listbuild(tOneSetting.Target, tOneSetting.Name, setting.value)
                If ($Data(rArray(tOneSetting.Target,tOneSetting.Name))) {
                    Set tArray(rArray(tOneSetting.Target,tOneSetting.Name)) = settingList
                } else {
                    Set key = $Increment(tArray)
                    Set tArray(key) = settingList
                }
                Quit  
            }
	    } 
    }
    $$$ThrowOnError(pHost.UpdateSettings(.tArray))
    Return $$$OK
}

ClassMethod ReadSettings(pHost As %RegisteredObject, pSettingsType) As %Library.DynamicArray [ Private ]
{
    Set result = []
    
    If (pSettingsType = "ModifiedSettings") {
        Do pHost.PopulateModifiedSettings() 
        Set settings = pHost.ModifiedSettings
    } Else {
        Set settings = pHost.Settings
    }
    For i=1:1:settings.Count() {
        Set jSetting = {"name":(settings.GetAt(i).Name), "target":(settings.GetAt(i).Target), "value":(settings.GetAt(i).Value)}
        Do result.%Push(jSetting) 
    }
    Return result
}

ClassMethod GetProductionList() As %Library.DynamicArray
{
    Set result = []
    Set stmt = ##class(%SQL.Statement).%New()
    $$$ThrowOnError(stmt.%PrepareClassQuery("Ens.Config.Production","ProductionStatus"))
    Set rset = stmt.%Execute()
    While rset.%Next() {
        Set po = {}
        Set po."production_name" = rset.%Get("Production")
        Set po."status" = rset.%Get("Status")
        Set po."last_start_datetime" = $p(rset.%Get("LastStartTime"),".")
        Set po."last_stop_datetime" = $p(rset.%Get("LastStopTime"),".")
        Do result.%Push(po)
    }
    return result
}

/// Returns json object with:
///  - Item Name, type
///  - Item Settings
ClassMethod GetItemSettings(pProductionName As %String = "", pItemName As %Integer = "", pSettingsType As %String = "ModifiedSettings") As %Library.DynamicObject
{
    Set tProduction = ..GetProductionByName(pProductionName)

    Set tItem = tProduction.FindItemByConfigName(pItemName, .tSC, 1)
    If ('$IsObject(tItem)) {
        throw ##class(RestProduction.Exception).CreateException("404 Not Found","Item Not Found: "_pItemName)
    }
	If ($$$ISERR(tSC)) { $$$ThrowStatus(tSC) }
    Set result = {}
    Set result.name = tItem.Name
    Set result.type = ..GetBusinessHostTypeString(tItem.BusinessType())
    Set result.enabled = tItem.Enabled
    Set result."pool_size" = tItem.PoolSize
    Set result."class_name" = tItem.ClassName

    Set result.comment = tItem.Comment
    Set result.schedule = tItem.Schedule
    Set result.category = tItem.Category

    Set result."alert_groups" = tItem.AlertGroups
    Set result."disable_error_traps" = tItem.DisableErrorTraps
    Set result."foreground" = tItem.Foreground
    Set result."inactivity_timeout" = tItem.InactivityTimeout
    Set result."log_trace_events" = tItem.LogTraceEvents

    Set result.settings = ..ReadSettings(tItem, pSettingsType) 

    Return result
}

/// Returns json object with:
///  - Production Name and Description
///  - Production Settings
ClassMethod GetProductionSettings(pProductionName As %String = "", pSettingsType As %String = "ModifiedSettings") As %Status
{
    Set tProduction = ..GetProductionByName(pProductionName)
    Set result = {}
    Set result.name = tProduction.Name
    Set result.description = tProduction.Description
    Set result."actor_pool_size" = tProduction.ActorPoolSize
    Set result."log_general_trace_events" = tProduction.LogGeneralTraceEvents
    Set result."testing_enabled" = tProduction.TestingEnabled
    Set result.settings = ..ReadSettings(tProduction, pSettingsType) 
    Set result.items = []
    Set itemsCount = tProduction.Items.Count()
    For i=1:1:itemsCount {
        Set tItem = tProduction.Items.GetAt(i)
        Do result.items.%Push({"name":(tItem.Name)})
    }
    Return result
}

/// Returns json object with:
///  - Production Name and Description
///  - Production status
///  - Arrays of business hosts and their statuses
///  - Array of queues (for running production)
ClassMethod GetProductionSummary(pProductionName As %String = "") As %Library.DynamicObject
{
    Set tProduction = ..GetProductionByName(pProductionName)
    set result = {}
    Set stmt = ##class(%SQL.Statement).%New()
    $$$ThrowOnError(stmt.%PrepareClassQuery("Ens.Config.Production","ProductionStatus"))
    Set rset = stmt.%Execute()
    While rset.%Next() {
        If (rset.%Get("Production")=pProductionName) {
            Set result = {"production_name":(pProductionName), "status":(rset.%Get("Status")), "last_start_datetime":($p(rset.%Get("LastStartTime"),".")),"last_stop_datetime":($p(rset.%Get("LastStopTime"),"."))}
        }
    }

    Set tIsRunning = ($G($$$EnsRuntime("Name")) = pProductionName) // if production is runing

    Set tCount = tProduction.Items.Count()
    For iItem=1:1:tCount {
		Set tItem = tProduction.Items.GetAt(iItem)
        Set tBusinessType = ..GetBusinessHostTypeString(tItem.BusinessType())
        Set itemStatus = ..ItemStatus(tItem.Name, tIsRunning, tItem.Enabled, tItem.%Id())
        Set jItem = {"name":(tItem.Name), "enabled":(+tItem.Enabled), "status":(itemStatus)}
        If (tItem.Category'="") { Set jItem.category = tItem.Category}
        If 'result.%IsDefined(tBusinessType) { Do result.%Set(tBusinessType,[])}
        Do result.%Get(tBusinessType).%Push(jItem)
    }
    If tIsRunning {
        Set result.queues = ..GetQueuesInfo()
        Set result."suspended_messages_count" = ..GetSuspendedCount()
    }
    Return result
}

/// Returns the total amount of suspended messages
ClassMethod GetSuspendedCount() As %Integer
{
    Set tSusCount = 0
    &sql(SELECT COUNT(*) INTO :tSusCount From Ens.MessageHeader WHERE Status = 5)
    Return tSusCount
}

ClassMethod GetBusinessHostTypeString(type As %Integer) As %String [ Private ]
{
    Set BusinessTypes(1) = "BusinessService"
    Set BusinessTypes(2) = "BusinessProcess"
    Set BusinessTypes(3) = "BusinessOperation"
    Return $Get(BusinessTypes(type),"unknown")
}

ClassMethod ItemStatus(pName As %String, pIsRunning As %Boolean = 0, pEnabled As %String, pID As %String) As %String [ Private ]
{
	If pEnabled="" {
		// used by the status refresh logic
		Set tItem = ##class(Ens.Config.Item).%OpenId(pID,,.tSC)
		Quit:$$$ISERR(tSC) "NOTFOUND"
		If $IsObject(tItem) Set pEnabled = tItem.Enabled
	}
	If 'pIsRunning {
		Set tStatus= $select('pEnabled: "disabled", 1: "stopped")
		Set tIOStatus=tStatus
	} Else {
		Set tConfigId=$G($$$DispatchNameToConfigName(pName))
		If ""=tConfigId {
			Set tStatus="N/A"
			Set tIOStatus="N/A"
		} Else {
			Set tStatus = $ZCVT($$$GetHostMonitor(pName,$$$eMonitorStatus),"L") If tStatus="" Set tStatus="error"
			If 'pEnabled {
				If ((tStatus="ok")||(tStatus="inactive")) {
					Set tStatus = "disabled"
				}
			} Else {
				#; look to see if stopped - either because of schedule or temporary stop api
				If ($$$OrderHostMonitor(pName,$$$eMonitorJob,"") = "") && ($$$ConfigPoolSize(pName)>0) {
					#;InProc items might be configured with pool size which is ignored.
					Try {
						If $parameter($$$ConfigClassName(pName),"INVOCATION")="Queue" Set tStatus = "stopped"
					} Catch {}
				}
			}
		}
	}
	Set str = tStatus
    return str
}

ClassMethod GetQueuesInfo() As %Library.DynamicArray
{
    Set result = []
	Set stmt = ##class(%SQL.Statement).%New()
    $$$ThrowOnError(stmt.%PrepareClassQuery("Ens.Queue","Enumerate"))
	Set rset = stmt.%Execute()
    While rset.%Next() {
        Set jQueue = {}
        Set jQueue.name = rset.%Get("Name")
        Set jQueue.count = rset.%Get("Count")
        Do result.%Push(jQueue)
    }
	Return result
}

}
