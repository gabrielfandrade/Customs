--Book of the Divine Arts
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.fcfilter(c)
	return (c:IsCode(1770) or (c:IsSetCard(0x1700) and c:IsType(TYPE_EQUIP))) and c:IsAbleToHand()
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(1770,1777)		
end
function s.thfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsSetCard(0x1700) and c:IsAbleToHand()
end
function s.mcfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT) 
		and c:IsRace(RACE_WARRIOR) 
		and c:GetLevel()==8
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.fcfilter,tp,LOCATION_DECK,0,1,nil)
			or (Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil) 
			and Duel.IsExistingMatchingCard(s.mcfilter,tp,LOCATION_DECK,0,1,nil,e,tp))
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.IsExistingMatchingCard(s.fcfilter,tp,LOCATION_DECK,0,1,nil)
	local b=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil) 
		and Duel.IsExistingMatchingCard(s.mcfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	if not a and not b then return end
	if (not a and b) or (b and Duel.SelectYesNo(tp,aux.Stringid(id,1))) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.mcfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local cg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			if #cg>0 then Duel.SendtoHand(cg,nil,REASON_EFFECT) end
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.fcfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end