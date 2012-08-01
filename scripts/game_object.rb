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
  
  class Bullet < SpriteEx
    attr_accessor :thrusters
    attr_accessor :mass
    attr_accessor :verocity
    attr_accessor :age
    attr_accessor :life_span
    
    def initialize(viewport = nil)
      super viewport
      @verocity = Vector2d.new(0,0)
      @thrusters = []
      @mass = 1.0
      @age = 0
    end
    
    def update
      super
    end
    
    
  end
  
  class Machine < Bullet
    
  end
  
  class Player < Machine
    
    def initialize(viewport = nil)
      super
      
      @main_thruster = Force.new(
        Vector2d.new(0, -30),
        Proc.new{ |f| self.logic_main_thruster(f) }
      )
      @right_thruster = Force.new(
        Vector2d.new(0, 0),
        Proc.new{ |f| self.logic_vernier_thruster(:RIGHT, f) }
      )
      @left_thruster = Force.new(
        Vector2d.new(0, 0),
        Proc.new{ |f| self.logic_vernier_thruster(:LEFT, f) }
      )
      
      @right_thruster.available = false
      @left_thruster.available = false
      
      @thrusters.push(@main_thruster)
      @thrusters.push(@right_thruster)
      @thrusters.push(@left_thruster)
      
      @mass = 1
    end
    
    def update
      super
      @main_thruster.update
      @right_thruster.update
      @left_thruster.update
      
    end
    
    
    def logic_main_thruster(f)
      f.vector.unit!
      f.vector.angle = self.angle
      
      dir = Input.dir
      if dir[1] == -1
        f.vector.multiply! 800
      elsif dir[1] == 1
        f.vector.multiply! 100
      else
        f.vector.multiply! 200
      end
    end
    
    # rudder = :RIGHT or :LEFT
    def logic_vernier_thruster(rudder, f)
      sign = (rudder == :RIGHT ? -1 : 1)
      
      if Input.press? rudder
        f.vector.x = 800
        f.vector.y = 0
        f.vector.angle = self.angle + (90 * sign)
        self.angle -= (1*sign)
        f.available = true
      else
        if f.available
          if f.vector.length > 0
            f.vector.division! 20
            self.angle -= (1*sign)
            if f.vector.length < 0.001
              f.vector.x = 0
              f.vector.y = 0
              f.available = false
            end
          end
        end
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
      
      self.each do |obj|
        obj.update
        
        forces = obj.thrusters + @world.forces
        
        need_compact = false
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
      
    end
    
  end
  
end



