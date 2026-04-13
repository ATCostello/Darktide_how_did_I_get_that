local mod = get_mod("how_did_I_get_that")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = false,
	options = {
		widgets = {
			{
				setting_id = "general_settings",
				type = "group",

				sub_widgets = {
					{
						setting_id = "mod_name_pizazz_toggle",
						type = "checkbox",
						default_value = true,
						tooltip = "mod_name_pizazz_tooltip",
					},
				},
			},
		},
	},
}
