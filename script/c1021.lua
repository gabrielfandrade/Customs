--Snowdust Storm
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)		
end
s.counter_place_list={0x1015}
function s.filter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsLevelBelow(6) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		if Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,2000,2000,6,RACE_ROCK,ATTRIBUTE_WATER,POS_FACEUP,1-tp) and Duel.SelectYesNo(p,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			local token=Duel.CreateToken(tp,id+1)
			if Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP)~=0 then
				local lv=g:GetFirst():GetLevel()
				local g2=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
				if #g2==0 then return end
				for i=1,lv do
					local sg=g2:Select(tp,1,1,nil)
					sg:GetFirst():AddCounter(0x1015,1)
				end
			end
		end
	end
end