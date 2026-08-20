local mod = get_mod("how_did_I_get_that")
mod.version = "2.6.06"
mod:info("How Did I Get That is installed, using version: " .. tostring(mod.version))

local colours = {
	title = "200,140,20",
	subtitle = "226,199,126",
	text = "169,191,153",
}

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function utf8_chars(s)
	local chars = {}
	for char in string.gmatch(s, "[%z\1-\127\194-\244][\128-\191]*") do
		table.insert(chars, char)
	end
	return chars
end

mod.gradientText = function(text, startColor, endColor, colorSpaces)
	local result = ""
	local chars = utf8_chars(text)
	local visibleIndex = 0

	for _, char in ipairs(chars) do
		if colorSpaces or char ~= " " then
			visibleIndex = visibleIndex + 1
		end
	end

	local currentIndex = 0

	for _, char in ipairs(chars) do
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

	result = "{#color(" .. colours.title .. ")}" .. result .. "{#reset()}"
	return result
end

local mod_name = {
	en = "How Did I Get That?",
	ru = "Как я это получил?",
	["zh-cn"] = "我怎么得到的？",
	["zh-tw"] = "我怎麼得到的？",
}

mod.localisation = {
	mod_name_pizazz_toggle = {
		en = "Enable Name Pizazz",
		ru = "Включить красочные имена",
		["zh-cn"] = "启用名称特效",
		["zh-tw"] = "啟用名稱特效",
	},
	mod_name_pizazz_tooltip = {
		en = "Toggles the rainbow colours effect on the mod name text. Requires a reload.\nIf enabled, you will get a small euphoric experience everytime you scroll through the mod menu, \nIf disabled - you will be a John Darktide and have no rainbow sprinkles (but I'll love you anyway).",
		ru = "Включает радужный эффект для текста имени мода. Требуется перезагрузка.\nЕсли включено, вы будете получать небольшой эйфорический опыт каждый раз, когда прокручиваете меню модов.\nЕсли выключено - вы будете Джоном Дарктайдом и без радужных посыпок (но я все равно буду вас любить).",
		["zh-cn"] = "切换模组名称的彩虹颜色效果。需要重新加载。\n启用后，每次滚动模组菜单时你都会获得小小的愉悦体验。\n禁用后，你将失去彩虹点缀（但我仍然爱你）。",
		["zh-tw"] = "切換模組名稱的彩虹顏色效果。需要重新載入。\n啟用後，每次滾動模組選單時你都會獲得小小的愉悅體驗。\n停用後，你將成為一般的黑暗潮汐玩家，失去彩虹點綴（但我仍然愛你）。",
	},
	mod_name = {
		en = mod_name["en"],
		ru = mod_name["ru"],
		["zh-cn"] = mod_name["zh-cn"],
		["zh-tw"] = mod_name["zh-tw"],
	},
	mod_name_pizazz = {
		en = mod.gradientText(mod_name["en"], { 0, 255, 0 }, { 0, 255, 190 }, true),
		ru = mod.gradientText(mod_name["ru"], { 0, 255, 0 }, { 0, 255, 190 }, true),
		["zh-cn"] = mod.gradientText(mod_name["zh-cn"], { 0, 255, 0 }, { 0, 255, 190 }, true),
		["zh-tw"] = mod.gradientText(mod_name["zh-tw"], { 0, 255, 0 }, { 0, 255, 190 }, true),
	},
	mod_name_boring = {
		en = mod_name["en"],
		ru = mod_name["ru"],
		["zh-cn"] = mod_name["zh-cn"],
		["zh-tw"] = mod_name["zh-tw"],
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
		["zh-cn"] = "{#color("
			.. colours.text
			.. ")}"
			.. "查看所有化妆品的获取方式详情，包括苦行奖励、军需商店物品和赫斯提亚祝福奖励。"
			.. "{#reset()}\n\n"
			.. "{#color("
			.. colours.subtitle
			.. ")}作者："
			.. "{#color("
			.. colours.text
			.. ")}Alfthebigheaded\n"
			.. "{#color("
			.. colours.subtitle
			.. ")}版本：{#color("
			.. colours.text
			.. ")}"
			.. mod.version
			.. "{#reset()}",
		["zh-tw"] = "{#color("
			.. colours.text
			.. ")}"
			.. "查看所有化妝品的取得方式詳情，包括苦行獎勵、軍需商店物品和赫斯提亞祝福獎勵。"
			.. "{#reset()}\n\n"
			.. "{#color("
			.. colours.subtitle
			.. ")}作者："
			.. "{#color("
			.. colours.text
			.. ")}Alfthebigheaded\n"
			.. "{#color("
			.. colours.subtitle
			.. ")}版本：{#color("
			.. colours.text
			.. ")}"
			.. mod.version
			.. "{#reset()}",
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
		["zh-cn"] = "，需花费 " .. "!content" .. " 奥多凭证",
		["zh-tw"] = "，需花費 " .. "!content" .. " 奧多憑證",
		ru = ", за " .. "!content" .. " чеков ордо",
		--jp = "",
		--pl = "",
		--["pt-br"] = ""
	},
	aquila_amount_text = {
		en = " for " .. "!content" .. " Aquilas",
		ru = ", за " .. "!content" .. " аквил",
		["zh-cn"] = "，需花费 " .. "!content" .. " 鹰币",
		["zh-tw"] = "，需花費 " .. "!content" .. " 鷹幣",
	},
	penance_amount_singular_text = {
		en = "Requires the following penance to complete",
		--de= "",
		--fr="",
		--it="",
		ko = "획득하려면 아래의 고행을 완료해야 합니다",
		--es = "",
		["zh-cn"] = "需要完成以下苦行",
		["zh-tw"] = "需要完成以下苦行",
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
		["zh-cn"] = "需要完成以下 " .. "!content" .. " 项苦行",
		["zh-tw"] = "需要完成以下 " .. "!content" .. " 項苦行",
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
		["zh-cn"] = "赫斯提亚的祝福需要 " .. "!content" .. " 苦行点数",
		["zh-tw"] = "赫斯提亞的祝福需要 " .. "!content" .. " 苦行點數",
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
		["zh-cn"] = "你当前拥有 " .. "!content" .. " 苦行点数",
		["zh-tw"] = "你目前擁有 " .. "!content" .. " 苦行點數",
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
		["zh-cn"] = "暗潮：帝国版",
		["zh-tw"] = "黑暗潮汐：帝國版",
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
		["zh-cn"] = "暗潮 Twitch掉落",
		["zh-tw"] = "黑暗潮汐 Twitch掉落",
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
		["zh-cn"] = "2023年11月17日之前在PC上游玩暗潮",
		["zh-tw"] = "2023年11月17日之前在PC上遊玩黑暗潮汐",
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
		["zh-cn"] = "参与暗潮公测",
		["zh-tw"] = "參與黑暗潮汐封測",
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
		["zh-cn"] = "默认物品",
		["zh-tw"] = "預設物品",
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
		["zh-cn"] = "预购物品",
		["zh-tw"] = "預購物品",
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
		["zh-cn"] = "++ 已删除 ++",
		["zh-tw"] = "++ 已刪除 ++",
		ru = "++ УДАЛЕНО ++",
		--jp = "",
		--pl = "",
		--["pt-br"] = ""
	},
	rogue_trader_crossover = {
		en = "Owlcat & Fatshark - Rogue Trader & Darktide Crossover, May 2025",
		ru = "Кроссовер Owlcat & Fatshark - Rogue Trader & Darktide, май 2025",
		["zh-cn"] = "Owlcat & Fatshark - 诡秘妖鬼与暗潮联动，2025年5月",
		["zh-tw"] = "Owlcat & Fatshark - 詭秘妖鬼與黑暗潮汐聯動，2025年5月",
	},
	live_event_surveyor_of_the_storm = {
		en = "Live Event: Surveyor of the Storm",
		ru = "Событие: Инспектор Бури",
		["zh-cn"] = "限时活动：风暴勘察者",
		["zh-tw"] = "限時活動：風暴勘察者",
	},
	live_event_day_at_the_theatre = {
		en = "Live Event: Day at the Theatre, Mar 2025",
		ru = "Событие: День в театре, март 2025",
		["zh-cn"] = "限时活动：剧院之日，2025年3月",
		["zh-tw"] = "限時活動：劇院之日，2025年3月",
	},
	live_event_communication_breakdown = {
		en = "Live Event: Communication Breakdown, Apr 2025",
		ru = "Событие: Сбой связи, апрель 2025",
		["zh-cn"] = "限时活动：通讯故障，2025年4月",
		["zh-tw"] = "限時活動：通訊故障，2025年4月",
	},
	live_event_admonition_ascendant = {
		en = "Live Event: Admonition Ascendant, May 2025",
		ru = "Событие: Вознесение наставления, май 2025",
		["zh-cn"] = "限时活动：训诫升华，2025年5月",
		["zh-tw"] = "限時活動：訓誡昇華，2025年5月",
	},
	live_event_warhammer_fest = {
		en = "Live Event: Warhammer Fest",
		ru = "Событие: Warhammer Fest",
		["zh-cn"] = "限时活动：战锤嘉年华",
		["zh-tw"] = "限時活動：戰錘嘉年華",
	},
	live_event_waking_giants = {
		en = "Live Event: Waking Giants, Jan 2025",
		ru = "Событие: Пробуждение гигантов, январь 2025",
		["zh-cn"] = "限时活动：唤醒巨人，2025年1月",
		["zh-tw"] = "限時活動：喚醒巨人，2025年1月",
	},
	live_event_grandfather_gifts = {
		en = "Live Event: Grandfather Gifts, Nov 2024",
		ru = "Событие: Дары Деда, ноябрь 2024",
		["zh-cn"] = "限时活动：祖父的礼物，2024年11月",
		["zh-tw"] = "限時活動：祖父的禮物，2024年11月",
	},
	dev_exclusive = {
		en = "Fatshark developer exclusive <3",
		ru = "Эксклюзив для разработчиков Fatshark <3",
		["zh-cn"] = "Fatshark开发者专属 <3",
		["zh-tw"] = "Fatshark開發者專屬 <3",
	},
	live_event_cry_havoc = {
		en = "Live Event: Cry Havoc, Dec 2024",
		ru = "Событие: Сеять хаос, декабрь 2024",
		["zh-cn"] = "限时活动：大开杀戒，2024年12月",
		["zh-tw"] = "限時活動：大開殺戒，2024年12月",
	},

	arbites_deluxe = {
		en = "Arbites Class: Deluxe Edition",
		ru = "Класс Арбитрес: Делюкс-издание",
		["zh-cn"] = "仲裁者职业：豪华版",
		["zh-tw"] = "仲裁者職業：豪華版",
	},
	broker_deluxe = {
		en = "Hive Scum Class: Deluxe Edition",
		ru = "Класс Отброс Улья: Делюкс-издание",
		["zh-cn"] = "巢都渣滓职业：豪华版",
		["zh-tw"] = "巢都敗類職業：豪華版",
	},
	cryptic_deluxe = {
		en = "Skitarii Class: Deluxe Edition",
		ru = "Класс Скитарий: Делюкс-издание",
		["zh-cn"] = "机仆职业：豪华版",
		["zh-tw"] = "機僕職業：豪華版",
	},

	live_event_the_day_of_atonement = {
		en = "Live Event: The Day of Atonement, Dec 2025",
		ru = "Событие: День искупления, декабрь 2025",
		["zh-cn"] = "限时活动：赎罪日，2025年12月",
		["zh-tw"] = "限時活動：贖罪日，2025年12月",
	},
	live_event_stolen_rations = {
		en = "Live Event: Stolen Rations, Nov 2025",
		ru = "Событие: Украденные пайки, ноябрь 2025",
		["zh-cn"] = "限时活动：失窃口粮，2025年11月",
		["zh-tw"] = "限時活動：失竊口糧，2025年11月",
	},
	live_event_smuggled_munitions = {
		en = "Live Event: Smuggled Munitions, Oct 2025",
		ru = "Событие: Контрабандные боеприпасы, октябрь 2025",
		["zh-cn"] = "限时活动：走私弹药，2025年10月",
		["zh-tw"] = "限時活動：走私彈藥，2025年10月",
	},
	live_event_light_the_fuse = {
		en = "Live Event: Light the Fuse, Aug 2025",
		ru = "Событие: Зажги фитиль, август 2025",
		["zh-cn"] = "限时活动：点燃引信，2025年8月",
		["zh-tw"] = "限時活動：點燃引信，2025年8月",
	},
	live_event_rotten_armour = {
		en = "Live Event: Rotten Armour, Jul 2025",
		ru = "Событие: Гнилая броня, июль 2025",
		["zh-cn"] = "限时活动：腐朽装甲，2025年7月",
		["zh-tw"] = "限時活動：腐朽裝甲，2025年7月",
	},
	live_event_inferno = {
		en = "Live Event: Inferno, Jun 2025",
		ru = "Событие: Инферно, июнь 2025",
		["zh-cn"] = "限时活动：炼狱，2025年6月",
		["zh-tw"] = "限時活動：煉獄，2025年6月",
	},

	live_event_cartels_favour = {
		en = "Live Event: Cartel's Favour, Feb 2026",
		ru = "Событие: Благосклонность картеля, февраль 2026",
		["zh-cn"] = "限时活动：卡特尔的青睐，2026年2月",
		["zh-tw"] = "限時活動：卡特爾的青睞，2026年2月",
	},
	live_event_rumbling_giants = {
		en = "Live Event: Rumbling Giants, Mar 2026",
		ru = "Событие: Грохочущие гиганты, март 2026",
		["zh-cn"] = "限时活动：轰鸣巨人，2026年3月",
		["zh-tw"] = "限時活動：轟鳴巨人，2026年3月",
	},
	live_event_deadside_patrol = {
		en = "Live Event: Deadside Patrol, Apr 2026",
		ru = "Событие: Патруль мёртвой зоны, апрель 2026",
		["zh-cn"] = "限时活动：死域巡逻，2026年4月",
		["zh-tw"] = "限時活動：死域巡邏，2026年4月",
	},
	skulls_2023 = {
		en = "Warhammer Skulls 2023",
		ru = "Warhammer Skulls 2023",
		["zh-cn"] = "战锤骷髅节 2023",
		["zh-tw"] = "戰錘骷髏節 2023",
	},
	fest_2023 = {
		en = "Warhammer Fest 2023",
		ru = "Warhammer Fest 2023",
		["zh-cn"] = "战锤嘉年华 2023",
		["zh-tw"] = "戰錘嘉年華 2023",
	},
	live_event_nurgles_might = {
		en = "Live Event: Nurgle's Might, May 2026",
		ru = "Событие: Сила Нургла, май 2026",
		["zh-cn"] = "限时活动：纳垢之力，2026年5月",
		["zh-tw"] = "限時活動：納垢之力，2026年5月",
	},
	unknown_penance = {
		en = "Penance\n(Unavailable)",
		ru = "Искупление\n(Недоступно)",
		["zh-cn"] = "苦行\n（不可用）",
		["zh-tw"] = "苦行\n（不可用）",
	},
	unknown_commissary = {
		en = "Commissary\n(Unavailable)",
		ru = "Комиссариат\n(Недоступно)",
		["zh-cn"] = "军需商店\n（不可用）",
		["zh-tw"] = "軍需商店\n（不可用）",
	},
	unknown_hestias = {
		en = "Hestia's Blessings\n(Unavailable)",
		ru = "Благословения Гестии\n(Недоступно)",
		["zh-cn"] = "赫斯提亚的祝福\n（不可用）",
		["zh-tw"] = "赫斯提亞的祝福\n（不可用）",
	},

	general_settings = {
		en = "{#color(" .. colours.title .. ")}General Settings{#reset()}",
		ru = "{#color(" .. colours.title .. ")}Общие настройки{#reset()}",
		["zh-cn"] = "{#color(" .. colours.title .. ")}通用设置{#reset()}",
		["zh-tw"] = "{#color(" .. colours.title .. ")}一般設定{#reset()}",
	},
	placeholder = {
		en = "",
		ru = "",
		["zh-cn"] = "",
		["zh-tw"] = "",
	},
	placeholder_tooltip = {
		en = "A placeholder entry to initialise the mod menu, does not do anything yet.\nMore features may be added at some point.",
		ru = "Заглушка для инициализации меню мода, пока ничего не делает.\nВозможно, в будущем будут добавлены дополнительные функции.",
		["zh-cn"] = "用于初始化模组菜单的占位符，目前没有任何功能。\n后续可能会添加更多功能。",
		["zh-tw"] = "用於初始化模組選單的佔位符，目前沒有任何功能。\n後續可能會添加更多功能。",
	},
	live_event_heretical_artefacts = {
		en = "Live Event: Heretical Artefacts, Jun 2026",
		ru = "Событие: Еретические артефакты, июнь 2026",
		["zh-cn"] = "限时活动：异端圣物，2026年6月",
		["zh-tw"] = "限時活動：異端聖物，2026年6月",
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
