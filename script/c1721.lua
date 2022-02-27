--World Change
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Ritual Summon
	local e2=Ritual.CreateProc({handler=c,lvtype=RITPROC_EQUAL,filter=s.ritualfilter,lv=8,matfilter=aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT+ATTRIBUTE_DARK),stage2=s.ritualop})
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCost(s.ritualcost)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsLevel(8) and c:IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_LIGHT) and c:IsRace(RACE_BEAST+RACE_DRAGON+RACE_WARRIOR) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.ritualfilter(c)
	return c:IsLevel(8) and c:IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_LIGHT) and c:IsRace(RACE_BEAST+RACE_DRAGON+RACE_WARRIOR)
end
function s.ritualcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost()
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp) end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.filter2(c,tp)
	return c:IsCode(667,1770) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.ritualop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	aux.PlayFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
end