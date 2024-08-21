--bloxo save



--gianfragolo was here, founder of bloxo

local function base64Encode(data)
	local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	return ((data:gsub('.', function(x) 
		local r, b = '', x:byte()
		for i = 8, 1, -1 do r = r .. (b % 2^i - b % 2^(i-1) > 0 and '1' or '0') end
		return r;
	end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
		if (#x < 6) then return '' end
		local c = 0
		for i = 1, 6 do c = c + (x:sub(i,i) == '1' and 2^(6-i) or 0) end
		return b:sub(c+1,c+1)
	end)..({ '', '==', '=' })[#data%3+1])
end

local HttpService = game:GetService("HttpService")

local git = {}


function git.new()
local new = setmetatable({} , git)
new.githubToken = ""

	function new:login(token : string)
		if git.isTokenValid(token) then
			new.githubToken = token
			return true
		else
			return false
		end
	end

	function new:action(action, ...)
		if git[action] ~= nil then
			return git[action](new.githubToken, ...)
		end
	end

	return new
end

function git.getFileSHA(token, repoName, filePath)
	local user = git.getGitHubUsername(token)
	local url = "https://api.github.com/repos/"..user.."/"..repoName.."/contents/" .. filePath

	local headers = {
		["Authorization"] = "token " .. token,
	}

	local success, response = pcall(function()
		return HttpService:GetAsync(url, false, headers)
	end)

	if success then
		local data = HttpService:JSONDecode(response)
		return data.sha
	else
		warn("Failed to retrieve the SHA for file:", filePath, response)
		return nil
	end
end

function git.deleteFile(token, repoName, path, sha)
	local user = git.getGitHubUsername(token)
	local headers = {
		["Authorization"] = "token " .. token,
	}
	local endpoint2 = "https://api.github.com/repos/"..user.."/"..repoName.."/contents/" .. path
	local body = {
		message = "Deleted old file " .. path,
		sha = sha
	}

	local success, response = pcall(function()
		return HttpService:RequestAsync({
			Url = endpoint2,
			Method = "DELETE",
			Headers = headers,
			Body = HttpService:JSONEncode(body)
		})
	end)

	if success then
		local jsonResponse = HttpService:JSONDecode(response.Body)
	else
		warn("Failed to delete old file")
	end
end

function git.createRepository(token, name, description, isPrivate)
	local url = "https://api.github.com/user/repos"
	local headers = {
		["Authorization"] = "token " .. token,
	}
	print("name is "..name)
	local body = {
		name = name,
		description = description,
		private = isPrivate
	}

	local success, response = pcall(function()
		return HttpService:PostAsync(url, HttpService:JSONEncode(body), Enum.HttpContentType.ApplicationJson, false, headers)
	end)

	if success then
		local data = HttpService:JSONDecode(response)
		return data
	else
		warn("Failed to create repository: " .. response)
		return nil
	end
end

function git.isRepoValid(token, repoOwner, repoName)
	repoOwner = repoOwner or "ciabalaiz" 
	local url = "https://api.github.com/repos/" .. repoOwner .. "/" .. repoName
	local headers = {
		["Authorization"] = "token " .. token,
	}

	local success, response = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = "GET",
			Headers = headers
		})
	end)

	if success then
		local statusCode = response.StatusCode
		if statusCode == 200 then
			return true
		else
			return false
		end
	else
		warn("Failed to validate repository: " .. response)
		return false
	end
end


function git.createFile(token, repoName, filePath, content, commitMessage)
	local user = git.getGitHubUsername(token)
	local url = "https://api.github.com/repos/" .. user .. "/" .. repoName .. "/contents/" .. filePath
	local headers = {
		["Authorization"] = "token " .. token,
	}

	local body = {
		message = commitMessage,
		content = base64Encode(content) -- Content must be base64 encoded
	}

	local success, response = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = "PUT",
			Headers = headers,
			Body = HttpService:JSONEncode(body)
		})
	end)

	if success then
		local data = HttpService:JSONDecode(response.Body)

		return data
	else
		warn("Failed to create file: " .. response)
		return nil
	end
end

function git.updateFile(token, repoName, filePath, newContent, commitMessage, sha)
	local user = git.getGitHubUsername(token)
	local url = "https://api.github.com/repos/" .. user .. "/" .. repoName .. "/contents/" .. filePath
	local headers = {
		["Authorization"] = "token " .. token,
		["Content-Type"] = "application/json"
	}

	local body = {
		message = commitMessage,
		content = base64Encode(newContent), -- Content must be base64 encoded
		sha = sha -- SHA of the file to be updated
	}

	local success, response = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = "PUT",
			Headers = headers,
			Body = HttpService:JSONEncode(body)
		})
	end)

	if success then
		local data = HttpService:JSONDecode(response.Body)
		return data
	else
		warn("Failed to update file: " .. response)
		return nil
	end
end

local function getRepoContents(token, user, name, path)
	local url = "https://api.github.com/repos/" .. user .. "/" .. name .. "/contents/" .. (path or "")
	local headers = {
		["Authorization"] = "token " .. token,
	}

	local success, response = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = "GET",
			Headers = headers
		})
	end)

	if success then
		local data = HttpService:JSONDecode(response.Body)
		return data
	else
		warn("Failed to get repository contents: " .. response)
		return nil
	end
end


function git.getGitHubUsername(token)

	local url = "https://api.github.com/user"
	local headers = {
		["Authorization"] = "token " .. token,
	}

	local success, response = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = "GET",
			Headers = headers
		})
	end)

	if success then
		local data = HttpService:JSONDecode(response.Body)
		return data.login -- The 'login' field contains the username
	else
		warn("Failed to get GitHub username: " .. response)
		return nil
	end
end

function git.clone(token, user, name)
	local function downloadContents(path)
		local contents = getRepoContents(user, name, path)
		local data = {}

		if contents then
			for _, item in ipairs(contents) do
				if item.type == "file" then
					if string.find(item.path, ".lua") ~= nil then
						table.insert(data, item)	
					end
				elseif item.type == "dir" then
					downloadContents(item.path)
				end
			end
		end

		return data
	end

	return downloadContents("")
end

function git.isTokenValid(tok)

	local url = "https://api.github.com/user"
	local headers = {
		["Authorization"] = "token " .. tok,
	}

	local success, response = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = "GET",
			Headers = headers
		})
	end)

	if success then
		local statusCode = response.StatusCode
		if statusCode == 200 then
			return true
		else
			return false
		end
	else
		return false
	end
end

function git.getRepoNameFromUrl(token, repoUrl)
	local repoName = string.match(repoUrl, "https://github.com/[^/]+/([^/]+)")
	if repoName then

		return repoName
	else

		return nil
	end
end

function git.downloadFileContent(token, url)
	local success, fileContent = pcall(function()
		return HttpService:GetAsync(url)
	end)
	if success then
		return fileContent
	else
		warn("Failed to download file content from: " .. url)
		return nil
	end
end


return git
