--Crystalline White Dragon
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,s.xyzfilter,nil,2,s.ovfilter,aux.Stringid(id,0),nil,nil,false,s.xyzcheck)
	--immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	--indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(s.indes)
	c:RegisterEffect(e2)
	--
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.negcon)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
	--destroy replace
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.reptg)
	c:RegisterEffect(e4)
end
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:GetCounter(0x1015)~=0 and c:IsLevel(6) and c:GetOwner()==1-tp
end
function s.xyzfilter(c,xyz,sumtype,tp)
	return c:IsType(TYPE_XYZ,xyz,sumtype,tp) and not c:IsSetCard(0x48,xyz,sumtype,tp)
end
function s.xyzcheck(g,tp,xyz)
	return g:GetClassCount(Card.GetRank)==1
end
function s.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:GetHandler():GetCounter(0x1015)~=0
end
function s.indes(e,c)
	return c:GetCounter(0x1015)~=0
end
function s.tfilter(c,tp)
	return c:IsFaceup() and c:GetCounter(0x1015)~=0 and c:IsLocation(LOCATION_ONFIELD)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return e:GetHandler():GetFlagEffect(id)==0 and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) 
		and re:GetOwnerPlayer()~=e:GetHandlerPlayer()
		and g and g:IsExists(s.tfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(re,REASON_EFFECT)
	end
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		return true
	else return false end
end
