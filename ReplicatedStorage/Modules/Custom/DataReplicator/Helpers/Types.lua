-- @ScriptType: ModuleScript
--[[
This is associated with DataReplicator package module.
Formed by :- Dilpreet Singh at ChicMic Studios @2024
]]


local Types = {}

export type StoresData = {
	[string] :StoreDataType,
}

export type StoreDataType = {
	Name : string,
	KeySuffix :string,
	StoreObj : DataStore,
	PlrsData : {},
	Instance : {},
}

export type PathsSpecificType = {
	Conn :RBXScriptConnection,
	Func :()->(),
}

export type PlayerData = {
	Key : string, --Player.UserId + Store.keySuffix
	PlayerObj :Instance & Player,
	Data : any,
	Listeners : {WholeData : RBXScriptSignal, PathsSpecific : {[string] : PathsSpecificType}},
}

return Types
