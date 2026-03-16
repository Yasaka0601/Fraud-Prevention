module UserBadgesHelper
  def badge_icon(badge_type)
    # svg に case文の結果をそのまま代入している。
    svg = case badge_type.to_sym
    when :white_belt     then belt_svg("#f8fafc", "#94a3b8", "#e2e8f0")
    when :blue_belt      then belt_svg("#3b82f6", "#1e3a8a", "#93c5fd")
    when :brown_belt     then belt_svg("#b45309", "#78350f", "#f59e0b")
    when :black_belt     then belt_svg("#1f2937", "#000000", "#4b5563")
    when :master         then master_svg
    when :weekly_king    then crown_svg("#fcd34d", "#b45309", "#ef4444")
    when :weekly_king_3  then crown_svg("#fcd34d", "#b45309", "#3b82f6")
    when :weekly_king_6  then crown_svg("#f9a8d4", "#be185d", "#a855f7")
    when :weekly_king_10 then tenka_muso_svg
    when :weekly_second  then shogi_svg("#f3f4f6", "#6b7280", "#1f2937", "銀将")
    when :weekly_third   then shogi_svg("#fcd34d", "#b45309", "#78350f", "銅将")
    end
    svg&.html_safe
  end

  private

  # 帯（結び目と垂れをリアルに表現）
  def belt_svg(main_color, stroke_color, highlight_color)
    <<~SVG
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" class="badge-icon">
        <!-- 後ろの影 -->
        <path d="M12,28 Q32,36 52,28 L52,36 Q32,44 12,36 Z" fill="#000000" opacity="0.15"/>
        <!-- 右の垂れ -->
        <path d="M36,32 L44,56 L34,58 L30,32 Z" fill="#{main_color}"/>
        <path d="M42,52 L36,53" stroke="#{stroke_color}" stroke-width="2"/>
        <!-- 左の垂れ -->
        <path d="M28,32 L20,58 L30,56 L34,32 Z" fill="#{main_color}"/>
        <path d="M22,54 L28,53" stroke="#{stroke_color}" stroke-width="2"/>
        <!-- 横に巻く部分 -->
        <path d="M6,24 Q32,32 58,24 L58,32 Q32,40 6,32 Z" fill="#{main_color}"/>
        <path d="M6,24 Q32,32 58,24" stroke="#{stroke_color}" stroke-width="1.5" fill="none"/>
        <path d="M6,32 Q32,40 58,32" stroke="#{stroke_color}" stroke-width="1.5" fill="none"/>
        <!-- 結び目 -->
        <rect x="25" y="22" width="14" height="16" rx="4" fill="#{main_color}" stroke="#{stroke_color}" stroke-width="2"/>
        <path d="M28,24 L28,36 M32,23 L32,37 M36,24 L36,36" stroke="#{stroke_color}" stroke-width="1" opacity="0.5"/>
      </svg>
    SVG
  end

  # 師範（黒帯ベース＋豪華な金の装飾）
  def master_svg
    <<~SVG
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" class="badge-icon">
        <!-- 背景の金の装飾 -->
        <polygon points="32,2 38,16 54,18 42,28 46,42 32,34 18,42 22,28 10,18 26,16" fill="#fde047" opacity="0.6"/>
        <!-- 帯本体（黒） -->
        <path d="M36,32 L44,56 L34,58 L30,32 Z" fill="#1f2937"/>
        <path d="M28,32 L20,58 L30,56 L34,32 Z" fill="#1f2937"/>
        <path d="M6,24 Q32,32 58,24 L58,32 Q32,40 6,32 Z" fill="#1f2937"/>
        <rect x="25" y="22" width="14" height="16" rx="4" fill="#1f2937" stroke="#fbbf24" stroke-width="2"/>
        <!-- 金のラインと刺繍 -->
        <path d="M6,28 Q32,36 58,28" stroke="#fbbf24" stroke-width="2" fill="none"/>
        <path d="M22,54 L28,53" stroke="#fbbf24" stroke-width="3"/>
        <path d="M42,52 L36,53" stroke="#fbbf24" stroke-width="3"/>
        <circle cx="32" cy="30" r="3" fill="#fbbf24"/>
      </svg>
    SVG
  end

  # 王冠（立体的でリッチな王冠）
  def crown_svg(main_color, stroke_color, gem_color)
    <<~SVG
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" class="badge-icon">
        <path d="M16,20 Q32,10 48,20 L32,36 Z" fill="#{stroke_color}" opacity="0.5"/>
        <path d="M8,46 L12,20 L24,34 L32,12 L40,34 L52,20 L56,46 Z" fill="#{main_color}" stroke="#{stroke_color}" stroke-width="2" stroke-linejoin="round"/>
        <rect x="10" y="46" width="44" height="8" rx="3" fill="#{main_color}" stroke="#{stroke_color}" stroke-width="2"/>
        <path d="M14,50 L50,50" stroke="#{stroke_color}" stroke-width="1.5" stroke-dasharray="2 4"/>
        <circle cx="32" cy="12" r="4" fill="#{gem_color}" stroke="#{stroke_color}" stroke-width="1.5"/>
        <circle cx="12" cy="20" r="3" fill="#{gem_color}" stroke="#{stroke_color}" stroke-width="1.5"/>
        <circle cx="52" cy="20" r="3" fill="#{gem_color}" stroke="#{stroke_color}" stroke-width="1.5"/>
        <circle cx="32" cy="36" r="5" fill="#{gem_color}" stroke="#{stroke_color}" stroke-width="1.5"/>
        <circle cx="20" cy="40" r="3" fill="#{gem_color}" stroke="#{stroke_color}" stroke-width="1.5"/>
        <circle cx="44" cy="40" r="3" fill="#{gem_color}" stroke="#{stroke_color}" stroke-width="1.5"/>
      </svg>
    SVG
  end

  # 天下無双（月桂樹・後光・巨大王冠・リボンを備えた超豪華版）
  def tenka_muso_svg
    <<~SVG
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 80 80" class="badge-icon">
        <!-- 豪華な後光 -->
        <g stroke="#fef08a" stroke-width="2" opacity="0.8">
          <line x1="40" y1="40" x2="40" y2="4"/>
          <line x1="40" y1="40" x2="40" y2="76"/>
          <line x1="40" y1="40" x2="4" y2="40"/>
          <line x1="40" y1="40" x2="76" y2="40"/>
          <line x1="40" y1="40" x2="14" y2="14"/>
          <line x1="40" y1="40" x2="66" y2="66"/>
          <line x1="40" y1="40" x2="14" y2="66"/>
          <line x1="40" y1="40" x2="66" y2="14"/>
        </g>
        <!-- 月桂樹のリース -->
        <path d="M40,70 C10,70 10,20 30,15 M40,70 C70,70 70,20 50,15" fill="none" stroke="#fbbf24" stroke-width="4" stroke-linecap="round"/>
        <g fill="#f59e0b">
          <path d="M22,50 Q15,45 20,40 Q25,45 22,50" />
          <path d="M16,35 Q10,30 18,25 Q22,30 16,35" />
          <path d="M24,22 Q20,15 28,12 Q32,18 24,22" />
          <path d="M58,50 Q65,45 60,40 Q55,45 58,50" />
          <path d="M64,35 Q70,30 62,25 Q58,30 64,35" />
          <path d="M56,22 Q60,15 52,12 Q48,18 56,22" />
        </g>
        <!-- 巨大で豪華な王冠 -->
        <path d="M20,55 L24,25 L32,40 L40,12 L48,40 L56,25 L60,55 Z" fill="#ef4444" stroke="#7f1d1d" stroke-width="2" stroke-linejoin="round"/>
        <path d="M22,55 L25,30 L32,43 L40,18 L48,43 L55,30 L58,55 Z" fill="#fca5a5" opacity="0.3"/>
        <rect x="20" y="55" width="40" height="8" rx="2" fill="#f59e0b" stroke="#7f1d1d" stroke-width="2"/>
        <!-- 装飾の宝石 -->
        <circle cx="40" cy="12" r="5" fill="#a855f7" stroke="#581c87" stroke-width="1.5"/>
        <circle cx="24" cy="25" r="4" fill="#3b82f6" stroke="#1e3a8a" stroke-width="1.5"/>
        <circle cx="56" cy="25" r="4" fill="#3b82f6" stroke="#1e3a8a" stroke-width="1.5"/>
        <polygon points="40,32 46,38 40,44 34,38" fill="#10b981" stroke="#047857" stroke-width="1.5"/>
      </svg>
    SVG
  end

  # 将棋の駒（立体的で縦書き2文字）
  def shogi_svg(main_color, stroke_color, text_color, text_content)
    <<~SVG
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" class="badge-icon">
        <!-- 駒の影 -->
        <polygon points="36,6 56,22 52,58 18,58 14,22" fill="#000" opacity="0.15"/>
        <!-- 駒の本体 -->
        <polygon points="32,6 52,22 48,56 16,56 12,22" fill="#{main_color}" stroke="#{stroke_color}" stroke-width="2.5" stroke-linejoin="round"/>
        <!-- 上面のハイライト -->
        <polygon points="32,6 52,22 48,56 32,56" fill="#ffffff" opacity="0.2"/>
        <polygon points="32,6 12,22 16,56 32,56" fill="#000000" opacity="0.05"/>
        <!-- 文字 (縦書き風に2文字) -->
        <text x="32" y="32" text-anchor="middle" font-size="16" fill="#{text_color}" font-family="'Noto Serif JP', serif" font-weight="900">#{text_content[0]}</text>
        <text x="32" y="50" text-anchor="middle" font-size="16" fill="#{text_color}" font-family="'Noto Serif JP', serif" font-weight="900">#{text_content[1]}</text>
      </svg>
    SVG
  end
end
