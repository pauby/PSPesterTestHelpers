Import-Module PowerShellBuild -force
. PowerShellBuild.IB.Tasks

$PSBPreference.Build.CompileModule = $true
# $PSBPreference.Build.Dependencies                           = 'StageFiles', 'BuildHelp'
$PSBPreference.Test.Enabled = $false
$PSBPreference.Test.CodeCoverage.Enabled = $false
$PSBPreference.Test.CodeCoverage.Threshold = 0.1
$PSBPreference.Test.CodeCoverage.Files =
(Join-Path -Path $PSBPreference.Build.ModuleOutDir -ChildPath "*.psm1")
$PSBPreference.Test.ScriptAnalysis.Enabled = $true
$PSBPreference.Test.ScriptAnalysis.FailBuildOnSeverityLevel = 'Error'

#region Build Tasks
task LocalDeploy {
    $sourcePath = $PSBPreference.Build.ModuleOutDir
    $destPath = Join-Path -Path ([Environment]::GetFolderPath('MyDocuments')) `
        -ChildPath "WindowsPowerShell\Modules\$($PSBPreference.General.ModuleName)\$($PSBPreference.General.ModuleVersion)\"

    if (Test-Path -Path $destPath) {
        Remove-Item -Path $destPath -Recurse -Force
    }
    Copy-Item -Path $sourcePath -Destination $destPath -Recurse -Force
}

task Clean Init, {
    Clear-PSBuildOutputFolder -Path $PSBPreference.Build.ModuleOutDir

    # Remove docs folder
    Remove-Item -Path $PSBPreference.Docs.RootDir -Recurse -Force -ErrorAction SilentlyContinue
}

task CreateGitHubRelease {
    # Create the artifact
    $artifactPath = Join-Path -Path $env:TEMP -ChildPath ("{0}-{1}.zip" -f $PSBPreference.General.ModuleName, $PSBPreference.General.ModuleVersion)
    $modulePath = Join-Path -Path $PSBPreference.Build.ModuleOutDir -ChildPath "*"
    Compress-Archive -Path $modulePath -DestinationPath $artifactPath

    $params = @{
        Repository  = $PSBPreference.General.ModuleName
        Name        = "$($PSBPreference.General.ModuleName) v$($PSBPreference.General.ModuleVersion)"
        Description = "Release v$($PSBPreference.General.ModuleVersion)"
        Target      = 'master'
        Tag         = "v$($PSBPreference.General.ModuleVersion)"
        Confirm     = $false
        Asset      = @{
            "Path"         = $artifactPath
            "Content-Type" = "application/zip"
        }
    }
    Set-GitHubSessionInformation -User $env:GITHUB_USERNAME -ApiKey $env:GITHUB_API_KEY
    New-GitHubRelease @params
}

task deploy Publish, CreateGitHubRelease, { }

#endregion

# Only needed to workaround PowerShellBuild issues
$moduleVersion = (Get-Module -Name PowerShellBuild -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).Version
if ($moduleVersion -le [version]"0.3.0") {
    task Build {
    }, StageFiles, BuildHelp

    task Init {
        Initialize-PSBuild
        Set-BuildEnvironment -BuildOutput $PSBPreference.Build.ModuleOutDir -Force
        $nl = [System.Environment]::NewLine
        "$nl`Environment variables:"
        (Get-Item ENV:BH*).Foreach( {
                '{0,-20}{1}' -f $_.name, $_.value
            })
    } # task

    task Pester -If ( $pesterPreReqs -eq $true ), Build, {
        $pesterParams = @{
            Path                  = $PSBPreference.Test.RootDir
            ModuleName            = $PSBPreference.General.ModuleName
            OutputPath            = $PSBPreference.Test.OutputFile
            OutputFormat          = $PSBPreference.Test.OutputFormat
            CodeCoverage          = $PSBPreference.Test.CodeCoverage.Enabled
            CodeCoverageThreshold = $PSBPreference.Test.CodeCoverage.Threshold
            CodeCoverageFiles     = $PSBPreference.Test.CodeCoverage.Files
        }
        Test-PSBuildPester @pesterParams
    }

    task Publish Test, {
        assert ($PSBPreference.Publish.PSRepositoryApiKey -or $PSBPreference.Publish.PSRepositoryCredential) "API key or credential not defined to authenticate with [$($PSBPreference.Publish.PSRepository)] with."

        $publishParams = @{
            Path       = $PSBPreference.Build.ModuleOutDir
            Version    = $PSBPreference.General.ModuleVersion
            Repository = $PSBPreference.Publish.PSRepository
            Verbose    = $VerbosePreference
        }
        if ($PSBPreference.Publish.PSRepositoryApiKey) {
            $publishParams.ApiKey = $PSBPreference.Publish.PSRepositoryApiKey
        }
        else {
            $publishParams.Credential = $PSBPreference.Publish.PSRepositoryCredential
        }

        Publish-PSBuildModule @publishParams
    }

}