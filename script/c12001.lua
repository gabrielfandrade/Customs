--Spare Noble Arms - Dannel
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsCode,TOKEN_BRAVE))
end
s.listed_names={TOKEN_BRAVE}