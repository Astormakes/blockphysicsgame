**Game Concept: A Deep, Customizable Technical Survival Sandbox**

## Summary
This is a game I started building to fill a gap that ive been looking to fill for a while now. A highly technical, but also challenging sandbox that makes the player entirely dependent on their own creations to survive and thrive.

It draws inspiration from several games, including:

blockbuilding games like space engineers, Stormworks, Minecraft modpacks

powder toy, noitia, 

### Personal Motivation
With over 5000 hours in Garry's Mod, I loved the freedom and complexity that could be achived though Wiremod and and Sprops when building Cars, machines and Dynos. The Physgun and the Toolgun enable great Precision while making the Player extremly powerfull... That though sometimes felt ... pointless, though. I sometimes wished i had to household with recources or build cranes just so i could use them for something that wouldnt otherwise be possible. Stormworks is the first game, able to convey that feeling a little bit. But its really inconsistent and limiting in some other ways.

### Project Status
As a complete novice when it comes to game design and my only serious programming experience being drawn from Garry's mod and Arduino this is a pretty serious undertaking. some systems that this game requires and will require. I feel like would even be non-trivial  for experienced game developers ... 

Next to my irl Job and all I work on this when I have the mental for it.

## Design Goals
The core design philosophy is believability: when a player does something, the expected thing should happen, consistently. Cemical Reactions should be discoverable, logical and belivable. I want to allow and encourage the player to think outside the box without crashing their expectations.

### Block Size and Scale
I designed this game around 20x20x20cm blocks which happend to result in a nice round number of 8 liters Volume per Block. This resolution allows for realistic, Scaleish and complex machinery. Stormworks comes very close to that with its 30x30x30 Gridsize and it shows in the way creations can be build and the complexity that is achivable. Performance will be a pretty big issue, though, so that has to be kept in mind. especially since most things in Godot are kinda forced to run in a single thread <.< 

## Key Mechanics & Features

### Building
Stormworks way around Building, is dispite its also very small Blocks suprinsingly quiuck and overall well done. Just by enabling the Player to drag a chain of blocks or a plane, the player can place great amounts of blocks very quick. 

I wanna have 2 building systems. One that works by placing blocks per hand ( like Minecraft ) and one with a sort of computer designer that provides lots of tools, functions and also allows to check a design in a " simulation " enabling the player to perfect a design before committing to it.

### worth of creations
The commiting bit is important. Having a Design a actually be made, could be quiet expensive. Rewarding the player to deaign for servicability, compatibility and lots of other bilities. the player will spent more time with his machines care for them. tipping over a truck means fiddling with the forklift for 20 minutes because that's the better alternative to just respawning it.

i fear it might also be limiting to players... so this still has to be determined.

### digging 

resources could be mined. I don't plan to make a voxek game so it will be a bit simple. I kinda wanna have rain actually to some hydraulic erosion even if I player happens to be in that hole trying to mine out some soil rn... that sounds fun. earth could be processed into resources.


### Fluid and Gas Systems

- Blocks with different physical properties (weight, density, etc.).
- Liquids are incompressible; gases are compressible.
Volumes, like rooms and Containers have a temperature and pressure to affect their Insides.
- Steam generation, combustion, evaporation, condensation — all based on basic thermodynamic rules.
  - Example: Diesel vapor + heat + oxygen = combustion, releasing energy(heat) and byproducts.
  - instead of heaving a "refinery block" I wanna make the player build a burner room and a boiler room, evaporate the oil and then build big air to liquid coolers to get it back into a liquid form for example.
- maybe a simple density mechanic allows the player to separate compounds based on outlet position

- Heat transfer through blocks (maybe to hard to do.)
- Blocks like: Pumps, Valves, Heatexchangers, Radiators, Engines, ElectricMotors, HydraulicMotors, Pistons, Hinges (to create atriculated Creations)
- Hydraulic systems.
- Pipes for transporting fluids and mechanical power (like rotation).
- Sensors (pressure, temperature) and logic (switches, thresholds). programming ? 
- Static structures "bases" / gerages
- Survival Mechanics
- Hunger, thirst, weather exposure.
- crafting and refining systems.
- Build infrastructure to support power generation, food production, and survival.

### Feature Wishlist & Future Ideas

Some of these are big-picture ideas for future expansions:

- chunk-based weather simulation with storms, wind, and temperature zones.

- Ecosystems: wildlife that interacts with the player or are able to be disrupted

- Seasonal changes affecting weather, wildlife, and survival strategies.

- Potential Population systems Villages for NPCs that the player could grow by meeting demands or wildlife behavior.

## Final Thoughts
This project was born out of passion — and a bit of frustration. I see so much untapped potential in games like Stormeorks, Garry's Mod and Space engineers, but also limitations.

in the good old Garry's mod days the ways we interacted with the engine and discovered new techniques to cope with the limitations of said engine were quiet amazing. I felt like a scientist discovering new things having Heureka moments and discussing different ways of doing stuff with ppl that feeling when someone discovered a better way of controlling a thruster engine and you start trying around with offset cranks and different timing algorithms just to match their performance ... I wish that would be in a survival setting. Where the developmental pressure isn't the engines limitations but the harsh environment that this game takes place in.

 I'm still unsure how I want to accomplish that environment that is rewarding for a new player learning how to build something and also for a player with 2000 hours and a true fleet of different machines and vehicles for all different purposes. that and most other things still has to be determined. I think missions, that unlock in complexity and scale based on accomplishments in previous missions could be the key here... I dunno xD 

## Controls

this Game has common wasd and mouse controlls. With the Mousewheel you change the Block to build with

U I O you cange the direction of  the block thats being placed. U and O for yaww I and K for pitch J and L for roll ... 
J K L

T is a debugg key and does what ever I'm working at the time untill I made it run on it's own.

with P you spawn a new Grid that you can start building on. 
