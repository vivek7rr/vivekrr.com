$AppDetails = Import-Csv C:tempCSVtest2.csv
foreach  ($appdetail in $Appdetails) {
$Error.Clear()
    
    $release = $appdetail.appversion
    $description = $null
    $description = $AppDetail.Appdescription
    $install = $appdetail.AppInstall
    $publisher = $appdetail.AppPublisher
    $name = $AppDetail.apptitle
    $file = $appdetail.Detection
    $filename = $AppDetail.filename
    $source = $appdetail.Appsource
    $AppOwner = $appdetail.AppSponsor
    $ApplicationSoftwareVersion = $appdetail.Appswversion
    $DeploymentUninstallCommandLine = $appdetail.Appuninstall

# initialise management scope.

$factory = New-Object Microsoft.ConfigurationManagement.AdminConsole.AppManFoundation.ApplicationFactory
$wrapper = [Microsoft.ConfigurationManagement.AdminConsole.AppManFoundation.AppManWrapper]::Create($connection, $factory)

# create the application.

$app = New-Object Microsoft.ConfigurationManagement.ApplicationManagement.Application

# set the application properties.

$app.Title = $name
$ppm = "PPM Number:"
$created = "Created By : a589220"
$description1 = $ppm + $description + "`n$created"
$app.Description = $description1
$app.SoftwareVersion = $ApplicationSoftwareVersion
$app.Publisher = $publisher
# prepare the localised display info.
$info = New-Object Microsoft.ConfigurationManagement.ApplicationManagement.AppDisplayInfo
# set the localised application name.
$info.Title = $name
$info.Language = "en-AU"
# save the display properties.
$app.DisplayInfo.Add($info)
# create a script-based installer.
$installer = New-Object Microsoft.ConfigurationManagement.ApplicationManagement.ScriptInstaller
$installer.InstallCommandLine = $install
$installer.MachineInstall = $true
$installer.UserInstall = $false
$installer.UninstallCommandLine = $DeploymentUninstallCommandLine

# reference the content source.

$content = [Microsoft.ConfigurationManagement.ApplicationManagement.ContentImporter]::CreateContentFromFolder($source)
$content.OnSlowNetwork = [Microsoft.ConfigurationManagement.ApplicationManagement.ContentHandlingMode]::Download
$content.OnFastNetwork = [Microsoft.ConfigurationManagement.ApplicationManagement.ContentHandlingMode]::Download
$installer.Contents.Add($content)
$reference  =  New-Object Microsoft.ConfigurationManagement.ApplicationManagement.ContentRef
$reference.Id  = $content.Id
$installer.InstallContent =  $reference

# use an enhanced detection method.

$installer.DetectionMethod = [Microsoft.ConfigurationManagement.ApplicationManagement.DetectionMethod]::Enhanced
$detector = New-Object Microsoft.ConfigurationManagement.ApplicationManagement.EnhancedDetectionMethod
# use a file detector.
$type = [Microsoft.ConfigurationManagement.DesiredConfigurationManagement.ConfigurationItemPartType]::File
# prepare the detection settings.
$setting = New-Object Microsoft.ConfigurationManagement.DesiredConfigurationManagement.FileOrFolder($type , $null)
# configure the detection settings.
$setting.FileOrFolderName = $filename
$setting.Path = $file
$setting.Is64Bit = 1
$setting.SettingDataType = [Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.DataType]::Version
# save the detection settings.
$detector.Settings.Add($setting)
# configure the setting reference.
$reference = New-Object Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.SettingReference($app.Scope, $app.Name, $app.Version, $setting.LogicalName, $setting.SettingDataType, $setting.SourceType, [bool]0)
$reference.MethodType = [Microsoft.ConfigurationManagement.DesiredConfigurationManagement.ConfigurationItemSettingMethodType]::Value

# create the version comparison value.
$value = New-Object Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.ConstantValue($version, [Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.DataType]::Version)
# configure the comparison operands.
$operands = New-Object Microsoft.ConfigurationManagement.DesiredConfigurationManagement.CustomCollection``1[[Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.ExpressionBase]]
$operands.Add($reference)
$operands.Add($value)
# build the comparison expression.
$expression = New-Object Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.Expression([Microsoft.ConfigurationManagement.DesiredConfigurationManagement.ExpressionOperators.ExpressionOperator]::IsEquals, $operands)
# save the detection rule.
$rule = New-Object Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Rules.Rule("IsInstalledRule", [Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Rules.NoncomplianceSeverity]::None, $null, $expression)
# associate the detection rule with the detection method.
$detector.Rule = $rule
# associate the detector with the installer.
$installer.EnhancedDetectionMethod = $detector
# create the deployment type.
$deployment = New-Object Microsoft.ConfigurationManagement.ApplicationManagement.DeploymentType($installer, [Microsoft.ConfigurationManagement.ApplicationManagement.ScriptInstaller]::TechnologyId, [Microsoft.ConfigurationManagement.ApplicationManagement.NativeHostingTechnology]::TechnologyId)
# name the deployment type after the application.
$deployment.Title = $name
# associate the deployment type with the application.
$app.DeploymentTypes.Add($deployment)

# save the application.
$wrapper.InnerAppManObject = $app
$factory.PrepareResultObject($wrapper)
$wrapper.InnerResultObject.Put()

Set-Location QPS:
Set-CMApplication -Name "$name" -Owner "$AppOwner" -SupportContact "Techline 3274" -DistributionPointSetting AutoDownload
Set-CMDeploymentType -DeploymentTypeName "$name" -ApplicationName "$name" -MsiOrScriptInstaller -AdministratorComment "Script Installation method" -InstallationBehaviorType InstallForSystem -AllowClientsToShareContentOnSameSubnet $false

if ($error[0]){ Write-Host "Application : $name Failed to create" -ForegroundColor Yellow  } else {Write-Host "Application : $name Creted Successfully" -ForegroundColor green}
}
