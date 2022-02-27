--The Song of the Last Lover 
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,1})
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsReleasableByEffect()
end
function s.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsLevel(1) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	if ct>2 then ct=2 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local dg=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,dg,#dg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,#dg,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	local ct=Duel.Release(sg,REASON_EFFECT)
	local th=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if ct==0 or #th==0 then return end
	if ct>th:GetClassCount(Card.GetCode) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g1=th:Select(tp,1,1,nil)
	if ct==2 then
		th:Remove(Card.IsCode,nil,g1:GetFirst():GetCode())
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g2=th:Select(tp,1,1,nil)
		g1:Merge(g2)
	end
	Duel.SendtoHand(g1,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g1)
end