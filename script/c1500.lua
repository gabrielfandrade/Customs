--Clamoring the God's of Space
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.afilter1(c)
	return c:GetLevel()==10 and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsDiscardable()
end
function s.afilte2(c,tp)
	return c:GetLevel()==10 and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.afilter3(c)
	return c:IsCode(1555)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCurrentPhase()~=PHASE_MAIN2 end
	
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(1,0)
	Duel.RegisterEffect(e2,tp)
	
	local b1=Duel.IsPlayerCanDraw(tp,2)
	local b2=Duel.IsExistingMatchingCard(s.efilter1,tp,LOCATION_DECK,0,3,nil,e,tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
	local b3=Duel.IsExistingMatchingCard(afilter3,tp,LOCATION_MZONE,0,1,nil) 
	if chk==0 then return b1 or b2 or b3 end
	local op=0
	if b1 and b2 and b3 then
		if Duel.IsExistingMatchingCard(s.afilter3,tp,LOCATION_MZONE,0,1,nil) then
			op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))
		else
			op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
		end
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0))
	elseif b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,2))+1
	end
	e:SetLabel(op)
	
	if op==0 then
		if chk==0 then return Duel.IsExistingMatchingCard(s.afilter1,tp,LOCATION_HAND,0,1,nil) end
		Duel.DiscardHand(tp,s.afilter1,1,1,REASON_COST+REASON_DISCARD)
	end
	if op==1 then
		if chk==0 then return Duel.IsExistingMatchingCard(s.afilter2,tp,LOCATION_MZONE,0,1,nil,tp) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,s.afilter2,tp,LOCATION_MZONE,0,1,1,nil,tp)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
	if op==2 then
		e:SetLabel(0)
	end
end

function s.efilter1(c,e,tp)
	return c:IsLevel(5) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	--Effect options
	local b1=Duel.IsPlayerCanDraw(tp,2)
	local b2=Duel.IsExistingMatchingCard(s.efilter1,tp,LOCATION_DECK,0,3,nil,e,tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
	local b3=Duel.IsExistingMatchingCard(afilter3,tp,LOCATION_MZONE,0,1,nil) 
	if chk==0 then return b1 or b2 or b3 end
	local op=0
	if b1 and b2 and b3 then
		if Duel.IsExistingMatchingCard(s.afilter3,tp,LOCATION_MZONE,0,1,nil) then
			op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))
		else
			op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
		end
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0))
	elseif b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,2))+1
	end
	
	local op2=e:GetLabel()
	
	--Set Operation
	if op2==0 then
		Duel.SetTargetPlayer(tp)
		Duel.SetTargetParam(2)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	elseif op2==1 then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_DECK)
	else
		local dg=Duel.GetMatchingGroup(s.afilter3,tp,LOCATION_MZONE,0,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,tp,LOCATION_MZONE)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==0 then
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Draw(p,d,REASON_EFFECT)
	end
	if op==1 then
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<3 then return end
		local g=Duel.GetMatchingGroup(s.efilter1,tp,LOCATION_DECK,0,nil,e,tp)
		if #g>=3 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=g:Select(tp,3,3,nil)
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	if op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g1=Duel.SelectMatchingCard(tp,s.afilter3,tp,LOCATION_MZONE,0,1,1,nil)
		if #g1>0 and Duel.Destroy(g1,REASON_EFFECT)~=0 then
			local g2=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
			if #g2>0 then
				Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
end