local mod = get_mod("how_did_I_get_that")
mod.version = "2.6.05"
mod:info("How Did I Get That is installed, using version: " .. tostring(mod.version))

local colours = {
	title = "200,140,20",
	subtitle = "226,199,126",
	text = "169,191,153",
}

local function lerp(a, b, t)
	return a + (b - a) * t
end

mod.gradientText = function(text, startColor, endColor, colorSpaces)
	local result = ""
	local length = #text
	local visibleIndex = 0

	-- Count visible characters
	for i = 1, length do
		local char = text:sub(i, i)
		if colorSpaces or char ~= " " then
			visibleIndex = visibleIndex + 1
		end
	end

	local currentIndex = 0

	for i = 1, length do
		local char = text:sub(i, i)

		if not colorSpaces and char == " " then
			result = result .. char
		else
			currentIndex = currentIndex + 1
			local t = (visibleIndex <= 1) and 0 or (currentIndex - 1) / (visibleIndex - 1)

			local r = math.floor(lerp(startColor[1], endColor[1], t))
			local g = math.floor(lerp(startColor[2], endColor[2], t))
			local b = math.floor(lerp(startColor[3], endColor[3], t))

			result = result .. string.format("{#color(%d,%d,%d)}%s", r, g, b, char)
		end
	end

	result = "{#color(" .. colours.title .. ")} " .. result .. "{#reset()}"
	return result
end

local mod_name = {
	en = "How Did I Get That?",
	ru = "Как я это получил?",
}

mod.localisation = {
	mod_name_pizazz_toggle = {
		en = "Enable Name Pizazz",
		ru = "Включить красочные имена",
	},
	mod_name_pizazz_tooltip = {
		en = "Toggles the rainbow colours effect on the mod name text. Requires a reload.\nIf enabled, you will get a small euphoric experience everytime you scroll through the mod menu, \nIf disabled - you will be a John Darktide and have no rainbow sprinkles (but I'll love you anyway).",
		ru = "Включает радужный эффект для текста имени мода. Требуется перезагрузка.\nЕсли включено, вы будете получать небольшой эйфорический опыт каждый раз, когда прокручиваете меню модов.\nЕсли выключено - вы будете Джоном Дарктайдом и без радужных посыпок (но я все равно буду вас любить).",
	},
	mod_name = {
		en = mod_name["en"],
		ru = mod_name["ru"],
	},
	mod_name_pizazz = {
		en = mod.gradientText(mod_name["en"], { 0, 255, 0 }, { 0, 255, 190 }, true),
		ru = mod.gradientText(mod_name["ru"], { 0, 255, 0 }, { 0, 255, 190 }, true),
	},
	mod_name_boring = {
		en = mod_name["en"],
		ru = mod_name["ru"],
	},
	mod_description = {
		en = "{#color("
			.. colours.text
			.. ")}"
			.. "See details on how to obtain all cosmetics, including penance rewards, commissary items and Hestia's blessing rewards."
			.. "{#reset()}\n\n"
			.. "{#color("
			.. colours.subtitle
			.. ")}Author: "
			.. "{#color("
			.. colours.text
			.. ")}Alfthebigheaded\n"
			.. "{#color("
			.. colours.subtitle
			.. ")}Version: {#color("
			.. colours.text
			.. ")}"
			.. mod.version
			.. "{#reset()}",
		--de= "",
		--fr="",
		--it="",
		ko = "화장품 잠금 해제 세부정보 표시",
		--es = "",
		--["zh-cn"] = "",
		--["zh-tw"] = "",
		ru = "{#color("
			.. colours.text
			.. ")}"
			.. "How Did I Get That - Показывает подробности о том, как получить все косметические предметы, включая награды за искупления, предметы из магазина и награды за благословение Гестии."
			.. "{#reset()}\n\n"
			.. "{#color("
			.. colours.subtitle
			.. ")}Автор: "
			.. "{#color("
			.. colours.text
			.. ")}Alfthebigheaded\n"
			.. "{#color("
			.. colours.subtitle
			.. ")}Версия: {#color("
			.. colours.text
			.. ")}"
			.. mod.version
			.. "{#reset()}",
		--jp = "",
		--pl = "",
		--["pt-br"] = ""
	},
	ordo_docket_amount_text = {
		en = " for " .. "!content" .. " Ordo Dockets",
		--de= "",
		--fr="",
		--it="",
		ko = " 에서 " .. "!content" .. " 오도 명세서로 구매할 수 있습니다",
		--es = "",
		--["zh-cn"] = "",
		--["zh-tw"] = "",
		ru = ", за " .. "!content" .. " чеков ордо",
		--jp = "",
		--pl = "",
		--["pt-br"] = ""
	},
	aquila_amount_text = {
		en = " for " .. "!content" .. " Aquilas",
		ru = ", за " .. "!content" .. " аквил",
	},
	penance_amount_singular_text = {
		en = "Requires the following penance to complete",
		--de= "",
		--fr="",
		--it="",
		ko = "획득하려면 아래의 고행을 완료해야 합니다",
		--es = "",
		--["zh-cn"] = "",
		--["zh-tw"] = "",
		ru = "Для завершения требуется следующее искупление",
		--jp = "",
		--pl = "",
		--["pt-br"] = ""
	},
	penance_amount_multiple_text = {
		en = "Requires the following " .. "!content" .. " penances to complete",
		--de= "",
		--fr="",
		--it="",
		ko = "획득하려면 아래 " .. "!content" .. " 개의 고행을 완료해야 합니다",
		--es = "",
		--["zh-cn"] = "",
		--["zh-tw"] = "",
		ru = "Для завершения требуется выполнить "
			.. "!content"
			.. " искуплений",
		--jp = "",
		--pl = "",
		--["pt-br"] = ""
	},
	hestias_blessings_obtained_text = {
		en = "Hestia's Blessings at " .. "!content" .. " penance points",
		--de= "",
		--fr="",
		--it="",
		ko = "헤스티아의 축복에서 " .. "!content" .. "  점의 고행 점수가 필요합니다",
		--es = "",
		--["zh-cn"] = "",
		--["zh-tw"] = "",
		ru = "Благословение Гестии, за " .. "!content" .. " очков искуплений",
		--jp = "",
		--pl = "",
		--["pt-br"] = ""
	},
	hestias_blessings_current_text = {
		en = "You currently have " .. "!content" .. " penance points",
		--de= "",
		--fr="",
		--it="",
		ko = "당신의 현재 고행 점수는 " .. "!content" .. " 점입니다",
		--es = "",
		--["zh-cn"] = "",
		--["zh-tw"] = "",
		ru = "У вас на данный момент " .. "!content" .. " очков искуплений",
		--jp = "",
		--pl = "",
		--["pt-br"] = ""
	},
	imperial_edition = {
		en = "Darktide: Imperial Edition",
		--de= "",
		--fr="",
		--it="",
		ko = "다크타이드: 임페리얼 에디션",
		--es = "",
		--["zh-cn"] = "",
		--["zh-tw"] = "",
		ru = "Darktide: Имперское издание",
		--jp = "",
		--pl = "",
		--["pt-br"] = ""
	},
	twitch_drop = {
		en = "Darktide Twitch Drop",
		--de= "",
		--fr="",
		--it="",
		ko = "다크타이드 트위치 드롭스",
		--es = "",
		--["zh-cn"] = "",
		--["zh-tw"] = "",
		ru = "Darktide Twitch Drop",
		--jp = "",
		--pl = "",
		--["pt-br"] = ""
	},
	first_year = {
		en = "Playing Darktide on PC before November 17, 2023",
		--de= "",
		--fr="",
		--it="",
		ko = "2023년 11월 17일 이전 PC에서 다크타이드 플레이",
		--es = "",
		--["zh-cn"] = "",
		--["zh-tw"] = "",
		ru = "За игру в Darktide на ПК до 17 ноября 2023 года",
		--jp = "",
		--pl = "",
		--["pt-br"] = ""
	},
	beta = {
		en = "Participating in the Darktide Beta",
		--de= "",
		--fr="",
		--it="",
		ko = "다크타이드 베타에 참여하기",
		--es = "",
		--["zh-cn"] = "",
		--["zh-tw"] = "",
		ru = "За участие в бета-тестировании Darktide",
		--jp = "",
		--pl = "",
		--["pt-br"] = ""
	},
	default_item = {
		en = "Default Item",
		--de= "",
		--fr="",
		--it="",
		ko = "기본 아이템",
		--es = "",
		--["zh-cn"] = "",
		--["zh-tw"] = "",
		ru = "Стандартный предмет",
		--jp = "",
		--pl = "",
		--["pt-br"] = ""
	},
	pre_order = {
		en = "Pre-Order Item",
		--de= "",
		--fr="",
		--it="",
		ko = "사전예약 아이템",
		--es = "",
		--["zh-cn"] = "",
		--["zh-tw"] = "",
		ru = "Предмет выдан за предзаказ игры",
		--jp = "",
		--pl = "",
		--["pt-br"] = ""
	},
	redacted = {
		en = "++ REDACTED ++",
		--de= "",
		--fr="",
		--it="",
		ko = "++ 편집됨 ++",
		--es = "",
		--["zh-cn"] = "",
		--["zh-tw"] = "",
		ru = "++ УДАЛЕНО ++",
		--jp = "",
		--pl = "",
		--["pt-br"] = ""
	},
	rogue_trader_crossover = {
		en = "Owlcat & Fatshark - Rogue Trader & Darktide Crossover, May 2025",
		ru = "Кроссовер Owlcat & Fatshark - Rogue Trader & Darktide, май 2025",
	},
	live_event_surveyor_of_the_storm = {
		en = "Live Event: Surveyor of the Storm",
		ru = "Событие: Инспектор Бури",
	},
	live_event_day_at_the_theatre = {
		en = "Live Event: Day at the Theatre, Mar 2025",
		ru = "Событие: День в театре, март 2025",
	},
	live_event_communication_breakdown = {
		en = "Live Event: Communication Breakdown, Apr 2025",
		ru = "Событие: Сбой связи, апрель 2025",
	},
	live_event_admonition_ascendant = {
		en = "Live Event: Admonition Ascendant, May 2025",
		ru = "Событие: Вознесение наставления, май 2025",
	},
	live_event_warhammer_fest = {
		en = "Live Event: Warhammer Fest",
		ru = "Событие: Warhammer Fest",
	},
	live_event_waking_giants = {
		en = "Live Event: Waking Giants, Jan 2025",
		ru = "Событие: Пробуждение гигантов, январь 2025",
	},
	live_event_grandfather_gifts = {
		en = "Live Event: Grandfather Gifts, Nov 2024",
		ru = "Событие: Дары Деда, ноябрь 2024",
	},
	dev_exclusive = {
		en = "Fatshark developer exclusive <3",
		ru = "Эксклюзив для разработчиков Fatshark <3",
	},
	live_event_cry_havoc = {
		en = "Live Event: Cry Havoc, Dec 2024",
		ru = "Событие: Сеять хаос, декабрь 2024",
	},

	arbites_deluxe = {
		en = "Arbites Class: Deluxe Edition",
		ru = "Класс Арбитрес: Делюкс-издание",
	},
	broker_deluxe = {
		en = "Hive Scum Class: Deluxe Edition",
		ru = "Класс Отброс Улья: Делюкс-издание",
	},
	cryptic_deluxe = {
		en = "Skitarii Class: Deluxe Edition",
		ru = "Класс Скитарий: Делюкс-издание",
	},

	live_event_the_day_of_atonement = {
		en = "Live Event: The Day of Atonement, Dec 2025",
		ru = "Событие: День искупления, декабрь 2025",
	},
	live_event_stolen_rations = {
		en = "Live Event: Stolen Rations, Nov 2025",
		ru = "Событие: Украденные пайки, ноябрь 2025",
	},
	live_event_smuggled_munitions = {
		en = "Live Event: Smuggled Munitions, Oct 2025",
		ru = "Событие: Контрабандные боеприпасы, октябрь 2025",
	},
	live_event_light_the_fuse = {
		en = "Live Event: Light the Fuse, Aug 2025",
		ru = "Событие: Зажги фитиль, август 2025",
	},
	live_event_rotten_armour = {
		en = "Live Event: Rotten Armour, Jul 2025",
		ru = "Событие: Гнилая броня, июль 2025",
	},
	live_event_inferno = {
		en = "Live Event: Inferno, Jun 2025",
		ru = "Событие: Инферно, июнь 2025",
	},

	live_event_cartels_favour = {
		en = "Live Event: Cartel's Favour, Feb 2026",
		ru = "Событие: Благосклонность картеля, февраль 2026",
	},
	live_event_rumbling_giants = {
		en = "Live Event: Rumbling Giants, Mar 2026",
		ru = "Событие: Грохочущие гиганты, март 2026",
	},
	live_event_deadside_patrol = {
		en = "Live Event: Deadside Patrol, Apr 2026",
		ru = "Событие: Патруль мёртвой зоны, апрель 2026",
	},
	skulls_2023 = {
		en = "Warhammer Skulls 2023",
		ru = "Warhammer Skulls 2023",
	},
	fest_2023 = {
		en = "Warhammer Fest 2023",
		ru = "Warhammer Fest 2023",
	},
	live_event_nurgles_might = {
		en = "Live Event: Nurgle's Might, May 2026",
		ru = "Событие: Сила Нургла, май 2026",
	},
	unknown_penance = {
		en = "Penance\n(Unavailable)",
		ru = "Искупление\n(Недоступно)",
	},
	unknown_commissary = {
		en = "Commissary\n(Unavailable)",
		ru = "Комиссариат\n(Недоступно)",
	},
	unknown_hestias = {
		en = "Hestia's Blessings\n(Unavailable)",
		ru = "Благословения Гестии\n(Недоступно)",
	},

	general_settings = {
		en = "{#color(" .. colours.title .. ")}General Settings{#reset()}",
		ru = "{#color(" .. colours.title .. ")}Общие настройки{#reset()}",
	},
	placeholder = {
		en = "",
		ru = "",
	},
	placeholder_tooltip = {
		en = "A placeholder entry to initialise the mod menu, does not do anything yet.\nMore features may be added at some point.",
	},
	live_event_heretical_artefacts = {
		en = "Live Event: Heretical Artefacts, Jun 2026",
		ru = "Событие: Еретические артефакты, июнь 2026",
	},
}

mod.toggle_pizazz = function()
	for key, values in pairs(mod.localisation) do
		if key == "mod_name" then
			for language, text in pairs(values) do
				if mod:get("mod_name_pizazz_toggle") then
					mod.localisation[key][language] = mod.localisation["mod_name_pizazz"][language]
				else
					mod.localisation[key][language] = mod.localisation["mod_name_boring"][language]
				end
			end
		end
	end
end

mod.toggle_pizazz()

return mod.localisation
