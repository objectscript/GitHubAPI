Class GitHub.API Extends %RegisteredObject
{

/// Name of a valid Cache SSL config. 
/// Created on object initialization automatically. 
Parameter SSLConfig = "GitHub";

/// GitHub API server address
Parameter Server = "api.github.com";

/// Default accept header for our requests
Parameter Accept = "application/vnd.github.v3+json";

Parameter Directory = "C:/temp/mirror/";

Property Request As %Net.HttpRequest [ Internal ];

Method %OnNew(Username As %String = "", Password As %String = "") As %Status [ Private, ServerOnly = 1 ]
{
	Quit ..CreateRequest(Username,Password)
}

/// This methd is called automatically on object creation.<br>
/// <var>Username</var> - GitHub user, who has access to repository. Optional for public repositories.<br>
/// <var>Password</var> - GitHub password, corresponding to Username. Optional for public repositories.<br>
/// Note, that with Username, you can make up to 5,000 requests per hour. 
/// For unauthenticated requests, the rate limit allows to make up to 60 requests per hour. 
/// Unauthenticated requests are associated with an IP address.<br>
Method CreateRequest(Username As %String, Password As %String) As %Status
{
	New $Namespace
 	Set SSLConfig = ..#SSLConfig
 	
 	Zn "%SYS"
 	Do:'##class(Security.SSLConfigs).Exists(SSLConfig) ##class(Security.SSLConfigs).Create(SSLConfig)

 	Set ..Request = ##class(%Net.HttpRequest).%New()
 	Set ..Request.Https = 1
	Set ..Request.SSLConfiguration = SSLConfig
	Set ..Request.Server=	..#Server					
	Do ..Request.SetHeader("Accept",..#Accept) 		// we want 3rd version of api	
	
	If ($d(Username) && $d(Password) && (Username'="") && (Password'="")) {	// supply Username and Passwor, if both are provided. GitHub accept Basic Auth
		Set ..Request.Username = Username									// https://developer.github.com/v3/auth/
	 	Set ..Request.Password = Password
	} 	

	Return $$$OK
}

/// Get list of names of all repositories in a organization.<br>
/// <var>Org</var> - name of Organization<br>
/// <var>Type</var> - select one type of repos to return (all - for eveything)<br>
/// <var>Repos</var> - list of repositories' names<br>
/// <var>Page</var> - internal, do not set
Method GetOrgReposNames(Org As %String, Type As %String(VALUELIST=",all,public,private,forks,sources,member") = "all", ByRef Repos As %ListOfDataTypes, Page As %Integer = 1) As %Status
{
	Set:(('$Data(Repos)) || ('$IsObject(Repos))) Repos = ##class(%ListOfDataTypes).%New()
	#dim obj As List of %ZEN.proxyObject

	Set ..Request.Location = "orgs/" _ Org _ "/repos" 
	Do ..Request.SetParam("page",Page) 
	Do ..Request.SetParam("type",Type) 
	Set st = ..Request.Get()

	Set st1 = ##class(%ZEN.Auxiliary.jsonProvider).%ConvertJSONToObject(..Request.HttpResponse.Data,,.obj,1)
	Set st = $$$ADDSC(st, st1)
	
	For i=1:1:obj.Count() {
		Set repo = obj.GetAt(i)
		Do Repos.Insert(repo.name)
		/// Write repo.name,"  ",repo.url,!
		/// see structure of repo object at:
		/// https://developer.github.com/v3/repos/#list-organization-repositories
	}
	
	If obj.Count()'=0 {
		/// next page exists
		Set Page = Page + 1
		Set st1 = ..GetOrgReposNames(Org, Type, .Repos, Page)
		Set st = $$$ADDSC(st, st1)
	}
	Return st
}

/// Get list of all repositories in a organization. Use GetOrgReposNames method if you only need names<br>
/// <var>Org</var> - name of Organization<br>
/// <var>Type</var> - select one type of repos to return (all - for eveything)<br>
/// <var>Repos</var> - list of repositories' names<br>
/// <var>Page</var> - internal, do not set
Method GetOrgRepos(Org As %String, Type As %String(VALUELIST=",all,public,private,forks,sources,member") = "all", ByRef Repos As %ListOfObjects, Page As %Integer = 1) As %Status
{
	Set:(('$Data(Repos)) || ('$IsObject(Repos))) Repos = ##class(%ListOfObjects).%New()
	#dim obj As List of %ZEN.proxyObject

	Set ..Request.Location = "orgs/" _ Org _ "/repos" 
	Do ..Request.SetParam("page",Page) 
	Do ..Request.SetParam("type",Type) 
	Set st = ..Request.Get()

	Set st1 = ##class(%ZEN.Auxiliary.jsonProvider).%ConvertJSONToObject(..Request.HttpResponse.Data,,.obj,1)
	Set st = $$$ADDSC(st, st1)
	
	For i=1:1:obj.Count() {
		Set repo = obj.GetAt(i)
		Do Repos.Insert(repo)
		/// Write repo.name,"  ",repo.url,!
		/// see structure of repo object at:
		/// https://developer.github.com/v3/repos/#list-organization-repositories
	}
	
	If obj.Count()'=0 {
		/// next page exists
		Set Page = Page + 1
		Set st1 = ..GetOrgRepos(Org, Type, .Repos, Page)
		Set st = $$$ADDSC(st, st1)
	}
	Return st
}

/// Get list of names of all repositories in a organization.<br>
/// <var>TeamId</var> - Id (not Name) of a team<br>
/// <var>Type</var> - select one type of repos to return (all - for eveything)<br>
/// <var>Repos</var> - list of repositories' names<br>
/// <var>Page</var> - internal, do not set
Method GetTeamReposNames(TeamId As %String, Type As %String(VALUELIST=",all,public,private,forks,sources,member") = "all", ByRef Repos As %ListOfDataTypes, Page As %Integer = 1) As %Status
{
	Set:(('$Data(Repos)) || ('$IsObject(Repos))) Repos = ##class(%ListOfDataTypes).%New()
	#dim obj As List of %ZEN.proxyObject

	Set ..Request.Location = "teams/" _ TeamId _ "/repos" 
	Do ..Request.SetParam("page",Page) 
	Do ..Request.SetParam("type",Type) 
	Set st = ..Request.Get()

	Set st1 = ##class(%ZEN.Auxiliary.jsonProvider).%ConvertJSONToObject(..Request.HttpResponse.Data,,.obj,1)
	Set st = $$$ADDSC(st, st1)
	
	For i=1:1:obj.Count() {
		Set repo = obj.GetAt(i)
		Do Repos.Insert(repo.name)
		/// Write repo.name,"  ",repo.url,!
		/// see structure of repo object at:
		/// https://developer.github.com/v3/repos/#list-organization-repositories
	}
	
	If obj.Count()'=0 {
		/// next page exists
		Set Page = Page + 1
		Set st1 = ..GetTeamReposNames(TeamId, Type, .Repos, Page)
		Set st = $$$ADDSC(st, st1)
	}
	Return st
}

/// Add repository to team.<br>
/// <var>Org</var> - name of Organization<br>
/// <var>TeamId</var> - Id (not Name) of a team<br>
/// <var>Repo</var> - repository name (eg. Cache-MDX2JSON)<br>
/// <var>Permission</var> - access level. Currently <b>defaults to team default level</b><br>
Method AddRepoToTeam(Org As %String, TeamId As %Integer, Repo As %String, Permission As %String(VALUELIST=",pull,push,admin") = "pull") As %Status
{
	Set ..Request.Location = "teams/" _ TeamId _ "/repos/" _ Org _ "/" _ Repo 
	Do ..Request.SetHeader("Accept","application/vnd.github.ironman-preview+json") 
	//Do ..Request.SetHeader("Content-Length",0) 
	Do ..Request.SetParam("permission",Permission) 		
	Set st = ..Request.Put()
	Return st
}

/// Protect branch<br>
/// <var>Owner</var> - owner of repository<br>
/// <var>Repo</var> - repository name (eg. Cache-MDX2JSON)<br>
/// <var>Branch</var> - branch to protect<br>
/// <a href="https://help.github.com/articles/about-protected-branches/">About</a> protected branches
Method ProtectBranch(Owner As %String, Repo As %String, Branch As %String = "master") As %Status
{
	Set ..Request.Location = "repos/" _ Owner _ "/" _ Repo _ "/branches/" _ Branch 
	Do ..Request.RemoveHeader("Accept")
	Do ..Request.SetHeader("Accept"," application/vnd.github.loki-preview+json") // custom header as this functionality is currently in beta
	Do ..Request.EntityBody.Write("{""protection"": {""enabled"": true}") // to supply true value in pre 16.1 versions
	Set st = ..Request.Send("PATCH","")
	Do ..Request.RemoveHeader("Accept")
	Do ..Request.SetHeader("Accept",..#Accept) // back to main header
	Return st
}

Method GetLastCommit(Owner As %String, Repository As %String, Branch As %String = "master", Output Commit As %ZEN.proxyObject) As %Status
{
	kill Commit
	Set:(Branch="") Branch="HEAD" // Branch does not automatically elevates to master
	Set ..Request.Location = "repos/" _ Owner _ "/" _ Repository _ "/commits/" _ Branch 									
	
	Set st = ..Request.Get()
	Return:$$$ISERR(st) st
	Return:(..Request.HttpResponse.StatusCode = 404) $$$ERROR($$$GeneralError,"Repository doesn't exist OR you don't have access")
	Return:((..Request.HttpResponse.StatusCode = 403) && (..Request.HttpResponse.GetHeader("X-RATELIMIT-REMAINING")=0)) $$$ERROR($$$GeneralError,"API rate limit exceeded. Try logging in.")
 	Return:(..Request.HttpResponse.StatusCode '= 200) $$$ERROR($$$GeneralError,"Received " _ ..Request.HttpResponse.StatusCode _ " expected 200")

	Set st = ##class(%ZEN.Auxiliary.jsonProvider).%ConvertJSONToObject(..Request.HttpResponse.Data,,.Commit,1)
	Return st
}

Method MirrorAll(Directory As %String = {..#Directory}) As %Status
{

	#Dim conf As %DynamicObject 
	#Dim repos As %DynamicArray
	#Dim mirrors As %DynamicArray
	#Dim st As %Status
	
	Set stream = ##class(%Stream.FileCharacter).%New()
	Set st = stream.LinkToFile(Directory_"repos.json")
	Set conf = {}.%FromJSON(stream.Read($$$MaxCacheInt))
	
	set mirrors = conf.mirrors
	
	for i=0:1:mirrors.%Size()-1
	{
		set mirror = mirrors.%Get(i)
		Set ownerfrom = mirror.from
		Set ownerto = mirror.to
		Set org = mirror.org
		Set repos = mirror.repos
		
		for j=0:1:repos.%Size()-1
		{
			Set repo = repos.%Get(j)_".git"

			if (##class(%File).Exists(Directory_repo)=1)
			{
				Do ..FetchAndPush(Directory_repo)
				Continue
			}
			
			Set st1 = ..MirrorOne(repo, ownerfrom, ownerto, org)
			Set st = $$$ADDSC(st, st1)
			
		}
	}
	Return st
}

Method MirrorOne(Repo As %String, OwnerFrom As %String, OwnerTo As %String, Org As %String, Directory As %String = {..#Directory}) As %Status
{
	Set st = $$$OK
	
	Set github = "https://github.com/"
	Set sourceRepo = github_OwnerFrom_"/"_Repo
	Set mirrorRepo = github_OwnerTo_"/"_Repo
	
	set description = "This is a read-only mirror of "_sourceRepo_". Put you PR there."

	w !,"Create repo for mirroring: "_mirrorRepo
	Set st1 = ..CreateRepo(Repo, description, $select(Org=0:"",1:OwnerTo))
	
	w "    "_st1,!,!,"Clone bare repo: "_sourceRepo
	Set st2 = ..Clone(sourceRepo, Directory)
	Set st = $$$ADDSC(st1, st2)
	
	w "    "_st,!,!,"Mirroring: "_sourceRepo_" -> "_mirrorRepo
	Set st3 = ..Mirroring(Directory_Repo, mirrorRepo)
	Set st = $$$ADDSC(st, st3)
	
	w "    "_st,!,!,"Fetch and push... "
	Set st4 = ..FetchAndPush(Directory_Repo)
	Set st = $$$ADDSC(st, st4)

	Return st
}

Method CreateRepo(Name As %String, Description As %String = "empty", Org As %String, Private As %String = "false") As %Status
{
	if $d(Org) && (Org '= "") {
		Set ..Request.Location = "orgs/" _ Org _ "/repos"
	}else {
		Set ..Request.Location = "user/repos"
	}
	
	set json = "{""name"":"""_Name_""" ,""description"":"""_Description_""","_
			   """private"":"_Private_", ""has_issues"":false}"

	Do ..Request.EntityBody.Write(json)
	
	Set st = ..Request.Post()
	
	Return st
}

ClassMethod Clone(Repo As %String, Directory As %String, Parameter As %String = "--mirror") As %Status
{
	Do $system.Process.CurrentDirectory(Directory)
	Set cmd = "git clone " _ Parameter _" "_ Repo 
	
	Set st = ##class(GitHub.Utils).execute(cmd)

	Return st
}

ClassMethod Mirroring(Directory As %String, RepoForMirroring) As %Status
{
	Do $system.Process.CurrentDirectory(Directory)
	
	Set cmd = "git remote set-url --push origin " _ RepoForMirroring
	
	Set st = ##class(GitHub.Utils).execute(cmd)
	
	Return st
}

ClassMethod FetchAndPush(Directory As %String) As %Status
{
	Do $system.Process.CurrentDirectory(Directory)
	w !!,"directory: "_Directory,!
	Set cmd = "git fetch -p origin"
	Set st1 = ##class(GitHub.Utils).execute(cmd,1)
	
	Set cmd = "git push --mirror"
	Set st2 = ##class(GitHub.Utils).execute(cmd,1)
	
	Return $$$ADDSC(st1, st2)
}

ClassMethod UpdateMirrors(Directory As %String = {..#Directory}) As %Status
{
	Set stream=##class(%Stream.FileCharacter).%New()
	Set sc=stream.LinkToFile(Directory_"repos.json")
	Set conf={}.%FromJSON(stream.Read($$$MaxCacheInt))
	
	Set repos = conf.repos
	
	for i=0:1:repos.%Size()-1
	{
		Set repo = repos.%Get(i)_".git"
		Set sc = ..FetchAndPush(Directory_repo)
	}
	
	Return sc
}

}

