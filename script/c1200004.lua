--Night End Ruler Dragon
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,s.sfilter,1,99,Synchro.NonTunerEx(s.sfilter),1,99)
	c:EnableReviveLimit()
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.synlimit)
	c:RegisterEffect(e1)
end
function s.sfilter(c,val,scard,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_DARK,scard,sumtype,tp) and c:IsType(TYPE_SYNCHRO,scard,sumtype,tp)
end
function s.chlimit(e,ep,tp)
	if not e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) then return end
	return tp==ep
end