Class RestProduction.Exception Extends %Exception.AbstractException
{

Property HTTPStatusCode As %String;

Property HTTPMessage As %String;

ClassMethod CreateException(pHTTPStatusCode As %String = "500", pHTTPMessage As %String = "") As RestProduction.Exception
{
    Set ex = ..%New()
    Set ex.HTTPStatusCode = pHTTPStatusCode
    Set ex.HTTPMessage = pHTTPMessage
    Set ex.Code = 5001
    Set ex.Name = pHTTPStatusCode_" "_pHTTPMessage
    Return ex
}

}
