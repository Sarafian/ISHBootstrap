<#
# Copyright (c) 2014 All Rights Reserved by the SDL Group.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#>

if ($PSBoundParameters['Debug']) {
    $DebugPreference = 'Continue'
}

try
{
    $sourcePath=Resolve-Path "$PSScriptRoot\..\Source"
    $cmdletsPaths="$sourcePath\Cmdlets"
    $scriptsPaths="$sourcePath\Scripts"
    $modulesPaths="$sourcePath\Modules"

    . "$PSScriptRoot\Cmdlets\Get-ISHBootstrapperContextValue.ps1"
    . "$cmdletsPaths\Helpers\Invoke-CommandWrap.ps1"

    $computerName=Get-ISHBootstrapperContextValue -ValuePath "ComputerName" -DefaultValue $null
    $credential=Get-ISHBootstrapperContextValue -ValuePath "CredentialExpression" -Invoke

    if(-not $computerName)
    {
        & "$scriptsPaths\Helpers\Test-Administrator.ps1"
    }

    $ishVersion=Get-ISHBootstrapperContextValue -ValuePath "ISHVersion"
    $ishServerVersion=($ishVersion -split "\.")[0]

    $ishServerModuleName="xISHServer.$ishServerVersion"

    $ishDeployRepository=Get-ISHBootstrapperContextValue -ValuePath "ISHDeployRepository"
    $ishDeployModuleName="ISHDeploy.$ishVersion"

    & $scriptsPaths\PowerShellGet\Install-Module.ps1 -Computer $computerName -Credential $credential -ModuleName @("CertificatePS","PSFTP") -Repository PSGallery
    & $scriptsPaths\PowerShellGet\Install-Module.ps1 -Computer $computerName -Credential $credential -ModuleName $ishDeployModuleName -Repository $ishDeployRepository

    if($computerName)
    {
        $ishServerRepository=Get-ISHBootstrapperContextValue -ValuePath "xISHServerRepository"
        & $scriptsPaths\PowerShellGet\Install-Module.ps1 -Computer $computerName -Credential $credential -ModuleName $ishServerModuleName -Repository $ishServerRepository
    }
    else
    {
        $path="$modulesPaths\xISHServer\$ishServerModuleName.psm1"
        Import-Module $path -Force
        Write-Warning "Not installed $ishServerModuleName. Instead loaded from $path"
    }
}
finally
{
}
