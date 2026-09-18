# RoboVerse: The Last Signal

**Engine**: Godot 4.x (Tested with Godot 4.7.2 Stable)  
**Genre**: 3D Third-Person Story-Driven Exploration + Repair + Puzzle + Light Action  
**Objective**: "Restore the Last Signal and bring RoboVerse back online."

---

## Quick Start: How to Run & Play

### Option 1: Using Godot Console Executable (Direct Launch)
Run the following command from PowerShell:
```powershell
& "C:\Users\Krith\Downloads\Godot_v4\Godot_v4.7.2-stable_win64_console.exe" --path "c:\Users\Krith\Downloads\fin"
```

### Option 2: Using the Godot Editor
1. Open the Godot 4.7.2 editor (`C:\Users\Krith\Downloads\Godot_v4\Godot_v4.7.2-stable_win64.exe`).
2. Click **Import**, browse to `c:\Users\Krith\Downloads\fin\project.godot`, and click **Import & Edit**.
3. Press **F5** (Run Project) or **F6** on `res://scenes/main/Main.tscn`.

### Option 3: Automated In-Engine Test Suite
Verify all 41 core systems, robot powers, level progressions, arrival positioning, and mechanics:
```powershell
& "C:\Users\Krith\Downloads\Godot_v4\Godot_v4.7.2-stable_win64_console.exe" --path "c:\Users\Krith\Downloads\fin" --headless "res://scenes/main/TestRunner.tscn"
```

---

## Dedicated Character Controls

| Character | Separate Key(s) | Role & Guaranteed Power Action |
|---|---|---|
| **Human Explorer** | **E** | Context-Sensitive Interaction: Repair robots, operate consoles, stabilize generators, pull breakers |
| **PETALO** (Flower) | **1** or **Z** or **Num 1** | **Light & Signalling**: Instantly arrives at player's side; fires 60m optical beacon, activates all hidden power nodes, and neutralizes electric barriers |
| **QUACKY** (Duck) | **2** or **X** or **Num 2** | **Scout & Delivery**: Instantly arrives at player's side; fires scout thruster, traverses ducts to retrieve AI Core, and delivers payloads to mainframe |
| **TOLLY** (Tollgate) | **3** or **C** or **Num 3** | **Access & Gate**: Instantly arrives at player's side; fires purple EMP decryption wave, and overrides biometric blast gates and lockouts |
| **TIKO** (Centipede) | **4** or **V** or **Num 4** | **Heavy Manipulation**: Instantly arrives at player's side; fires 2000kN hydraulic ram, shakes screen, pushes heavy server racks, and locks bridges |

### General Explorer & Camera Controls

| Key / Action | Function |
|---|---|
| **W, A, S, D** | Move Explorer (Smoothly turns and runs into movement direction) |
| **Mouse Move** | 360° Orbit Camera (Continuous horizontal yaw & pitch look) |
| **Shift** | Sprint (Fast Movement) |
| **Space** | Jump |
| **Q** | Universal Reticle Command: Directs current active companion to 3D crosshair reticle target |
| **Tab** | Respawn Player & Companion Squad at Facility Entrance (Full 100 HP) |
| **M** | Toggle Holographic Radar Mini-Map (Bottom-Left) |
| **Mouse Scroll** | Zoom Camera In / Out |
| **Esc** | Pause Menu / Fast Travel Selector / Release Mouse Cursor |

---

## Core Gameplay Features & Flow

### 1. Cinematic Opening
- Dynamic sci-fi intro sequence with floating dust motes, dark ambience, distant distress signal, system glitch, energy surge pulse through the inactive tower, and player awakening at the Landing Area.
- Wrist scanner HUD bootup: `INCOMING SIGNAL / DISTANCE: 1.2 KM / System failure... central network offline...`
- Smooth handoff directly into third-person player control (press `Space` or `Esc` to skip).

### 2. Player Character, Health (100 HP) & Downfall Recovery
- **Human Explorer Model**: Realistic human proportions with futuristic exploration suit, helmet visor with cyan glow, reactor backpack, glowing wrist scanner, boots, and armor plating.
- **Health System (100 HP)**: Human explorer starts with 100 HP displayed on the top-left HUD health bar.
  - Hazards (Electric Arc Barriers -20 HP, Optical Laser Grids -15 HP, Unstable Machine Rotors -15 HP) inflict damage, play zap SFX, and flash the screen red with suit diagnostic warnings.
  - If HP reaches 0, emergency life-support recall engages, respawning the explorer at the entrance with full 100 HP.
- **Downfall Recovery**: If the explorer falls off catwalks, high platforms, or out-of-bounds chasms (Y < -7m), emergency gravitational recall instantly activates and respawns the player and companions at the starting point with full 100 HP.
- **Movement & Camera**: WASD turns and moves smoothly into the travel direction, while mouse camera orbits freely 360° around the explorer.

### 3. The Four Funobotz Helper Robots (Official Card Specification)
1. **PETALO (Flower Robot — Light & Signalling)**: Distinctive 8-petal golden bloom, cute face with tongue, papercraft hexagonal body with orange trim, and lantern spotlight. Reveals hidden optical power nodes and illuminates dark sectors.
2. **QUACKY (Duck Scout Robot — Scout & Delivery)**: Origami-style white/orange duck body, prism head, toy connector limbs (red structural bars, yellow knuckle joints, green 4-way cross feet), and delivery payload slot. Navigates tight maintenance ducts and delivers core logic modules.
3. **TOLLY (Tollgate Robot — Access & Security)**: Stacked tollgate tower with minimalist smiling face, red/green signal beacon status lights, and animated toll barrier arm. Executes security decryption protocols to open biometric security blast gates.
4. **TIKO (Centipede Crawler Robot — Heavy Manipulation)**: Articulated centipede crawler with hexagonal cab, forward prongs, coiled wire spring legs, and 4 tapering trailing body segments. Relocates fallen heavy server racks and aligns high-altitude catwalk bridges.

### 4. Interactive Robot Repair System
- Robots initially start offline and sparking with disconnected power conduits.
- Approaching a broken robot displays `[E] Repair Robot`.
- Opens an interactive conduit connection interface (`RepairUI.tscn`): align the power conduit to synchronize energy flow.
- Rising fanfare chime plays, the robot's status lights transition to active cyan/gold/green, and the robot joins the player's active squad!
- As you rescue robots across buildings, they accompany you from facility to facility in an ever-growing cooperative squad.

### 5. Strict Sequential Mission Progression & Obstacles
- **Strict Sequential Progression**: In order to advance from one facility to the next, **every single objective** in the current facility must be 100% completed.
  - Air-locks start locked with glowing red warning beacons and energy fields.
  - Attempting to step on a locked air-lock plays a rejection buzzer, pushes the explorer back, and displays the exact list of remaining objectives required to unlock passage.
  - Only when all objectives are verified does the exit blast gate unlock and the air-lock transition pad activate with a green/cyan energy flare.
- **Electric Arc Barriers (`ElectricBarrier.tscn`)**: High-voltage crackling energy gates that block pathways and knock back intruders. Deactivated via local circuit breaker switches.
- **Optical Laser Grids (`OpticalBarrier.tscn`)**: Ruby-red laser tripwire security corridors with transmitter/receiver pylons. Stepping across trips the alarm; disarmed via optical prism realignment console or Petalo light refraction.
- **Unstable Turbines & Rotors (`UnstableMachine.tscn`)**: Malfunctioning generators and cooling rotors spinning at dangerous velocities with electrical discharge. Players can approach the maintenance switch to stabilize the equipment.
- **Physical Blockades**: Massive fallen server units and misaligned bridges that require Tiko's hydraulic push to clear.

### 6. Five Functional Facilities & Grand Finale Execution
- **Building 1: Welcome Centre**: Atrium reception, broken power conduits, dark maintenance room with 3 hidden light-sensitive signal nodes, sparking generator hazard, Petalo repair, and security blast gate leading to Knowledge Centre.
- **Building 2: Knowledge Centre**: Data archive with fallen heavy server rack (cleared using Tiko's physical manipulation), electric barrier, optical laser tripwire, sequence routing puzzle (Alpha -> Beta -> Gamma), and gate to Coding & AI Hub.
- **Building 3: Coding & AI Hub**: AI mainframe laboratory with low maintenance duct, high-voltage conduit hazard, optical sensor corridor, Quacky scout mission for AI Core Energy Module, and reboot terminal.
- **Building 4: Innovation Tower**: Vertical multi-tier facility with functional elevator platform, catwalk electric hazard, optical tripwire, suspended catwalk bridge aligned by Tiko, and biometric security gate hacked by Tolly.
- **Building 5: Testing Arena (GRAND FINALE CLIMAX)**:
  - Grand coliseum with concentric floor circuits and 4 cardinal Elemental Relay Pylons surrounding the massive Central Signal Tower:
    - **South Pylon (Solar Gold)**: Channeled by **Petalo** (440 MHz Carrier Wave)
    - **East Pylon (Logic Amber)**: Channeled by **Quacky** (Neural Matrix Routing)
    - **North Pylon (Decryption Magenta)**: Channeled by **Tolly** (Firewall Neutralization)
    - **West Pylon (Kinetic Emerald)**: Channeled by **Tiko** (Hydraulic Reactor Surge)
  - **Orchestrated Climax Sequence**:
    1. Squad Rally: Explorer commands all 4 Funobotz into position at their elemental pylons.
    2. Synchronized Beam Ignition: Each companion channels their elemental beam horizontally into the Spire with unique synthesized audio tones and dialogue.
    3. Spire Overcharge: Tower light flares blindingly, dynamic camera screen shake builds up, bass swell rumble plays, and high-energy shockwave rings expand across the arena floor!
    4. Colossal Sky Beam: Massive dual-layer vertical sky beam pierces into the stratosphere, and world atmosphere transitions to a celestial aurora borealis.
    5. Grand Victory Presentation: Ornate golden sci-fi certificate appears with 5 facility restoration stamps, 4 companion honor medals, and interactive `[R]` Replay and `[ESC]` Free Roam controls!

### 7. Built-in Procedural Audio Synthesizer
- Uses Godot's `AudioStreamWAV` runtime PCM generation to create footsteps, UI clicks, electrical sparks, robot chirps, gate servo sweeps, repair fanfares, laser zaps, air-lock denial buzzers, elemental beam tones, overcharge rumble, and triumphant multi-chord victory fanfare with zero external file dependencies.

### 8. Facility Fast-Travel (Sequential Access)
- Press **Esc** during gameplay to open the Pause Menu. Facilities are unlocked sequentially as missions are completed!

