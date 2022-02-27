--Corrupted Samurai
local s,id=GetID()
local TYPE_FULL=TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK
local TYPE_ARRAY={TYPE_FUSION,TYPE_SYNCHRO,TYPE_XYZ,TYPE_LINK }
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Special Summon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(0)
	c:RegisterEffect(e1)
	--Special Sumon Procedure
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_DECK)
	e2:SetValue(1)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--immune spell
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
	--Destruction replacement
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.desreptg)
	e4:SetOperation(s.desrepop)
	c:RegisterEffect(e4)
	--Equip 1 Equip Spell from your Deck to a Warrior monster you control
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(id,1)
	e5:SetCategory(CATEGORY_EQUIP)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_HAND)
	e5:SetCountLimit(1,id)
	e5:SetTarget(s.eqtg)
	e5:SetOperation(s.eqop)
	c:RegisterEffect(e5)
end
function s.eqcfilter(c)
	return c:IsType(TYPE_SPELL)
end
function s.tgfilter(c)
	local g=c:GetEquipGroup()
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
		and c:IsType(TYPE_MONSTER) and c:IsType(TYPE_FULL)
		and g:IsExists(s.eqcfilter,1,nil)
		and c:IsAbleToGraveAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE,0,nil)
	return #rg>0 and aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g=nil
	local rg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE,0,nil)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_TOGRAVE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoGrave(g,REASON_COST)
end
function s.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_TRAP) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function s.repfilter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_SPELL) and c:IsType(TYPE_EQUIP)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsOnField() and c:IsFaceup()
		and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_SZONE,0,1,nil,e) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_SZONE,0,1,1,nil,e)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else
		return false
	end
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
function s.filter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK,0,1,nil,c,tp)
end
function s.eqfilter(c,tc,tp)
	return c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(tc) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,tp) end
	local ft=0
	if e:GetHandler():IsLocation(LOCATION_HAND) then ft=1 end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>ft
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK,0,1,1,nil,tc,tp)
		if #g>0 and Duel.Equip(tp,g:GetFirst(),tc)~=0 then
			Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_EFFECT)
		end
	end
end