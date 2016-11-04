--Copyright 2016 Anton Petrochenko

--This program is free software: you can redistribute it and/or modify
--it under the terms of GNU General Public License version 2 as published
--by the Free Software Foundation

--This program is distributed WITHOUT ANY WARRANTY; without even the implied
--warranty of MERCHANTIBILITY or FITNESS FOR A PARTICULAR PURPOSE.
--See GNU General Public License for more details.

--You should have recieved a copy of GNU General Public License
--along with this program. If not, see http://www.gnu.org/licenses

require "string"
hammerver = "0.9.1"
execd = 0


print("MetoolDaddy's Hammertime Panel")
print("Running v"..hammerver)
dofile("hammertime.conf")
votebalance = 0
target = ""
word = "a dummy string, hey"
input = {} --Dummy table, hey
hasvoted = {} --For callvote
capswarnlevel = {}
wordwarnlevel = {}
knownip = {}
schedmes = 0
dofile("perms.lua") --Loading various permissions
function inc(var,amt)
if amt then return var + amt else return var + 1 end
end

function parse()
	if execd == 0 then
		input = {}
		tid = -3
		if ninput == oinput then return nil end
		oinput = ninput --Failsafe
		for word in string.gmatch(ninput,"%S+") do
			tid = inc(tid)
			if tid > 0 then input[tid] = word end
		end
	end
end

function bash(cmd)
	local f = assert(io.popen(cmd, 'r'))
	local s = assert(f:read('*a'))
	f:close()
	s = string.gsub(s, '^%s+', '')
	s = string.gsub(s, '%s+$', '')
	s = string.gsub(s, '[\n\r]+', ' ')
	return s
end
function sleep(t)
	while n < t do n=inc(n) end
	n=0
end


function exec(cmd,t) --All it does is prepare a minecrafty input for bash function
	print(cmd)
	bash("screen -S " .. session .. " -X stuff '" .. cmd .. "\\n'")
	return nil
end

--Quality of life things
function command() return input[2] end
function player()
	if input[1] == nil then input[1] = "Failsafe" end
	input[1] = string.gsub(input[1],"<","")
	input[1] = string.gsub(input[1],">","")
	input[1] = string.gsub(input[1],"§[a-f0-9]","")
	input[1] = string.gsub(input[1],"§r","")--Yeah ;-;
 	return input[1]
end
function argument(arg) return input[arg+2] end

session = bash("screen -ls | grep " .. server_name .. " | awk '{print $1}'") --Getting screen session name


math.randomseed( os.time() )
caps = 0
lcase = 0
halted = 1
voted = {}
print("Session is " .. session)
n = 0


while debug == 1 do



end

while "True" do --------------------------------------------- OH GAWD FINALLY THE INFINITE LOOP SECTION
sleep(100000)
execd = 0 --idk
ninput = bash("tail -1 " .. server_path .. "logs/latest.log")
parse()


--Vhguide
if command() == namespace then
	if argument(1) == "callvote" then initvote = 1 end
	if argument(1) == "apt-get" and argument(2) == "moo" then exec("/summon Cow 0 300 0") end
	if argument(1) == "vote" then--for voteban
		if hasvoted[player()] ~= nil then exec("/msg " .. player() .. " You have already voted") else
			if argument(2) == "yes" then votebalance=votebalance + 1 hasvoted[player()] = 1 exec("/say " .. player() .. " voted YES (" .. votebalance .. ")") end
			if argument(2) == "no" then votebalance=votebalance - 1 hasvoted[player()] = 1 exec("/say " .. player() .. " voted NO (" .. votebalance .. ")") end
			if argument(2) == "fail" and callvoteperm[player()] == 2 then votebalance=-9001 exec("/say " .. player() .. " voted VERY NO (" .. votebalance .. ")") end
		end
	end
end

if command() == "hammertime" then
	if argument(1) == "reloadconfig" then dofile("hammertime.conf") exec("/say Config reloaded") end
	if argument(1) == "reloadperms" then dofile("perms.lua") exec("/say Permissions reloaded") end
	if argument(1) == "about" then exec("/say Hammertime Panel v" .. hammerver) exec("/say Written in Lua by MetoolDaddy") exec("/say Have you apt-get moo today?") end

end

--Movement messages (fly, speed, etc)
if enable_movement_messages > 0 then
	flyingman = bash("tail -3 logs/latest.log | grep floating | awk '{print $4}'")
	if flyingman ~= "" then exec("/msg @a[tag=servernotice] " .. flyingman .. " was kicked for flying!") sleep(1000000) end
	if enable_movement_messages > 1 then
		if command() == "moved" and argument(1) == "wrongly!" then exec("/msg @a[tag=" .. warning_message_tag .. "] " .. player() .. " is moving suspiciously") sleep(100000) end
		if command() == "moved" and argument(1) == "too" then exec("/msg @a[tag=" .. warning_message_tag .. "] " .. player() .. " moved too fast") end
	end
end

--Voteban
if initvote == 1 and votetime == nil then
	initvote = 0
	votebalance = 0
if argument(2) == "kick" or argument(2) == "ban" then
	if argument(3) == nil then
		exec("/msg " .. player() .. " Incorrect syntax - missing target name")
	elseif callvoteperm[player()] ~= nil then
			hasvoted = {}
			starttime = os.time()
			target = argument(3)
			if argument(2) == "ban" then
				votetime = ban_duration exec("/say Vote ban brought up for " .. target)
				banvote = 1
			else
				votetime = kick_duration exec("/say Vote kick brought up for " .. target)
				banvote = 0
			end
			exec("/say Vote with §bvhguide §bvote §byes/no")
		else exec("/say Insufficient permissions")
	end
end
end
if votetime then
--print(os.time() .. " " .. starttime+votetime)
if os.time() > starttime + votetime then votetime = nil
	hasvoted = {}
	if votebalance > 0 then
	exec("/say Vote passed")
	if banvote == 1 then exec("/say Banning " .. target) exec("/ban " .. target .. " " .. ban_message) else exec("/say Kicking " .. target) exec("/kick " .. target .. " " .. kick_message) end
	else
	exec("/say Vote failed")
	end
	votebalance = 0
end
end
if enable_caps_protection == 1 then
	ninput = string.gsub(ninput,"^.*>","")
	for letter in string.gmatch(ninput,"%u") do if letter ~= "" then caps = caps + 1 end end
	for letter in string.gmatch(ninput,"%l") do if letter ~= "" then lcase = lcase + 1 end end
	if caps > lcase and player() ~= "Failsafe" then
		print(ninput)
		exec("msg " .. player() .." Less caps, " .. player())
		if capswarnlevel[player()] == nil then capswarnlevel[player()] = 0 end
		capswarnlevel[player()] = capswarnlevel[player()] + 1
		if capswarnlevel[player()] > caps_kick_threshold and caps_kick_treshold ~= 0 then
			exec("/kick " .. player() .. " Tone down the caps.")
			capswarnlevel[player()] = 0
		end
	end
end
lcase = 0
caps = 0

if word_filter_mode > 0 then
	ninput = string.gsub(ninput,"^.*>",""
	if wordwarnlevel[player()] == nil then wordwarnlevel[player()] = 0 end


	if word_filter_mode == 2 then
		for index,word in pairs(banned_words) do

			local linput = string.lower(ninput)
			local lword = string.lower(word)
			if string.find(linput,lword) and player() ~= "Failsafe" then exec("msg ".. player() .. " Bad words, " .. player()) wordwarnlevel[player()] = wordwarnlevel[player()] + 1
			end

		end
	end

	if word_filter_mode == 1 then
		for index,word in pairs(banned_words) do
			for key,input in pairs(input) do

			if string.lower(input) == string.lower(word) and player() ~= "Failsafe" then exec("msg " .. player() .. " Bad words, " .. player()) wordwarnlevel[player()] = wordwarnlevel[player()] + 1
			end

			end
		end
	end

		if wordwarnlevel[player()] > word_kick_threshold then exec("kick " .. player() .. " Watch what you are saying.") wordwarnlevel[player()] = 0
		end
end


if enable_ip_notifications == 1 and command() == "joined" and argument(1) == "the" and argument(2) == "game" then
ninput = bash("tail -n 2 " .. server_path .. "logs/latest.log | grep 'logged in with'")
parse()
ninput = nil
if command() == "logged" and argument(1) == "in" and argument(2) == "with" then




ip = string.match(ninput,"%[/(.*):")
name = string.gsub(input[1],"%[(%A+)","")

exec("msg @a[tag=servernotice] " .. name .. " joined with IP " .. ip)

--Three situations : IP is not known, IP is known and belongs to NAME, IP is known and doesn't belong to NAME
--Second situation doesn't require threatment

if knownip[ip] == nil then knownip[ip] = name print("Remembered", ip, name) end --Remembered IP as NAME's ip
if knownip[ip] ~= name and knownip[ip] ~= nil then --IP is known and doesn't belong to NAME, shit is deep
	schedmes = 5
end
end


end

schedmes = schedmes - 1
if schedmes == 0 then
exec("/msg @a[tag=" .. warning_message_tag .. "] " .. name .. " and " .. knownip[ip] .. " IPs match ")
print("Warning", name, ip, knownip[ip])
schedmes = -1
end
end; --for while true
