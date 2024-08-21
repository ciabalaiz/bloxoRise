local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LogService = game:GetService("LogService")
local UserInputService = game:GetService("UserInputService")
local ScriptEditorService = game:GetService("ScriptEditorService")
local scriptEditor = require(script.scriptEditor)
local Signal = require(script.Signal)
local github = require(script.github)
local documents = ScriptEditorService:GetScriptDocuments()
local account = github.new()
local currentID = tostring(game.PlaceId)
local GameLocations = {Workspace = game.Workspace,Players = game.Players,Lighting = game.Lighting,ReplicatedStorage = game.ReplicatedStorage,ServerStorage = game.ServerStorage,ServerScriptService = game.ServerScriptService,StarterGui = game.StarterGui,StarterPack = game.StarterPack,StarterPlayer = game.StarterPlayer,Teams = game.Teams,SoundService = game.SoundService,Chat = game.Chat,}

export type dataTemplate = {projects : {};currentToken : string;currentUser : string}
export type projectTemplate = {scripts : {};repoURL : string}
export type scriptTemplate = {UUID : string; sha : string; url : string}

local dataTemplate = 
	{
		projects = {};
		currentToken = "";
		currentUser = "";
	}


local projectTemplate = 
	{
		scripts = {};
		repoURL = "";
	}

local scriptTemplate = 
	{
		UUID = "";
		url = "";
		sha = "";
	}

local repoConfiguration = 
	{
		{question = "Choose a name for your repo = "};
		{question = "Make private = "; responses = {"y", "n", "yes", "no"}};
		{question = "Repo description = "};
		{question = "Enter to confirm"};
	}


local currentData : dataTemplate = plugin:GetSetting("main") or dataTemplate

account.githubToken = currentData.currentToken

if currentID == "0" or currentID == "" or currentID == nil then
	currentID = HttpService:GenerateGUID(false)
end

function message(msg, doc, line)
	doc:EditTextAsync(msg,line,1,line,string.len(doc:GetLine(line)))
end

function save()
	plugin:SetSetting("main", currentData)
end


function getUUID(instance : Script)
	for _, v in pairs(instance:GetTags()) do if string.find(v, "bloxo") then return v end end
	local uuid = "bloxo"..HttpService:GenerateGUID(false)
	instance:AddTag(uuid)
	return uuid
end

function hasUUID(instance : Script)
	for _, v in pairs(instance:GetTags()) do if string.find(v, "bloxo") then return true end end
	return false
end

function removeUUID(instance : Script)
	for _, v in pairs(instance:GetTags()) do if string.find(v, "bloxo") then instance:RemoveTag(v) return true end end
	return false
end

function overrideUUID(instance : Script)
	local old = ""
	for _, v in pairs(instance:GetTags()) do if string.find(v, "bloxo") then instance:RemoveTag(v); old = v end end
	local uuid = "bloxo"..HttpService:GenerateGUID(false)
	instance:AddTag(uuid)
	return uuid, old
end

function addScript(instance : Script)
	if currentData.projects[currentID].repoURL == ("" or nil) then return end
	
	local uuid = getUUID(instance)
	local repoName = account:action("getRepoNameFromUrl", currentData.projects[currentID].repoURL)
	local scriptSha = account:action("getFileSHA", repoName,instance.Name..".lua")
	
	if currentData.projects[currentID].scripts[uuid] == nil then
		print("CREATE")
		
		local createdFile = account:action("createFile",github.getRepoNameFromUrl(currentData.currentToken, currentData.projects[currentID].repoURL) ,instance.Name..".lua", instance.Source, "Added "..instance.Name)
		if createdFile.content == nil then warn(createdFile) return end
		local newFile = table.clone(scriptTemplate)
		
		newFile.name =  instance.Name
		newFile.html = createdFile.content.url;
		
		currentData.projects[currentID].scripts[uuid] = newFile
		save()
		
		return createdFile
	elseif currentData.projects[currentID].scripts[uuid] ~= nil then

		print("UPDATE")
		
		local updatedFile = account:action("updateFile",github.getRepoNameFromUrl(currentData.currentToken, currentData.projects[currentID].repoURL) , instance.Name..".lua", instance.Source ,"Updated "..instance.Name, scriptSha)
		if updatedFile.content == nil then warn(updatedFile) return end
		local newFile = table.clone(scriptTemplate)
		
		newFile.name =  instance.Name
		newFile.html = updatedFile.content.url;
		
		currentData.projects[currentID].scripts[uuid] = newFile
		save()
		
		return updatedFile
	end
	
	return nil
end

function deleteScript(newScript : Instance)
	local firstName = currentData.projects[currentID].scripts[getUUID(newScript)].name
	local repoName = account:action("getRepoNameFromUrl", currentData.projects[currentID].repoURL)
	local scriptSha = account:action("getFileSHA", repoName,firstName..".lua")
	
	account:action("deleteFile", repoName,firstName..".lua", scriptSha)
	currentData.projects[currentID].scripts[getUUID(newScript)] = nil
end

function findMapScripts()
	for _, scriptDocument in ScriptEditorService:GetScriptDocuments() do
		if not scriptDocument:IsCommandBar() then		
			currentData.projects[currentID].scripts[getUUID(scriptDocument:GetScript())] = nil
		end
	end
end

function sync(newScript : Instance)
	if newScript:IsA("LocalScript") or newScript:IsA("Script") or newScript:IsA("ModuleScript") then
		newScript:GetPropertyChangedSignal("Name"):Connect(function()
			if currentData.projects[currentID] == nil then return end
			if currentData.projects[currentID].scripts[getUUID(newScript)] == nil then warn(currentData.projects[currentID].scripts[getUUID(newScript)]) return end
			deleteScript(newScript)
			overrideUUID(newScript)
			addScript(newScript)
		end)
	
		newScript.Destroying:Connect(function()
			if currentData.projects[currentID] == nil then return end
			if currentData.projects[currentID].scripts[getUUID(newScript)] == nil then warn(currentData.projects[currentID].scripts[getUUID(newScript)]) return end
			deleteScript(newScript)
		end)

		documents = ScriptEditorService:GetScriptDocuments()
	end
end

function map(location)
	location.DescendantAdded:Connect(function(newScript)
		sync(newScript)
	end)
	
	for _, newScript in pairs(location:GetDescendants()) do
		sync(newScript)
	end
end

local debugCmd = scriptEditor.newcmd("--bloxo debug")
local loginCmd = scriptEditor.newcmd("--bloxo login")

local saveallCmd = scriptEditor.newcmd("--bloxo saveall")
local updateallCmd = scriptEditor.newcmd("--bloxo updateall")
local saveCmd = scriptEditor.newcmd("--bloxo save")
local createCmd = scriptEditor.newcmd("--bloxo create")
local deleteCmd = scriptEditor.newcmd("--bloxo delete")

deleteCmd.commandExecuted:Connect(function(document : ScriptDocument, positionLine : number, positionCharacter : number)
	if currentData.projects[currentID] == nil then return end
	if currentData.projects[currentID].scripts[getUUID(document:GetScript())] == nil then warn(currentData.projects[currentID].scripts[getUUID(document:GetScript())]) return end

	deleteScript(document:GetScript())
	removeUUID(document:GetScript())
	
	deleteCmd.msg(document, positionLine-1, "--File removed with success from the repo")
end)

createCmd.commandExecuted:Connect(function(document : ScriptDocument, positionLine : number, positionCharacter : number)
    local text = document:GetLine(positionLine-1)
	local _, start  = string.find(text, "--bloxo create ")

	if start ~= nil then
		local answer = string.sub(text, start+1, string.len(text))
		
		if answer == nil then debugCmd.msg(document, positionLine-1, "--Name is not valid, try again.") return end
		if string.len(answer) < 2 then debugCmd.msg(document, positionLine-1, "--Name is not valid, try again.") return end
		if game.PlaceId == (0 or nil or "") then debugCmd.msg(document, positionLine-1, "--Place must be saved to Roblox first to work.") return end
		if currentData.projects[currentID] ~= nil then debugCmd.msg(document, positionLine-1, "--Repo already exists for this place, you can already start saving") return end

		local result = account:action("createRepository", answer ,"Github repo for "..game.Name.. ", created by ".. game.Players:GetNameFromUserIdAsync(game.CreatorId), false)
		
		if result ~= nil then
			print(result)
			currentData.projects[currentID] = table.clone(projectTemplate)
			currentData.projects[currentID].repoURL = result.html_url
			
			save()
			
			debugCmd.msg(document, positionLine-1, "--Repo created with success! You can find it at "..result.html_url)
		else
			debugCmd.msg(document, positionLine-1, "--Github error : make sure that you are using an unique name.")
		end
	end
end)

debugCmd.commandExecuted:Connect(function(document : ScriptDocument, positionLine : number, positionCharacter : number)
	debugCmd.msg(document, positionLine-1, "--Debugged with success in the Output")
	print(currentData)
end)

saveCmd.commandExecuted:Connect(function(document : ScriptDocument, positionLine : number, positionCharacter : number)
	local s = addScript(document:GetScript())
	
	if s ~= nil then
		saveCmd.msg(document, positionLine-1, "-- Script saved to Github correctly!")
	else
		saveCmd.msg(document, positionLine-1, "-- Save failed. Github error")
	end
end)

saveallCmd.commandExecuted:Connect(function(document : ScriptDocument, positionLine : number, positionCharacter : number)
	local cache = 0

	for _, location : Instance in pairs(GameLocations) do
		local total = #location:GetDescendants()

		for _, code : Instance in pairs(location:GetDescendants()) do
			if code:IsA("Script") or code:IsA("LocalScript") or code:IsA("ModuleScript") then
				local success = addScript(code)

				if success ~= "" or success ~= nil or success ~= {} then
					cache += 1
				end
			end

			saveallCmd.msg(document, positionLine-1, "")
			saveallCmd.msg(document, positionLine-1, "--Saving in progress. "..tostring(cache))

			wait()
		end
	end
	
	saveallCmd.msg(document, positionLine-1, "--Scripts of your game were saved correctly")
end)

updateallCmd.commandExecuted:Connect(function(document : ScriptDocument, positionLine : number, positionCharacter : number)
	local cache = 0

	for _, location : Instance in pairs(GameLocations) do
		for _, code : Instance in pairs(location:GetDescendants()) do
			if code:IsA("Script") or code:IsA("LocalScript") or code:IsA("ModuleScript") then
				if hasUUID(code) == true then
					local success = addScript(code)

					if success ~= "" or success ~= nil or success ~= {} then
						cache += 1
					end
				end
			end

			updateallCmd.msg(document, positionLine-1, "")
			updateallCmd.msg(document, positionLine-1, "--Saving in progress. "..tostring(cache))

			wait()
		end
	end

	updateallCmd.msg(document, positionLine-1, "--Scripts of your game were saved correctly")
end)

loginCmd.commandExecuted:Connect(function(document : ScriptDocument, positionLine : number, positionCharacter : number)
	local previousText= document:GetLine(positionLine-1)
	
	if string.find(previousText, "--bloxo login")  then
		local newString = string.sub(previousText, 15, string.len(previousText))

		if account:login(newString) then

			--update data

			currentData.currentToken = newString
			currentData.currentUser = github.getGitHubUsername(newString)

			save()

			saveallCmd.msg(document, positionLine-1, "--Logged in with success")
		else
			saveallCmd.msg(document, positionLine-1, "--Login failed, token invalid")
		end							
	end
end)

task.spawn(function()
	while wait(15) do
		save()
	end
end)