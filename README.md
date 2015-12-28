# GitHubAPI
Github API for InterSystems Caché

## Installation

Import xmls into any namespace and compile.

## Usage

First create api object to interact with GitHub API (provide valid GitHub user and pass):

`Set api = ##class(GitHub.API).%New("user","pass")`

After that you can query some GitHub APIs. For example to get info about all public repos in organization:

`Do api.GetOrgRepos("intersystems-ru","public",.repos)`

All availible API calls are listed in class documentation of `GitHub.API` class.

Some workflows to automate work with GitHub are availible in `GitHub.Workflows` class.

## Some API method I want is not availible. What do I do?
Everyone is welcome to add methods or wokflows via pull requests.
