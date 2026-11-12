## DSA Academy – UI Theme System
## Glassmorphic styling, high contrast legibility, and algorithm identities.

extends RefCounted
class_name UITheme

const THEMES: Dictionary = {
	"linear_search": {
		"chapter": "Chapter 1",
		"name": "Linear Search",
		"icon": "🔍",
		"coda_mood": "curious",
		"accent": Color(0.0, 0.82, 1.0),          # Bright Cyan
		"accent_dark": Color(0.0, 0.35, 0.55),
		"bg_dark": Color(0.03, 0.07, 0.16, 0.88),  # Glassmorphic dark blue-slate
		"border": Color(0.0, 0.75, 1.0, 0.75),
		"coda_color": Color(0.0, 0.82, 1.0),
		"bar_bg": Color(0.02, 0.06, 0.14, 0.90),
	},
	"binary_search": {
		"chapter": "Chapter 2",
		"name": "Binary Search",
		"icon": "⚡",
		"coda_mood": "smart",
		"accent": Color(0.78, 0.42, 1.0),          # Vibrant Purple
		"accent_dark": Color(0.36, 0.12, 0.60),
		"bg_dark": Color(0.07, 0.03, 0.18, 0.88),  # Glassmorphic dark violet
		"border": Color(0.78, 0.38, 1.0, 0.75),
		"coda_color": Color(0.78, 0.42, 1.0),
		"bar_bg": Color(0.06, 0.03, 0.16, 0.90),
	},
	"bubble_sort": {
		"chapter": "Chapter 3",
		"name": "Bubble Sort",
		"icon": "🔄",
		"coda_mood": "energetic",
		"accent": Color(1.0, 0.62, 0.10),          # Vibrant Orange
		"accent_dark": Color(0.55, 0.25, 0.05),
		"bg_dark": Color(0.12, 0.05, 0.02, 0.88),  # Glassmorphic dark amber
		"border": Color(1.0, 0.55, 0.10, 0.75),
		"coda_color": Color(1.0, 0.62, 0.10),
		"bar_bg": Color(0.12, 0.05, 0.02, 0.90),
	},
	"hub": {
		"chapter": "Nexus Terminal",
		"name": "Quantum Archive",
		"icon": "🌐",
		"coda_mood": "welcoming",
		"accent": Color(0.0, 0.88, 1.0),          # Neon Cyan
		"accent_dark": Color(0.0, 0.38, 0.60),
		"bg_dark": Color(0.02, 0.06, 0.14, 0.88),  # Glassmorphic cyber slate
		"border": Color(0.0, 0.85, 1.0, 0.75),
		"coda_color": Color(0.0, 0.88, 1.0),
		"bar_bg": Color(0.02, 0.05, 0.12, 0.90),
	}
}

# ── High-Contrast, Crystal-Clear Color Palette ──
const C_TEXT_MAIN      := Color(1.0,  1.0,  1.0,  1.0)
const C_TEXT_MUTED     := Color(0.82, 0.88, 0.96, 0.95)
const C_WHITE          := Color(1.0,  1.0,  1.0,  1.0)
const C_GREEN          := Color(0.20, 0.96, 0.50, 1.0)
const C_RED            := Color(1.0,  0.30, 0.30, 1.0)
const C_YELLOW         := Color(1.0,  0.88, 0.25, 1.0)
const C_ORANGE         := Color(1.0,  0.62, 0.15, 1.0)
const C_AMBER          := Color(1.0,  0.65, 0.10, 1.0)
const C_CYAN           := Color(0.15, 0.88, 1.0,  1.0)
const C_PURPLE         := Color(0.78, 0.42, 1.0,  1.0)
const C_BLACK_SCRIM    := Color(0.01, 0.03, 0.08, 0.72)

static func for_algo(theme_key: String) -> Dictionary:
	if THEMES.has(theme_key):
		return THEMES[theme_key]
	return THEMES["linear_search"]

## Standard styled box with glassmorphism drop-shadow and rounded corners
static func styled_box(bg: Color, border: Color, bw: int = 2, radius: int = 16) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(bw)
	sb.corner_radius_top_left    = radius
	sb.corner_radius_top_right   = radius
	sb.corner_radius_bottom_left  = radius
	sb.corner_radius_bottom_right = radius
	sb.shadow_color = Color(0, 0, 0, 0.65)
	sb.shadow_size  = 26
	sb.shadow_offset = Vector2(0, 6)
	return sb

## Premium Glassmorphic Card Container
static func glass_card(accent: Color, radius: int = 18) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.04, 0.08, 0.18, 0.85)
	sb.border_color = Color(accent.r, accent.g, accent.b, 0.70)
	sb.set_border_width_all(2)
	sb.corner_radius_top_left    = radius
	sb.corner_radius_top_right   = radius
	sb.corner_radius_bottom_left  = radius
	sb.corner_radius_bottom_right = radius
	sb.shadow_color = Color(0, 0, 0, 0.68)
	sb.shadow_size  = 28
	sb.shadow_offset = Vector2(0, 8)
	return sb

## Interactive Button Style (Normal)
static func button_style(bg: Color, border: Color, bw: int = 2, radius: int = 12) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(bw)
	sb.corner_radius_top_left = radius
	sb.corner_radius_top_right = radius
	sb.corner_radius_bottom_left = radius
	sb.corner_radius_bottom_right = radius
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	sb.shadow_color = Color(0, 0, 0, 0.40)
	sb.shadow_size = 12
	sb.shadow_offset = Vector2(0, 3)
	return sb

## Glassmorphic Button Hover Style
static func button_hover_style(accent: Color, radius: int = 12) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(accent.r * 0.35, accent.g * 0.35, accent.b * 0.35, 0.90)
	sb.border_color = Color(1.0, 1.0, 1.0, 0.95)
	sb.set_border_width_all(2)
	sb.corner_radius_top_left = radius
	sb.corner_radius_top_right = radius
	sb.corner_radius_bottom_left = radius
	sb.corner_radius_bottom_right = radius
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	sb.shadow_color = Color(accent.r, accent.g, accent.b, 0.50)
	sb.shadow_size = 20
	sb.shadow_offset = Vector2(0, 4)
	return sb

## Correct Answer Button Style (Luminous Emerald)
static func button_correct_style(radius: int = 12) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.35, 0.18, 0.92)
	sb.border_color = C_GREEN
	sb.set_border_width_all(2)
	sb.corner_radius_top_left = radius
	sb.corner_radius_top_right = radius
	sb.corner_radius_bottom_left = radius
	sb.corner_radius_bottom_right = radius
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	sb.shadow_color = Color(0.15, 0.95, 0.45, 0.55)
	sb.shadow_size = 22
	sb.shadow_offset = Vector2(0, 4)
	return sb

## Wrong Answer Button Style (Luminous Amber / Red)
static func button_wrong_style(radius: int = 12) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.38, 0.08, 0.08, 0.92)
	sb.border_color = C_RED
	sb.set_border_width_all(2)
	sb.corner_radius_top_left = radius
	sb.corner_radius_top_right = radius
	sb.corner_radius_bottom_left = radius
	sb.corner_radius_bottom_right = radius
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	sb.shadow_color = Color(0.95, 0.25, 0.25, 0.55)
	sb.shadow_size = 22
	sb.shadow_offset = Vector2(0, 4)
	return sb

## Explanation card with luminous left accent or rounded border
static func explanation_box(border_color: Color, bg_color: Color = Color(0.03, 0.06, 0.12, 0.92)) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg_color
	sb.border_color = border_color
	sb.border_width_left = 4
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.corner_radius_top_left = 12
	sb.corner_radius_top_right = 12
	sb.corner_radius_bottom_left = 12
	sb.corner_radius_bottom_right = 12
	sb.content_margin_top = 14
	sb.content_margin_bottom = 14
	sb.content_margin_left = 20
	sb.content_margin_right = 20
	sb.shadow_color = Color(0, 0, 0, 0.55)
	sb.shadow_size = 18
	sb.shadow_offset = Vector2(0, 4)
	return sb

static func make_font(weight: int = 700) -> Font:
	var f := SystemFont.new()
	f.font_names  = ["Segoe UI", "Ubuntu", "Arial", "Sans-Serif"]
	f.font_weight = weight
	return f
