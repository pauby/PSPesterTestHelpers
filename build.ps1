[CmdletBinding()]
Param (
    $Task = 'build'
)

$dependModules = @(
    @{
        Name = 'InvokeBuild'
    },
    @{
        Name = 'Configuration'
    },
    @{
        Name            = 'PowerShellBuild'
        MinimumVersion  = '0.3.0-beta'
        AllowPrerelease = $true
    },
    @{
        Name           = 'Pester'
        MinimumVersion = 4.4.3
    }
    @{
        Name           = 'PSScriptAnalyzer'
        MinimumVersion = '1.17.1'
    }
    @{
        Name           = 'GitHubReleaseManager'
        MinimumVersion = '1.2.0'
    }
)

$dependChocoPackage = @(
    @{
        Name = 'git'
        CheckCommand = 'git.exe'
    }
)

#region functions
function Install-BuildModule {
    [CmdletBinding()]
    Param (
        # Hashtable:
        #   Same parameters as Install-Module - Name is mandatory
        [hashtable[]]
        $Module
    )

    # dependencies
    if (-not (Get-Command -Name 'Get-PackageProvider' -ErrorAction SilentlyContinue)) {
        $null = Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
        Write-Verbose 'Bootstrapping NuGet package provider.'
        Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null
    }

    Set-PSRepository -Name PSGallery -InstallationPOlicy Trusted

    $Module | ForEach-Object {
        if (-not (Get-Module -Name $_.Name -ListAvailable)) {
            Write-Verbose "Installing module '$($_.Name)'."
            Install-Module @_ -SkipPublisherCheck -AllowClobber
        }
        else {
            Write-Verbose "Module '$($_.Name)' already installed."
        }
        Import-Module -Name $_.Name -Force
    }
}

function Install-BuildChocolateyPackage {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [hashtable[]]
        $Package
    )

    # Check if Chocolatey is installed
    Write-Verbose 'Checking if Chocolatey is installed'
    if (-not (Get-Command -Name 'choco.exe' -ErrorAction SilentlyContinue)) {
        try {
            Write-Verbose 'Chocolatey not installed. Installing.'
            # taken from https://chocolatey.org/install
            Set-ExecutionPolicy Bypass -Scope Process -Force
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        }
        catch {
            throw "Could not install Chocolatey ($($Error[0].Exception))"
        }
    }

    # if we get here either Chocolatey is installed
    $Package | ForEach-Object {
        Write-Verbose "Checking for '$($_.CheckCommand)'."
        if (-not (Get-Command -Name $_.CheckCommand -ErrorAction SilentlyContinue)) {
            Write-Verbose "'$($_.CheckCommand)' not found. Installing '$($_.Name)' package."
            choco install $_.Name -y
        }
        else {
            Write-Verbose "'$($_.CheckCommand) found."
        }
    }

    Write-Verbose 'Refreshing the PATH'
    refreshenv
}

# Initialize the build environment if the session is running as Admin
function Test-Administrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
#endregion

if (Test-Administrator) {
    Install-BuildModule -Module $dependModules
    Install-BuildChocolateyPackage -Package $dependChocoPackage
}
else {
    Write-Warning "Not running as Administrator - could not initialize build environment."
}

# Configure git
if ($null -eq (Invoke-Expression -Command 'git config --get user.email')) {
    Write-Verbose 'Git is not configured so we need to configure it now.'
    git config --global user.email "pauby@users.noreply.github.com"
    git config --global user.name "pauby"
    git config --global core.safecrlf false
}

Invoke-Build -File .\.pspestertesthelpers.build.ps1 -Task $Task -Verbose:$VerbosePreference