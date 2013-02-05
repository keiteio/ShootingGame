@config = Config.new

# 優先的に読み込むスクリプト
@config.prior_scripts = [
  "win32helpers.rb",
  "sprite_ex.rb",
  "game_object.rb"
]