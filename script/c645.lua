--Disciple of the Darkness Stars
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 level 7 Warrior monster to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Add itself to the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg2)
	e2:SetOperation(s.thop2)
	c:RegisterEffect(e2)
end
function s.thfilter(c)
	return (c:IsSetCard(0x4602) or c:IsCode(44330098)) and c:IsLevel(7) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0,nil)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(Card.IsReleasableByEffect,tp,LOCATION_MZONE,0,ct,nil)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,ct,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0,nil)
	if Duel.IsExistingMatchingCard(Card.IsReleasableByEffect,tp,LOCATION_MZONE,0,ct,nil) then
		local g=Duel.GetMatchingGroup(Card.IsReleasableByEffect,tp,LOCATION_MZONE,0,nil)
		if Duel.Release(g,REASON_EFFECT)>0 then
			g=g:Filter(Card.IsAttribute,nil,ATTRIBUTE_DARK)
			if #g>0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,#g,#g,nil)
				if #sg>0 then
					Duel.SendtoHand(sg,nil,REASON_EFFECT)
					Duel.ConfirmCards(1-tp,sg)
					Duel.BreakEffect()
					Duel.SkipPhase(tp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
					Duel.SkipPhase(tp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_FIELD)
					e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
					e1:SetTargetRange(1,0)
					e1:SetCode(EFFECT_CANNOT_BP)
					e1:SetReset(RESET_PHASE+PHASE_END)
					Duel.RegisterEffect(e1,tp)
				end
			end
		end
	end
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and tp~=rp and r&REASON_BATTLE~=0 and Duel.GetAttacker():IsControler(1-tp)
end
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end