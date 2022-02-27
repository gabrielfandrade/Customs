--Served HERO Paladin of the Quartz Dragon of Sky
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,s.sfilter,s.afilter)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	--Fusion Substitute
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_FUSION_SUBSTITUTE)
	e1:SetCondition(s.subcon)
	e1:SetValue(s.subval)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(id)
	e2:SetRange(LOCATION_EXTRA+LOCATION_ONFIELD+LOCATION_GRAVE)
	c:RegisterEffect(e2)
	--Banish up to 2 cards your opponent controls
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(s.retg)
	e3:SetOperation(s.reop)
	c:RegisterEffect(e3)
	--Send 1 card from your opponent's Deck to the GY
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_DECKDES)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCountLimit(1)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.sdtg)
	e4:SetOperation(s.sdop)
	c:RegisterEffect(e4)
end
function s.afilter(c,fc,sumtype,tp,sub,mg,sg,contact)
	if contact then sumtype=0 end
	return c:IsAttribute(ATTRIBUTE_LIGHT,fc,sumtype,tp) and (not contact or c:IsType(TYPE_MONSTER,fc,sumtype,tp))
end
function s.sfilter(c,fc,sumtype,tp,sub,mg,sg,contact)
	if contact then sumtype=0 end
	return c:IsSetCard(0x3d1,fc,sumtype,tp) and c:IsSetCard(0x8,fc,sumtype,tp)
		and (not contact or c:IsType(TYPE_MONSTER,fc,sumtype,tp))
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,nil)
end
function s.contactop(g)
	Duel.SendtoGrave(g,REASON_COST+REASON_MATERIAL)
end
function s.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
function s.subcon(e)
	return e:GetHandler():IsLocation(LOCATION_EXTRA+LOCATION_ONFIELD+LOCATION_GRAVE)
end
function s.subval(e,c)
	return c:IsSetCard(0x3e7) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.retg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
	Duel.SetChainLimit(s.chlimit)
end
function s.chlimit(e,ep,tp)
	return tp==ep
end
function s.reop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	if #g<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=g:Select(tp,1,2,nil)
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end
function s.filter1(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAbleToDeck()
end
function s.sdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.GetFieldGroupCount(ep,LOCATION_HAND,0)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g1=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,1)
end
function s.sdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc and tc:IsRelateToEffect(e) 
		and Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)~=0 then
		Duel.BreakEffect()
		Duel.DiscardDeck(1-tp,1,REASON_EFFECT)
	end
end