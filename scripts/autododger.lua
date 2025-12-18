local function ToggleAutododger()
	if not InGame() then return end
	--
	local pl = _G.ThePlayer
	local cmp = pl.components.remiimp_autododger
	if pl.prefab == "wortox" and cmp then cmp:ToggleDodging() end
end
Bind("KITE_KEY", ToggleAutododger)