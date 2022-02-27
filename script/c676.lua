--Kariel The Guardian of Darkness
local s,id=GetID()
function s.initial_effect(c)
	--Your "Darkness" cards cannot be destroyed by card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(TIMING_END_PHASE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Add this from the GY to hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)return eg:IsExists(s.thfilter,1,nil,tp) end)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil) end
end
function s.filter(c)
	return c:IsFaceup() and (c:IsCode(44330098) or c:IsSetCard(0x4602))
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local cphase=Duel.GetCurrentPhase()
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,0,nil)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		--Cannot be destroyed by card effect
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3001)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+cphase)
		tc:RegisterEffect(e1)
	end
end
function s.thfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and (c:IsCode(44330098) or c:IsSetCard(0x4602))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
	--Add this banished card to hand
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end