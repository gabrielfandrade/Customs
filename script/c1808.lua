--Dark Gear Beast
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon condition
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.spconlimit)
	c:RegisterEffect(e1)
end
function s.spconlimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS) and se:GetHandler():IsRace(RACE_MACHINE)
end