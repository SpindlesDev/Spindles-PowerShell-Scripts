$license="AGPL-3.0"
$author="Spindles"
$startMessage="This was created by " + $author + " and is licensed under " + $license

Write-Output $startMessage


$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = 'SilentlyContinue'

function getConfig {
	return (Get-Content -Path "./autoServerRestartScriptConfig.json" | ConvertFrom-Json)
}

$ServerName = (getConfig).ServerName
$DiscordWebhookUrl = (getConfig).DiscordWebhookUrl
	
$ServerExec = (getConfig).ServerExec

$DiscordWebhookBodyRaw = "" | Select-Object username, content, embeds
$DiscordWebhookBodyRaw.username = $ServerName

function getStartMap {
	# WIP
	return (Get-Content -Path "./startMaps.json") | ConvertFrom-Json | Get-Random
}

function startServer {

	#$DiscordWebhookBodyContentJSON=''

	$DiscordWebhookBodyEmbedJSONTemplate = '{
		"embeds":[
			{
				"title": null,
				"description": null,
				"color": null
			}
		]
	}'
	$DiscordWebhookBodyEmbedRaw = $DiscordWebhookBodyEmbedJSONTemplate | ConvertFrom-Json


	$StartMap = getStartMap
	$ServerStartArgsTemplate = $StartMap +
	"?Game=" + (getConfig).gamemode +
	"?AdminPassword=" + (getConfig).adminPassword +
	"?MaxPlayers=" + (getConfig).maxPlayers +
	" -Port=" + (getConfig).gamePort +
	" -PeerPort=" + (getConfig).peerPort +
	" -QueryPort=" + (getConfig).queryPort +
	(getConfig).additionalArgs
	$ServerStartArgs = ($ServerStartArgsTemplate).Split(" ")
	$ServerStartArgsTemplate
	$ServerStartArgs

	$ServerStatus = "Started"
	$ServerMapMessage = "Start map: " + $StartMap
	$DiscordWebhookBodyEmbedRaw.embeds[0].title = $ServerStatus
	$DiscordWebhookBodyEmbedRaw.embeds[0].description = $ServerMapMessage
	$DiscordWebhookBodyEmbedRaw.embeds[0].color = 65280
	$DiscordWebhookBodyRaw.embeds = $DiscordWebhookBodyEmbedRaw.embeds

	$DiscordWebhookBodyRaw.content = $null
	$DiscordWebhookBody = $DiscordWebhookBodyRaw | ConvertTo-Json
	Invoke-WebRequest -Uri $DiscordWebhookUrl -Method "POST" -Body $DiscordWebhookBody -ContentType "application/json" | Out-Null

	Start-Process -FilePath $ServerExec -ArgumentList $ServerStartArgs -Wait


	$ServerStatus = "Stopped"
	$ServerMapMessage = "Start map was: " + $StartMap
	$DiscordWebhookBodyEmbedRaw.embeds[0].title = $ServerStatus
	$DiscordWebhookBodyEmbedRaw.embeds[0].description = $ServerMapMessage
	$DiscordWebhookBodyEmbedRaw.embeds[0].color = 16711680
	$DiscordWebhookBodyRaw.embeds = $DiscordWebhookBodyEmbedRaw.embeds

	$DiscordWebhookBodyRaw.content = $null
	$DiscordWebhookBody = $DiscordWebhookBodyRaw | ConvertTo-Json
	Invoke-WebRequest -Uri $DiscordWebhookUrl -Method "POST" -Body $DiscordWebhookBody -ContentType "application/json" | Out-Null

	startServer
}

startServer

exit
