**Game Concept: A Deep, Customizable Technical Survival Sandbox**

## Summary
This is a game I started building to fill a gap that ive been looking to fill for a while now. A highly technical, deeply customizable sandbox that makes the player entirely dependent on their own creations to survive and thrive.

It draws inspiration from several games, including:

Stormworks – A technical block-based vehicle builder focused on Rescue Missions and suprisingly much techincal-depth.

From the Depths – A less "realistic" war-machine builder with advanced WeaponSimulations.

Noita – A surprising source of inspiration, thanks to its consistent world rules and deep emergent gameplay.

### Why Noita?
At first glance, Noita might not seem to fit with the others. But what makes Noita special is its consistency: every pixel follows very simelar rules. Even particles from portal effects can be collected and used for different things. If you happend to catch Fire and Water in the same Flask it makes Steam that and simelar reactions are a big part of the gameplay and are super saticfying and rewarding to use to your advantage.

### Personal Motivation
With over 5000 hours in Garry's Mod, I loved the freedom and complexity that could be achived though Wiremodand and Sprops when building Cars and Dynos. The Physgun and the Toolgun enable great Precision while making the Player extremly powerfull... That though sometimes felt ... pointless. I sometimes wished i had to household with recources or build cranes just so i could use them for something that wouldnt otherwise be possible. Stormworks is able to convey that feeling a little bit. But its really inconsistent and limiting in some ways.

### Project Status
This game hit technical roadblocks. I struggled with implementing a system to detect and measure rooms for fluid storage and chemical reactions. Performance quickly became an issue.

Although I've paused this project, I hope it serves as a spark for someone else — or maybe I’ll reboot it from scratch with lessons learned. Maybe it takes me an other 10 aproches to get a working Start to a Game scratches that ich for me. 

## Design Goals
The core design philosophy is believability: when a player does something, the expected thing should happen, consistently. Cemical Reactions should be discoverable, logical and belivable.

### Block Size and Scale
I designed this game around 20x20x20cm blocks which happend to result in a nice round number of 8 liters Volume per Block. This resolution allows for realistic, to-Scale and complex machinery. Stormworks comes very close to that with its 30x30x30 Gridsize and it shows in the way creations can be build and the complexity that is achivable but i think a little smaler cant hurt. 

### Building
Stormworks way around Building, is dispite its also very small Blocks suprinsingly quiuck. Just by enabling the Player to drag a chain of blocks or a plane the player can place great amounts of blocks very quick. 

## Key Mechanics & Features

### Fluid and Gas Systems

- Since all blocks are 8 liters: if a block weighs <8kg, it floats.
- Blocks with different physical properties (weight, density, etc.).
- Liquids are incompressible; gases are compressible.
Volumes, like rooms and Containers have a temperature and pressure to affect their Insides.
- Steam generation, combustion, evaporation, condensation — all based on basic thermodynamic rules.
  - Example: Diesel vapor + heat + oxygen = combustion, releasing energy and byproducts.
  - Complex Reactions and Materials
  - Crude oil refining (raw → light oil → diesel → vapor).
  - Heavy oil → sludge (low-efficiency fuel, or dead-end compound).

- Heat transfer through blocks, requiring real heat management.
- Blocks like: Pumps, Valves, Heatexchangers, Radiators, Engines, ElectricMotors, HydraulicMotors, Pistons, Hinges (to create atriculated Creations)
- Hydraulic systems using heavy oil.
- Pipes for transporting fluids and mechanical power (like rotation).
- Sensors (pressure, temperature) and logic (switches, thresholds).
- Static structures ("bases").
- Survival Mechanics
- Hunger, thirst, weather exposure.
- crafting and refining systems.
- Hostile environments that force planning and engineering.
- Build infrastructure to support power generation, food production, and survival.

### Feature Wishlist & Future Ideas

Some of these are big-picture ideas for future expansions:

- Full chunk-based weather simulation with storms, wind, and temperature zones.

- Ecosystems: wildlife that interacts with the player (e.g., predators, food chains).

- Seasonal changes affecting weather, wildlife, and survival strategies.

- Potential Population systems for NPCs or wildlife behavior.

## Final Thoughts
This project was born out of passion — and a bit of frustration. I see so much untapped potential in games like Stormworks, but also limitations. I wanted to push further.

Even though I had to put this version on hold, this concept still burns bright in my mind. Whether it's me or someone else who brings it to life, I hope this README helps communicate what could be a new kind of game — one that’s deep, demanding, and incredibly rewarding to master.

## Controls

this Game has common wasd and mouse controlls. With the Mousewheel you change the Block to build with

U I O you cange the direction of  the block thats being placed. U and O for yaww I and K for pitch J and L for roll ... 
J K L

If you have build something with T you can step though or trigger the room detection that ive been working on

with P you spawn a new Grid that you can start building on. 

## news ! 

This inspired me to do a little bit more Programming.
