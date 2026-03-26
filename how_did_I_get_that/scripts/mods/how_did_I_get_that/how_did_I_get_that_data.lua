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
						setting_id = "placeholder",
						type = "checkbox",
						default_value = true,
						tooltip = "placeholder_tooltip",
					},
				},
			},
		},
	},
}
