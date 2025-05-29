local mod = get_mod("how_did_I_get_that")
local ScrollbarPassTemplates = require("scripts/ui/pass_templates/scrollbar_pass_templates")
local Settings = mod:io_dofile("how_did_I_get_that/scripts/mods/how_did_I_get_that/how_did_I_get_that_settings")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")

local grid_settings = Settings.grid
local list_settings = Settings.list_item
local grid_margin = grid_settings.grid_margin
local grid_size = grid_settings.grid_size
local grid_mask_size = grid_settings.grid_mask_size

local penance_grid_settings = {
    scrollbar_vertical_margin = 20,
    use_terminal_background = false,
    use_terminal_background_icon = "content/ui/materials/icons/system/escape/achievements",
    hide_background = true,
    hide_dividers = true,
    title_height = 0,
    grid_spacing = {
        grid_size[1],
        8
    },
    grid_size = grid_size,
    mask_size = grid_mask_size,
    scrollbar_pass_templates = ScrollbarPassTemplates.terminal_scrollbar,
    scrollbar_width = ScrollbarPassTemplates.terminal_scrollbar.default_width,
    edge_padding = grid_margin * 2,
    vertical_alignment = "bottom",
    scenegraph_id = {
        penance_grid_pivot = {
            vertical_alignment = "bottom",
            parent = "canvas",
            horizontal_alignment = "right",
            size = {
                0,
                0
            },
            position = {
                -grid_size[1] - 640,
                -100,
                99
            }
        },
        penance_grid = {
            vertical_alignment = "bottom"
        }
    }
}

local definitions = {
    penance_grid_settings = penance_grid_settings
}

return definitions