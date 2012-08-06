class GameField
  attr_reader :viewport
  
  
  def initialize(viewport = nil)
    @viewport = viewport
    @tilemap = Tilemap.new(@viewport1)
    
    
    create_tilemap
    load_tileset
    create_parallax
  end
  
  def dispose
    dispose_tilemap
    dispose_parallax
  end
  
  def update
    update_tileset
    update_tilemap
    update_parallax
  end
  
  def setup()
    
    
    
    
  end
  
  
  
  #--------------------------------------------------------------------------
  # �� �^�C���}�b�v�̍쐬
  #--------------------------------------------------------------------------
  def create_tilemap
    @tilemap = Tilemap.new(@viewport)
    @tilemap.map_data = $game_map.data
    load_tileset
  end
  #--------------------------------------------------------------------------
  # �� �^�C���Z�b�g�̃��[�h
  #--------------------------------------------------------------------------
  def load_tileset
    @tileset = $game_map.tileset
    @tileset.tileset_names.each_with_index do |name, i|
      @tilemap.bitmaps[i] = Cache.tileset(name)
    end
    @tilemap.flags = @tileset.flags
  end
  #--------------------------------------------------------------------------
  # �� ���i�̍쐬
  #--------------------------------------------------------------------------
  def create_parallax
    @parallax = Plane.new(@viewport)
    @parallax.z = -200
  end
  #--------------------------------------------------------------------------
  # �� �^�C���}�b�v�̉��
  #--------------------------------------------------------------------------
  def dispose_tilemap
    @tilemap.dispose
  end
  #--------------------------------------------------------------------------
  # �� ���i�̉��
  #--------------------------------------------------------------------------
  def dispose_parallax
    @parallax.bitmap.dispose if @parallax.bitmap
    @parallax.dispose
  end
  #--------------------------------------------------------------------------
  # �� �^�C���Z�b�g�̍X�V
  #--------------------------------------------------------------------------
  def update_tileset
    if @tileset != $game_map.tileset
      load_tileset
    end
  end
  #--------------------------------------------------------------------------
  # �� �^�C���}�b�v�̍X�V
  #--------------------------------------------------------------------------
  def update_tilemap
  end
  #--------------------------------------------------------------------------
  # �� ���i�̍X�V
  #--------------------------------------------------------------------------
  def update_parallax
  end
  
end