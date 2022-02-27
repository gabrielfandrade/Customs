--Servi, Twin-Headed Dragon
local s,id=GetID()
function s.initial_effect(c)
	--Non-tuner
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_NONTUNER)
	e1:SetValue(s.ntval)
	c:RegisterEffect(e1)
	--synchrolv
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SYNCHRO_LEVEL)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.synchrolv)
	c:RegisterEffect(e2)
end
function s.ntval(c,sc,tp)
	return sc and (sc:IsSetCard(0x3dc) or sc:IsSetCard(0x3e7))
end
function s.synchrolv(e,c,rc)
	if rc:IsCode(9030) then
		return 6,e:GetHandler():GetLevel()
	else
		return e:GetHandler():GetLevel()
	end
end