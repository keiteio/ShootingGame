module GameObject
  class Force
    attr_accessor :vector    # チカラの強さを表すベクトル
    attr_accessor :proc      # 更新時に呼び出される処理
    attr_accessor :available # チカラが有効であるかを表すフラグ
    attr_reader   :counter   # アップデートの呼び出し回数のカウント
    
    def initialize(vector, proc=nil)
      @vector = vector
      @proc = proc
      @available = true
      @counter = 0
    end
    
    def update
      if @proc
        @proc.call self
      end
      @counter += 1
    end
    
    
  end
  
  class Particle < SpriteEx
    attr_accessor :thrusters
    attr_accessor :mass
    attr_accessor :verocity
    attr_accessor :age
    attr_accessor :life_span
    attr_accessor :dead
    
    def initialize(viewport = nil)
      super viewport
      @verocity = Vector2d.new(0,0)
      @thrusters = []
      @mass = 1.0
      @age = 0
      @life_span = -1
      @dead = false
    end
    
    def update
      super
      @age += 1
      if @life_span > 0 && @life_span < @age
        self.dead = true
      end
    end
    
  end
  
  class Bullet < Particle
    attr_accessor :side   # 敵かな、味方かな識別用
    
  end
  
  class Machine < Bullet
    
  end
  
  class Player < Machine
    
    def initialize(viewport = nil)
      super
      
      @main_thruster = MainThruster.new(self)
      @right_thruster = VernierThruster.new(self, :RIGHT)
      @left_thruster = VernierThruster.new(self, :LEFT)
      @right_thruster.available = false
      @left_thruster.available = false
      @flash_thruster = FlashThruster.new(self)
      @flash_thruster.available = false
      
      @thrusters.push(@main_thruster)
      @thrusters.push(@right_thruster)
      @thrusters.push(@left_thruster)
      @thrusters.push(@flash_thruster)
      
      @mass = 1
    end
    
    def update
      super
      @main_thruster.update
      @right_thruster.update
      @left_thruster.update
      @flash_thruster.update
      if Input.press?(:R)
        self.angle -= 1
      elsif Input.press?(:L)
        self.angle += 1
      end
    end
    
    class MainThruster < Force
      def initialize(parent)
        super Vector2d.new(0, -30), self.logic(parent)
      end
      
      def logic(parent)
        Proc.new{ |f|
          f.vector.unit!
          f.vector.angle = parent.angle
          
          dir = Input.dir
          if dir[1] == 1
            f.vector.multiply! -1200
          elsif dir[1] == -1
            f.vector.multiply! -800
          else
            f.vector.multiply! -400
          end
        }
      end
    end
    
    class VernierThruster < Force
      def initialize(parent, rudder)
        super Vector2d.new(0, -30), self.logic(parent, rudder)
      end
      
      def logic(parent, rudder)
        Proc.new{ |f|
          sign = (rudder == :RIGHT ? -1 : 1)
          
          if Input.press? rudder
            f.vector.x = 800
            f.vector.y = 0
            f.vector.angle = parent.angle + (120 * sign)
            f.available = true
          else
            if f.available
              if f.vector.length > 0
                f.vector.division! 20
                if f.vector.length < 0.001
                  f.vector.x = 0
                  f.vector.y = 0
                  f.available = false
                end
              end
            end
          end
        }
      end
    end
    
    class FlashThruster < Force
      def initialize(parent)
        super Vector2d.new(0, -30), self.logic(parent)
      end
      
      def logic(parent)
        Proc.new{ |f|
          sign = 0
          sign =  1 if Input.press?(:LEFT)
          sign = -1 if Input.press?(:RIGHT)
          
          if sign != 0 && Input.trigger?(:A)
            f.vector.x = 80000
            f.vector.y = 4000
            f.vector.angle = parent.angle + (90 * sign)
            f.available = true
          else
            if f.available
              if f.vector.length > 0
                f.vector.division! 10
                if f.vector.length < 0.001
                  f.vector.x = 0
                  f.vector.y = 0
                  f.available = false
                end
              end
            end
          end
        }
      end
      
    end
    
  end
  
  # --------------------------------
  # オブジェクトの存在する世界を表すクラス
  class World
    attr_accessor :forces  # 世界全体に恒常的に影響を及ぼすチカラ
    
    def initialize
      @forces = []
    end
    
  end
  
  
  # --------------------------------
  # オブジェクトマネージャ
  class Manager < Array
    ATTENUATION=0.96
    
    def initialize
      @world = World.new
    end
    
    def update
      delta = 1.0 / Graphics.frame_rate
      
      for i in 0...self.size
        obj = self[i]
        if obj.disposed?
          self[i] = nil
          next
        elsif obj.dead
          obj.dispose
          next
        end
        
        obj.update
        
        forces = obj.thrusters + @world.forces
        
        for i in 0...forces.size
          f = forces[i]
          f.update
          
          if forces[i].available
            a = f.vector.division(obj.mass)
            
            a.multiply!(delta)
            obj.verocity += a
            obj.verocity.multiply!(ATTENUATION)
            
          end
        end
        # 位置の更新
        obj.x += obj.verocity.x * delta
        obj.y += obj.verocity.y * delta
      end
      
      self.compact!
      
    end
    
  end
  
  class Emitter
    attr_accessor :direction
    attr_accessor :direction_spread
    attr_accessor :initial_speed
    attr_accessor :initial_speed_fluct
    attr_accessor :position
    attr_accessor :counter
    attr_accessor :amount
    attr_accessor :interval
    attr_accessor :particle
    attr_reader   :generated
    
    def initialize
      @direction = 0
      @direction_spread = 0
      @initial_speed = 1
      @initial_speed_rand = 0.0
      @position = Vector2d.new(0, 0)
      @counter = 0
      @proc = nil
    end
    
    def update
      generated = nil
      if @proc
        @proc.call self
      end
      
      if @counter % @interval < 1
        @generated = self.generate
      end
      
      @counter += 1
    end
    
    def generate
      gen = []
      @amount.times do
        ptcl = Particle.new(@particle.viewport)
        ptcl.bitmap = @particle.bitmap
        ptcl.ox = @particle.ox
        ptcl.oy = @particle.oy
        ptcl.zoom_x = @particle.zoom_x
        ptcl.zoom_y = @particle.zoom_y
        ptcl.life_span = @particle.life_span
        ptcl.vector = Vector2d.from_rotation(
            @direction - @direction_spread / 2 + @direction_spread * rand, 
            @initial_speed
          )
        ptcl.x = @position.x
        ptcl.y = @position.y
        ptcl.z = @particle.z
        ptcl.blend_type = @particle.blend_type
        ptcl.visible = true
        gen.push ptcl
      end
      return gen
    end
    
  end
  
end



