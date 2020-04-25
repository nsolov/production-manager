Class RestProduction.REST Extends RestProduction.RESTBase
{

Parameter CHARSET = "utf-8";

Parameter CONTENTTYPE = "application/json";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
    <!--Start Production ++ -->
    <Route Url="/start/:production" Method="GET" Call="Start"/>

    <!--Start Production ++ -->
    <Route Url="/stop/:production" Method="GET" Call="Stop"/>

    <!--Get Production Status ++ -->
    <Route Url="/status/:production" Method="GET" Call="Status"/>

    <!--Get Production Summary ++ -->
    <Route Url="/summary/:production" Method="GET" Call="Summary"/>

    <!--Get List of all productions in current namespace and their statuses ++ -->
    <Route Url="/production" Method="GET" Call="ProductionList"/>

    <!--Get Production Settings and production Items -->
    <Route Url="/production/:production" Method="GET" Call="GetProductionSettings"/>

    <!--Create new Production-->
    <Route Url="/production/:production" Method="POST" Call="AddProduction"/>

    <!--Update Production Settings-->
    <Route Url="/production/:production" Method="PUT" Call="UpdateProductionSettings"/>

    <!--Get Item Settings-->
    <Route Url="/item/:production/:item" Method="GET" Call="GetItemSettings"/>

    <!--Add Item to the Production-->
    <Route Url="/item/:production/:item" Method="POST" Call="AddItem"/>
    
    <!--Update Item Settings-->
    <Route Url="/item/:production/:item" Method="PUT" Call="UpdateItemSettings"/>

    <!--Delete Item -->
    <Route Url="/item/:production/:item" Method="DELETE" Call="DeleteItem"/>


    <Route Url="/_ping" Method="GET" Call="Ping" />
    <!--Get Swagger Specifiacation-->
    <Route Url="/_spec" Method="GET" Call="SwaggerSpec" />
</Routes>
}

ClassMethod Ping() As %Status
{
    Write {"result":"pong"}.%ToJSON()
    Return $$$OK
}

ClassMethod Stop(pProductionName As %String) As %Status
{
    Set jResult = {}
    Try {
        Set jResult = ##class(RestProduction.Manager).ProductionStop(pProductionName)
        Write jResult.%ToJSON()
    } Catch ex {
        Return ..ProcessException(ex)
    }
    Return $$$OK
}

ClassMethod Start(pProductionName As %String) As %Status
{
    Set jResult = {}
    Try {
        Set jResult = ##class(RestProduction.Manager).ProductionStart(pProductionName)
        Write jResult.%ToJSON()
    } Catch ex {
        Return ..ProcessException(ex)
    }
    Return $$$OK
}

ClassMethod Status(pProductionName As %String) As %Status
{
    Set jResult = {}
    Try {
        Set jResult = ##class(RestProduction.Manager).ProductionStatus(pProductionName)
        Write jResult.%ToJSON()
    } Catch ex {
        Return ..ProcessException(ex)
    }
    Return $$$OK
}

ClassMethod Summary(pProductionName As %String) As %Status
{
    Set jResult = {}
    Try {
        Set jResult = ##class(RestProduction.Manager).GetProductionSummary(pProductionName)
        Write jResult.%ToJSON()
    } Catch ex {
        Return ..ProcessException(ex)
    }
    Return $$$OK
}

ClassMethod ProductionList() As %Status
{
    Set jResult = {}
    Try {
        Set jResult.productions = ##class(RestProduction.Manager).GetProductionList()
        Write jResult.%ToJSON()
    } Catch ex {
        Return ..ProcessException(ex)
    }
    Return $$$OK
}

ClassMethod AddProduction(pProductionName As %String) As %Status
{
    Set jResult = {}
    Try {
        Set jResult = ##class(RestProduction.Manager).AddProduction(pProductionName, %request.Content)
        Write jResult.%ToJSON()
    } Catch ex {
        Return ..ProcessException(ex)
    }
    Return $$$OK
}

ClassMethod UpdateProductionSettings(pProductionName As %String) As %Status
{
    Set jResult = {}
    Try {
        Set jResult = ##class(RestProduction.Manager).UpdateProductionSettings(pProductionName, %request.Content)
        Write jResult.%ToJSON()
    } Catch ex {
        do ex.Log()
        Return ..ProcessException(ex)
    }
    Return $$$OK
}

ClassMethod GetProductionSettings(pProductionName As %String) As %Status
{
    Set jResult = {}
    Try {
        Set jResult = ##class(RestProduction.Manager).GetProductionSettings(pProductionName)
        Write jResult.%ToJSON()
    } Catch ex {
        Return ..ProcessException(ex)
    }
    Return $$$OK
}

ClassMethod GetItemSettings(pProductionName As %String, pItemName As %String) As %Status
{
    Set jResult = {}
    Try {
        Set jResult = ##class(RestProduction.Manager).GetItemSettings(pProductionName, pItemName)
        Write jResult.%ToJSON()
    } Catch ex {
        Return ..ProcessException(ex)
    }
    Return $$$OK
}

ClassMethod AddItem(pProductionName As %String, pItemName As %String) As %Status
{
    Set jResult = {}
    Try {
        Set jResult = ##class(RestProduction.Manager).AddItem(pProductionName, pItemName, %request.Content)
        Write jResult.%ToJSON()
    } Catch ex {
        Return ..ProcessException(ex)
    }
    Return $$$OK
}

ClassMethod UpdateItemSettings(pProductionName As %String, pItemName As %String) As %Status
{
    Set jResult = {}
    Try {
        Set jResult = ##class(RestProduction.Manager).UpdateItemSettings(pProductionName, pItemName, %request.Content)
        Write jResult.%ToJSON()
    } Catch ex {
        Return ..ProcessException(ex)
    }
    Return $$$OK
}

ClassMethod DeleteItem(pProductionName As %String, pItemName As %String) As %Status
{
    Set jResult = {}
    Try {
        Set jResult = ##class(RestProduction.Manager).DeleteItem(pProductionName, pItemName)
        Write jResult.%ToJSON()
    } Catch ex {
        Return ..ProcessException(ex)
    }
    Return $$$OK
}

}
