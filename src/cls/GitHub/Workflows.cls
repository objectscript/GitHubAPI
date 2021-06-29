Class GitHub.Workflows
{

/// Protect default branches in organization.<br>
/// <var>Org</var> - name of Organization<br>
/// <var>Token</var> - GitHub user token, whois organisation owner<br>
ClassMethod ProtectDefaultBranches(Org As %String, Token As %String)
{
	Set api = ##class(GitHub.API).%New(Token)
	#dim repos As List of %ZEN.proxyObject
	Set st = api.GetOrgRepos(Org, "public", .repos)
	Write $System.Status.GetErrorText(st)
	For i=1:1:repos.Count() {
		Set repo = repos.GetAt(i).name
		Set branch = repos.GetAt(i)."default_branch"
		Set st = api.ProtectBranch(Org, repo, branch)
		Write repo, " ", $System.Status.GetErrorText(st), !
	}
}

/// Add team to all organization repositories<br>
/// <var>Org</var> - name of Organization<br>
/// <var>TeamId</var> - Id of a team<br>
/// <var>Token</var> - GitHub user token, whois organisation owner<br>
ClassMethod AddTeamToAllOrgRepos(Org As %String, TeamId As %String, Token As %String)
{
	Set api = ##class(GitHub.API).%New(Token)
	#dim orgrepos,teamrepos As %ListOfDataTypes

	Set st = api.GetOrgReposNames(Org, "public", .orgrepos)
	Write $System.Status.GetErrorText(st)
	Set st = api.GetTeamReposNames(TeamId, "public", .teamrepos)
	Write $System.Status.GetErrorText(st)
	
	Set added = ##class(%ListOfDataTypes).%New()
	For i=1:1:orgrepos.Count() {
		// Add repos to "added" list, which we can see in organisation, but not in team repos
		Do:'teamrepos.Find(orgrepos.GetAt(i)) added.Insert(orgrepos.GetAt(i))
	}

	For i=1:1:added.Count() {
		Set repo = added.GetAt(i)
		Set st = api.AddRepoToTeam(Org, TeamId, repo, "push")
		Write repo, " ", $System.Status.GetErrorText(st), !
	}
}

}

