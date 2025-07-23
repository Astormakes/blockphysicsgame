**Game Concept: A Extremly Technical Survival Sandbox**

## Summary
This is a game I started building to fill a gap that ive been looking to fill for a while now. A highly technical, but also challenging sandbox that makes the player entirely dependent on their own creations to survive and thrive.

It draws inspiration from several games, including:

blockbuilding games like space engineers, Stormworks, Minecraft modpacks

powder toy, noitia, Factorio

### Personal Motivation
With over 5000 hours in Garry's Mod, I loved the freedom and complexity that could be achived though Wiremod and and Sprops when building Cars, machines and Dynos. The Physgun and the Toolgun enable great Precision while making the Player extremly powerfull... That though sometimes felt ... pointless, though. I sometimes wished i had to household with recources or build cranest to lift things. Stormworks is the first game, that was able to convey that feeling a bit.

### Project Status
As a complete novice when it comes to game design and my only serious programming experience being drawn from Garry's mod and Arduino this is a pretty serious undertaking. some systems that this game requires and will require. I feel like would even be non-trivial for experienced game developers ... 

But in some Ways im Suprised of myself. Im glad that my spelling issues arent also effecting my programming too much xD

## Design Goals
The core design philosophy is believability: when a player does something, the expected thing should happen, consistently. Cemical Reactions should be discoverable, logical and belivable. I want to allow and encourage the player to think outside the box without crashing their expectations.

### Block Size and Scale
I designed this game around 20x20x20cm blocks which happend to result in a nice round number of 8 liters Volume per Block. This resolution allows for realistic, Scaleish and complex machinery. Stormworks comes very close to that with its 30x30x30 Gridsize and it shows in the way creations can be build and the complexity that is achivable. Performance will be a pretty big issue, though, so that has to be kept in mind. especially since most things in Godot is neither known for its hiht performing nor its very accuarate physicsengine. BUT it can be swapped out.

## Key Mechanics & Features

### Building
Stormworks way around Building, is dispite its also very small Blocks suprinsingly quiuck and overall well done. Just by enabling the Player to drag a chain of blocks or a plane, the player can place great amounts of blocks very quick. 

I wanna have 2 building systems. One that works by placing blocks per hand ( like Minecraft ) and one with a sort of computer designer that provides lots of tools, functions and also allows to check a design in a " simulation " enabling the player to perfect a design before committing to it.

### worth of creations
The commiting bit is important. Having a Design a actually be made, could be quiet expensive. Rewarding the player to deaign for servicability, compatibility and lots of other bilities. I hope this encourages Players to spent more time with their creations and makes them wanna build it better but also really lern the querks of it.

i fear it might also be limiting to players... so this still has to be determined.

### digging 

resources could be mined. I don't plan to make a voxel game so it will be a bit simple. Im currently working on and have partly sucsessfully implemented Hydraulic Erosion for the Terrain Generation and i think most of the ground behaving like lose dirt in a sagging and flowing into a holw is a acceptable and belivable compramise that might come with its own challanges to the player.


### Physical, Fluid and Gas Systems

- Blocks with different physical properties (weight, density, etc.).
- Liquids are incompressible; gases are compressible.
- Volumes, like rooms and Containers have a temperature and pressure to affect their Insides.
- Steam generation, combustion, evaporation, condensation — all based on basic thermodynamic rules.
  - Example: Diesel vapor + heat + oxygen = combustion, releasing energy(heat) and byproducts.
  - instead of heaving a "refinery block" I wanna make the player build a burner and a boiler, evaporate the oil and then build an air to liquid cooler to get it back into a liquid form for example.
- maybe a simple density mechanic allows the player to separate compounds based on outlet height in a container

- Heat transfer through blocks (probably too hard to do.) so heatpipes it will be ig
- Blocks like: Pumps, Valves, Heatexchangers, Radiators, Engines, ElectricMotors, HydraulicMotors, Pistons, Hinges, Suspensions and Wheels
- i feel like Hydraulic systems with pumps driven by engines and fluids pushing pistons shouldnt be too hard to do.
- Pipes for transporting fluids and mechanical power (like rotation).
- Sensors (pressure, temperature, Rangers, ) and logic (switches, thresholds). programming ? (hopefully)
- Static structures "bases" / gerages
- Survival Mechanics
- Hunger, thirst, weather.
- crafting and refining systems.

### Gameloop

I think this game could be played in 2 ways:

- Simelar to Factorio where the player creates some sort of living from nothing first to become self sufficient and later to request trading ships to Sell goods.

- More Openword'ed where there are cities and villages that will sell and buy stuff but also creates Events like lost fishingboats, deepsea rescue missions and what ever comes to mind. 

### Feature Wishlist & Future Ideas

Some of these are big-picture ideas for future expansions:

- chunk-based weather simulation with storms, wind, and temperature zones.

- Ecosystems: wildlife and plant Systems that interact with the player or are able to be disrupted

- Seasonal changes affecting weather, wildlife, and survival strategies.

## Final Thoughts
This project was born out of passion — and a bit of frustration. I see so much untapped potential in games like Stormeorks, Garry's Mod and Space engineers, but also limitations.

in the good old Garry's mod days the ways we interacted with the engine and discovered new techniques to cope with the limitations of said engine were quiet amazing. I felt like a scientist discovering new things having Heureka moments and discussing different ways of doing stuff with ppl. That feeling when someone discovered a better way of controlling a thruster engine and you start trying around with offset cranks and different timing algorithms just to match their performance ... I wish those times back. I dont think this game will be able to fill that Gap but a different Survival Gap that Where the developmental pressure isn't the engines limitations but the harsh environment that this game takes place in.

I'm still unsure how I want to accomplish that environment that is rewarding for a new player learning how to build something and also for a player with 2000 hours and a true fleet of different machines and vehicles for all different purposes. That and most other things still has to be determined. I think missions, that unlock in complexity and scale based on accomplishments in previous missions could be the key here... I dunno xD 

## Controls

this Game has common wasd and mouse controlls. With the "del" Key you change from Noclip to physicsbased Movement. The Movement is currently only very temporary and i think will be hard to get feeling good.... With the Mousewheel you change the block that is selected for buildiung. Mousekey 1 & 2 for building like you wold expect.

U I O you cange the direction of  the block thats being placed. U and O for yaww I and K for pitch J and L for roll ... 
J K L

T,Z and U are debuging keys and do what ever I'm working at the time untill I made it run automatically. RN that is T for generating chunks, Z for loading all created Chunks in the Chunk Directory and U for turning on and off the Hydraulic Erosion. U will know once you turned it on. You can see the ground changing live.

with P you spawn a new Grid that you can start building on. The building Mechanik is still very wonky ive allrady spent a lot of time on it and it will require even more it seems...

## Future Vision

I kinda plan on having this Game Open Source but i think ill still sell it for a not much money. 
