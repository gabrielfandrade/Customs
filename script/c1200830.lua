--Queen of the Realms of Legends
--King of the Realms of Legends
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	c:EnableReviveLimit()
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetCondition(s.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--ritual level
	Ritual.AddWholeLevelTribute(c,aux.FilterBoolFunction(Card.IsType,TYPE_RITUAL))
end
function s.filter(c)
	return c:IsFaceup()
end
function s.indcon(e)
	return Duel.IsExistingMatchingCard(Card.IsType,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,TYPE_RITUAL)
end