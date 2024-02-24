--
local ignoreMultipleDecimalPoints = false
--

local module = {}
local baseNumbers = {
	[0] = "零", -- called rei but also can be in katakana as literally ze-ro, will never be used with any tens
	[1] = "一",
	[2] = "二",
	[3] = "三",
	[4] = "四",
	[5] = "五",
	[6] = "六",
	[7] = "七",
	[8] = "八",
	[9] = "九",	
	["Phoneme1"] = "いっ",  
	["Phoneme8"] = "はっ",
}
local decimalUnits = {
	[1] = "わり",
	[2] = "ぶ",
	[3] = "ん"
}
local higherNumbers = {
	[10] = "十",
	[100] = "百",
	[1000] = "千",
	[10000] = "万",
	[100000] = "十万",
	[1000000] = "百万",
	[10000000] = "千万",
	[100000000] = "億"
}
local highestNumber --= 999999999;

function calculateHighestIntegerAllowed()
	local largestIntegerPossible
	for index, _ in pairs(higherNumbers) do
		largestIntegerPossible = largestIntegerPossible and math.max(index, largestIntegerPossible) or index
	end
	largestIntegerPossible *= 9.9
	return largestIntegerPossible
end
highestNumber = calculateHighestIntegerAllowed();

local function convertNumbers(stringNumber, actualNumber, phonemeBool) -- convert digits
	
	local stringLength = string.len(stringNumber) -- the string length
	if not baseNumbers[stringLength] or higherNumbers[stringLength] then
		warn("Given number "..stringNumber.." is too large for translation. Largest allowed number at the moment: "..highestNumber)
		return
	end
	if stringLength == 1 then -- if numbers 0-9
		return baseNumbers[actualNumber]
	end
	local indexPower = 10^(-1 + stringLength)
	local finalString = ""
	local lowerPower = indexPower
	local lowerPowerIndex
	
	local numberLimit, oneHundredThousandPlus
	if stringLength <= 5 then
		numberLimit = stringLength
	elseif stringLength > 5 then
		numberLimit = 5
		oneHundredThousandPlus = true
	end
	for i = 1, numberLimit do
		local sub = string.sub(stringNumber, i, i)
		local subToNumber = tonumber(sub)
		if i ~= stringLength and subToNumber ~= 0 then
			if subToNumber > 1 then
				finalString = finalString..baseNumbers[subToNumber]
			end
			if lowerPower >= 10 then
				lowerPowerIndex = higherNumbers[lowerPower]
				finalString = finalString..lowerPowerIndex
			end
			
			lowerPower = lowerPower * 0.1
		end
		if i == stringLength then
			if subToNumber ~= 0 then
				local findLastDigit = phonemeBool == true and baseNumbers["Phoneme"..subToNumber] or baseNumbers[subToNumber]
				finalString = finalString..findLastDigit
			end
		end
	end
	return finalString
end

function module:NumberToJapanese(givenNumber)
	if type(givenNumber) ~= "string" and type(givenNumber) ~= "number" then
		return -- guard clause if the given value wasn't even text or number
	end
	if type(givenNumber) ~= "string" then
		givenNumber = tostring(givenNumber) -- converts to a string automatically
	end
	if string.find(givenNumber, "[^%d%s%.,%%]+") then -- if anything other than "%", whitespace characters, " ", number digits are found.
		if string.find(givenNumber, "/") then
			warn("This version of Latin numbers to Japanese form does not support fractions at the moment.")
		end
		return -- more guard clauses
	end
	local percentageSymbolFound = string.find(givenNumber, "%%")
	if percentageSymbolFound then
		if percentageSymbolFound ~= string.len(givenNumber) then
			warn("Cannot have the percentage symbol before the end of the number.")
			return
		end
		local percentageSymbolsFound = 0
		for _ in string.gmatch(givenNumber, "%%") do
			percentageSymbolsFound = percentageSymbolsFound + 1
			if percentageSymbolsFound >= 2 then
				warn("Number can only have one percentage symbol for translation.")
				return
			end
		end
		givenNumber = string.gsub(givenNumber, "%%", "") -- cut percentage signs out
	end
	givenNumber = string.gsub(givenNumber, "%s+", "") -- cut whitespace characters out
	givenNumber = string.gsub(givenNumber, ",", "") -- if there are commas for example: 1,000,000 or 100,000
	if not ignoreMultipleDecimalPoints then
		local decimalCount = 0
		for _ in string.gmatch(givenNumber, "%.") do -- find only periods/dots
			decimalCount = decimalCount + 1
			if decimalCount >= 2 then
				warn("Attempted to translate a number that has more than one decimal point.")
				return
			end
		end
	end
	local finalJapaneseNumber = ""
	local split = string.split(givenNumber, ".")
	for i, v in pairs(split) do
		local nextValue = split[i + 1]
		if not string.match(v, "[^0%s]+") and nextValue then
			for subIndex = 1, #nextValue do
				local indexSub = tonumber(string.sub(nextValue, subIndex, subIndex))
				local getBaseNumber = baseNumbers[indexSub]
				finalJapaneseNumber = finalJapaneseNumber..getBaseNumber..(decimalUnits[math.log10(10^i)] or "")
			end
			break
		end
		finalJapaneseNumber = finalJapaneseNumber..convertNumbers(v, tonumber(v), nextValue ~= nil and true)
		if nextValue then
			finalJapaneseNumber = finalJapaneseNumber.."ーてん"
		end
	end
	if percentageSymbolFound then
		finalJapaneseNumber = finalJapaneseNumber.."パーセント" -- percent
	end
	return finalJapaneseNumber
end

return module