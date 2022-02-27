--Servanas' Legacy
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.filter)
	e2:SetValue(s.indval)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsFaceup() 
		and (c:IsSetCard(0x3e7) or c:IsSetCard(0x3d1) or c:IsSetCard(0x3dc))
		and (c:IsType(TYPE_FUSION) or c:IsType(TYPE_SYNCHRO) or c:IsType(TYPE_XYZ))
end
function s.indval(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and not re:GetHandler():IsAttribute()
end