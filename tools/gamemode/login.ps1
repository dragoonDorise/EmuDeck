function startSteam(){
	 $steamRegPath = "HKCU:\Software\Valve\Steam"
	 $steamInstallPath = (Get-ItemProperty -Path $steamRegPath).SteamPath
	 $steamInstallPath = $steamInstallPath.Replace("/", "\")
	 $steamArguments = "-bigpicture"
	 Start-Process -FilePath "$steamInstallPath\Steam.exe" -Wait -ArgumentList $steamArguments
 }
 function startScriptWithAdmin {
	 param (
		 [string]$ScriptContent
	 )
	 $tempScriptPath = [System.IO.Path]::GetTempFileName() + ".ps1"
	 $ScriptContent | Out-File -FilePath $tempScriptPath -Encoding utf8 -Force

	 $psi = New-Object System.Diagnostics.ProcessStartInfo
	 $psi.Verb = "runas"
	 $psi.FileName = "powershell.exe"
	 $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File ""$tempScriptPath"""
	 [System.Diagnostics.Process]::Start($psi).WaitForExit()

	 Remove-Item $tempScriptPath -Force
 }

Function NewWPFDialog() {
	 <#
	 .SYNOPSIS
	 This neat little function is based on the one from Brian Posey's Article on Powershell GUIs

	 .DESCRIPTION
	   I re-factored a bit to return the resulting XaML Reader and controls as a single, named collection.

	 .PARAMETER XamlData
	  XamlData - A string containing valid XaML data

	 .EXAMPLE

	   $MyForm = New-WPFDialog -XamlData $XaMLData
	   $MyForm.Exit.Add_Click({...})
	   $null = $MyForm.UI.Dispatcher.InvokeAsync{$MyForm.UI.ShowDialog()}.Wait()

	 .NOTES
	 Place additional notes here.

	 .LINK
	   http://www.windowsnetworking.com/articles-tutorials/netgeneral/building-powershell-gui-part2.html

	 .INPUTS
	  XamlData - A string containing valid XaML data

	 .OUTPUTS
	  a collection of WPF GUI objects.
   #>

	 Param([Parameter(Mandatory = $True, HelpMessage = 'XaML Data defining a GUI', Position = 1)]
		 [string]$XamlData)

	 # Add WPF and Windows Forms assemblies
	 try {
		 Add-Type -AssemblyName PresentationCore, PresentationFramework, WindowsBase, system.windows.forms
	 }
	 catch {
		 Throw 'Failed to load Windows Presentation Framework assemblies.'
	 }

	 # Create an XML Object with the XaML data in it
	 [xml]$xmlWPF = $XamlData

	 # Create the XAML reader using a new XML node reader, UI is the only hard-coded object name here
	 Set-Variable -Name XaMLReader -Value @{ 'UI' = ([Windows.Markup.XamlReader]::Load((new-object -TypeName System.Xml.XmlNodeReader -ArgumentList $xmlWPF))) }

	 # Create hooks to each named object in the XAML reader
	 $Elements = $xmlWPF.SelectNodes('//*[@Name]')
	 ForEach ( $Element in $Elements ) {
		 $VarName = $Element.Name
		 $VarValue = $XaMLReader.UI.FindName($Element.Name)
		 $XaMLReader.Add($VarName, $VarValue)
	 }

	 return $XaMLReader
 }


 function confirmDialog {
	 param (
		 [string]$TitleText = "Do you want to continue?",
		 [string]$MessageText = "",
		 [string]$OKButtonText = "Continue",
		 [string]$CancelButtonText = "Cancel",
		 [string]$Position = "CenterScreen"
	 )
	 # This is the XAML that defines the GUI.
	 $WPFXaml = @"
 <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
	 xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
	 Title="Popup" AllowsTransparency="True" Background="Transparent"  Foreground="#FFFFFFFF" ResizeMode="NoResize" WindowStartupLocation="$Position" SizeToContent="WidthAndHeight" WindowStyle="None" MaxWidth="600" Padding="20" Margin="0" Topmost="True">
	 <Border CornerRadius="10" BorderBrush="#222" BorderThickness="2" Background="#222">
	  <Grid Name="grid">
				 <ScrollViewer VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
					 <StackPanel>
						 <Border Margin="20,10,0,20" Background="Transparent">
							 <TextBlock Name="Title" Margin="0,10,0,10" TextWrapping="Wrap" Text="_TITLE_" FontSize="24" FontWeight="Bold" HorizontalAlignment="Left"/>
						 </Border>
						 <Border Margin="20,0,20,0" Background="Transparent">
							 <TextBlock Name="Message" Margin="0,0,0,20" TextWrapping="Wrap" Text="_CONTENT_" FontSize="18"/>
						 </Border>
						 <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
							 <Border CornerRadius="20" BorderBrush="#5bf" BorderThickness="1" Background="#5bf" Margin="0,0,10,20" >
								 <Button Name="OKButton" BorderBrush="Transparent" Content="_OKBUTTONTEXT_" Background="Transparent" FontSize="16" Foreground="White">
									 <Button.Style>
										 <Style TargetType="Button">
											 <Setter Property="Background" Value="#5bf" />
											 <Setter Property="Template">
												 <Setter.Value>
													 <ControlTemplate TargetType="Button">
														 <Border CornerRadius="20" Background="{TemplateBinding Background}" BorderThickness="1" Margin="16,8,16,8">
															 <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" />
														 </Border>
														 <ControlTemplate.Triggers>
															 <Trigger Property="IsMouseOver" Value="True">
																 <Setter Property="Background" Value="#fff" />
															 </Trigger>
														 </ControlTemplate.Triggers>
													 </ControlTemplate>
												 </Setter.Value>
											 </Setter>
										 </Style>
									 </Button.Style>
								 </Button>
							 </Border>
						 </StackPanel>
					 </StackPanel>
				 </ScrollViewer>
			 </Grid>
	 </Border>
 </Window>
 "@

	 # Build Dialog
	 $WPFGui = NewWPFDialog -XamlData $WPFXaml
	 $WPFGui.Message.Text = $MessageText
	 $WPFGui.Title.Text = $TitleText
	 $WPFGui.Message.Text = $MessageText

	 $WPFGui.OKButton.Content = $OKButtonText

	 # Create a script block to handle the button click event
	 $buttonClickEvent = {
		 param($sender, $e)
		 $global:Result = $sender.Name
		 $WPFGui.UI.Close()
	 }

	 # Add the script block to the button's Click event
	 $WPFGui.OKButton.Add_Click($buttonClickEvent)

	 # Create a variable to hold the result
	 $global:Result = $null

	 # Show the dialog
	 $null = $WPFGUI.UI.Dispatcher.InvokeAsync{ $WPFGui.UI.ShowDialog() }.Wait()

	 # Return the result
	 return $global:Result
 }



startSteam
if($?){
	#Back to desktop
	#We set the good old explorer.exe as shell
$scriptContent = @"
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "Shell" -Value "explorer.exe"
	#We restart sihost to launch explorer and the desktop
	Wait-Event -Timeout 5
	Stop-Process -Name "sihost" -Force
	Wait-Event -Timeout 5
	& "C:\Windows\System32\sihost.exe"
	#We set the next restart to be on game mode.
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "Shell" -Value "$env:APPDATA\EmuDeck\backend\tools\gamemode\login.bat"
"@
	startScriptWithAdmin -ScriptContent $scriptContent
	#We don't restart sihost since we don't want to go to game mode now.
}else{
	confirmDialog -TitleText "Game Mode" -MessageText "There was an error running Steam. Please press CTRL ALT DEL, open task manager, then New Task and run explorer.exe, navigate to EmuDeck, enable Desktop Mode and restart your device"

	#Disable game mode in case of fail, we set explorer.exe and restart the desktop with sihost
$scriptContent = @"
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "Shell" -Value "explorer.exe"
	Wait-Event -Timeout 5
	#We restart sihost to launch explorer and the desktop
	Stop-Process -Name "sihost" -Force
	Wait-Event -Timeout 5
	& "C:\Windows\System32\sihost.exe"
"@
	confirmDialog -TitleText "Game mode failed to start" -MessageText "Going back to your Desktop"
	startScriptWithAdmin -ScriptContent $scriptContent
}
