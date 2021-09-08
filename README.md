A design pattern for doing finite state machines (FSMs) in Lua.  

Based on a very appreciated contribution of Luiz Henrique de Figueiredo  
Original code from http://lua-users.org/wiki/FiniteStateMachine

The FSM is described with: old_state, event, new_state and action.  
One easy way to do this in Lua would be to create a table in exactly the form above:  
```
yourStateTransitionTable = { 
	{state1, event1, state2, action1},
	{state1, event2, state3, action2},
	...
}
```
The function FSM takes the simple syntax above and creates tables:  
```
for (state, event) pairs with fields (action, new):

function FSM(yourStateTransitionTable)
  local stt = {}
  for _,v in ipairs(t) do
    local old, event, new, action = v[1], v[2], v[3], v[4]
    if stt[old] == nil then a[old] = {} end
    stt[old][event] = {new = new, action = action}
  end
  return stt
end
```
Note that this scheme works for states and events of any type: number,  
string, functions, tables, anything. Such is the power of associate arrays.  

However, the double array stt[old][event] caused a problem for event = nil  
Instead a single array is used, constructed as stt[state .. SEPARATOR .. event]   
Where SEPARATOR is a constant and defined as '.'

Three special state transitions are added to the original code:
- any state but a specific event
- any event but a specific state
- unknown state-event combination to be used for exception handling

The any state and event are defined by the ANY constant, defined as "\*"  
The unknown state-event is defined as the combination of ANY.ANY (\*.\*)  

A default exception handler for unknown state-event combinations is
provided and therefore a specification a your own exception handling is
optional.

After creating a new FSM, the initial state is set to the first defined
state in your state transition table. With add(t) and delete(t), new state
transition can be added and removed later.  

A DEBUG-like method called silent is included to prevent wise-guy remarks
about things you shouldn't be doing.  

USAGE EXAMPLES:
-------------------------------------------------------------------------------
```
FSM = require "fsm"

function action1() print("Performing action 1") end

function action2(is_true, is_false)
	if is_true and not is_false then
		print("Performing action 2")
	end
end

-- Define your state transitions here
local myStateTransitionTable = {
	{"state1", "event1", "state2", action1},
	{"state2", "event2", "state3", action2},
	{"*",      "event3", "state2", action1},  -- for any state
	{"*", 	   "*",	     "state2", action2}   -- exception handler
}

-- Create your finite state machine
fsm = FSM.new(myStateTransitionTable)

-- Use your finite state machine 
-- which starts by default with the first defined state
print("Current FSM state: " .. fsm.get())

-- Or you can set another state
fsm.set("state2")							
print("Current FSM state: " .. fsm.get())

-- Resond on "event" and last set "state"
fsm.fire("event2", true, false)
print("Current FSM state: " .. fsm.get())

Output:
-------
Current FSM state: state1
Current FSM state: state2
Performing action 2
Current FSM state: state3
```
