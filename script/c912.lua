--Shocking Fox
local s,id=GetID()
function s.initial_effect(c)
	--Special summon itself from hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
	--If added to hand besides drawing
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsReason(REASON_DRAW)
end
	--Activation legality
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
	--Special summon itself from hand, restricted to machine monsters for rest of turn
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsRace,RACE_THUNDER),tp,LOCATION_MZONE,0,1,c)
end
function s.filter1(c)
	return c:IsCode(id) and c:IsAbleToHand()
end
function s.filter2(c)
	return ((c:IsCode(id)) or c:IsRace(RACE_THUNDER)) and c:IsAbleToHand()
end
function s.envfilter(c)
	return c:IsFaceup() and c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if not Duel.IsExistingMatchingCard(s.envfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler()) then
			return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil) end
		return Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=nil
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	if not Duel.IsExistingMatchingCard(s.envfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler()) then
		g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_DECK,0,1,1,nil)
	else g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,1,1,nil) end
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end