-- ==========================================================================================
--
-- Finite State Machine Class for Lua 5.1 & Defold
-- 
-- Written by Erik Cornelisse, inspired by Luiz Henrique de Figueiredo
-- E-mail: e.cornelisse@gmail.com
-- 
-- Edited by Alp Ertunga Elgün
-- E-mail: elgunalp1@gmail.com
--
-- Version 1.0  April 27, 2011
-- 
-- Class is MIT Licensed
-- 
-- ==========================================================================================

local M = {}

-- FSM CONSTANTS --------------------------------------------------------------
local SEPARATOR = '.'
local ANY       = '*'
local ANYSTATE  = ANY .. SEPARATOR
local ANYEVENT  = SEPARATOR .. ANY
local UNKNOWN   = ANYSTATE .. ANY

function M.new(t)
	
	local fsm = {}
	
	-- ATTRIBUTES -------------------------------------------------------------
	local state = t[1][1]	-- current state, default the first one
	local stt = {}			-- state transition table
	local str = ""			-- <state><SEPARATOR><event> combination
	local silence = false	-- use silent() for whisper mode
		
	-- METHODS ----------------------------------------------------------------	
	
	-- some getters and setters
	function fsm.set(s) state = s end
	function fsm.get() return state	end
	function fsm.silent() silence = (not silence) end

	-- default exception handling
	local function exception() 
		if not silence then 
			print("FSM: unknown combination: " .. str) end

		return false
	end	
	
	-- respond based on current state and event
	-- Added vararg to call actions func with args
	function fsm.fire(event, ...)
		local act = stt[state .. SEPARATOR .. event]
		-- raise exception for unknown state-event combination
		if act == nil then 
			-- search for wildcard "states" for this event
			act = stt[ANYSTATE .. event]
			-- if still not a match than check any event
			if act == nil then
				-- check if there is a wildcard event
				act = stt[state .. ANYEVENT]
				if act == nil then
					act = stt[UNKNOWN]; str = state .. SEPARATOR .. event
				end
			end
		end
		-- set next state as current state
		state = act.newState	
		
		-- Call with go_self
		return act.action(...)
	end

	-- add new state transitions to the FSM
	function fsm.add(t)
		for _,v in ipairs(t) do
			local oldState, event, newState, action = v[1], v[2], v[3], v[4]
			
			stt[oldState .. SEPARATOR .. event] = {newState = newState, action = action}
		end

		return #t	-- the requested number of state-transitions to be added 
	end
	
	-- remove state transitions from the FSM
	function fsm.delete(t)
		for _,v in ipairs(t) do
			local oldState, event = v[1], v[2]
			if oldState == ANY and event == ANY then
				if not silence then
					print( "FSM: you should not delete the exception handler" )
					print( "FSM: but assign another exception action" )
				end 
				-- assign default exception handler but stay in current state
				stt[exception] = {newState = state, action = exception}

			else
				stt[oldState .. SEPARATOR .. event] = nil
			end
		end

		return #t 	-- the requested number of state-transitions to be deleted
	end
	
	-- initalise state transition table
	stt[UNKNOWN] = {newState = state, action = exception}
	
	fsm.add(t)

	-- return FSM methods
	return fsm
end

return M