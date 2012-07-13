class SpriteEx < Sprite
  def initialize(viewport = nil)
    super viewport
    @position = Vector2d.new(0, 0)
    
  end
  
  def position
    return @position
  end
  
  def position=(value)
    @position = value
    self.x = value.x
    self.y = value.y
  end
  
  def x=(value)
    @position.x = value
    super value
  end
  
  def y=(value)
    @position.y = value
    super value
  end
  
end



