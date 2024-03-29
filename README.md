# Number-to-Japanese-Kanji-Conversion

Made in May 2020

A number to Japanese Kanji conversion that supports percentages and decimals. Goes up to 999,999,999 only.
I was learning Japanese along the same time and wanted to do something fun using Roblox Lua and I was also
learning string manipulation and regex along the same time.

![](https://github.com/codeponics/Number-to-Japanese-Kana-Conversion/blob/main/JapaneseNumbers-ezgif.com-video-to-gif-converter.gif)

## How to use

Here's an example of connecting to a RemoteFunction where you might have the GUI communicate.
(Yes, you can just instead require inside a local script if you'd like.)
```lua
local module = require(game.ServerScriptService.JapaneseNumbersModule) -- arbritrary place, change this
local funcRemote = game.ReplicatedStorage.ConvertToJapanese -- RemoteFunction for frontend communication

function convert(_, text)
	local success, result = pcall(function()
		return module:NumberToJapanese(text) -- text: string
	end)
    return success and result or nil
end

funcRemote.OnServerInvoke = convert
```

## Extra

I initially planned to create a Japanese Kanji to number back conversion and also a number to Hiragana version.
But, I just wanted to flex off knowing Japanese numbers, and left it there.

Additionally, Hiragana wouldn't be too useful either because I would just rewrite the kanji to their hiragana forms.
As well as the fact that 4,7,9 can be pronounced differently in Japanese sometimes which wouldn't preserve the
unambiguous readability of a kanji number (or even just an English number for that matter, but that of course defeats the purpose of the fun project).

## License
MIT License