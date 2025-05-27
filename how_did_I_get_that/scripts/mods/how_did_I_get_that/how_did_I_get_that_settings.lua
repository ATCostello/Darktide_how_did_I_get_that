local mod = get_mod("how_did_I_get_that")

local grid_size = {
    550,
    200
}
local padding = 5
local grid_margin = 2
local margin_left = 10
local margin_right = 10
local counter_width = 80
local icon_size = 80
local main_column_offset = margin_left + icon_size + padding + grid_margin
local main_column_width = grid_size[1] - (main_column_offset + padding + counter_width + margin_right + grid_margin)
local font_large = 18
local font_medium = 14
local font_small = 12
local title_height = font_large * 2 + padding * 2
local desc_height = font_medium * 4 + padding * 2
local item_height = title_height + desc_height
local sub_list_mult = 0.9

local grid_settings = {
    grid = {
        grid_margin = grid_margin,
        grid_size = grid_size,
        grid_mask_size = {
            grid_size[1],
            grid_size[2]
        }
    },
    list_item = {
        gap = padding,
        main_offset = main_column_offset,
        font_large = font_large,
        font_medium = font_medium,
        font_small = font_small,
        margin_left = margin_left,
        icon_size = {
            icon_size,
            icon_size
        },
        title_size = {
            main_column_width,
            title_height
        },
        desc_size = {
            main_column_width,
            desc_height
        },
        counter_size = {
            counter_width,
            item_height
        },
        item_size = {
            (grid_size[1] - grid_margin * 2),
            item_height
        }
    },
    sub_list_item = {
        gap = padding * sub_list_mult,
        main_offset = (grid_size[1] - ((grid_size[1] - grid_margin * 2) * sub_list_mult) + padding * sub_list_mult) + (icon_size * sub_list_mult) + padding * sub_list_mult,
        font_large = font_large * sub_list_mult,
        font_medium = font_medium * sub_list_mult,
        font_small = font_small * sub_list_mult,
        margin_left = grid_size[1] - ((grid_size[1] - grid_margin * 2) * sub_list_mult),
        icon_size = {
            icon_size * sub_list_mult,
            icon_size * sub_list_mult
        },
        title_size = {
            main_column_width * sub_list_mult,
            title_height * sub_list_mult
        },
        desc_size = {
            main_column_width * sub_list_mult,
            desc_height * sub_list_mult
        },
        counter_size = {
            counter_width * sub_list_mult,
            item_height * sub_list_mult
        },
        item_size = {
            (grid_size[1] - grid_margin * 2) * sub_list_mult,
            item_height * sub_list_mult
        }
    }
}

return settings("how_did_I_get_that_settings", grid_settings)
