--Roar of the Forest
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Add itself to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg2)
	e2:SetOperation(s.thop2)
	c:RegisterEffect(e2)
end

function s.mfilter(c)
	return c:IsFaceup() and (c:IsSetCard(0x1169) or c:IsSetCard(0x2169)) and c:IsMonster()
end
function s.thfilter(c,e,tp,myst_chk)
	return c:IsMonster() and c:IsRace(RACES_BEAST_BWARRIOR_WINGB+RACE_INSECT+RACE_PLANT) 
		and (c:IsAbleToHand() or (myst_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local myst_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.mfilter,tp,LOCATION_MZONE,0,1,nil)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.thfilter(chkc,e,tp,myst_chk) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,myst_chk) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,myst_chk)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,g,1,0,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local myst_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.mfilter,tp,LOCATION_MZONE,0,1,nil)
	local tc=Duel.GetFirstTarget()
	if not tc then return end
	aux.ToHandOrElse(tc,tp,
		function(tc)
			return myst_chk and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		end,
		function(tc)
			return Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end,
		aux.Stringid(id,1)
	)
end

function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsControler(tp)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0 then
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end