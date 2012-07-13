# 簡易ParticleSystem
class Particle < SpriteEx
  attr_accessor :verocity
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
    if @age < @life_span
      self.position += @verocity.division(Graphics.frame_rate)
      @verocity += @accel.division(Graphics.frame_rate)
      @age += 1
      super
    else
      unless self.disposed?
        self.dispose
      end
    end
  end
end

class Emitter
  attr_accessor :position # 位置
  attr_accessor :direction # 角度(360度)
  attr_accessor :initial_verocity
  attr_accessor :viewport
  attr_accessor :span # 放出間隔(フレーム)
  attr_accessor :amount # 放出粒子量
  attr_accessor :bitmap # パーティクルのBitmap
  attr_accessor :particle_life_span
  attr_accessor :spread
  
  def initialize()
    @position = Vector2d.new(0,0)
    @direction = 0
    @initial_verocity = 0
    @viewport = nil
    @age = 0
    @span = 1
    @amount = 0
    @particle_life_span = 0
    @bitmap = nil
    @spread = 0
  end
  
  def emit(num = 0)
    result = Array.new(0)
    for i in 0...num
      result[i] = Particle.new(@viewport)
    end
    return result
  end
  
  def update
    emittion = []
    if @amount > 0 && (@age % @span) == 0
      @amount.times do
        pt = Particle.new(@viewport)
        pt.position.x = self.position.x
        pt.position.y = self.position.y
        pt.verocity = Vector2d.from_rotation(@direction + @spread * 0.5 - (@spread * 0.5 * rand) , @initial_verocity)
        pt.life_span = @particle_life_span
        pt.bitmap = @bitmap
        emittion.push pt
      end
    end
    @age += 1
    return emittion
  end
  
end

class ParticleSystem
  attr_accessor :emitters
  
  def initialize
    @particles = []
    @emitters = []
  end
  
  def update
    # emittion
    unless emitters.empty?
      emitters.each do |em|
        @particles += em.update
      end
    end
    
    # update
    alive = []
    @particles.each do |ptcl|
      ptcl.update
      alive.push ptcl unless ptcl.disposed?
    end
    @particles = nil
    @particles = alive
    
  end
  
end



