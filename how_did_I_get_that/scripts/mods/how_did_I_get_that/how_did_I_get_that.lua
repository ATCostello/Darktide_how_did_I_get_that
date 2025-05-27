--[[
    Name: How Did I Get That?
    Author: Alfthebigheaded
    version: 1.0
]]

local mod = get_mod("how_did_I_get_that")
local ViewElementGrid = require("scripts/ui/view_elements/view_element_grid/view_element_grid")
local Blueprints = mod:io_dofile("how_did_I_get_that/scripts/mods/how_did_I_get_that/how_did_I_get_that_blueprints")
local Definitions = mod:io_dofile("how_did_I_get_that/scripts/mods/how_did_I_get_that/how_did_I_get_that_definitions")
local InventoryViewDefinitions = require(
    "scripts/ui/views/inventory_cosmetics_view/inventory_cosmetics_view_definitions")
local AchievementUIHelper = require("scripts/managers/achievements/utility/achievement_ui_helper")
local AchievementTypes = require("scripts/managers/achievements/achievement_types")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIFonts = require("scripts/managers/ui/ui_fonts")
local MasterItems = require("scripts/backend/master_items")

local PENANCE_TRACK_ID = "dec942ce-b6ba-439c-95e2-022c5d71394d"
local commisary_cache
local hestias_rewards_cache = {}
local current_penance_points = 0

mod:hook_safe(CLASS.InventoryCosmeticsView, "on_enter", function(self)
    -- Load cache with items
    mod.cache_hestias(self)
    mod.cache_commissary(self)
end)

mod:hook_safe(CLASS.InventoryCosmeticsView, "on_exit", function(self)
    -- clear cache
    commisary_cache = nil
    hestias_rewards_cache = {}
end)

mod:hook_safe(CLASS.InventoryCosmeticsView, "_preview_element", function(self, element)
    local selected_item = self._previewed_item
    mod:dump({}, "TEST", 4)
    local selected_item_source = selected_item
        .source -- 1 = Penance, 2 = Commisary, 3 = Commodore's Vestures, 4 = Hestia's Blessings

    -- Hide penance view if present
    if (self.penance_grid_view) then
        self.penance_grid_view:set_visibility(false)
    end

    if selected_item_source == 1 then
        mod.display_penances(self, selected_item)
    elseif selected_item_source == 2 then
        mod.display_commisary(self, selected_item)
        --elseif selected_item_source == 3 then
        --    mod.display_commodores_vestures(self, selected_item)
    elseif selected_item_source == 4 then
        mod.display_hestias_blessings(self, selected_item)
    end
end)

mod.display_commisary = function(self, selected_item)
    local selected_slot = self._selected_slot
    local selected_slot_name = selected_slot.name
    local selected_item_sku_name = selected_item.display_name
    local selected_item_cost = 0

    if commisary_cache ~= nil then
        local offers = commisary_cache.offers
        local startpos = mod.find_obtained_text(self)
        for i = 1, #offers do
            local offer = offers[i]
            local offer_sku_name = offer.sku.name
            if selected_item_sku_name == offer_sku_name then
                selected_item_cost = offer.price.amount.amount

                if selected_item_cost > 0 then
                    self._side_panel_widgets[startpos + 1].content.text = self._side_panel_widgets[startpos + 1].content
                        .text ..
                        " for " .. mod.format_number(selected_item_cost) .. " gold"
                end
                break
            end
        end
    else
        mod.cache_commissary(self)
    end
end


mod.display_penances = function(self, selected_item)
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
        self.penance_grid_view:set_pivot_offset(570, 750)

        for i = 1, #requiredPenances do
            local currentAchievement = AchievementUIHelper.achievement_definition_by_id(requiredPenances[i])

            local achievement_id = currentAchievement.id

            local achievement_definition = Managers.achievements:achievement_definition(achievement_id)

            local progress = 0
            local goal = 1
            local player = Managers.player:local_player_safe(1);

            local type = AchievementTypes[achievement_definition.type]
            local has_progress_bar = type.get_progress ~= nil

            if has_progress_bar then
                progress, goal = type.get_progress(achievement_definition, player)
            end

            penance_list[#penance_list + 1] = {
                widget_type = "penance_list_item",
                achievement_definition = achievement_definition,
                progress = progress,
                goal = goal
            }
        end

        -- Replace default description of locked penances with an actually useful one
        local penance_description = "Requires:"

        local startpos = mod.find_obtained_text(self)
        if #self._side_panel_widgets > 2 and startpos ~= nil then
            if (#penance_list > 1) then
                penance_description = "Requires the following " ..
                    #penance_list .. " penances to complete:"
            else
                penance_description = "Requires the following penance to complete:"
            end

            if (self._side_panel_widgets[startpos + 2]) then
                self._side_panel_widgets[startpos + 2].content.text = penance_description
            end
            -- Increase offset
            for i = 1, #self._side_panel_widgets do
                self._side_panel_widgets[i].offset[2] = self._side_panel_widgets[i].offset[2] - 170
            end


            -- Add description to unlocked penances
        elseif startpos ~= nil then
            if (#penance_list > 1) then
                penance_description = "Requires the following " ..
                    #penance_list .. " penances to complete:"
            else
                penance_description = "Requires the following penance to complete:"
            end

            mod.create_text_widget(self, InventoryViewDefinitions.big_details_text_pass, penance_description)

            -- Increase offset
            for i = 1, #self._side_panel_widgets do
                self._side_panel_widgets[i].offset[2] = self._side_panel_widgets[i].offset[2] - 120
            end
        end

        self.penance_grid_view:present_grid_layout(penance_list, Blueprints)
    else
        if (self.penance_grid_view) then
            self.penance_grid_view:set_visibility(false)
        end
    end
end

mod.display_hestias_blessings = function(self, selected_item)
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

        local startpos = mod.find_obtained_text(self)
        self._side_panel_widgets[startpos + 1].content.text = self._side_panel_widgets[startpos + 1].content.text ..
            " at " ..
            mod.format_number(hestias_penance.points_required) .. " penance points"

        mod.create_text_widget(self, InventoryViewDefinitions.small_header_text_pass,
            "You currently have " .. mod.format_number(current_penance_points) .. " penance points")
        self._side_panel_widgets[#self._side_panel_widgets].offset[2] = self._side_panel_widgets
            [#self._side_panel_widgets - 1].offset[2] + 30
    end
end

mod.format_number = function(number)
    return tostring(math.floor(number)):reverse():gsub("(%d%d%d)", "%1,"):gsub(",(%-?)$", "%1"):reverse()
end

mod.create_text_widget = function(self, pass_template, text)
    local y_offset = 8
    local scenegraph_id = "side_panel_area"
    local max_width = self._ui_scenegraph[scenegraph_id].size[1]
    local widgets = self._side_panel_widgets

    local widget_definition = UIWidget.create_definition(pass_template, scenegraph_id, nil, {
        max_width,
        0,
    })
    local widget = self:_create_widget(string.format("side_panel_widget_%d", #widgets), widget_definition)

    widget.content.text = text
    widget.offset[2] = y_offset

    local widget_text_style = widget.style.text
    local text_options = UIFonts.get_font_options_by_style(widget.style.text)
    local _, text_height = self:_text_size(text, widget_text_style.font_type, widget_text_style.font_size, {
        max_width,
        math.huge,
    }, text_options)

    y_offset = y_offset + text_height
    widget.content.size[2] = text_height
    widgets[#widgets + 1] = widget

    return widget
end

mod.find_obtained_text = function(self)
    for i = 1, #self._side_panel_widgets do
        if (self._side_panel_widgets[i].content.text == "OBTAINED FROM:") then
            return i
        end
    end
end

mod.cache_hestias = function(self)
    mod._fetch_penance_track_account_state():next(function(response)
        current_penance_points = response.state.xpTracked
    end)


    if (#hestias_rewards_cache < 1) then
        Managers.data_service.penance_track:get_track(PENANCE_TRACK_ID):next(function(data)
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

                        hestias_rewards_cache[i] = {
                            points_required = xp_limit,
                            items = items,
                        }
                    end
                end
            end
        end)
    end
end

mod.cache_commissary = function(self)
    if (commisary_cache == nil) then
        Managers.data_service.store:get_credits_cosmetics_store():next(function(data)
            commisary_cache = data
        end)
    end
end

mod._fetch_penance_track_account_state = function(self)
    local backend_interface = Managers.backend.interfaces
    local penance_track = backend_interface.tracks
    local promise = penance_track:get_track_state(PENANCE_TRACK_ID):next(function(response)
        return response
    end)

    return promise:next(function(response)
        return response
    end)
end
