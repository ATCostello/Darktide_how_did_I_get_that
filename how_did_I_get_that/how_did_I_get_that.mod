return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`how_did_I_get_that` encountered an error loading the Darktide Mod Framework.")

		new_mod("how_did_I_get_that", {
			mod_script       = "how_did_I_get_that/scripts/mods/how_did_I_get_that/how_did_I_get_that",
			mod_data         = "how_did_I_get_that/scripts/mods/how_did_I_get_that/how_did_I_get_that_data",
			mod_localization = "how_did_I_get_that/scripts/mods/how_did_I_get_that/how_did_I_get_that_localization",
		})
	end,
	packages = {},
}
