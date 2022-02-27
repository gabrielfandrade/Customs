--Dark Factory of Industrial Production
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	--Fusion
	local params={aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),Fusion.OnFieldMat,s.fextra}
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(s.fuscon)
	e3:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e3:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
						if not e:GetHandler():IsRelateToEffect(e) then return end
						Fusion.SummonEffOP(table.unpack(params))(e,tp,eg,ep,ev,re,r,rp)
					end)
	c:RegisterEffect(e3)
end
function s.filter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAbleToDeck()
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,5,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,5,5,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,5,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=5 then return end
	Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==5 then
		Duel.BreakEffect()
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
function s.fuscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
function s.filterchk(c)
	return c:IsFaceup() and c:IsLevelAbove(8) and c:IsRace(RACE_MACHINE) and c:IsOnField()
end
function s.fcheck(tp,sg,fc)
	if sg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
		return sg:IsExists(s.filterchk,1,nil) end
	return true
end
function s.fextra(e,tp,mg)
	if mg:IsExists(s.filterchk,1,nil) then
		local eg=Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_DECK,0,nil)
		if eg and #eg>0 then
			return eg,s.fcheck
		end
	end
	return nil
end