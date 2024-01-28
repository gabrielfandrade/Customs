--B-Bolt
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon and discard this card and 1 other Thunder monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Target 2 Level 3 Thunder monsters in the GY with the same name to return to the deck and Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end

function s.spcostfilter(c,e,tp,dc_chk,sp_chk)
	return c:IsRace(RACE_THUNDER) and not c:IsPublic()
		and ((sp_chk and c:IsDiscardable(REASON_EFFECT)) or (dc_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local dc_chk=c:IsDiscardable(REASON_EFFECT)
	local sp_chk=c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	if chk==0 then return (dc_chk or sp_chk) and not c:IsPublic()
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_HAND,0,1,c,e,tp,dc_chk,sp_chk) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_HAND,0,1,1,c,e,tp,dc_chk,sp_chk)
	g:AddCard(c)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,g,1,0,0)
end
function s.spfilter(c,e,tp,g)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and g:IsExists(Card.IsDiscardable,1,c,REASON_EFFECT)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
	local g=Duel.GetTargetCards(e)
	if #g~=2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:FilterSelect(tp,s.spfilter,1,1,nil,e,tp,g)
	if #sg==1 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		Duel.SendtoGrave(g:Sub(sg),REASON_EFFECT|REASON_DISCARD)
	end
end

function s.thunderfilter(c,e,tp)
	return c:IsRace(RACE_THUNDER) and c:IsLevel(3) and c:IsCanBeEffectTarget(e)
		and (c:IsAbleToDeck() or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetCode)==1 and #sg==2 and sg:IsExists(s.spcheck,1,nil,sg,e,tp)
end
function s.spcheck(c,sg,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (sg-c):GetFirst():IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.thunderfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,1,tp,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g~=2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local td=g:FilterSelect(tp,Card.IsAbleToDeck,1,1,nil)
	if #td==0 then return end
	Duel.HintSelection(td,true)
	g:RemoveCard(td)
	if Duel.SendtoDeck(td,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and #g>0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end