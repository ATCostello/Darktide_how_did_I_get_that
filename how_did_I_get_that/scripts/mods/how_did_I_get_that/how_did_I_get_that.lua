--[[
    Name: How Did I Get That?
    Author: Alfthebigheaded
]] local mod = get_mod("how_did_I_get_that")
local ViewElementGrid = require("scripts/ui/view_elements/view_element_grid/view_element_grid")
local Blueprints = mod:io_dofile("how_did_I_get_that/scripts/mods/how_did_I_get_that/how_did_I_get_that_blueprints")
local Definitions = mod:io_dofile("how_did_I_get_that/scripts/mods/how_did_I_get_that/how_did_I_get_that_definitions")
local InventoryViewDefinitions = require("scripts/ui/views/inventory_cosmetics_view/inventory_cosmetics_view_definitions")
local AchievementUIHelper = require("scripts/managers/achievements/utility/achievement_ui_helper")
local AchievementTypes = require("scripts/managers/achievements/achievement_types")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIFonts = require("scripts/managers/ui/ui_fonts")
local MasterItems = require("scripts/backend/master_items")
local Items = require("scripts/utilities/items")
local ItemUtils = require("scripts/utilities/items")
local InventoryCosmeticsView = require("scripts/ui/views/inventory_cosmetics_view/inventory_cosmetics_view")
local InventoryCosmeticsViewDefinitions = require("scripts/ui/views/inventory_cosmetics_view/inventory_cosmetics_view_definitions")

local ViewElementBase = require("scripts/ui/view_elements/view_element_base")

local PENANCE_TRACK_ID = "dec942ce-b6ba-439c-95e2-022c5d71394d"
local commisary_cache
local hestias_rewards_cache = {}
local current_penance_points = 0
local view_obtained_details = true

mod.is_weapon_customization_installed = function(self)
    self.weapon_customization = self.weapon_customization or get_mod("weapon_customization")
end

mod:hook_safe(
    CLASS.InventoryCosmeticsView, "on_enter", function(self)
        -- Load cache with items
        mod.cache_hestias(self)
        mod.cache_commissary_cosmetics(self)
    end
)

mod:hook_safe(
    CLASS.InventoryCosmeticsView, "on_exit", function(self)
        -- clear cache
        commisary_cache = nil
        hestias_rewards_cache = {}
    end
)

mod:hook_safe(
    CLASS.InventoryWeaponCosmeticsView, "on_enter", function(self)
        mod.is_weapon_customization_installed(self)
        -- Load cache with items
        mod.cache_hestias(self)
        mod.cache_commissary_cosmetics(self)
    end
)

mod:hook_safe(
    CLASS.InventoryWeaponCosmeticsView, "on_exit", function(self)
        -- clear cache
        commisary_cache = nil
        hestias_rewards_cache = {}
    end
)

-- Hide obtained details when on extended weapon customization view.
mod:hook_safe(
    CLASS.InventoryWeaponCosmeticsView, "cb_switch_tab", function(self, element)
        if self._selected_tab_index == 3 and self.weapon_customization then
            view_obtained_details = false
            if self.penance_grid_view then
                self.penance_grid_view:set_visibility(false)
            end
        else
            view_obtained_details = true
        end
    end
)

------------------------------------------------------------------------------------------------------
--- Hooks into the inventory weapons cosmetics view, on selecting any item.
------------------------------------------------------------------------------------------------------

mod:hook_safe(
    CLASS.InventoryWeaponCosmeticsView, "_preview_element", function(self, element)
        if element then
            self.real_item = element.real_item
            mod.display_obtained_weapon_cosmetic_view(self)
        end
    end
)

------------------------------------------------------------------------------------------------------
--- Hooks into the inventory cosmetics view, on selecting an item.
------------------------------------------------------------------------------------------------------
mod:hook_safe(
    CLASS.InventoryCosmeticsView, "_preview_element", function(self, element)
        mod.display_obtained_cosmetic_view(self)
    end
)

InventoryCosmeticsView._setup_side_panel = function(self, item, is_locked, dx, dy)
    self:_destroy_side_panel()

    if not item then
        return
    end

    local y_offset = 0
    local scenegraph_id = "side_panel_area"
    local max_width = self._ui_scenegraph[scenegraph_id].size[1]
    local widgets = {}

    self._side_panel_widgets = widgets

    local function _add_text_widget(pass_template, text)
        local widget_definition = UIWidget.create_definition(pass_template, scenegraph_id, nil, {max_width, 0})
        local widget = self:_create_widget(string.format("side_panel_widget_%d", #widgets), widget_definition)

        widget.content.text = text
        widget.offset[2] = y_offset

        local widget_text_style = widget.style.text
        local text_options = UIFonts.get_font_options_by_style(widget.style.text)
        local _, text_height = self:_text_size(text, widget_text_style.font_type, widget_text_style.font_size, {max_width, math.huge}, text_options)

        y_offset = y_offset + text_height
        widget.content.size[2] = text_height
        widgets[#widgets + 1] = widget
    end

    local function _add_spacing(height)
        y_offset = y_offset + height
    end

    local properties_text = ItemUtils.item_property_text(item, true)
    local unlock_title, unlock_description = ItemUtils.obtained_display_name(item)

    if unlock_title and is_locked then
        unlock_title = string.format("%s %s", "", unlock_title)
    end

    local any_text = properties_text or unlock_title or unlock_description
    local should_display_side_panel = any_text

    if not should_display_side_panel then
        return
    end

    if properties_text then
        if #widgets > 0 then
            _add_spacing(24)
        end

        _add_text_widget(InventoryCosmeticsViewDefinitions.small_header_text_pass, Utf8.upper(Localize("loc_item_property_header")))
        _add_spacing(8)
        _add_text_widget(InventoryCosmeticsViewDefinitions.small_body_text_pass, properties_text)
    end

    if unlock_title or unlock_description then
        if #widgets > 0 then
            _add_spacing(24)
        end

        _add_text_widget(InventoryCosmeticsViewDefinitions.big_header_text_pass, Utf8.upper(Localize("loc_item_source_obtained_title")))
        _add_spacing(12)

        if unlock_title then
            _add_text_widget(InventoryCosmeticsViewDefinitions.big_body_text_pass, unlock_title)
        end

        if unlock_title and unlock_description then
            _add_spacing(8)
        end

        if unlock_description then
            -- _add_text_widget(InventoryCosmeticsViewDefinitions.big_details_text_pass, unlock_description)
        end

        if unlock_title then
            _add_spacing(8)
        end

        if unlock_title then
            _add_text_widget(InventoryCosmeticsViewDefinitions.big_details_text_pass, "")
        end
    end

    for i = 1, #widgets do
        local widget_offset = widgets[i].offset

        widget_offset[1] = dx
        widget_offset[2] = dy + widget_offset[2] - y_offset
    end
end

mod.display_obtained_cosmetic_view = function(self)
    local selected_item = self._previewed_item

    local selected_item_source = selected_item.source -- 1 = Penance, 2 = Commisary, 3 = Commodore's Vestures, 4 = Hestia's Blessings

    -- Hide penance view if present
    if (self.penance_grid_view) then
        self.penance_grid_view:set_visibility(false)
    end

    if selected_item_source == 1 then
        mod.display_penances_inventory_view(self, selected_item)
    elseif selected_item_source == 2 then
        mod.display_commisary_inventory_view(self, selected_item)
    elseif selected_item_source == 3 then
        mod.display_commodores_vestures(self, selected_item)
    elseif selected_item_source == 4 then
        mod.display_hestias_blessings_inventory_view(self, selected_item)
    else
        mod.fetch_unknown_item_source_text(self, selected_item, 0)
    end
end

mod.display_obtained_weapon_cosmetic_view = function(self, real_item)

    local selected_item = self._previewed_item
    local presentation_item = self._presentation_item
    local real_item = self.real_item

    -- Hide penance view if present
    if (self.penance_grid_view) then
        self.penance_grid_view:set_visibility(false)
    end

    if (real_item) then
        local source = real_item.source or real_item.__master_item.source

        -- sort out broken items
        -- Fix "Plasma Canister" trinket being set as a Hestia's reward - when it's actually a penance reward.
        if real_item.__master_item and real_item.__master_item.name == "content/items/weapons/player/trinkets/trinket_17b" then
            real_item.__master_item.source = 1
            source = 1
        end

        if view_obtained_details then
            if source == 1 then
                mod.display_penances_weapon_view(self, real_item)
            elseif source == 2 then
                mod.display_commisary_weapon_view(self, real_item)
            elseif source == 3 then
                mod.display_commodores_vestures_weapon_view(self, real_item)
            elseif source == 4 then
                mod.display_hestias_blessings_weapon_view(self, real_item)
            else
                mod.fetch_unknown_item_source_text(self, real_item, 1)
            end

            -- Adjust font sizes and position of new text
            -- display_name and sub_display_name are the titles for items in the weapon view
            -- changes if extended weapon customization is installed
            local widgets_by_name = self._widgets_by_name

            if self.weapon_customization then
                if source == 1 then
                    widgets_by_name.sub_display_name.style.style_id_1.font_size = 24
                    widgets_by_name.sub_display_name.offset[2] = 0
                    widgets_by_name.display_name.style.style_id_1.font_size = 30
                    widgets_by_name.display_name.offset[2] = 0
                else
                    widgets_by_name.sub_display_name.style.style_id_1.font_size = 24
                    widgets_by_name.sub_display_name.offset[2] = 0
                    widgets_by_name.display_name.style.style_id_1.font_size = 30
                    widgets_by_name.display_name.offset[2] = 0
                end
                if self.penance_grid_view then
                    local w = RESOLUTION_LOOKUP.width
                    local h = RESOLUTION_LOOKUP.height
                    local aspect_ratio = tonumber(string.format("%.1f", w / h))
                    if aspect_ratio > 2 and aspect_ratio < 2.5 then
                        self.penance_grid_view:set_pivot_offset(1700, 20)
                    elseif aspect_ratio > 2.5 and aspect_ratio < 3 then
                        self.penance_grid_view:set_pivot_offset(1900, 20)
                    elseif aspect_ratio > 3 and aspect_ratio < 3.5 then
                        self.penance_grid_view:set_pivot_offset(2000, 20)
                    elseif aspect_ratio > 3.5 and aspect_ratio < 4 then
                        self.penance_grid_view:set_pivot_offset(2300, 20)
                    elseif aspect_ratio > 1.35 and aspect_ratio < 1.63 then
                        self.penance_grid_view:set_pivot_offset(1250, 50)
                    elseif aspect_ratio > 1 and aspect_ratio < 1.35 then
                        self.penance_grid_view:set_pivot_offset(1200, 150)
                    else
                        self.penance_grid_view:set_pivot_offset(1200, 20)
                    end
                end
            else
                if source == 1 then
                    widgets_by_name.sub_display_name.style.style_id_1.font_size = 24
                    widgets_by_name.sub_display_name.offset[2] = -180
                    widgets_by_name.display_name.style.style_id_1.font_size = 30
                    widgets_by_name.display_name.offset[2] = -180
                else
                    widgets_by_name.sub_display_name.style.style_id_1.font_size = 24
                    widgets_by_name.sub_display_name.offset[2] = -60
                    widgets_by_name.display_name.style.style_id_1.font_size = 30
                    widgets_by_name.display_name.offset[2] = -60
                end
                if self.penance_grid_view then
                    local w = RESOLUTION_LOOKUP.width
                    local h = RESOLUTION_LOOKUP.height
                    local aspect_ratio = tonumber(string.format("%.1f", w / h))
                    if aspect_ratio > 2 and aspect_ratio < 2.5 then
                        self.penance_grid_view:set_pivot_offset(1000, 800)
                    elseif aspect_ratio > 2.5 and aspect_ratio < 3 then
                        self.penance_grid_view:set_pivot_offset(1350, 800)
                    elseif aspect_ratio > 3 and aspect_ratio < 3.5 then
                        self.penance_grid_view:set_pivot_offset(1500, 800)
                    elseif aspect_ratio > 3.5 and aspect_ratio < 4 then
                        self.penance_grid_view:set_pivot_offset(1650, 800)
                    elseif aspect_ratio > 1.35 and aspect_ratio < 1.63 then
                        self.penance_grid_view:set_pivot_offset(670, 900)
                    elseif aspect_ratio > 1 and aspect_ratio < 1.35 then
                        self.penance_grid_view:set_pivot_offset(670, 1000)
                    else
                        self.penance_grid_view:set_pivot_offset(670, 800)
                    end
                end
            end
        end
    end
end

mod.display_commodores_vestures = function(self, selected_item)

    if selected_item and selected_item.offer then

        local skin_name = selected_item.__master_item.name
        local selected_item_cost = 0
        local bundle = selected_item.offer.bundleInfo or nil

        if bundle then
            for _, bundleitem in pairs(bundle) do
                if bundleitem.description.id == skin_name then
                    selected_item_cost = bundleitem.price.amount.amount
                end
            end
        else
            selected_item_cost = selected_item.offer.price.amount.amount or 0
        end

        if selected_item_cost ~= 0 then
            local text = mod:localize("ordo_docket_amount_text"):gsub("!content", mod.format_number(selected_item_cost))

            self._side_panel_widgets[#self._side_panel_widgets - 1].content.text =
                self._side_panel_widgets[#self._side_panel_widgets - 1].content.text .. text
        end
    end

    for i = 1, #self._side_panel_widgets do
        self._side_panel_widgets[i].offset[2] = self._side_panel_widgets[i].offset[2] + 76
    end
end

------------------------------------------------------------------------------------------------------
--- For the inventory cosmetics view, displays the ordo docket cost of commisary items.
---@param selected_item any The selected item from the _preview_element function.
------------------------------------------------------------------------------------------------------
mod.display_commisary_inventory_view = function(self, selected_item)

    local selected_slot = self._selected_slot
    local selected_slot_name = selected_slot.name
    local selected_item_sku_name = selected_item.display_name
    local selected_item_cost = 0

    if commisary_cache ~= nil then
        local offers = commisary_cache.offers

        for i = 1, #offers do
            local offer = offers[i]
            local offer_sku_name = offer.sku.name
            if selected_item_sku_name == offer_sku_name then

                selected_item_cost = offer.price.amount.amount

                local text = mod:localize("ordo_docket_amount_text"):gsub("!content", mod.format_number(selected_item_cost))

                if text and selected_item_cost > 0 then
                    self._side_panel_widgets[#self._side_panel_widgets - 1].content.text =
                        self._side_panel_widgets[#self._side_panel_widgets - 1].content.text .. text
                end
                break
            end
        end

        -- if no cost was found, should be set as a redacted item
        if selected_item_cost and selected_item_cost == 0 or selected_item_cost == nil then

            -- remove all other elements left over so that we just have the nice ++redacted++ bits ;)
            if #self._side_panel_widgets >= 3 then
                table.remove(self._side_panel_widgets, 3)
            end
            if #self._side_panel_widgets >= 3 then
                table.remove(self._side_panel_widgets, 3)
            end
            if #self._side_panel_widgets >= 3 then
                table.remove(self._side_panel_widgets, 3)
            end

            mod.fetch_unknown_item_source_text(self, selected_item, 0)
        end

    else
        mod.cache_commissary_cosmetics(self)
    end
end

------------------------------------------------------------------------------------------------------
--- For the inventory cosmetics view, gathers and displays required penances for the selected item in a grid view.
---@param selected_item any The selected item from the _preview_element function.
------------------------------------------------------------------------------------------------------
mod.display_penances_inventory_view = function(self, selected_item)
    local penance_list = {}

    local item_penance = AchievementUIHelper.get_acheivement_by_reward_item(selected_item)

    if (item_penance) then
        local requiredPenances = {}

        if (item_penance.achievements) then
            requiredPenances = item_penance.achievements
            requiredPenances = table.keys(requiredPenances)
        else
            table.insert(requiredPenances, 1, item_penance.id)
        end

        Definitions = mod:io_dofile("how_did_I_get_that/scripts/mods/how_did_I_get_that/how_did_I_get_that_definitions")

        local penance_grid_settings = Definitions.penance_grid_settings
        local layer = 100

        self.penance_grid_view = self:_add_element(ViewElementGrid, "penance_grid", layer, penance_grid_settings)
        self.penance_grid_view:present_grid_layout({}, {})
        self.penance_grid_view:set_visibility(true)

        local w = RESOLUTION_LOOKUP.width
        local h = RESOLUTION_LOOKUP.height

        for i = 1, #requiredPenances do
            local currentAchievement = AchievementUIHelper.achievement_definition_by_id(requiredPenances[i])

            local achievement_id = currentAchievement.id

            local achievement_definition = Managers.achievements:achievement_definition(achievement_id)

            local progress = 0
            local goal = 1
            local player = Managers.player:local_player_safe(1);

            local type = AchievementTypes[achievement_definition.type]
            local has_progress_bar = type.get_progress ~= nil

            local is_completed = Managers.achievements:achievement_completed(player, achievement_id)

            if has_progress_bar then
                progress, goal = type.get_progress(achievement_definition, player)
            end
            if is_completed and progress < goal then
                progress = goal
            end

            penance_list[#penance_list + 1] = {
                widget_type = "penance_list_item", achievement_definition = achievement_definition, progress = progress, goal = goal
            }

            -- ADD SUB PENANCES
            local sub_achievements = achievement_definition.achievements
            if sub_achievements then
                for sub_achievement_id, _ in pairs(sub_achievements) do
                    local sub_achievement_definition = Managers.achievements:achievement_definition(sub_achievement_id)

                    local sub_progress = 0
                    local sub_goal = 1
                    local sub_player = Managers.player:local_player_safe(1);

                    local sub_type = AchievementTypes[sub_achievement_definition.type]
                    local sub_has_progress_bar = sub_type.get_progress ~= nil

                    local sub_is_completed = Managers.achievements:achievement_completed(sub_player, sub_achievement_id)

                    if sub_has_progress_bar then
                        sub_progress, sub_goal = sub_type.get_progress(sub_achievement_definition, sub_player)
                    end
                    if sub_is_completed and sub_progress < sub_goal then
                        sub_progress = sub_goal
                    end

                    penance_list[#penance_list + 1] = {
                        widget_type = "sub_penance_list_item", achievement_definition = sub_achievement_definition, progress = sub_progress,
                        goal = sub_goal
                    }
                end
            end
        end

        -- Replace default description of locked penances with an actually useful one

        local text = mod:localize("penance_amount_singular_text")
        if (#penance_list > 1) then
            text = mod:localize("penance_amount_multiple_text"):gsub("!content", mod.format_number(#penance_list))
        end

        local initial_offset = -150
        if (#penance_list > 1) then
            initial_offset = -180
        end

        if #self._side_panel_widgets > 2 then
            if (self._side_panel_widgets[#self._side_panel_widgets]) then
                self._side_panel_widgets[#self._side_panel_widgets].content.text = text
            end
        else
            local current_text = self._side_panel_widgets[#self._side_panel_widgets].content.text or ""
            self._side_panel_widgets[#self._side_panel_widgets].content.text = current_text .. text
        end

        -- Increase offset for all widgets
        for i = 1, #self._side_panel_widgets do
            self._side_panel_widgets[i].offset[2] = initial_offset + (i * 25)
        end

        -- adjust position of widget to be placed below the "OBTAINED FROM" text
        local side_panel_position = self._ui_scenegraph.side_panel_area.local_position
        local offset_x = side_panel_position[1]
        local offset_y = side_panel_position[2]

        if (#penance_list > 1) then
            offset_y = offset_y - 50
        end

        self.penance_grid_view:set_pivot_offset(-370, offset_y)
        self.penance_grid_view._ui_scenegraph.pivot.vertical_alignment = "bottom"
        self.penance_grid_view._ui_scenegraph.pivot.horizontal_alignment = "center"

        self.penance_grid_view:present_grid_layout(penance_list, Blueprints)
    else
        if (self.penance_grid_view) then
            self.penance_grid_view:set_visibility(false)
        end
    end
end

------------------------------------------------------------------------------------------------------
--- For the inventory cosmetics view, displays the required number of penance points required for hestias blessing items.
---@param selected_item any The selected item from the _preview_element function.
------------------------------------------------------------------------------------------------------
mod.display_hestias_blessings_inventory_view = function(self, selected_item)
    local hestias_penance = {}

    if (#hestias_rewards_cache < 1) then
        mod.cache_hestias(self)
    else
        -- Find hestias penance for the selected item
        for i = 1, #hestias_rewards_cache do
            for j = 1, #hestias_rewards_cache[i].items do
                if (hestias_rewards_cache[i].items[j].name == selected_item.name) then
                    hestias_penance = hestias_rewards_cache[i]
                end
            end
        end

        -- Add Cost of hestias item
        if hestias_penance and hestias_penance.points_required then
            local text = mod:localize("hestias_blessings_obtained_text"):gsub("!content", mod.format_number(hestias_penance.points_required))

            -- add lock symbol to locked items
            if selected_item and selected_item.__locked then
                text = " " .. text
            end

            if self._side_panel_widgets[#self._side_panel_widgets - 1] and self._side_panel_widgets[#self._side_panel_widgets - 1].content and
                self._side_panel_widgets[#self._side_panel_widgets].content.text then
                self._side_panel_widgets[#self._side_panel_widgets - 1].content.text = text
            end

            -- Add current amount of hestias points
            text = mod:localize("hestias_blessings_current_text"):gsub("!content", mod.format_number(current_penance_points))
            self._side_panel_widgets[#self._side_panel_widgets].content.text = text
        end

    end
end

------------------------------------------------------------------------------------------------------
--- For the inventory cosmetics view, displays the required number of penance points required for hestias blessing items.
---@param selected_item any The selected item from the _preview_element function.
------------------------------------------------------------------------------------------------------
mod.display_commisary_weapon_view = function(self, selected_item)

    mod.cache_commissary_cosmetics(self)

    local item_name = selected_item.display_name
    local selected_item_cost = 0

    if commisary_cache ~= nil then
        local offers = commisary_cache.offers

        for i = 1, #offers do
            local offer = offers[i]
            local offer_sku_name = offer.sku.name

            -- offer found
            if item_name == offer_sku_name then
                selected_item_cost = offer.price.amount.amount

                local widgets_by_name = self._widgets_by_name

                local text = mod:localize("ordo_docket_amount_text"):gsub("!content", mod.format_number(selected_item_cost))

                if view_obtained_details then
                    local obtained_desc = string.upper(Localize("loc_item_source_obtained_title"))

                    widgets_by_name.sub_display_name.content.text = widgets_by_name.sub_display_name.content.text .. "\n\n{#color(113,126,103)}" ..
                                                                        obtained_desc .. "\n{#color(216,229,207)}" ..
                                                                        Localize("loc_cosmetics_vendor_view_title") .. text
                end
                break
            end
        end

        -- if no cost was found, should be set as a redacted item
        if selected_item_cost == 0 then
            mod.fetch_unknown_item_source_text(self, selected_item, 1)
        end
    else
        mod.cache_commissary_cosmetics(self)
    end
end

------------------------------------------------------------------------------------------------------
--- Displays penance info for weapon cosmetics
---@param selected_item any The selected item from the _preview_element function.
------------------------------------------------------------------------------------------------------
mod.display_penances_weapon_view = function(self, selected_item)
    local penance_list = {}

    local item_penance = AchievementUIHelper.get_acheivement_by_reward_item(selected_item)

    if (item_penance) then
        local requiredPenances = {}

        if (item_penance.achievements) then
            requiredPenances = item_penance.achievements
            requiredPenances = table.keys(requiredPenances)
        else
            table.insert(requiredPenances, 1, item_penance.id)
        end

        Definitions = mod:io_dofile("how_did_I_get_that/scripts/mods/how_did_I_get_that/how_did_I_get_that_definitions")

        local penance_grid_settings = Definitions.penance_grid_settings
        local layer = 100

        self.penance_grid_view = self:_add_element(ViewElementGrid, "penance_grid", layer, penance_grid_settings)
        self.penance_grid_view:present_grid_layout({}, {})
        self.penance_grid_view:set_visibility(true)

        for i = 1, #requiredPenances do
            local currentAchievement = AchievementUIHelper.achievement_definition_by_id(requiredPenances[i])

            local achievement_id = currentAchievement.id

            local achievement_definition = Managers.achievements:achievement_definition(achievement_id)

            local progress = 0
            local goal = 1
            local player = Managers.player:local_player_safe(1);

            local type = AchievementTypes[achievement_definition.type]
            local has_progress_bar = type.get_progress ~= nil

            local is_completed = Managers.achievements:achievement_completed(player, achievement_id)

            if has_progress_bar then
                progress, goal = type.get_progress(achievement_definition, player)
            end

            if is_completed and progress < goal then
                progress = goal
            end

            penance_list[#penance_list + 1] = {
                widget_type = "penance_list_item", achievement_definition = achievement_definition, progress = progress, goal = goal
            }

            -- ADD SUB PENANCES
            local sub_achievements = achievement_definition.achievements
            if sub_achievements then
                for sub_achievement_id, _ in pairs(sub_achievements) do
                    local sub_achievement_definition = Managers.achievements:achievement_definition(sub_achievement_id)

                    local sub_progress = 0
                    local sub_goal = 1
                    local sub_player = Managers.player:local_player_safe(1);

                    local sub_type = AchievementTypes[sub_achievement_definition.type]
                    local sub_has_progress_bar = sub_type.get_progress ~= nil

                    local sub_is_completed = Managers.achievements:achievement_completed(sub_player, sub_achievement_id)

                    if sub_has_progress_bar then
                        sub_progress, sub_goal = sub_type.get_progress(sub_achievement_definition, sub_player)
                    end
                    if sub_is_completed and sub_progress < sub_goal then
                        sub_progress = sub_goal
                    end

                    penance_list[#penance_list + 1] = {
                        widget_type = "sub_penance_list_item", achievement_definition = sub_achievement_definition, progress = sub_progress,
                        goal = sub_goal
                    }
                end
            end
        end

        -- Replace default description of locked penances with an actually useful one
        local text = mod:localize("penance_amount_singular_text")

        if (#penance_list > 1) then
            text = mod:localize("penance_amount_multiple_text"):gsub("!content", mod.format_number(#penance_list))
        end

        local widgets_by_name = self._widgets_by_name
        if view_obtained_details then
            widgets_by_name.sub_display_name.content.text = widgets_by_name.sub_display_name.content.text .. "\n{#color(113,126,103)}" .. text
        end

        self.penance_grid_view:present_grid_layout(penance_list, Blueprints)
    else
        if (self.penance_grid_view) then
            self.penance_grid_view:set_visibility(false)
        end
    end
end

------------------------------------------------------------------------------------------------------
--- Displays weapon cosmetics information for commodores vestures
---@param selected_item any The selected item from the _preview_element function.
------------------------------------------------------------------------------------------------------
mod.display_commodores_vestures_weapon_view = function(self, selected_item)
    local widgets_by_name = self._widgets_by_name
    if view_obtained_details then
        local obtained_desc = string.upper(Localize("loc_item_source_obtained_title"))

        widgets_by_name.sub_display_name.content.text =
            widgets_by_name.sub_display_name.content.text .. "\n\n{#color(113,126,103)}" .. obtained_desc .. "\n{#color(216,229,207)}" ..
                Localize("loc_premium_store_main_title")
    end
end

------------------------------------------------------------------------------------------------------
--- Displays hestias blessing penance points for weapon cosmetics
---@param selected_item any The selected item from the _preview_element function.
------------------------------------------------------------------------------------------------------
mod.display_hestias_blessings_weapon_view = function(self, selected_item)
    local hestias_penance = {}

    if (#hestias_rewards_cache < 1) then
        mod.cache_hestias(self)
    else

        -- Find hestias penance for the selected item
        if selected_item and selected_item.name then
            for i = 1, #hestias_rewards_cache do
                for j = 1, #hestias_rewards_cache[i].items do
                    if (hestias_rewards_cache[i].items[j].name == selected_item.name) then
                        hestias_penance = hestias_rewards_cache[i]
                    end
                end
            end
        end

        if hestias_penance then
            local widgets_by_name = self._widgets_by_name
            local obtained_desc = string.upper(Localize("loc_item_source_obtained_title"))
            local text_obtained = mod:localize("hestias_blessings_obtained_text"):gsub("!content", mod.format_number(hestias_penance.points_required))
            local text_current = mod:localize("hestias_blessings_current_text"):gsub("!content", mod.format_number(current_penance_points))
            if view_obtained_details then
                widgets_by_name.sub_display_name.content.text = widgets_by_name.sub_display_name.content.text .. "\n\n{#color(113,126,103)}" ..
                                                                    obtained_desc .. "\n{#color(216,229,207)}" .. text_obtained ..
                                                                    "\n{#color(113,126,103)}" .. text_current
            end
        end
    end
end

mod.fetch_unknown_item_source_text = function(self, selected_item, source)
    local obtained_desc = string.upper(Localize("loc_item_source_obtained_title"))
    local name = selected_item.name:lower()

    dbg_unknown_item = selected_item
    -- Remove any previous "Obtained From:" elements in _side_panel_widgets
    if self._side_panel_widgets then
        local widgets = self._side_panel_widgets
        local i = #widgets
        while i > 0 do
            local widget = widgets[i]
            if widget and widget.content and widget.content.text and type(widget.content.text) == "string" then
                -- Remove if matches or contains the localized "Obtained From:" string
                if string.find(widget.content.text, obtained_desc, 1, true) then
                    table.remove(widgets, i)
                    table.remove(widgets, i)

                end
            end
            i = i - 1
        end
    end

    local special_sources = {
        { -- Imperial/Deluxe/Skull Edition
            patterns = {"deluxe", "skull_edition"}, desc_key = "imperial_edition"
        }, { -- Twitch Drops
            patterns = {"twitch"}, desc_key = "twitch_drop"
        }, { -- First Year/Atoma
            patterns = {"atoma"}, desc_key = "first_year", extra_names = {
                "content/items/characters/player/human/backpacks/backpack_b_var_02", "content/items/2d/portrait_frames/achievements_47",
                "content/items/2d/portrait_frames/achievements_49"
            }
        }, { -- Beta
            patterns = {"beta"}, desc_key = "beta"
        }, { -- Default/Prisoner
            patterns = {"prisoner"}, desc_key = "default_item", extra_names = {
                "content/items/characters/player/human/gear_head/empty_headgear", "content/items/2d/portrait_frames/achievements_49",
                "content/items/2d/portrait_frames/portrait_frame_default", "content/items/2d/insignias/insignia_default",
                "content/items/animations/emotes/emote_human_personality_006_squat_01",
                "content/items/animations/emotes/emote_human_personality_005_kneel_01",
                "content/items/animations/emotes/emote_human_negative_001_refuse_01",
                "content/items/animations/emotes/emote_human_affirmative_001_thumbs_up_01",
                "content/items/animations/emotes/emote_human_greeting_002_wave_02", "content/items/animations/end_of_round/end_of_round_psyker_009",
                "content/items/animations/end_of_round/end_of_round_veteran_003", "content/items/animations/end_of_round/end_of_round_zealot_001",
                "content/items/animations/emotes/emote_ogryn_personality_005_kneel_01",
                "content/items/animations/emotes/emote_ogryn_negative_002_head_shake_01",
                "content/items/animations/emotes/emote_ogryn_personality_004_pants_01",
                "content/items/animations/emotes/emote_ogryn_affirmative_006_thumbs_up_02",
                "content/items/animations/emotes/emote_ogryn_greeting_002_wave_02", "content/items/animations/end_of_round/end_of_round_ogryn_002",
                "content/items/titles/title_default"
            }
        }, { -- Pre-order
            patterns = {"pre_order"}, desc_key = "pre_order", extra_names = {"content/items/weapons/player/trinkets/trinket_3d"}
        }, { -- Rogue Trader Crossover
            patterns = {}, desc_key = "rogue_trader_crossover", extra_names = {"content/items/weapons/player/trinkets/trinket_18a"}
        }, { -- Surveyor of the Storm Live Event
            patterns = {}, desc_key = "live_event_surveyor_of_the_storm", extra_names = {"content/items/2d/insignias/insignia_94"}
        },
        { -- A day at the theatre Live Event
            patterns = {}, desc_key = "live_event_day_at_the_theatre", extra_names = {"content/items/2d/insignias/insignia_event_hordes"}
        },
        { -- Communication Breakdown Live Event
            patterns = {}, desc_key = "live_event_communication_breakdown", extra_names = {"content/items/2d/insignias/insignia_event_hack"}
        },
        { -- Admonition Ascendant Live Event
            patterns = {}, desc_key = "live_event_admonition_ascendant", extra_names = {"content/items/2d/insignias/insignia_skull_week_2025"}
        },
        { -- Warhammer Fest Live Event
            patterns = {}, desc_key = "live_event_warhammer_fest", extra_names = {"content/items/2d/portrait_frames/events_warhammer_fest_01"}
        },
        { -- Waking giants Live Event
            patterns = {}, desc_key = "live_event_waking_giants", extra_names = {"content/items/2d/portrait_frames/class_ogryn_05_yellow"}
        },
        { -- Grandfathers Gifts Live Event
            patterns = {}, desc_key = "live_event_grandfather_gifts", extra_names = {"content/items/2d/portrait_frames/events_poxwalker"}
        },
        { -- Developer Exclusive
            patterns = {}, desc_key = "dev_exclusive", extra_names = {"content/items/2d/portrait_frames/developer_exclusive"}
        },
        { -- Cry Havoc Live Event
            patterns = {}, desc_key = "live_event_cry_havoc", extra_names = {"content/items/weapons/player/trinkets/trinket_15c"}
        }
    }

    local found = false
    for _, entry in ipairs(special_sources) do

        for _, pat in ipairs(entry.patterns) do
            if string.find(name, pat, 1, true) then
                found = entry
                break
            end
        end

        if not found and entry.extra_names then
            for _, ename in ipairs(entry.extra_names) do
                if selected_item.name == ename then
                    found = entry
                    break
                end
            end
        end
        if found then
            break
        end
    end

    local description = found and mod:localize(found.desc_key) or mod:localize("redacted")

    if source == 0 then
        mod.create_text_widget(self, InventoryViewDefinitions.big_header_text_pass, obtained_desc, 20)
        mod.create_text_widget(self, InventoryViewDefinitions.big_body_text_pass, description, 15)
    elseif source == 1 then
        local widgets_by_name = self._widgets_by_name
        widgets_by_name.sub_display_name.content.text =
            widgets_by_name.sub_display_name.content.text .. "\n\n{#color(113,126,103)}" .. obtained_desc .. "\n{#color(216,229,207)}" .. description
    end
end

------------------------------------------------------------------------------------------------------
--- Formats integers into nice, readable strings with comma separation.
---@param number any The number to convert.
---@return string any formatted number with comma separators.
------------------------------------------------------------------------------------------------------
mod.format_number = function(number)
    if number then
        return tostring(math.floor(number)):reverse():gsub("(%d%d%d)", "%1,"):gsub(",(%-?)$", "%1"):reverse()
    end
end

------------------------------------------------------------------------------------------------------
--- Caches items of the hestias blessings rewards.
------------------------------------------------------------------------------------------------------
mod.cache_hestias = function(self)
    mod._fetch_penance_track_account_state():next(
        function(response)
            current_penance_points = response.state.xpTracked
        end
    )

    if (#hestias_rewards_cache < 1) then
        Managers.data_service.penance_track:get_track(PENANCE_TRACK_ID):next(
            function(data)
                self._track_data = data
                local points_per_reward = 100

                if self._track_data then
                    local tiers = self._track_data.tiers

                    if tiers then
                        local archetype_name = self:_player():archetype_name()

                        for i = 1, #tiers do
                            local tier = tiers[i]
                            local tier_rewards = tier.rewards
                            local xp_limit = tier.xpLimit
                            local items = {}

                            for reward_name, reward in pairs(tier_rewards) do
                                if reward.type == "item" then
                                    local item_id = reward.id
                                    local item = MasterItems.get_item(item_id)

                                    if #items > 0 then
                                        local first_item_archetypes = items[1].archetypes
                                        local first_item_has_matching_archetype = false

                                        if first_item_archetypes then
                                            for j = 1, #first_item_archetypes do
                                                local item_archetype = first_item_archetypes[j]

                                                if item_archetype == archetype_name then
                                                    first_item_has_matching_archetype = true

                                                    break
                                                end
                                            end
                                        end

                                        if not first_item_has_matching_archetype then
                                            local archetypes = item.archetypes
                                            local added_item = false

                                            if archetypes then
                                                for j = 1, #archetypes do
                                                    local item_archetype = archetypes[j]

                                                    if item_archetype == archetype_name then
                                                        items[#items + 1] = items[1]
                                                        items[1] = item
                                                        added_item = true

                                                        break
                                                    end
                                                end
                                            end

                                            if not added_item then
                                                items[#items + 1] = item
                                            end
                                        else
                                            items[#items + 1] = item
                                        end
                                    else
                                        items[#items + 1] = item
                                    end
                                end
                            end

                            hestias_rewards_cache[i] = {points_required = xp_limit, items = items}
                        end
                    end
                end
            end
        )
    end
end

------------------------------------------------------------------------------------------------------
--- Caches cosmetic items of the commisary rewards.
------------------------------------------------------------------------------------------------------
mod.cache_commissary_cosmetics = function(self)
    if (commisary_cache == nil) then
        Managers.data_service.store:get_credits_cosmetics_store():next(
            function(data)
                Managers.data_service.store:get_credits_weapon_cosmetics_store():next(
                    function(data2)
                        for k, v in pairs(data2.offers) do
                            table.insert(data.offers, v)
                        end

                        commisary_cache = data
                    end
                )
            end
        )
    end
end

------------------------------------------------------------------------------------------------------
--- Creates a new text widget from the passed template.
---@param pass_template any
---@param text any Text to be contained.
------------------------------------------------------------------------------------------------------
mod.create_text_widget = function(self, pass_template, text, y_offset)
    local scenegraph_id = "side_panel_area"
    local max_width = self._ui_scenegraph[scenegraph_id].size[1]
    local widgets = self._side_panel_widgets

    -- Calculate y_offset to place the new widget underneath existing widgets
    local calculated_y_offset = 0
    if widgets and #widgets > 0 then
        for i = 1, #widgets do
            local w = widgets[i]
            local widget_bottom = (w.offset and w.offset[2] or 0) + (w.content and w.content.size and w.content.size[2] or 0)
            if widget_bottom > calculated_y_offset then
                calculated_y_offset = widget_bottom
            end
        end
    end
    -- If a y_offset is provided, add it as extra spacing
    if y_offset then
        calculated_y_offset = calculated_y_offset + y_offset
    end

    local widget_definition = UIWidget.create_definition(pass_template, scenegraph_id, nil, {max_width, 0})
    local widget = self:_create_widget(string.format("side_panel_widget_%d", #widgets), widget_definition)

    widget.content.text = text
    widget.offset[2] = calculated_y_offset

    local widget_text_style = widget.style.text
    local text_options = UIFonts.get_font_options_by_style(widget.style.text)
    local _, text_height = self:_text_size(text, widget_text_style.font_type, widget_text_style.font_size, {max_width, math.huge}, text_options)

    widget.content.size[2] = text_height
    widgets[#widgets + 1] = widget

    return widget
end

------------------------------------------------------------------------------------------------------
--- Grabs the current penance details (e.g. penance points)
------------------------------------------------------------------------------------------------------
mod._fetch_penance_track_account_state = function(self)
    local backend_interface = Managers.backend.interfaces
    local penance_track = backend_interface.tracks
    local promise = penance_track:get_track_state(PENANCE_TRACK_ID):next(
                        function(response)
            return response
        end
                    )

    return promise:next(
               function(response)
            return response
        end
           )
end

local add_definitions = function(definitions)
    if not definitions then
        return
    end

    definitions.scenegraph_definition = definitions.scenegraph_definition or {}
    definitions.widget_definitions = definitions.widget_definitions or {}

    local info_box_size = {1250, 200}

    definitions.scenegraph_definition.side_panel_area = {
        horizontal_alignment = "left", parent = "canvas", vertical_alignment = "bottom", size = {650, 0}, position = {600, -260, 3}
    }

    definitions.scenegraph_definition.info_box = {
        horizontal_alignment = "right", parent = "canvas", vertical_alignment = "bottom", size = info_box_size, position = {-70, -125, 3}
    }

    definitions.scenegraph_definition.item_name_pivot = {
        horizontal_alignment = "right", parent = "canvas", vertical_alignment = "bottom", size = {0, 0}, position = {-0, -260, 3}
    }
end

mod:hook_require(
    "scripts/ui/views/inventory_cosmetics_view/inventory_cosmetics_view_definitions", function(definitions)
        add_definitions(definitions)
    end
)
