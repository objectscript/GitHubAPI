Class GitHub.Utils
{

/// Do ##class(GitHub.Utils).Test(10)
ClassMethod Test(Count As %Integer(MINVAL=1) = 10)
{
	Set token = $Get(^GHAPI("token"))
	Set owner = "intersystems-ru"
	Set repository = "highlight.js"
		
	Set obj = ##class(GitHub.API).%New(token)
	Set start = $Now()
	For i=1:1:Count {
		Do obj.GetLastCommit(owner, repository,,.commit)
	}
	Set end = $Now()
	Set time = $Piece(end,",",*) - $Piece(start,",",*)
	Set timeAvg = time/Count
	W "Avg time: ",timeAvg
}

/// Выполнить команду ОС
ClassMethod execute(cmd, debug As %Boolean = {$$$NO}) As %Status
{
	#dim sc As %Status = $$$OK
	set code = ""
	
	write:debug !, "cmd: ", cmd
	
	set code = $zf(-1, cmd)
	write:debug !,"code: ", code
	
	if code'=0 {
		set sc1 = $$$ERROR($$$GeneralError, $$$FormatText("Комманда ОС: `%1` завершилась с кодом: `%2`", cmd, code))
		set sc = $$$ADDSC(sc, sc1)	
	}
	return sc
}

}

