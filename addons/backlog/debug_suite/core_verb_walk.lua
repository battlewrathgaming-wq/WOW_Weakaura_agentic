-- addons/COA_DungeonRun/core.lua:199-213 at ac41961

    elseif cmd == "walk" then
        local W = NS.Walk
        if rest == "" or rest == "stop" then
            W.Stop()
            NS.Say("walk stopped")
        else
            -- ★ §95: the report lives in Walk, because the promoter's play says the
            -- same thing and two copies would be two things that must agree.
            local lines, err = W.StartLines(rest)
            if not lines then
                NS.Say("could not walk: " .. tostring(err))
            else
                for _, l in ipairs(lines) do NS.Say(l) end
            end
        end
