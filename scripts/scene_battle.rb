class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    @game_field = GameField.new(Viewport.new)
    
    @player = GameObject::Player.new(@game_field.viewport)
    @player.bitmap = Cache.picture("vector")
    @player.ox = @player.bitmap.width / 2
    @player.oy = @player.bitmap.height / 2
    @player.x = Graphics.width / 2
    @player.y = Graphics.height / 2
    @player.angle = 90
    @player.z = 100
    
    @object_manager = GameObject::Manager.new
    @object_manager.push @player
    
    
    
  end
  #--------------------------------------------------------------------------
  # ● 開始後処理
  #--------------------------------------------------------------------------
  def post_start
    super
  end
  #--------------------------------------------------------------------------
  # ● 終了前処理
  #--------------------------------------------------------------------------
  def pre_terminate
    super
    Graphics.fadeout(30) if SceneManager.scene_is?(Scene_Map)
    Graphics.fadeout(60) if SceneManager.scene_is?(Scene_Title)
  end
  #--------------------------------------------------------------------------
  # ● 終了処理
  #--------------------------------------------------------------------------
  def terminate
    super
    
    @game_field.viewport.dispose
    @object_manager.dispose
    
    RPG::ME.stop
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    @object_manager.update
    v = Vector2d.from_rotation(@player.angle, 120)
    p [v.x, v.y]
    @game_field.viewport.ox = @player.x - Graphics.width / 2 - v.x
    @game_field.viewport.oy = @player.y - Graphics.height / 2 - v.y
    
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新（基本）
  #--------------------------------------------------------------------------
  def update_basic
    super
  end
  
  
  
  
end