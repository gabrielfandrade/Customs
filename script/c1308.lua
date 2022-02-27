--Samurai Blader
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--Equip all Equip cards to this card
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
end
function s.eqfilter(c,ec)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP) and c:GetEquipTarget()~=ec and c:CheckEquipTarget(ec)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,c)
	end
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() then
		local g=Duel.GetMatchingGroup(s.eqfilter,tp,LOCATION_SZONE,LOCATION_SZONE,nil,c)
		for ec in ~g do 
			Duel.Equip(tp,ec,c,true)
		end
		Duel.EquipComplete()
	end
end