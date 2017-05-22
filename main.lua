--[[
ADRIAN ALBERTO
adrian@whitecollargames.com

NOTE: Problem should've specified that pipes can't run alongside themselves. Implementing this
      cut me down from ~300^5 solutions to check to ~10^5 per problem.

      Also this is an easily google-able problem.
]]


function main()
	local file = io.open("zapposCodeChallenge.txt")
	local inputting = false
	for line in file:lines() do
		if line == "Input:" then
			inputting = true
		elseif inputting then
			--print(line)
			local wid, hgt = string.match(line, "(%d+)%s+(%d+)")
			if wid and hgt then
				--BEGIN READING GRID IN
				local grid = {}
				for i = 1, hgt do
					grid[i] = {}
					for x in string.gmatch(file:read("*l"), ".") do
						table.insert(grid[i], x)
					end
				end

				solveGrid(grid)


				print("\n======\n")
				
			end
		end
	end
end

function solveGrid(grid)
	local gridstate = {} --current state
	local charsleft = {} -- if a char needs solving, charsleft[char] will be true (HACKY)
	local cl2 = {}

	--reconvert to single array because i'm an idiot
	for y, row in pairs(grid) do
		for x, char in pairs(row) do
			if char ~= "." then
				gridstate[tolinear(x,y)] = char
				if not charsleft[char] then
					charsleft[char] = true
					table.insert(cl2, char)
				end
			end
		end
	end


	print("input:")
	printstate(gridstate)
	print("\noutput:")

	--Generate all possible paths for each color
	local CHARPATHS = {}
	for _, c in pairs(cl2) do
		local paths = getAllPaths(gridstate, c)
		local paths2 = {}
		for ____, p in pairs(paths) do
			local good = true
			for __, c2 in pairs(cl2) do
				if c2 ~= c then
					if not getAllPaths(p, c2, true) then
						good = false
						break
					end
				end
			end
			if good then
				table.insert(paths2, p)
			end
		end
		CHARPATHS[c] = paths2
	end

	gridstate.length = 0
	local Q = {{gridstate, 1}}

	--Mash paths together until you get something
	while #Q > 0 do
		local ppair = table.remove(Q, 1)
		local path = ppair[1]
		local char_i = ppair[2]
		local char = cl2[char_i]

		if not char then
			print("failed")
			break
		end

		for i, path2 in pairs(CHARPATHS[char]) do
			local path3, count = cross(path, path2)
			if path3 then
				if count == 36 and char_i <= #cl2 +1 then
					--FOUND SOLUTION
					printstate(path3)
					return
				else
					table.insert(Q, {path3, char_i+1})
				end
			end
		end
	end



end

function tolinear(x, y, wid, hgt)
	wid = wid or 6
	hgt = hgt or 6
	if x <= 0 or x > wid or y <= 0 or y > wid then
		return nil
	end
	return (y-1)*wid + x
end

function to2d(n, wid, hgt)
	wid = wid or 6
	hgt = hgt or 6
	local y = math.ceil(n / wid)
	local x = ((n-1) % wid) + 1
	return x, y
end

function getAllPaths(state, char, GETANY)
	local paths = {}
	local dupcheck = {}
	--print("Finding paths for: " .. p_start .. ", " .. p_end .. ",   " .. char)
	---printstate(state)


	local p_start
	local p_goal
	for i = 1, 36 do
		if state[i] == char then
			if not p_start then
				p_start = i
			elseif not p_goal then
				p_goal = i
				break
			end
		end
	end


	local q = {}
	function push2(state, head)
		--head is the most recently placed node
		local state2 = setmetatable({}, {["__index"] = state})
		state2[head] = char
		--printstate(state2)
		table.insert(q, {state2, head})
	end

	push2(state, p_start)

	while #q > 0 do
		curstate = table.remove(q, 1)
		local state = curstate[1]
		local headx, heady = to2d(curstate[2])
		local nexts = {tolinear(headx, heady+1), tolinear(headx, heady-1), tolinear(headx-1, heady), tolinear(headx+1, heady)}
		for i, n in pairs(nexts) do
			if not state[n] then
				--make sure not touching any other pipe
				local good = true
				local curx, cury = to2d(n)
				local nexts2 = {tolinear(curx, cury+1), tolinear(curx, cury-1), tolinear(curx-1, cury), tolinear(curx+1, cury)}
				for j, n2 in pairs(nexts2) do
					if n2 ~= curstate[2] then
						if state[n2] == char and n2 ~= p_goal then
							good = false
							break
						end
					end
				end
				if good then
					push2(state, n)
				end
			elseif state[n] == char and n == p_goal then
				if GETANY then
					return true
				end

				local compressed = ""
				for j = 1, 36 do
					compressed = compressed .. (state[j] or " ")
				end
				if not dupcheck[compressed] then
					dupcheck[compressed] = true
					state["length"] = length(state, char)
					table.insert(paths, state)
				end
			end
		end
	end

	if GETANY then
		return false
	end

	return paths
end

function cross(state1, state2)
	--[[if state1.length + state2.length > 36 then
		return false
	end]]
	local state3 = {}
	local count = 0
	for i = 1, 36 do
		if (state1[i] and state2[i] and state1[i] ~= state2[i]) then
			--printstate(state1)
			--printstate(state2)
			return
		else
			state3[i] = state1[i] or state2[i]
			if state3[i] then
				count = count + 1
			end
		end
	end
	state3.length = count
	return state3, count
end

function length(state, char)
	len = 0
	local start = {}
	local ends = {}
	for i = 1, 36 do
		if state[i] == char then
			--not actual starts and ends, just for checking length

			len = len + 1
			
		end
	end
	return len
end

function printstate(state)
	local test = ""
	for i = 1, 36 do
		if (i-1) % 6 == 0 and i > 1then
			test = test .. "\n"
		end
		test = test .. (state[i] or ".")
	end
	print(test)
end
main()