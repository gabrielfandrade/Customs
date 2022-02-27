--Existence of the Knowledge
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Search "Herald of Parahax" monsters after Ritual Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(2)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--Change form of 1 "Herald of Parahax"
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
function s.thcfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL) and c:IsControler(tp) and c:IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.thcfilter,1,nil,tp)
end
function s.thfilter(c)
	return c:IsSetCard(0x4f6) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_PZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	local dg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	local ct=math.min(2,dg:GetClassCount(Card.GetCode))
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local td=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_PZONE,0,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,td,#td,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,#td,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local td=tg:Filter(Card.IsRelateToEffect,nil,e)
	if not tg or #td<=0 then return end
	if Duel.SendtoDeck(td,nil,0,REASON_EFFECT)~=0 then
		local dg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
		if dg:GetClassCount(Card.GetCode)==0 
			or dg:GetClassCount(Card.GetCode)<#tg then return end
		local g=Group.CreateGroup()
		for i=1,#tg do
			local tc=dg:Select(tp,1,1,td):GetFirst()
			g:AddCard(tc)
			dg:Remove(Card.IsCode,nil,tc:GetCode())
		end
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.cfilter(c,e,tp,ft)
	return c:IsSetCard(0x4f6) and c:HasLevel() and (c:IsControler(tp) or c:IsFaceup())
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp,c:GetLevel(),c:GetCode())
end
function s.spfilter(c,e,tp,lvl,code)
	if c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)==0 then return false end
	return c:IsSetCard(0x4f6) and c:IsType(TYPE_MONSTER) and c:IsLevel(lvl) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
		and c:IsCanBeSpecialSummoned(e,0,tp,true,true) and not c:IsCode(code) 
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,nil,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local tc=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,nil,nil,e,tp):GetFirst()
	e:SetLabel(tc:GetLevel(),tc:GetCode())
	Duel.Release(tc,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		return true
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_EXTRA+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lvl,code=e:GetLabel()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp,lvl,code)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,true,true,POS_FACEUP) then
		-- Cannot be tributed
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3303)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
	Duel.SpecialSummonComplete()
end