--Servi, Materialist Dragon
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,s.tfilter,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.tkcon)
	e1:SetTarget(s.tktg)
	e1:SetOperation(s.tkop)
	c:RegisterEffect(e1)
end
function s.tfilter(c,lc,stype,tp)
	return c:IsSetCard(0x3dc,lc,stype,tp)
end
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0x3dc,TYPES_TOKEN,0,0,3,RACE_DRAGON,ATTRIBUTE_DARK,POS_FACEUP) end
	Duel.Hint(HINT_SELECTMSG,tp,563)
	local aat=Duel.AnnounceAttribute(tp,1,0xff-e:GetHandler():GetAttribute())
	e:SetLabel(aat)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
			and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0x3dc,TYPES_TOKEN,0,0,3,RACE_DRAGON,ATTRIBUTE_DARK,POS_FACEUP) then
			local token=Duel.CreateToken(tp,id+1)
			Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE) 
			e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e2:SetRange(LOCATION_MZONE)
			e2:SetValue(e:GetHandler():GetAttribute())
			e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
			token:RegisterEffect(e2,true)
		end
	end
end