--For Tormentas!
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--Attach 1 Thunder monster from your hand as material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.mattg)
	e2:SetOperation(s.matop)
	c:RegisterEffect(e2)
end

function s.get_count(g)
	if #g==0 then return 0 end
	local ret=0
	repeat
		local tc=g:GetFirst()
		g:RemoveCard(tc)
		local ct1=#g
		g:Remove(Card.IsCode,nil,tc:GetCode())
		local ct2=#g
		local c=ct1-ct2+1
		if c>ret then ret=c end
	until #g==0 or #g<=ret
	return ret
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	local ct=s.get_count(g)
	return ct>1
end
function s.desfilter(c,e)
	return (c:IsType(TYPE_MONSTER) or c:IsType(TYPE_SPELL+TYPE_TRAP))
		and c:IsCanBeEffectTarget(e)
end
function s.rescon(sg)
	return #sg==1 or (sg:IsExists(Card.IsType,1,nil,TYPE_MONSTER) and sg:IsExists(Card.IsType,1,nil,TYPE_SPELL+TYPE_TRAP))
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil,e)
	if chk==0 then return #g>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tg=aux.SelectUnselectGroup(g,e,tp,1,2,s.rescon,1,tp,HINTMSG_DESTROY)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

function s.xyzfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_THUNDER) and c:IsType(TYPE_XYZ)
end
function s.matfilter(c)
	return c:IsRace(RACE_THUNDER)
end
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.xyzfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g=Duel.SelectMatchingCard(tp,s.matfilter,tp,LOCATION_HAND,0,1,1,nil)
		if #g>0 then
			Duel.Overlay(tc,g)
		end
	end
end