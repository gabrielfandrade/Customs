--Lightos' Served
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x7d0),1,1)
	--cannot link material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Search "Servana" and 1 "Fusion"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_RECOVER)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,0})
	e2:SetCondition(s.condition)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.thfilter1(c)
	return c:IsCode(203) and c:IsAbleToHand()
end
function s.thfilter2(c)
	return c:IsSetCard(0x46) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil)
		or Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.ctcheck(sg,e,tp)
	return sg:GetClassCount(Card.GetCode)==#sg and sg:GetClassCount(Card.GetSetCard)==#sg
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g1,g2=Duel.GetMatchingGroup(s.thfilter1,tp,LOCATION_DECK,0,nil),Duel.GetMatchingGroup(s.thfilter2,tp,LOCATION_DECK,0,nil)
	g1:Merge(g2)
	local sg=aux.SelectUnselectGroup(g1,e,tp,1,2,s.ctcheck,1,tp,HINTMSG_ATOHAND)
	if #sg>0 then 
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end