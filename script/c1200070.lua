--Parasite Original
local s,id=GetID()
function s.initial_effect(c)
	--tohand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--hand synchro
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_HAND_SYNCHRO)
	e3:SetLabel(id)
	e3:SetValue(s.synval)
	c:RegisterEffect(e3)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
function s.filter(c)
	return c:IsRace(RACE_INSECT) and c:IsLevelBelow(3) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.synval(e,c,sc)
	if sc:IsRace(RACE_INSECT) and (not c:IsType(TYPE_TUNER) or c:IsHasEffect(EFFECT_NONTUNER)) and c:IsLocation(LOCATION_HAND) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
		e1:SetLabel(id)
		e1:SetTarget(s.synchktg)
		c:RegisterEffect(e1)
		return true
	else return false end
end
function s.chk2(c)
	if not c:IsHasEffect(EFFECT_HAND_SYNCHRO) or c:IsHasEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK) then return false end
	local te={c:GetCardEffect(EFFECT_HAND_SYNCHRO)}
	for i=1,#te do
		local e=te[i]
		if e:GetLabel()==id then return true end
	end
	return false
end
function s.synchktg(e,c,sg,tg,ntg,tsg,ntsg)
	if c then
		local res=tg:IsExists(s.chk2,1,c) or ntg:IsExists(s.chk2,1,c) or sg:IsExists(s.chk2,1,c)
		return res,Group.CreateGroup(),Group.CreateGroup()
	else
		return true
	end
end
