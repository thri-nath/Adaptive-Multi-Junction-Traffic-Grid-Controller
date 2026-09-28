\# Adaptive Traffic Controller — System Architecture and Planning



\## 1. Document Purpose



This document defines the architecture and implementation plan for an adaptive traffic controller containing two coordinated 4-way traffic junctions:



\* \*\*Junction A\*\*

\* \*\*Junction B\*\*



The two junctions operate together rather than as independent traffic controllers.



The system provides:



1\. Normal North-South and East-West traffic signal sequencing at both junctions.

2\. A \*\*green-wave mechanism\*\* that coordinates the North-South traffic flow between Junction A and Junction B.

3\. A \*\*shared pedestrian arbiter\*\* that receives pedestrian crossing requests from both junctions and fairly selects which request is served.

4\. A single \*\*emergency override\*\* that causes both junctions to transition safely to an all-red state within a specified number of clock cycles.

5\. A single-clock-domain synchronous design.

6\. A verification plan covering normal operation, coordination, arbitration, emergency handling, reset behavior, and corner cases.



This document acts as the architectural contract for the RTL implementation and verification stages.



\---



\# 2. System Requirements



\## 2.1 Functional Requirements



\### FR-01 — Two Traffic Junctions



The system shall contain two 4-way traffic junction controllers:



\* Junction A

\* Junction B



Each junction shall control two traffic directions:



\* North-South

\* East-West



Each direction shall have:



\* Red

\* Yellow

\* Green



signals.



\---



\### FR-02 — Normal Traffic Sequencing



Each junction shall normally operate using a safe traffic-light sequence.



The basic sequence shall be:



```text

North-South Green

&#x20;       ↓

North-South Yellow

&#x20;       ↓

All Red

&#x20;       ↓

East-West Green

&#x20;       ↓

East-West Yellow

&#x20;       ↓

All Red

&#x20;       ↓

North-South Green

&#x20;       ...

```



At no time during normal operation shall both traffic directions have green signals simultaneously.



\---



\### FR-03 — Green-Wave Coordination



Junction B shall coordinate its North-South green phase with Junction A.



When Junction A begins its North-South green phase, Junction B shall begin its corresponding North-South green phase after a configurable delay.



Define:



```text

GREEN\_WAVE\_DELAY = D clock cycles

```



The intended relationship is:



```text

Junction A NS Green

&#x20;       │

&#x20;       │ D clock cycles

&#x20;       ▼

Junction B NS Green

```



The delay shall be configurable through a parameter rather than hard-coded into the architecture.



The implementation shall ensure that Junction B does not violate its own safe signal sequencing while responding to the green-wave request.



\---



\### FR-04 — Shared Pedestrian Arbitration



Pedestrian requests shall be accepted from both junctions.



The architecture shall contain \*\*one shared pedestrian arbiter\*\* instead of separate pedestrian controllers.



Inputs:



```text

ped\_request\_A

ped\_request\_B

```



The arbiter shall determine which request receives service.



The arbiter shall prevent starvation.



\---



\### FR-05 — Simultaneous Pedestrian Requests



If both junctions request pedestrian service at the same time, the arbiter shall use a fair arbitration policy.



The selected policy is \*\*round-robin arbitration\*\*.



A fairness state shall remember which junction was most recently given priority.



For example:



```text

Previous winner = A



A request only      → A

B request only      → B

A + B requests      → B

```



After B is selected, A receives priority the next time both requests are simultaneous.



This prevents one junction from continuously winning simultaneous arbitration.



\---



\### FR-06 — Pedestrian Request Persistence



A pedestrian request shall remain pending until it is accepted for service.



The architecture shall not lose a request merely because another request was being serviced.



The arbiter shall therefore operate on pending request information rather than relying only on a one-cycle pulse.



\---



\### FR-07 — Emergency Override



The system shall have one global emergency input:



```text

emergency\_override

```



When asserted, both junctions shall transition toward an \*\*all-red\*\* state.



The emergency response shall complete within a defined maximum number of clock cycles:



```text

EMERGENCY\_RESPONSE\_CYCLES = E

```



For the initial architecture:



```text

E = 2 clock cycles

```



is selected as the design target.



The exact implementation shall ensure that no unsafe green-to-green transition occurs during emergency handling.



\---



\### FR-08 — Emergency Priority



Emergency handling has priority over:



\* Normal traffic sequencing

\* Green-wave coordination

\* Pedestrian scheduling



Once emergency override is active, normal traffic scheduling shall be suspended and both junctions shall move toward all-red.



\---



\### FR-09 — Reset



The system shall use a \*\*single synchronous reset\*\*.



After reset, both junctions shall enter a safe all-red state.



The system shall not begin normal traffic sequencing until reset is released.



\---



\# 3. High-Level Architecture



The proposed architecture consists of the following major modules:



```text

&#x20;                        +----------------------+

&#x20;                        |    System Clock      |

&#x20;                        |    \& Synchronous     |

&#x20;                        |       Reset          |

&#x20;                        +----------+-----------+

&#x20;                                   |

&#x20;                                   v

&#x20;                        +----------------------+

&#x20;                        |  Traffic Controller  |

&#x20;                        |      Top Module      |

&#x20;                        +----------+-----------+

&#x20;                                   |

&#x20;             +---------------------+----------------------+

&#x20;             |                     |                      |

&#x20;             v                     v                      v

&#x20;     +---------------+     +---------------+      +---------------+

&#x20;     |   Junction A  |     |   Junction B  |      |  Emergency    |

&#x20;     | Traffic FSM   |     | Traffic FSM   |      |    Control    |

&#x20;     +-------+-------+     +-------+-------+      +-------+-------+

&#x20;             |                     |                      |

&#x20;             |                     |                      |

&#x20;             |             Green-wave control             |

&#x20;             |<-------------------------------------------+

&#x20;             |                     ^

&#x20;             |                     |

&#x20;             +----------+----------+

&#x20;                        |

&#x20;                        v

&#x20;                +---------------+

&#x20;                | Green-Wave    |

&#x20;                | Coordinator   |

&#x20;                +-------+-------+

&#x20;                        ^

&#x20;                        |

&#x20;             +----------+----------+

&#x20;             |                     |

&#x20;             v                     v

&#x20;     +---------------+     +---------------+

&#x20;     | Pedestrian    |     | Pedestrian    |

&#x20;     | Request A     |     | Request B     |

&#x20;     +-------+-------+     +-------+-------+

&#x20;             |                     |

&#x20;             +----------+----------+

&#x20;                        |

&#x20;                        v

&#x20;                +---------------+

&#x20;                | Shared        |

&#x20;                | Pedestrian    |

&#x20;                | Arbiter       |

&#x20;                +-------+-------+

&#x20;                        |

&#x20;                 selected\_request

&#x20;                        |

&#x20;             +----------+----------+

&#x20;             |                     |

&#x20;             v                     v

&#x20;        Junction A             Junction B

&#x20;        pedestrian            pedestrian

&#x20;          service               service

```



\---



\# 4. Top-Level Block Diagram



The detailed top-level interface is:



```text

&#x20;                        CLOCK / RESET

&#x20;                            |

&#x20;                            v

&#x20;                 +----------------------+

&#x20;                 | traffic\_controller   |

&#x20;                 |        (TOP)         |

&#x20;                 +----------------------+

&#x20;                   |       |        |

&#x20;                   |       |        |

&#x20;      +------------+       |        +----------------+

&#x20;      |                    |                         |

&#x20;      v                    v                         v

+-------------+      +-------------+          +---------------+

|  Junction A |      |  Junction B |          | Emergency     |

| Controller  |      | Controller  |          | Controller    |

+------+------+      +------+------+          +-------+-------+

&#x20;      |                    |                         |

&#x20;      | NS Green           | NS Green               |

&#x20;      +----------+---------+                         |

&#x20;                 |                                   |

&#x20;                 v                                   |

&#x20;         +---------------+                           |

&#x20;         | Green-Wave    |<--------------------------+

&#x20;         | Coordinator   |

&#x20;         +-------+-------+

&#x20;                 |

&#x20;                 | B NS Green request

&#x20;                 v

&#x20;           Junction B





&#x20;Pedestrian Inputs:



&#x20;ped\_req\_A ------------------+

&#x20;                            |

&#x20;                            v

&#x20;                      +-------------+

&#x20;ped\_req\_B ----------->| Pedestrian  |

&#x20;                      |   Arbiter   |

&#x20;                      +------+------+

&#x20;                             |

&#x20;                +------------+------------+

&#x20;                |                         |

&#x20;                v                         v

&#x20;         ped\_grant\_A               ped\_grant\_B

&#x20;                |                         |

&#x20;                v                         v

&#x20;         Junction A                 Junction B

```



\---



\# 5. Module Breakdown



\## 5.1 `traffic\_controller\_top`



\### Purpose



This is the system-level integration module.



It connects:



\* Clock

\* Reset

\* Junction A

\* Junction B

\* Green-wave coordinator

\* Pedestrian arbiter

\* Emergency control



It does not directly implement the detailed traffic FSM behavior.



\### Inputs



| Signal               | Purpose                            |

| -------------------- | ---------------------------------- |

| `clk`                | System clock                       |

| `rst`                | Synchronous active-high reset      |

| `ped\_request\_A`      | Pedestrian request from Junction A |

| `ped\_request\_B`      | Pedestrian request from Junction B |

| `emergency\_override` | Global emergency request           |



\### Outputs



| Signal        | Purpose                                                        |

| ------------- | -------------------------------------------------------------- |

| `A\_NS\_R`      | Junction A North-South red                                     |

| `A\_NS\_Y`      | Junction A North-South yellow                                  |

| `A\_NS\_G`      | Junction A North-South green                                   |

| `A\_EW\_R`      | Junction A East-West red                                       |

| `A\_EW\_Y`      | Junction A East-West yellow                                    |

| `A\_EW\_G`      | Junction A East-West green                                     |

| `B\_NS\_R`      | Junction B North-South red                                     |

| `B\_NS\_Y`      | Junction B North-South yellow                                  |

| `B\_NS\_G`      | Junction B North-South green                                   |

| `B\_EW\_R`      | Junction B East-West red                                       |

| `B\_EW\_Y`      | Junction B East-West yellow                                    |

| `B\_EW\_G`      | Junction B East-West green                                     |

| `ped\_grant\_A` | Indicates that Junction A pedestrian request has been selected |

| `ped\_grant\_B` | Indicates that Junction B pedestrian request has been selected |



\---



\# 6. Junction Controller Module



A reusable module shall be used for both junctions.



Conceptually:



```text

junction\_controller

```



Two instances will be created:



```text

junction\_A

junction\_B

```



This avoids duplicating the FSM implementation.



\## 6.1 Purpose



The junction controller is responsible for:



\* Traffic-light sequencing

\* Yellow transitions

\* All-red safety intervals

\* Pedestrian service at the junction when granted

\* Emergency transition handling



The controller shall not independently implement pedestrian arbitration.



\---



\## 6.2 Inputs



| Signal               | Purpose                                                          |

| -------------------- | ---------------------------------------------------------------- |

| `clk`                | System clock                                                     |

| `rst`                | Synchronous reset                                                |

| `ped\_grant`          | Indicates that the shared arbiter has granted pedestrian service |

| `green\_wave\_enable`  | Enables green-wave coordination                                  |

| `green\_wave\_trigger` | Indicates that a coordinated NS-green transition is requested    |

| `emergency\_override` | Requests emergency transition                                    |

| `timing\_config`      | Configurable phase timing values                                 |



\---



\## 6.3 Outputs



| Signal             | Purpose                                       |

| ------------------ | --------------------------------------------- |

| `NS\_R`             | North-South red                               |

| `NS\_Y`             | North-South yellow                            |

| `NS\_G`             | North-South green                             |

| `EW\_R`             | East-West red                                 |

| `EW\_Y`             | East-West yellow                              |

| `EW\_G`             | East-West green                               |

| `NS\_green\_start`   | Pulse/event indicating start of NS green      |

| `ped\_service\_done` | Indicates completion of pedestrian service    |

| `all\_red`          | Indicates that the junction is safely all-red |



\---



\# 7. Junction State Machine



The junction controller shall use a finite-state machine.



Proposed states:



```text

RESET\_ALL\_RED

&#x20;     |

&#x20;     v

NS\_GREEN

&#x20;     |

&#x20;     v

NS\_YELLOW

&#x20;     |

&#x20;     v

ALL\_RED

&#x20;     |

&#x20;     v

EW\_GREEN

&#x20;     |

&#x20;     v

EW\_YELLOW

&#x20;     |

&#x20;     v

ALL\_RED

&#x20;     |

&#x20;     +---------> NS\_GREEN

```



Pedestrian service can be integrated at a safe point in the sequence.



Emergency handling shall override normal progression:



```text

ANY NORMAL STATE

&#x20;      |

&#x20;      | emergency\_override

&#x20;      v

EMERGENCY\_ALL\_RED

```



\---



\# 8. Traffic Timing



The architecture shall use parameterized timing values.



Example configuration:



| Parameter                   | Meaning                                 |

| --------------------------- | --------------------------------------- |

| `NS\_GREEN\_TIME`             | Duration of NS green                    |

| `NS\_YELLOW\_TIME`            | Duration of NS yellow                   |

| `EW\_GREEN\_TIME`             | Duration of EW green                    |

| `EW\_YELLOW\_TIME`            | Duration of EW yellow                   |

| `ALL\_RED\_TIME`              | Safety interval between directions      |

| `PED\_SERVICE\_TIME`          | Pedestrian service duration             |

| `GREEN\_WAVE\_DELAY`          | Delay between A NS green and B NS green |

| `EMERGENCY\_RESPONSE\_CYCLES` | Maximum emergency transition time       |



Exact values can be adjusted during RTL implementation and simulation.



\---



\# 9. Green-Wave Coordinator



\## 9.1 Purpose



The green-wave coordinator is a separate module because coordination between two junctions is a system-level function rather than a responsibility of an individual junction.



It detects the beginning of Junction A's North-South green phase and schedules Junction B's corresponding North-South green phase after the configured delay.



\---



\## 9.2 Inputs



| Signal               | Purpose                                                           |

| -------------------- | ----------------------------------------------------------------- |

| `clk`                | System clock                                                      |

| `rst`                | Synchronous reset                                                 |

| `A\_NS\_green\_start`   | Event indicating Junction A entered NS green                      |

| `B\_ready`            | Indicates Junction B can safely accept the coordinated transition |

| `emergency\_override` | Cancels/overrides coordination during emergency                   |

| `green\_wave\_enable`  | Enables coordination                                              |



\---



\## 9.3 Outputs



| Signal               | Purpose                                           |

| -------------------- | ------------------------------------------------- |

| `B\_NS\_green\_trigger` | Requests Junction B to enter coordinated NS green |

| `wave\_active`        | Indicates an active green-wave timing operation   |



\---



\## 9.4 Green-Wave Operation



When:



```text

A\_NS\_green\_start = 1

```



the coordinator starts a delay counter.



For:



```text

GREEN\_WAVE\_DELAY = D

```



the sequence is:



```text

Cycle N:

A enters NS Green

Coordinator starts counter



Cycle N+1:

Counter = 1



Cycle N+2:

Counter = 2



...



Cycle N+D:

B receives NS Green trigger

```



The coordinator shall not directly drive the traffic-light outputs.



Instead, it sends a request to Junction B, allowing Junction B to verify that the requested transition is safe.



\---



\# 10. Shared Pedestrian Arbiter



\## 10.1 Why the Pedestrian Controller Is Shared



A shared pedestrian arbiter is required rather than creating independent pedestrian controllers for each junction.



The shared architecture provides:



1\. \*\*Centralized fairness\*\*

2\. \*\*Consistent arbitration rules\*\*

3\. \*\*Avoidance of conflicting pedestrian-service decisions\*\*

4\. \*\*Reduced duplicated logic\*\*

5\. \*\*A single place to implement starvation prevention\*\*

6\. \*\*Simpler verification of simultaneous requests\*\*



Separate controllers could independently grant requests, making fairness and system-level coordination harder to reason about.



\---



\# 11. Pedestrian Arbiter Interface



\## Inputs



| Signal               | Purpose                                    |

| -------------------- | ------------------------------------------ |

| `clk`                | System clock                               |

| `rst`                | Synchronous reset                          |

| `request\_A`          | Pending pedestrian request from Junction A |

| `request\_B`          | Pending pedestrian request from Junction B |

| `service\_done\_A`     | Indicates A completed pedestrian service   |

| `service\_done\_B`     | Indicates B completed pedestrian service   |

| `emergency\_override` | Suspends pedestrian scheduling             |



\## Outputs



| Signal              | Purpose                                          |

| ------------------- | ------------------------------------------------ |

| `grant\_A`           | Grants pedestrian service to A                   |

| `grant\_B`           | Grants pedestrian service to B                   |

| `busy`              | Indicates pedestrian service is currently active |

| `selected\_junction` | Identifies the selected junction                 |



\---



\# 12. Pedestrian Arbitration Policy



The selected arbitration algorithm is \*\*round-robin arbitration\*\*.



The arbiter stores:



```text

last\_served

```



Possible values:



```text

A

B

```



When only one request exists:



```text

A = 1, B = 0 → grant A

A = 0, B = 1 → grant B

```



When both requests exist:



```text

A = 1, B = 1

```



the arbiter selects the junction that has not most recently been served.



Example:



```text

last\_served = A



A request = 1

B request = 1



→ grant B

```



After B completes:



```text

last\_served = B

```



If both request again:



```text

→ grant A

```



This alternates priority and prevents starvation.



\---



\# 13. Simultaneous Request Handling



Consider the following sequence:



```text

Time 0:

A requests pedestrian service

B requests pedestrian service

```



If the previous service was A:



```text

B is granted first.

A remains pending.

```



After B finishes:



```text

A is granted.

```



If both requests remain asserted, the arbiter continues alternating.



Therefore:



```text

A → B → A → B → ...

```



rather than:



```text

A → A → A → A → ...

```



or:



```text

B → B → B → B → ...

```



This provides a deterministic fairness mechanism.



\---



\# 14. Emergency Controller



\## 14.1 Purpose



The emergency controller provides a single global emergency mechanism.



Instead of requiring separate emergency inputs for Junction A and Junction B, one signal controls the entire system:



```text

emergency\_override

```



This ensures both junctions respond to the same emergency event.



\---



\## 14.2 Inputs



| Signal               | Purpose                         |

| -------------------- | ------------------------------- |

| `clk`                | System clock                    |

| `rst`                | Synchronous reset               |

| `emergency\_override` | Global emergency request        |

| `A\_all\_red`          | Indicates A has reached all-red |

| `B\_all\_red`          | Indicates B has reached all-red |



\## Outputs



| Signal               | Purpose                              |

| -------------------- | ------------------------------------ |

| `emergency\_active`   | Indicates emergency mode             |

| `force\_A\_all\_red`    | Requests A to transition to all-red  |

| `force\_B\_all\_red`    | Requests B to transition to all-red  |

| `emergency\_complete` | Indicates both junctions are all-red |



\---



\# 15. Emergency Timing Requirement



The design target is:



```text

EMERGENCY\_RESPONSE\_CYCLES = 2

```



Therefore, after the emergency signal is recognized, both junctions shall reach a safe all-red condition within two clock cycles.



The emergency path has higher priority than:



```text

Normal FSM transitions

Green-wave operation

Pedestrian arbitration

```



Conceptually:



```text

emergency\_override

&#x20;      |

&#x20;      v

Emergency Controller

&#x20;      |

&#x20;      +--------> Junction A → ALL\_RED

&#x20;      |

&#x20;      +--------> Junction B → ALL\_RED

```



Once all-red is reached, the traffic outputs remain all-red while emergency mode is active.



\---



\# 16. Clocking Strategy



\## 16.1 Single Clock Domain



The complete design shall operate in a \*\*single synchronous clock domain\*\*.



All sequential modules shall use:



```text

posedge clk

```



as their clock edge.



There shall be no internally generated clocks.



This means:



```text

&#x20;                   +-------+

&#x20;                   |  clk  |

&#x20;                   +---+---+

&#x20;                       |

&#x20;         +-------------+-------------+

&#x20;         |             |             |

&#x20;         v             v             v

&#x20;      Junction A    Junction B    Arbiter

&#x20;         |

&#x20;         v

&#x20;   Green-Wave

```



\---



\## 16.2 Reason for Single Clock Domain



A single clock domain is selected because:



\* The two junctions need deterministic timing relative to one another.

\* The green-wave delay is measured in clock cycles.

\* Pedestrian arbitration requires predictable synchronous state updates.

\* Emergency response timing is specified in clock cycles.

\* It avoids unnecessary clock-domain-crossing logic.

\* Simulation and verification are simpler.



\---



\# 17. Reset Strategy



The design shall use a \*\*synchronous active-high reset\*\*.



```text

rst = 1

```



causes sequential state to reset on the next active clock edge.



\---



\## 17.1 Reset State



After reset:



```text

Junction A → ALL\_RED

Junction B → ALL\_RED

Pedestrian Arbiter → IDLE

Green-Wave Coordinator → IDLE

Emergency Controller → IDLE

```



Traffic lights shall therefore start in a safe condition.



\---



\## 17.2 Why Synchronous Reset



A synchronous reset is selected because the system is entirely within one clock domain.



Advantages include:



\* Predictable state transitions.

\* Reset behavior occurs on a defined clock edge.

\* Consistent simulation behavior.

\* No asynchronous timing behavior is required.

\* Simpler integration with the single-clock architecture.



The reset design also avoids asynchronous interactions between the two junction controllers.



\---



\# 18. Data and Control Flow



The overall control flow is:



```text

&#x20;                   +-------------+

&#x20;                   |    Clock    |

&#x20;                   +------+------+

&#x20;                          |

&#x20;                          v

&#x20;                 +------------------+

&#x20;                 | System Controller|

&#x20;                 +--------+---------+

&#x20;                          |

&#x20;         +----------------+----------------+

&#x20;         |                |                |

&#x20;         v                v                v

&#x20;  +-------------+  +-------------+  +-------------+

&#x20;  | Junction A  |  | Junction B  |  | Pedestrian  |

&#x20;  | Controller  |  | Controller  |  |   Arbiter   |

&#x20;  +------+------+  +------+------+  +------+------+

&#x20;         |                |                |

&#x20;         | NS Green       |                |

&#x20;         +-------+--------+                |

&#x20;                 |                         |

&#x20;                 v                         |

&#x20;         +---------------+                |

&#x20;         | Green-Wave    |                |

&#x20;         | Coordinator   |                |

&#x20;         +---------------+                |

&#x20;                                           |

&#x20;                             +-------------+

&#x20;                             |

&#x20;                             v

&#x20;                      Pedestrian Grants

```



Emergency control overrides the normal control flow:



```text

&#x20;                   emergency\_override

&#x20;                           |

&#x20;                           v

&#x20;                 +-------------------+

&#x20;                 | Emergency Control |

&#x20;                 +---------+---------+

&#x20;                           |

&#x20;                  +--------+--------+

&#x20;                  |                 |

&#x20;                  v                 v

&#x20;             Junction A       Junction B

&#x20;                ALL RED          ALL RED

```



\---



\# 19. Safety Properties



The following architectural safety properties shall be maintained.



\### SP-01 — No Simultaneous Green



For each junction:



```text

NS\_GREEN \&\& EW\_GREEN == 0

```



must always hold.



\---



\### SP-02 — Emergency All-Red



When emergency handling completes:



```text

A\_ALL\_RED == 1

B\_ALL\_RED == 1

```



\---



\### SP-03 — Green-Wave Does Not Bypass Safety



The green-wave trigger shall request a state transition but shall not directly force unsafe signal combinations.



\---



\### SP-04 — Pedestrian Service Is Controlled



A junction shall only enter pedestrian service when the shared arbiter grants it.



\---



\### SP-05 — Pending Requests Are Not Lost



A request that was not selected shall remain pending until it is served or explicitly withdrawn.



\---



\# 20. Verification Plan



Verification shall be performed after the architecture has been implemented in RTL.



At least the following scenarios shall be tested.



| #  | Test Scenario                                 | Expected Result                                                     |

| -- | --------------------------------------------- | ------------------------------------------------------------------- |

| 1  | Reset asserted                                | Both junctions enter all-red                                        |

| 2  | Reset released                                | Normal traffic sequencing begins                                    |

| 3  | Junction A NS green                           | A NS signals become green                                           |

| 4  | Junction A NS green expires                   | A transitions through yellow and all-red                            |

| 5  | Junction A EW green                           | A EW signals become green                                           |

| 6  | Junction B normal sequencing                  | B cycles through its normal states                                  |

| 7  | A NS green starts                             | Green-wave timer starts                                             |

| 8  | Green-wave delay expires                      | B receives NS-green coordination trigger                            |

| 9  | Green-wave delay not yet expired              | B does not prematurely start coordinated NS green                   |

| 10 | Pedestrian request from A only                | A receives pedestrian grant                                         |

| 11 | Pedestrian request from B only                | B receives pedestrian grant                                         |

| 12 | A and B request simultaneously                | Arbiter selects according to round-robin priority                   |

| 13 | Repeated simultaneous pedestrian requests     | Priority alternates; neither junction starves                       |

| 14 | New B request while A is being serviced       | B remains pending until it can be served                            |

| 15 | Emergency during NS green                     | Junctions transition safely to all-red                              |

| 16 | Emergency during EW green                     | Junctions transition safely to all-red                              |

| 17 | Emergency during pedestrian service           | Emergency handling takes priority                                   |

| 18 | Emergency during green-wave delay             | Green-wave operation is overridden                                  |

| 19 | Emergency remains asserted                    | Both junctions remain all-red                                       |

| 20 | Emergency released                            | System resumes normal operation according to defined restart policy |

| 21 | Reset during normal operation                 | System returns to all-red                                           |

| 22 | Simultaneous reset and pedestrian request     | Reset takes priority and system enters safe state                   |

| 23 | Simultaneous emergency and pedestrian request | Emergency takes priority                                            |

| 24 | Simultaneous emergency and green-wave event   | Emergency takes priority                                            |

| 25 | Long-duration operation                       | No illegal signal combination or FSM lock-up occurs                 |



\---



\# 21. Corner-Case Verification



Special attention shall be given to the following cases.



\### 21.1 Simultaneous Pedestrian Requests



Verify that both requests are eventually served.



Expected behavior:



```text

A + B

&#x20;↓

one selected

&#x20;↓

other remains pending

&#x20;↓

other selected

```



\---



\### 21.2 Emergency During Green-Wave



If emergency is asserted while the green-wave delay counter is active:



```text

green\_wave\_active → cancelled/overridden

```



Both junctions must transition to all-red.



\---



\### 21.3 Emergency During Pedestrian Service



Emergency shall override pedestrian scheduling.



The system shall prioritize reaching the required all-red state.



\---



\### 21.4 Request During Emergency



Pedestrian requests received during emergency mode shall not cause traffic signals to leave the emergency all-red condition.



The treatment of such requests shall be deterministic; pending requests may be retained for service after emergency mode depending on the final RTL policy.



\---



\### 21.5 Repeated Pedestrian Requests



Repeated requests from one junction shall not indefinitely prevent service to the other junction.



The round-robin mechanism shall maintain fairness.



\---



\# 22. Verification Assertions



The following properties should eventually be represented as simulation checks or SystemVerilog assertions.



\### Assertion 1 — No Conflicting Green



```text

NOT (NS\_GREEN \&\& EW\_GREEN)

```



for Junction A and Junction B.



\### Assertion 2 — Emergency All-Red



After the emergency response deadline:



```text

emergency\_active → A\_ALL\_RED \&\& B\_ALL\_RED

```



\### Assertion 3 — Green-Wave Timing



If A starts North-South green at cycle `N`, B's coordinated NS-green event shall occur at the configured delay.



```text

B\_NS\_GREEN\_START ≈ A\_NS\_GREEN\_START + GREEN\_WAVE\_DELAY

```



subject to B's safe transition constraints.



\### Assertion 4 — Fair Arbitration



When both pedestrian requests remain continuously asserted, service shall alternate between A and B.



\### Assertion 5 — Reset Safety



After reset:



```text

A\_ALL\_RED \&\& B\_ALL\_RED

```



shall be true.



\---



\# 23. Design Decisions



\## Decision 1 — Reusable Junction Controller



One generic junction controller module shall be instantiated twice.



Reason:



\* Avoids duplicated RTL.

\* Ensures both junctions have identical baseline behavior.

\* Simplifies maintenance and verification.



\---



\## Decision 2 — Separate Green-Wave Coordinator



The green-wave mechanism is separated from the junction FSM.



Reason:



\* It is a coordination function between two modules.

\* It keeps individual junction logic simpler.

\* It allows the delay to be configured independently.



\---



\## Decision 3 — Shared Pedestrian Arbiter



One arbiter serves both junctions.



Reason:



\* Centralized fairness.

\* Deterministic simultaneous-request behavior.

\* Avoids duplicated arbitration logic.

\* Makes starvation prevention explicit.



\---



\## Decision 4 — Round-Robin Arbitration



Round-robin arbitration is used for simultaneous requests.



Reason:



\* Simple hardware implementation.

\* Deterministic.

\* Prevents starvation.

\* Naturally alternates priority.



\---



\## Decision 5 — Global Emergency Override



One emergency input controls both junctions.



Reason:



\* Represents a system-wide emergency condition.

\* Ensures both junctions respond consistently.

\* Simplifies top-level control.



\---



\## Decision 6 — Single Clock Domain



All modules use the same clock.



Reason:



\* Required for deterministic cycle-based coordination.

\* Simplifies timing analysis.

\* Eliminates unnecessary clock-domain crossings.



\---



\## Decision 7 — Synchronous Reset



A synchronous reset is used.



Reason:



\* Consistent with the single-clock architecture.

\* Provides deterministic reset timing.

\* Ensures both junctions enter the known safe state on a clock edge.



\---



\# 24. Open Implementation Parameters



The following values shall be configurable during RTL implementation:



```text

NS\_GREEN\_TIME

NS\_YELLOW\_TIME

EW\_GREEN\_TIME

EW\_YELLOW\_TIME

ALL\_RED\_TIME

PED\_SERVICE\_TIME

GREEN\_WAVE\_DELAY

EMERGENCY\_RESPONSE\_CYCLES

```



For the initial architectural contract:



```text

GREEN\_WAVE\_DELAY          = configurable

EMERGENCY\_RESPONSE\_CYCLES = 2

```



The exact traffic phase durations may be selected according to the simulation clock and project constraints.



\---



\# 25. Expected RTL Modules



The architecture maps directly to the following RTL modules:



```text

traffic\_controller\_top

&#x20;       |

&#x20;       +-- junction\_controller (instance A)

&#x20;       |

&#x20;       +-- junction\_controller (instance B)

&#x20;       |

&#x20;       +-- pedestrian\_arbiter

&#x20;       |

&#x20;       +-- green\_wave\_controller

&#x20;       |

&#x20;       +-- emergency\_controller

```



No RTL implementation is part of Task 1.



The purpose of this document is to establish the interfaces, responsibilities, timing assumptions, safety requirements, and verification strategy before RTL development begins.



\---



\# 26. Summary



The proposed system consists of two reusable traffic-junction controllers coordinated by system-level control logic.



The architecture separates responsibilities:



```text

Junction Controller

&#x20;   → controls local traffic signals



Green-Wave Coordinator

&#x20;   → coordinates NS traffic between A and B



Pedestrian Arbiter

&#x20;   → centrally and fairly schedules pedestrian requests



Emergency Controller

&#x20;   → provides global emergency handling



Top-Level Controller

&#x20;   → integrates the complete system

```



Both junctions operate from the same clock and synchronous reset. The green-wave coordinator synchronizes North-South traffic between the junctions, while the shared round-robin pedestrian arbiter ensures fair service when requests occur simultaneously. A global emergency override has the highest priority and causes both junctions to reach an all-red state within the specified response window.



This architecture provides the foundation for the subsequent RTL implementation and verification stages.



