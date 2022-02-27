--Served HERO Archer of the Esmerald Dragon of South
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
	--Send to the hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	--Send 1 card your opponent controls to the GY
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_TOGRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCountLimit(1)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.tgtg)
	e4:SetOperation(s.tgop)
	c:RegisterEffect(e4)
end
function s.afilter(c,fc,sumtype,tp,sub,mg,sg,contact)
	if contact then sumtype=0 end
	return c:IsAttribute(ATTRIBUTE_WIND,fc,sumtype,tp) and (not contact or c:IsType(TYPE_MONSTER,fc,sumtype,tp))
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
	return c:IsSetCard(0x3e7) and c:IsAttribute(ATTRIBUTE_WIND)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,0)
	Duel.SetChainLimit(s.chlimit)
end
function s.chlimit(e,ep,tp)
	return tp==ep
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_MZONE,nil)
	if #g<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local sg=g:Select(tp,1,2,nil)
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
end
function s.filter1(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAbleToDeck()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingTarget(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g1=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,1,0,0)
	e:SetLabelObject(g1:GetFirst())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g2=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g2,1,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc1=e:GetLabelObject()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc2=g:GetFirst()
	if tc1==tc2 then tc2=g:GetNext() end
	if tc1:IsRelateToEffect(e) and Duel.SendtoDeck(tc1,nil,2,REASON_EFFECT)~=0 then
		if tc2:IsRelateToEffect(e) then
			Duel.SendtoGrave(tc2,REASON_EFFECT)
		end
	end
end