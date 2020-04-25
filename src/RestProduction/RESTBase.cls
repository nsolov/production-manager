Class RestProduction.RESTBase Extends %CSP.REST [ System = 3 ]
{

Parameter CHARSET = "utf-8";

Parameter CONTENTTYPE = "application/json";

Parameter HandleCorsRequest = 1;

Parameter PAGESIZE As INTEGER = 20;

ClassMethod OnPreDispatch(pUrl As %String, pMethod As %String, ByRef pContinue As %Boolean) As %Status
{
    Set tSC = $$$OK
    Try {
        // Set the return type according to the Accept type in the request. Default is application/json.
        If ('..AcceptsContentType(..#CONTENTTYPEJSON)) {
            Set tSC = ..ReportHttpStatusCode(..#HTTP406NOTACCEPTABLE), pContinue=0
            Quit 
        } Else {   
            // This always returns json
            Set %response.ContentType=..#CONTENTTYPEJSON
        }
        // read request object into %DynamicObject format
        If ((pMethod'="POST") && (pMethod'="PUT")) || (%request.Content="") {
            Set %request.Content = {}
        } Else {
            If '$isobject(%request.Content) {
                Set tContent = %request.Content
            } Else {
                Set tContent = ""
                While '%request.Content.AtEnd {
                    Set tContent = tContent_%request.Content.Read()
                }
            }
            If (tContent="") {
                Set %request.Content = {}
            } Else {
                Set tContent = $zconvert(tContent, "I", "UTF8")
                Set %request.Content = ##class(%Library.DynamicObject).%FromJSON(tContent)
            }
        }
    } Catch ex {
        Set tSC = ex.AsStatus()
    }
    Return ##class(%iKnow.REST.Base).%ErrorHandler(tSC, .pContinue)
}

ClassMethod %ProcessResult(pStatus As %Status = {$$$OK}, pResult As %DynamicObject = "") As %Status [ Internal ]
{
  #dim %response As %CSP.Response
  SET tSC = $$$OK
  IF $$$ISERR(pStatus) {
    SET %response.Status = 500
    SET tSC = ..StatusToJSON(pStatus, .tJSON)
    IF $isobject(tJSON) {
      SET pResult = tJSON
    } ELSE {
      SET pResult = { "errors": [ { "error": "Unknown error parsing status code" } ] }
    }
  } 
  ELSEIF pStatus=1 {
    IF '$isobject(pResult){
      SET pResult = {
      }
    }
  }
  ELSE {
    SET %response.Status = pStatus
    SET error = $PIECE(pStatus, " ", 2, *)
    SET pResult = {
      "error": (error)
    }
  }
  
  IF pResult.%Extends("%Library.DynamicAbstractObject") {
    WRITE pResult.%ToJSON()
  }
  ELSEIF pResult.%Extends("%JSON.Adaptor") {
    DO pResult.%JSONExport()
  }
  ELSEIF pResult.%Extends("%Stream.Object") {
    DO pResult.OutputToDevice()
  }
  
  QUIT tSC
}

ClassMethod ProcessException(ex As %Exception.AbstractException) As %Status [ Private ]
{
    Set jResult = {}
    If (ex.%ClassName(1) = "RestProduction.Exception") {
        Set %response.Status = ex.HTTPStatusCode
        if (ex.HTTPStatusCode>=400) { 
            Set type = "error"
        } else {
            Set type = "ok"
        }
        Set jResult = {"type":(type), "message":(ex.HTTPMessage)}
    } Else {
        Set %response.Status = ..#HTTP500INTERNALSERVERERROR
        Set jResult = {"type":"error", "message":(ex.DisplayString())}
    }

    Write jResult.%ToJSON()

    Return $$$OK
}

ClassMethod ReportHttpStatusCode(pHttpStatus, pSC As %Status = {$$$OK}) As %Status
{
    Set %response.Status=pHttpStatus
    If $$$ISERR(pSC) {
        Set ex = ##class(%Exception.StatusException).CreateFromStatus(pSC)
        Return ..ProcessException(ex)
    }
    Return $$$OK
}

ClassMethod SwaggerSpec() As %Status
{
  Set tSC = ##class(%REST.API).GetWebRESTApplication($NAMESPACE, %request.Application, .swagger)
  Do swagger.info.%Remove("x-ISC_Namespace")
  Set swagger.basePath = "/production"
  Set swagger.info.title = "REST Production Manager"
  Set swagger.info.version = "0.1"
  Set swagger.host = "localhost:9098"
  Return ..%ProcessResult($$$OK, swagger)
}

}
