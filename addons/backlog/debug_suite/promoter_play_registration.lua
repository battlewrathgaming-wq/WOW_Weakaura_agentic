-- addons/COA_DungeonRun/promoter.lua:482-483 at ac41961

        R("promoter.play", playBtn, { kind = "button",
            read = function() return NS.Walk and NS.Walk.IsRunning() end })
