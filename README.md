# GitHubAPI
Github API for InterSystems Data Platforms

## Installation

Import into any namespace and compile.

## Usage

First create api object to interact with GitHub API (provide valid GitHub Token if available):

`Set api = ##class(GitHub.API).%New("<your token>")`

After that you can query some GitHub APIs. For example to get info about all public repos in organization:

`Do api.GetOrgRepos("intersystems-ru","public",.repos)`

All availible API calls are listed in class documentation of `GitHub.API` class.

Some workflows to automate work with GitHub are availible in `GitHub.Workflows` class.

### Mirroring

1. Create repos.json file: 

```
{
    "mirrors": [{
        "from": "intersystems-ru",  // owners: user or organization
        "to": "intersystems-community",
        "org": 1,                   // 1: if you want to mirror in organization owner. 0: if user owner.
        "repos": [
            "GitHubAPI"             // just repos name f.e. 'GitHubAPI'
        ]
    }, {
        "from": "user1",
        "to": "user2",
        "org": 0,
        "repos": [
            "repo1",
            "repo2"
        ]
    }]
}
```

2. Set repos.json location in param, class `GitHub.API`. `Parameter Directory = "C:/temp/mirror/"`
3. `Set api = ##class(GitHub.API).%New("user","pass")`
4. `Do api.Mirror()`

#### Task

Create task:
- Task Type = `RunLegacyTask`
- ExecuteCode = `Do ##class(GitHub.API).UpdateMirrors()`
- Choose the right time to start the task


## Some API method I want is not availible. What do I do?
Everyone is welcome to add methods or wokflows via pull requests.
