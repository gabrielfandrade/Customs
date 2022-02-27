--Fortune's Past
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local params = {aux.FilterBoolFunction(Card.IsSetCard,0x31),Fusion.OnFieldMat(Card.IsAbleToRemove),s.fextra,Fusion.BanishMaterial}
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target(params))
	c:RegisterEffect(e1)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(aux.exccon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	end
	return nil
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x31) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	
end
function s.target(params)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		local b2=Fusion.SummonEffTG(table.unpack(params))
		if chk==0 then return b1 or b2 end
		local stable={}
		local dtable={}
		if b1 then
			table.insert(stable,1)
			table.insert(dtable,aux.Stringid(id,0))
		end
		if b2 then
			table.insert(stable,2)
			table.insert(dtable,aux.Stringid(id,1))
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
		local op=stable[Duel.SelectOption(tp,table.unpack(dtable))+1]
		e:SetLabel(op)
		if op==1 then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
			e:SetOperation(s.spop)
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
		elseif op==2 then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
			e:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
			e:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
		end
	end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local sg=Duel.GetMatchingGroup(s.lvfilter,tp,LOCATION_MZONE,0,nil)
		local tc=sg:GetFirst()
		for tc in aux.Next(sg) do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
function s.thfilter(c)
	return c:IsCode(1200040) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end