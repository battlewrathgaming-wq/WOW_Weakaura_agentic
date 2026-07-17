For anyone interested im posting my macros that I've been using on cultist since I started playing
Blade of the Empire macro:
#showtooltip Blade of the Empire
/targetenemy [noharm][dead]
/startattack
/cast Blade of the Empire

Malevolence macro:
#showtooltip Malevolence
/targetenemy [noharm][dead]
/startattack
/cast Malevolence

Abyssal Covenant, personally I'm using focus on tank with this one, so I can easily insta heal him using Gaze of C'Thun when he has 10 stacks of Void-Touched:
#showtooltip Abyssal Covenant
/focus [@mouseover,help,nodead][@target,help,nodead]
/cast [@focus] Abyssal Covenant

Gaze macro:
#showtooltip Gaze of C'Thun
/cast [@mouseover,help][@focus,help][@target,harm][@player] Gaze of C'Thun

----

This one to be able to mouseover banes, can change name depending on what bane you want. Casts bane on whatever frame/nameplate/monster you have your mouse over, if no mouseover target it'll cast on whatever your current target is.

#showtooltip
/cast [@mouseover, exists] Bane of Chaos; Bane of Chaos


This one to cast Infernal wherever I have my cursor instead of having to click the floor after pressing the keybind.

#showtooltip
/cast [@cursor] Infernal


This one is the same but for the Fear, to aoe stop/interrupt faster.

#showtooltip
/cast [@cursor] Whispers of the Pit


Then I have a bunch of just "/cast Spell" macros for all the spec-specific abilities so that I don't have to put them on my bars all the time when I swap specs. 


----

Here are some of the macros I use for shifting 

#showtooltip Skulk
/cast [noform:1] Spider Form
/cast !Skulk

#showtooltip Nullifying Toxin
/cast [noform:1] Spider Form
/cast Nullifying Toxin

#showtooltip Harden
/cast [noform:2] Beetle Form
/cast Harden

You can use these as a template for the others. I also added a cancelform macro for heals 

#showtooltip Shadra's Prayer
/cancelform
/cast [@mouseover,exists][] Shadra's Prayer 

----

Try this macro as guardian :

#showtooltip [help] Guard; [harm] Battle Rush; Battle Rush
/cast [help,form:0/1/3] Tower Formation
/cast [harm,form:0/1/2] Assault Formation
/cast [help,form:2] Guard
/cast [harm,form:3] Battle Rush

----

There is a macro you can make that adds all items in your bags to your appearance collection.

/run local c=C_AppearanceCollection for b=0,4 do for s=1,GetContainerNumSlots(b)do if not c.IsAppearanceCollected(C_Appearance.GetItemAppearanceID(GetContainerItemID(b,s)))then c.CollectItemAppearance(GetContainerItemGUID(b,s)) end end end

----

Lastly, there has been 2 trinkets I found decently early on that macro really well into burst. (Premium banana, and Captains compass) when I use captains compass it pushes me to the expertise soft cap so my attacks cannot be dodged, and they can’t be parried because I’m behind the target. The premium banana is just on use strength. 2 macros I’ve enjoyed quite a bit are my burst macro: 
/startattack
/cast Blood of Mannoroth 
/cast Premium Banana 
/cast Captain’s Compass
/cast Fury unleashed 
I dont macro annihilation in, because its cooldown is only 1 minute, so i use it as frequently as possible, while still making sure i use it with my burst macro as well.
And then a simple start attack macro for smite. 
/startattack 
/cast Sargeron Smite

Before you use the burst macro make sure you have inner demon up, immolation aura up, and toss out a bane of fire 🙂 


----

Pet control macro, i use it always when playing with pets and i got it bound to mouse button for easy and quick access, extremely useful in pvp where u wanna let ur pet stop at a specific location or call it back quick to cc a guy that u didnt manage to kill:

/petattack [nomod]
/petfollow [mod:shift/alt]
/petstay [mod:ctrl]

pressing the button: pet attacks
pressing the button+shift (or alt): pet comes back to u
pressing the button+ctrl: pet stays at the current position

----

if anyone wants an all in one macro to both cast and cancel its simple:

#showtooltip Illidan's Guile
/cancelaura Illidan's Guile
/cast Illidan's Guile

----

Some Pyro macros : 
#showtooltip Phoenix Egg
/cast [mod:shift, @cursor][@player][] Phoenix Egg

#showtooltip Meteor
/cast [@cursor] Meteor

#showtooltip Reborn from Ash
/cast [@mouseover] Reborn from Ash

#showtooltip Dragon Leap
/cast [@cursor] Dragon Leap

----

This macro is useful for Time chronos to keep the Aeon swap talents on if you dont want to change Aeons:

#showtooltip
/cancelaura
/Cast !Aeon of Renewal

You can just cancel your Aeon and then cast the same you were and still get the bonus healing/damage and regen (would be quite happy if they extend at least 4 secs the duration, it is quite hard to keep them on in PvP when you have to deal with a lot of things).

----

made a travel form macro, let me know if theres a better one please!
#showtooltip
/cast [swimming, noform:3] venomwing form; [indoors, noform:1] spider form; [outdoors, noform:3] venomwing form; [outdoors, form:3] spider form; [indoors, form:1] beetle form; venomwing form

----

If you're interested in seeing if it's for you:
/cast [modifier:X] Quick Shot; Wild Strike

X can be: alt, crtl, shift

This particular ordering will cast Wild Strike by default and Quick Shot if you have the modifier held when you press the macro. This would be my suggestion for Brig, I would switch the two if you're playing a ranged spec

----

macroed pretty  much all of my normal abilities to autocast umbral  glaive
#showtooltip Spirit Eclipse
/cast Auto Shot
/cast Umbral  Glaive
/cast Spirit Eclipse

----

Macros, WeakAuras & Co.
A few things I'd definitely recommend:

Enable mouseover casting for Temple Guardian, Benediction and Rebuke.
Create a macro so you can trigger Armor of Faith whenever you want.
#showtooltip
/cancelaura Staffguard
/cast Sacred Swing

Cancelaura for Righteous Tempest
#showtooltip
/cancelaura Righteous Tempest
/cast Righteous Tempest

Templar doesn't have a dedicated resource UI, so I'd strongly recommend using a WeakAura to track your Oath Chain timer, stacks and important buffs. It makes the class much easier to play.

----

tired of mousing over an enemy's to cast  Serpent's Fang here's a wee macro so you can just cast it on the tank and will hit his target or w/e you targeting (incase you want to pull more ) over  add to clique custom macro for even more brain dead healing 🙂

#showtooltip
/cast [@mouseover,harm,nodead] [harm] [@mouseovertarget,harm,nodead] [@targettarget,harm,nodead] [] Serpent's Fang

enjoy 🙂

----

I made a macro, if you want to test : Logic is : if mouseover is friend, guard, if mouseover is enemy, battle rush

#showtooltip [@mouseover,help,nodead][help] Guard; [@mouseover,harm,nodead][harm] Battle Rush; Battle Rush
/cast [@mouseover,help,nodead,form:0/1/3][help,form:0/1/3] Tower Formation
/cast [@mouseover,harm,nodead,form:0/1/2][harm,form:0/1/2] Assault Formation
/cast [@mouseover,help,nodead,form:2][help,form:2] Guard
/cast [@mouseover,harm,nodead,form:3][harm,form:3] Battle Rush

----

This Macro helps with quick self heals, make sure you always use the heal or else make sure you have the Moonwell Splash on another key, just in case the sequence gets stuck.
Macro for quick self heal, press it twice:
#showtooltip
/castsequence reset=combat Lunar Eclipse, Moonwell Splash

Macro example for startattack to keep autoswings going. All tanks should use them.
Good for attacks like Starsunder, Starsweep, Celestial Strike, and Celestial Cleave:
#showtooltip
/startattack
/cast Celestial Cleave

----

I just use a standard mouseover macro for all of my spells. Just move mouse over party frame and hit keybinding, highly recommend. You can definitely use focus frames to your advantage, I just like a little more free flowing style
#showtooltip
/cast [@mouseover,exists,help,nodead][] Eldritch Mending

----

similar to this, we can do:
#showtooltip Paragon
/cast Paragon
/cast Champion of the Sun 

since there isn't really a case where we wouldn't want to use Champion of the Sun while using Paragon, we can macro them together (1 press activates both)
so just replace your normal Paragon with this macro, and when Paragon is on cd you can still use Champion separetely. all it does is it saves 1 button press when you need to pop all cd-s fast

----

Doesn't work 
/cast [@player] !Standard of Recovery
 My actual macro to do this is : 
#showtooltip
/cleartarget
/targetexact Standard of Recovery
/focus [@target,exists]
/targetlasttarget
/stopmacro [@focus,exists]
/cast [@player] Standard of Recovery
 This only cast the standard if its not up already 


----

Before unlocking all stances, you can use this to identify which number belongs to each stance:

/run print(GetShapeshiftForm())

In my case, and I guess it is the same for everyone:
Assault Formation = stance 2
Tower Formation = stance 1
No stance = stance 0

So you can use these macros to avoid removing your stance when spamming:

Net Throw
#showtooltip Net Throw
/cast [nostance:2] !Assault Formation
/cast Net Throw

Battle Rush
#showtooltip Battle Rush
/cast [nostance:2] !Assault Formation
/cast Battle Rush

Raise Shield
#showtooltip Raise Shield
/startattack
/cast [nostance:1] !Tower Formation
/cast Raise Shield

----

Depending on how much you play pet classes, get into the habit of using these two macros.

#showtooltip Grave March
/cast !Undead: Assault/Protect
/cast Grave March

#showtooltip
/cast !Undead: Pacify 

----

you make macro like 

#showtooltip
/startattack
/cast earthquake
/cast Therazane's Rage

you replenish mana every time you can and can forget about it ❤️

----

I just went and tested it, spamming only my wand of time macro
#showtooltip Wand of Time
/cast Wand of time
/cast !Wand
and the wand attacks were never canceled. Moving will stop them of course, but they're a tiny part of our damage anyway and the intent is just to add a small boost throughout our rotation

----

Hoping to gather some macros here.  I haven’t found I needed too many

I have all of my talent-selected spells macro’d since they disappear when I change back and forth (might be a bug, idk). This is literally the most basic macro you can make, but as a tip if you leave the icon as the ? it will automatically display whatever showtooltip is referencing.

#showtooltip
/Cast Threads of Fate

One-button macro for Infinite Clone and Rewind:

#showtooltip Infinite Clone
/castsequence reset=10 Infinite Clone, Rewind

Basic shift mod, I use it for Accel/Decel:

#showtooltip Accelerate
/cast [mod:shift]Decelerate;Accelerate

----

with the macro above : 
/cast [stance:0/1/2] Assault Formation
 this only cast if not in assault formation (3)

----

Conquest of Azeroth: Changelog
APP
 — 6/25/2026 11:45 PM
[2026-06-25 - CoA - General]
+ Macros can now hold 511 characters up from 255.

---

Here are stance / formation macros I made which seem to work well here in my testing so far. 
I saw there was another thread with macros that were built different, but for those you can't click the macros while things are on CD, or you end up wasting energy. Here there is no issue like that.
You need to press each macro twice to get the spell off. There is no harm if you mash the macro more than two times.

#showtooltip Battle Rush
/cast [stance:1/2] Assault Formation
/cast [nostance] Assault Formation
/cast Battle Rush

#showtooltip Advance
/cast [stance:2/3] Line Formation
/cast [nostance] Line Formation
/cast Advance

#showtooltip Raise Shield
/startattack
/cast [stance:1/3] Tower Formation
/cast [nostance] Tower Formation
/cast Raise Shield

#showtooltip Net Throw
/cast [stance:1/2] Assault Formation
/cast [nostance] Assault Formation
/cast Net Throw

#showtooltip Shield of Denial
/startattack
/cast [stance:3] Line Formation
/cast [nostance] Line Formation
/cast Shield of Denial

If you want to make your own macro for other spells, here is what you should know.
These are the stance numbers:
Line Formation = 1
Tower Formation = 2
Assault Formation = 3

"/cast [stance:3] Line Formation" means if you are in stance 3 (Assault Formation), you will cast Line Formation. 

----

We dont have an area I can find for macros or addons for necros so thought Id make this to share:

Safe Travel Macro - no more mounting and having your pets attack things

#showtooltip
/cast [mounted][combat] !Undead: Protect
/cast [nomounted] !Undead: Pacify
/cast MOUNTNAME

----

I made a macro:
#showtooltip Tentacle of C'thun
/cast [combat] Tentacle of C'thun
/cast [nocombat] Tentacle of C'thun
/click TotemFrameTotem2 RightButton

Else it's indeed very annoying to use.

----

All my Macros changed spell cast based on current Form or if I have no form. Example : 

#showtooltip
/cast [stance:2] Venom Fang; [stance:1] Hivebreak; Venom Bolt

----



