module GameObject
  class Bullet < SpriteEx
    attr_accessor :verocity #基礎速度
    attr_accessor :accel
    attr_accessor :age
    attr_accessor :life_span
    
    def initialize(viewport = nil)
      super viewport
      @verocity = Vector2d.new(0,0)
      @accel = Vector2d.new(0,0)
      @age = 0
    end
    
    def update
      self.position += @verocity.division(Graphics.frame_rate)
      @verocity += @accel.division(Graphics.frame_rate)
    end
  end
  
  class Machine < Bullet
    
  end
  
  class Player < Machine
    
    def initialize
      super
      @verocity = Vector2d.new(0,-1)
    end
    
    def update
      super
      dir = Input.dir
      if @verocity.len != 0
        uv = @verocity.unit
        a1 = uv.multiply(30 * -dir[1])
        a2 = uv.multiply(45)
        a2.rotate!(90 * dir[0])
        uv = nil
        @accel = a1 + a2
      end
      if @verocity.y != 0
        self.angle = Math.atan2(-@verocity.y, @verocity.x) / Math::PI * 180 - 90
      end
    end
    
  end
  
  
end