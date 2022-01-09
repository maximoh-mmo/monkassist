--[[
    Created by maximoh

    Designed as a combat aid, to maximise DPS whilst minimizing Carpal Tunnel Syndrome!
--]]

local mq = require('mq')

local debug = true
local function output(msg) print('\a-t[Monk Assist] '..msg) end
local trigger = 0
local terminate = false

-- bind handler
local function bind_monk(action)
    if action == 'on' then
        trigger = 1
        output('\ayMonk Assist: on')
    elseif action == 'off' then
        trigger = 0
        output('\ayMonk Assist: off')
    elseif action == nil then
        output('\ar no command given... try again.')
    else
        output('\ar command \"'..action..'\" does not exist... try again.')
    end
end

local function checkBuffs()
--[[ /if (${Spell[Familiar: Emperor Ganak].Stacks} && !${Me.Buff[Familiar: Emperor Ganak].ID} && !${Me.Moving} && !${Me.Invis}) /useitem "Emperor Ganak Familiar"
/if (!${Me.Aura[Master's Aura].ID} && !${Me.Invis} && !${Me.Moving} && ${Me.CombatAbilityReady[master's aura]} && !${Me.Invis}) /disc master's aura
/if (!${Me.Buff[Revival Sickness].ID} && !${Me.Buff[Resurrection Sickness].ID} && ${Me.PctEndurance}<21 && ${Me.CombatAbilityReady[Breather]}) /disc Breather
/if (${Spell[Twitching Speed].Stacks} && !${Me.Buff[Twitching Speed].ID} && !${Me.Moving} && !${Me.Invis} && ${Me.Haste}<200) /casting 52123
/if (${Me.Buff[Summon Familiar: Emperor Ganak].ID}) /removebuff Summon Familiar: Emperor Ganak
/if (${Cast.Ready[Chalandria's Fang]}) /casting 43987
/if (${Cursor.ID}==76910) /autoinv

/if (!${Me.Moving} && ${Me.Standing} && !${Me.Feigning} && !${Me.Invis} && ${Zone.ID}!=344)
--]]
    output('Checking for missing Buffs')
end

local function setup()
    mq.bind('/monk', bind_monk)
    output('\ayMonk Assist by maximoh - \atLoaded.')
    output('\ayUsage: /monk [on|off]')
end

local function outOfCombat()
    output('\ar not in Combat')
    -- precheck if it's time to buff
    if not mq.TLO.Me.Moving() and mq.TLO.Me.Standing and not mq.TLO.Me.Feigning() then
        checkBuffs()
    end
end

local function inCombat()
    output('\ar in Combat')
end


local function main()
  while not terminate do
    if trigger == 1 then
        if mq.TLO.Me.Combat() then
            inCombat()
            terminate = true
        elseif mq.TLO.Zone.ID() ~= 344 then
            outOfCombat()
            terminate = true
        end
    end
    mq.delay(100)
  end
end

setup()
main()
