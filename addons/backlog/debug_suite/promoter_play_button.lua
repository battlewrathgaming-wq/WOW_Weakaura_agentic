-- addons/COA_DungeonRun/promoter.lua:408-435 at ac41961

    -- ★★★ §95: A PLAY BESIDE THE ROUTE. His: *"bake it into promotion. Select
    -- route. Then a play next to it."* It also makes the instrument DISCOVERABLE - a
    -- slash command you have to already know is not a surface.
    --
    -- ★ It reports through Walk.StartLines, the same call the slash uses, so the two
    -- entrances cannot say different things.
    playBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    playBtn:SetWidth(52); playBtn:SetHeight(20)
    -- ★ 258, clear of the dropdown's ART at 252 - not its FIELD at 202. His:
    -- *"the content field, and the click drop-down art, that reacts, aren't the
    -- same thing."* 258 + 52 = 310, ten inside a 320 pane.
    playBtn:SetPoint("TOPLEFT", 258, -78)
    playBtn:SetScript("OnClick", function()
        local W = NS.Walk
        if W.IsRunning() then
            W.Stop()
            NS.Say("walk stopped")
        else
            local lines, err = W.StartLines(Map.LoadedId("route"))
            if not lines then
                NS.Say("could not walk: " .. tostring(err))
            else
                for _, l in ipairs(lines) do NS.Say(l) end
            end
        end
        refresh()
    end)

