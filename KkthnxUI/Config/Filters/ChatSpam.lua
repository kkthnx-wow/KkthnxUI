local K = unpack(select(2, ...))

local _G = _G

K.GeneralChatSpam = {
	"an[au][ls]e?r?%f[%L]",
	"nigg[ae]r?",
	"s%A*k%A*y%A*p%Ae",
}

K.PrivateChatEventSpam = {
	"%-(.*)%|T(.*)|t(.*)|c(.*)%|r",
	"%[(.*)ARENA ANNOUNCER(.*)%]",
	"%[(.*)Autobroadcast(.*)%]",
	"%[(.*)BG Queue Announcer(.*)%]",

	_G.ERR_LEARN_ABILITY_S:gsub("%%s","(.*)"),
	_G.ERR_LEARN_PASSIVE_S:gsub("%%s","(.*)"),
	_G.ERR_LEARN_SPELL_S:gsub("%%s","(.*)"),
	_G.ERR_NOT_IN_INSTANCE_GROUP or "You aren't in an instance group.",
	_G.ERR_NOT_IN_RAID or "You are not in a raid group",
	_G.ERR_PET_LEARN_ABILITY_S:gsub("%%s","(.*)"),
	_G.ERR_PET_LEARN_SPELL_S:gsub("%%s","(.*)"),
	_G.ERR_PET_SPELL_UNLEARNED_S:gsub("%%s","(.*)"),
	_G.ERR_QUEST_ALREADY_ON or "You are already on that quest",
	_G.ERR_SPELL_UNLEARNED_S:gsub("%%s","(.*)"),
}

K.PrivateChatNoEventSpam = {

}