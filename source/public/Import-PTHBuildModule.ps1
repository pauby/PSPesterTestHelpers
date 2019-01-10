function Import-PTHBuildModule {
    [CmdletBinding()]
    Param ()

    # build the filename
    $moduleScript = "{0}\{1}.psm1" -f $env:BHBuildOutput, $env:BHProjectName
    if (Test-Path -Path $moduleScript) {
        Remove-Module -Name $moduleScript -ErrorAction SilentlyContinue
        Import-Module -Name $moduleScript -Force -ErrorAction Stop

        $importedModule = Get-Module -Name $env:BHProjectName
        Write-Verbose "Imported module '$($importedModule.Path)'"
    }
    else {
        throw "Module manifest '$moduleScript' does not exist!"
    }
}