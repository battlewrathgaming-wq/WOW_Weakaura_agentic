Battle_wrath
OP
 — 8/18/2026 9:56 AM
Hey. Still in active development. I want it to be useable end to end with a bit of organizing and polish. I'll be happy to share when I'm happy with what I'm handing off.
I am interested in: Why would you use it?
Light list;
Use other people's pre-formed routes.
Use it to make your own.
Use it to record your own routing, without turning it into a route? (Self grading)
Other.
 
Battle_wrath
OP
 — Yesterday at 8:02 PM
Bump. Still seeking input / thoughts.
Bug [ASC], Role icon, Reaper Class — Yesterday at 10:56 PM
we need it so much to do Mythic plus dungeons
many times we dont know rotues , boss locations and more
this addon will be very very helpful
Nhya [KC], Role icon, Ranger — Yesterday at 10:59 PM
That would be insane ! idk if you can add the position of every boon too, or if you can add a tool/pin, to mark it on the path
Very nice idea
boniee — 6:34 AM
I am a novice tank and am looking forward to this plugin,
Battle_wrath
OP
 — 12:56 PM
Hey. Today will be the first test of the full driver. (A authored route that is build weak aura like with options) and then being able to run it and get pointed to each location. Including things like /say so when on a position, your character will announce things like "LOS Pull". But that all comes down to authoring time. 

I already have a custom pin during the sample run that will stand out for you to later mark as a POI. Then it's putting a stage or a step on that location.

I've yet to do any M+ but this is built with that in mind. If we know the buff names I could include a auto capture of when those buffs was gained. But this only has value if those interactives always spawn at the same location. (Only has value is over-broad. A compass of potential nearest could be useful across run samples collected. But the route should serve to flatten decision making, not open end potentials.) 
My plan is to make a route for RFC and Stockades so both factions can take it for a test run and see what the addon actually is from a end user view of the Route side. The capture and authoring side is by nature a bit more involved.
Nhya [KC], Role icon, Ranger — 1:03 PM
The boon are always at the same location yes, but give a random buff to use among many
Battle_wrath
OP
 — 1:03 PM
Do they have any prefix? Like Boon: ?
Nhya [KC], Role icon, Ranger — 1:03 PM
Dont make Stockades, this dungeon is not available in M+ yet
Battle_wrath
OP
 — 1:04 PM
I mean for no pressure testing of what a route is from a end user view. Someone picking up the addon. A mini-test drive / tutorial.
Nhya [KC], Role icon, Ranger — 1:04 PM
I will Check this
Battle_wrath
OP
 — 1:06 PM
If you have tool tips on also, you can see the source, most likely self though. 🙂 I'll poke around the UI and see if there is any info I can dump around M+.
Nhya [KC], Role icon, Ranger — 1:07 PM
Ye i have all the tooltips on my UI to use it when I collect one, you want them ?
There is a lot, like around 15-20 
Battle_wrath
OP
 — 1:08 PM
Yeah I'd love that info. Then on the run data the logger can sample and drop a marker when that buff was gained. Then on the author side it's dropping a beacon on them with a note "Pick up buff"
Nhya [KC], Role icon, Ranger — 1:09 PM
Oh ye true
Ill link it here when im online
Battle_wrath
OP
 — 1:10 PM
Appreciated. 🙂
Battle_wrath
OP
 — 1:39 PM
Whilst that topic is in mind. Any more auto-logging telemetry? Currently I have

Combat start and combat end (Showing a segment on the map)

Boss kill site and a capture of the boss name.

(Planned) per mob kill within a combat segment. I am unsure if M+ in CoA has a need to kill a certain amount of mobs. But the intent here is to surface what you did kill, then you can author a note for a pull that says "Kill 3 x, kill 4 x" as a shopping list. (Not tracked, that assumes too much certainty.)

Death and what killed you (Death recap the game already has)

Health at the end of a segment (By how well did you survive = smaller pulls or a time to use defensives)
Nhya [KC], Role icon, Ranger — 1:43 PM
CoA has a % trashes necessary ye, I guess that you can’t log every % that every mob gives, so players will have to do it
Battle_wrath
OP
 — 1:44 PM
Is there a UI that tells you current %?
Nhya [KC], Role icon, Ranger — 1:44 PM
Yep
Like in retail, same window same Ui
Battle_wrath
OP
 — 1:45 PM
That should be reachable then. And then it's mapping % against unit death. If 3 mobs die at the same moment, it's more ambigous. But isolate kills by time signature, and % increase would expose it as a value.
Nhya [KC], Role icon, Ranger — 1:46 PM
Yes, and bosses gives % too in this version
Battle_wrath
OP
 — 1:47 PM
Yeah. Sounds worth while. I'll need some time to consider the implimentation and what I can capture from the DBC/ game files first to build the tracking. But do-able. How that is then authored and makes it to a player running a route is the other side. But it starts with capturing.
Nhya [KC], Role icon, Ranger — 1:48 PM
And we have a 'boss list' to kill, certain dungeons gives a list (some gives a huge list that makes us chose amonst them, and some are just a restricted list that we have to kill before the last boss)
Battle_wrath
OP
 — 1:48 PM
Is that random every time? As it changes one premise about a route.
Nhya [KC], Role icon, Ranger — 1:49 PM
The list is the same for a dungeon
Example : in ZF you have to kill 6 bosses among a list of 8 or 9 before killing chief and Ruuzlu
In WC : You have 4 bosses to kill, with a list of 4 bosses, so you dont have the choice
Some dungeons allows you to make a custom route, some doesnt
Battle_wrath
OP
 — 1:52 PM
That's fine and matches well with the system today. The sample data collected at a run is every where you did go and decided to kill. So authoring is just picking out the useful data and putting a way marker / behaviour on it. So as a product, the route that is share-able is already what bosses you've decided ahead of time.
Nhya [KC], Role icon, Ranger — 1:52 PM
Sounds good
Battle_wrath
OP
 — 1:54 PM
If it was random it'd have to be a nearest route finder, which means every boss needs to be represented in a single run or across a few. But it's a non-issue. 🙂 The nearest boon on a compass might ship though.
Battle_wrath
OP
 — 2:20 PM
Thanks for the % insight. Building a stage that is "Kill until % = 20" is doable. Agnostic of what you killed, only that, at that stage you got the req amount.
And then maybe a shopping list in the note. Kill X , Y.
Nhya [KC], Role icon, Ranger — 2:39 PM
Done, in DM, since i cant link screens here
Battle_wrath
OP
 — 4:30 PM
One area I have been interested in is the mini-map. Currently it's kind of useless. Would a diablo style transparent map with no edge. A line between yourself and the next waypoint, and a display of stand out markers be useful? (Such as kill areas for %, boss locations, and boon positions) for orientation be useful? It might be limited to floor tiles. And currently there's no way to show navigation points against a route. (As in, not markers, but where a GPS knows where to clip to on route forming.) 
What I don't want to do with the addon is add more information load. It should help flatten decisions rather than open them up.
Nhya [KC], Role icon, Ranger — 4:33 PM
I dont think that would be relevant, in retail you use the layout of the addon that already displays the map with notes and keypaths, imo it would be overload of informations
Battle_wrath
OP
 — 4:35 PM
Yes. Currently we don't use the real map. It's a construct that acts like the map. Too many addons try influencing the map. And the route builder has too many custom needs with the map. But that's for the route builder addon. The one you run when doing the route is planned to be a lot lighter in nature. And might work against the native map.
Nhya [KC], Role icon, Ranger — 4:36 PM
Ye and this will be the one that we'll use while running
Battle_wrath
OP
 — 4:38 PM
The mini-map would be the same construct. Rather than using the mini-map as is. But I agree. Push the route content to the behaviour people already know. And luckily a lot of existing addons use the map for questing and such, which in a dungeon is less likely to conflict.