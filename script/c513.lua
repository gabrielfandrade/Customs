--Ardental Chariot
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,s.filter,nil,nil,nil)
	--damage
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.damcon)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
	--destroy sub
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	--damage
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_DAMAGE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCondition(s.damcon2)
	e5:SetTarget(s.damtg2)
	e5:SetOperation(s.damop2)
	c:RegisterEffect(e5)
end
function s.filter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local eqc=e:GetHandler():GetEquipTarget()
	local des=eg:GetFirst()
	return des:GetReasonCard()==eqc and des:IsType(TYPE_MONSTER)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	eg:GetFirst():CreateEffectRelation(e)
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local des=eg:GetFirst()
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	if des:IsRelateToEffect(e) then
		local dam=des:GetLevel()*200
		if dam<0 then dam=0 end
		Duel.Damage(p,dam,REASON_EFFECT)
	end
end
function s.damcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.damtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(500)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
function s.damop2(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end