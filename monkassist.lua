--[[
    Created by maximoh

    Designed as a combat aid, to maximise DPS whilst minimizing Carpal Tunnel Syndrome!
--]]

local mq = require('mq')

local debug = true
local function output(msg) print('\a-t[Monk Assist] '..msg) end
local monkMode = false
local burnMode = 0

local terminate = false

local spamDiscs = {'Icewalker\'s Synergy','Barrage of Fists','Doomwalker\'s Precision Strike','Firewalker\'s Precision Strike','Icewalker\'s Precision Strike','Vigorous Shuriken','Curse of Fifteen Strikes','Zlexak\'s Fang','Drunken Monkey Style'}
local abilities = {'Intimidation'}
--[[
    On Loading check for ini file?
    If ini exists load all data into memory

    If no ini file generate one
    Sections dependant on class
    fail on non monk


Monk Logic path

is there a shaman in group?

if yes hold best discs for shaman epic

shaman epic running time, epic cooldown time

monk disc stack/overlap/timing

assuming always end available what's the ideal rotation?


    
--]]

-- bind handler
local function bind_monk(action, toggle)
    if action == 'burn' then
        if toggle == 'constant' or toggle == '2' then
            burnMode = 2
            output('\ayBurn Mode: constant')
        elseif toggle == 'manual' or toggle == '1' then
            burnMode = 1
            output('\ayBurn Mode: constant')
        elseif toggle == 'off' or toggle == 'false' or toggle == '0' then
            burnMode = 0
            output('\ayBurn Mode: off')
        elseif toggle == nil then
        output('\ar no command given... try again.')
        end
    elseif action == 'on' or action == 'true' or action == '1' then
        monkMode = true
        output('\ayMonk Assist: on')
    elseif action == 'off' or action == 'false' or action == '0' then
        monkMode = false
        output('\ayMonk Assist: off')
    elseif action == nil then
        output('\ar no command given... try again.')
    else
        output('\ar command \"'..action..'\" does not exist... try again.')
    end
end

local function checkBuffs()
    if not mq.TLO.Me.Buff('Familiar: Emperor Ganak')() then
            mq.cmdf('/casting "Emperor Ganak Familiar"')
    end
    if not mq.TLO.Me.Aura('Master\'s Aura')() and mq.TLO.Me.CombatAbilityReady('Master\'s Aura') then
        mq.cmdf('/disc Master\'s Aura')
    end 
    if not mq.TLO.Me.Buff('Revival Sickness')() and not mq.TLO.Me.Buff('Resurrection Sickness')() and mq.TLO.Me.PctEndurance()<21 and mq.TLO.Me.CombatAbilityReady('Breather')() then
        mq.cmdf('/disc Breather')
    end
    if mq.TLO.FindItem('52123')() then
        if mq.TLO.Spell('Twitching Speed').Stacks() and not mq.TLO.Me.Buff('Twitching Speed')() and mq.TLO.Me.Haste()<200 then
            mq.cmdf('/casting 52123')
        end
    end
    if mq.TLO.FindItem('43987')() then
        if mq.TLO.Cast.Ready('43987')() then
            mq.cmdf('/casting 43987')
        end
    end
    if mq.TLO.Cursor.ID()==76910 then
        mq.cmdf('/autoinv')
    end
end

local function doConstantBurn()
if not mq.TLO.Me.ActiveDisc() then
    --check which disc's available, run best and available support
end

local function doManualBurn()
if mq.TLO.Me.ActiveDisc() then
    --check which disc, run best available support
end

local function doSpam()
    -- Run Spam spamDiscs
    for i=1, #spamDiscs do
        if mq.TLO.Me.CombatAbilityReady(spamDiscs[i]..' Rk. III')() then
            mq.cmdf('/disc '..spamDiscs[i])
        end
        if mq.TLO.Me.CombatAbilityReady(spamDiscs[i]..' Rk. II')() then
            mq.cmdf('/disc '..spamDiscs[i])
        end
        if mq.TLO.Me.CombatAbilityReady(spamDiscs[i])() then
            mq.cmdf('/disc '..spamDiscs[i])  
        end
    end
    -- Run Abilities
    for i=1, #abilities do
        if mq.TLO.Me.AbilityReady(abilities[i])() then
            mq.cmdf('/doability '..abilities[i])
        end
    end
    -- Run Burns dependant on mode
    if burnMode > 0 then
        if burnMode == 1 then
            doConstantBurn()
        elseif burnMode == 2 then
            doManualBurn()
        else
            output('\ar no command given... try again.')
        end   
    end
end

local function epic()
    if mq.TLO.FindItem('67742')() then
        if mq.TLO.Cast.Ready('67742')() then
            mq.cmdf('/casting 67742')
        end
    end
end

local function setup()
    mq.bind('/monk', bind_monk)
    output('\ayMonk Assist by maximoh - \atLoaded.')
    output('\ayUsage: /monk [on|off]')
    output('\ayUsage: /monk burn [constant|manual|off]')
end

local function outOfCombat()
    -- precheck if it's time to buff
    if not mq.TLO.Me.Moving() and mq.TLO.Me.Standing and not mq.TLO.Me.Feigning() and not mq.TLO.Me.Casting() then
        checkBuffs()
    end
end

local function inCombat()
  output('\ar in Combat')
  while mq.TLO.Me.Combat() do
    if not test and mq.TLO.Target() then
        if mq.TLO.Target.PctHPs() < 100 then
            if mq.TLO.Target.Distance() < mq.TLO.Target.MaxMeleeTo() then
                doSpam()
            end
        end
    end
  end
end


local function main()
  while not terminate do
    if monkMode then
        if mq.TLO.Me.Combat() then
            inCombat()
        elseif mq.TLO.Zone.ID() ~= 344 then
            outOfCombat()
        end
    end
    mq.delay(100)
  end
end

setup()
main()
