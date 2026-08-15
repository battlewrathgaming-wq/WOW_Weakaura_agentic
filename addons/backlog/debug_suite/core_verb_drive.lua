-- addons/COA_DungeonRun/core.lua:137-144 at ac41961

    elseif cmd == "drive" then
        NS.Driver.Toggle()
    -- ★★ §85: THE TEST DRIVER, and it lives on the EDITOR's slash surface on
    -- purpose. His: *"Runs in editing, but not from the driver."* A consumer that
    -- needs the editor loaded cannot be mistaken for the thing it is testing.
    -- ★★★ §97: THE UI VERB. Short on purpose - the chat box holds 255 letters
    -- (`FrameXML/ChatFrame.xml:21`, sourced), so a test is many short lines rather
    -- than one long one, and our own control keys are far shorter than frame names.
