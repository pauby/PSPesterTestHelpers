Import-Module PowerShellBuild -force
. PowerShellBuild.IB.Tasks

$PSBPreference.Build.CompileModule = $true
# $PSBPreference.Build.Dependencies                           = 'StageFiles', 'BuildHelp'
$PSBPreference.Test.Enabled                                 = $true
$PSBPreference.Test.CodeCoverage.Enabled                    = $true
$PSBPreference.Test.CodeCoverage.Threshold                  = 0.1
$PSBPreference.Test.CodeCoverage.Files                      =
    (Join-Path -Path $PSBPreference.Build.ModuleOutDir -ChildPath "*.psm1")
$PSBPreference.Test.ScriptAnalysis.Enabled                  = $true
$PSBPreference.Test.ScriptAnalysis.FailBuildOnSeverityLevel = 'Error'

task LocalDeploy {
    $sourcePath = $PSBPreference.Build.ModuleOutDir
    $destPath = Join-Path -Path ([Environment]::GetFolderPath('MyDocuments')) `
        -ChildPath "WindowsPowerShell\Modules\$($PSBPreference.General.ModuleName)\$($PSBPreference.General.ModuleVersion)\"

    if (Test-Path -Path $destPath) {
        Remove-Item -Path $destPath -Recurse -Force
    }
    Copy-Item -Path $sourcePath -Destination $destPath -Recurse -Force
}

task CreateGitHubRelease {
    Set-GitHubSessionInformation -User $env:GITHUB_USERNAME -ApiKey $env:GITHHUB_API_KEY

    # Create the artifact
    $artifactPath = Join-Path -Path $env:TEMP -ChildPath "{0}-{1}.zip" -f $PSBPreference.General.ModuleName, $PSBPreference.General.ModuleVersion
    $modulePath = Join-Path -Path $PSBPreference.Build.ModuleOutDir -ChildPath "*"
    Compress-Archive -Path $PSBPreference.Build.ModuleOutDir -DestinationPath $artifactPath

    $params = @{
        Repository = $PSBPreference.General.ModuleName
        Name = $PSBPreference.General.ModuleName
        Description = "v$($PSBPreference.General.ModuleVersion) Release"
        Target = 'master'
        Tag = "v$($PSBPreference.General.ModuleVersion)"
        Assets = @{
            "Path" = $artifactPath
            "Content-Type" = "application/zip"
        }
    }
    New-GitHubRelease @params
}

task deploy Publish, CreateGitHubRelease, { }

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
        (Get-Item ENV:BH*).Foreach({
            '{0,-20}{1}' -f $_.name, $_.value
        })
    } # task
}