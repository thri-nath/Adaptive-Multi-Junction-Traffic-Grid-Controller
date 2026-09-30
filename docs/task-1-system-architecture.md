## Adaptive Traffic Controller — System Architecture and Planning

1. System Overview & Design Objectives
   1.1 System Overview

  	This project is an adaptive traffic controller for two four-way junctions, called Junction A and Junction B. Each junction controls four approaches (North,        South, East and West), 	which are grouped into two phases: North-South (NS) and East-West (EW). Each junction cycles through its phases in the usual green,        yellow and red sequence. The NS and EW phases of      	 a junction are never green at the same time, so conflicting traffic is always separated.

  	The two junctions are designed to work together rather than independently, and three mechanisms tie them together. The first is the green-wave mechanism.          Junction B's NS green 	signal 	starts a fixed, configurable number of clock cycles after Junction A's NS green signal starts. Vehicles that leave Junction A      on the NS route then reach Junction B while 	its NS 	signal is green, which reduces stops and improves traffic flow.

	 The second mechanism is a shared pedestrian arbiter. Instead of giving each junction its own pedestrian controller, the design has a single arbiter that           receives pedestrian 	requests from both junctions and decides which one to serve first. It uses a fair scheme, so neither junction is ignored and every request    is eventually served.
	
	 The third mechanism is a single global emergency override input. When it is asserted, both junctions move safely to an all-red state within a specified number     of clock cycles. They 	stay in that state while the emergency is active and return to normal operation once it is released.

   1.2 Design Objectives

	 The first objective is correct normal sequencing. Each junction must run its NS and EW phases with proper green, yellow and red timing, and it must do so on       its own when no 	coordination event is active.

	 The second objective is safety. At no point may the NS and EW signals of the same junction be green together. This rule also applies during the transitions        caused by pedestrian 	service and emergency handling, not just during normal operation.

	The third objective is green-wave coordination. Junction B's NS green must begin a defined number of clock cycles after Junction A's NS green. This delay is       held in a named 	parameter so it can be changed without altering the design and checked exactly in simulation.

	The fourth objective is shared pedestrian control. One arbiter serves both junctions, which avoids duplicated logic and gives a single place where pedestrian      crossings are 	scheduled.

	The fifth objective is fairness. When both junctions request a pedestrian crossing at the same time, one is served first and the other is guaranteed the next      turn. Repeated 	requests from one junction must not block the other indefinitely, so no junction is starved.

	The sixth objective is bounded emergency response. After the emergency input is asserted, both junctions must reach the all-red state within a fixed maximum       number of clock cycles 	and remain there for as long as the input stays active. After release, the system resumes normal operation in a safe, known state.

	The seventh objective is predictable behaviour. The design uses a single clock domain and one reset strategy, so its behaviour is deterministic and free from      clock-crossing 	problems.

	The eighth objective is verifiability. The design is split into modules with clearly defined interfaces, so each block can be tested in isolation and then         together, and every 	requirement can be checked against a specific test scenario.

## 2.Top-Level Architecture & Block Diagram  

###High-Level System Architecture

![Traffic System Top-Level Block Diagram](images/traffic_system_top_block_diagram_v2.svg)
		
		
	

