local ScriptEditorService = game:GetService("ScriptEditorService")
local Signal = require(script.Parent:WaitForChild("Signal"))
local scriptEditor = {}

scriptEditor.__index = scriptEditor
scriptEditor.openDocuments =ScriptEditorService:GetScriptDocuments()
scriptEditor.openCommands = {} 
scriptEditor.lineEntered = Signal.new()
scriptEditor.menu = nil

export type cmd = {commandExecuted : Signal ; commandName:string; msg : {}}
export type menu = {menuAnswered : Signal ; menuName:string; finished : Signal; current : number; cOptions : {}}

function scriptEditor.newcmd(command : string) : cmd
	local cmd  = setmetatable({}, scriptEditor)
	
	cmd.commandExecuted = Signal.new()
	cmd.commandName = command
	
	function cmd.msg(document : ScriptDocument, line : number, message : string)
		local s, e = pcall(function() document:EditTextAsync(message,line,1,line,string.len(message)) end)
		if s == false then warn(e) end return s
	end
	 
	table.insert(scriptEditor.openCommands, cmd)
	
	return cmd
end

function scriptEditor.removecmd(cmd : cmd)
	if table.find(scriptEditor.openCommands, cmd) then
		table.remove(scriptEditor.openCommands, table.find(scriptEditor.openCommands, cmd))
	end
end


local function sync(document)
	document.SelectionChanged:Connect(function(positionLine, positionCharacter, anchorLine, anchorCharacter)
		local currentText = document:GetLine(positionLine)
		
		if document:GetScript().Name == script.Parent.Name then return end

		if positionLine ~= 1 then
			local previousText = document:GetLine(positionLine - 1)

			scriptEditor.lineEntered:Fire(positionLine)

			for _, cmd : cmd in pairs(scriptEditor.openCommands) do
				if cmd.commandName == previousText then
					cmd.commandExecuted:Fire(document, positionLine, positionCharacter)
				elseif string.find(previousText, cmd.commandName) then
					cmd.commandExecuted:Fire(document, positionLine, positionCharacter)
				end
			end
		end
	end)
end

game.DescendantAdded:Connect(function()
	scriptEditor.openDocuments = ScriptEditorService:GetScriptDocuments()
end)

ScriptEditorService.TextDocumentDidOpen:Connect(function(document)
	sync(document)
end)

for _, document in pairs(scriptEditor.openDocuments) do
	sync(document)
end

return scriptEditor
