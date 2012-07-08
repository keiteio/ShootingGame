#-------------------------------------------------------------------------------
# ■ベクトル計算をするためのクラス。
#-------------------------------------------------------------------------------
class Vector3d
  attr_accessor  :x
  attr_accessor  :y
  attr_accessor  :z
  
  def initialize(x, y = nil, z = nil)
    if z = nil
      if y = nil
        self.x = x * 1.0
        self.y = x * 1.0
        self.z = x * 1.0
      else
        self.x = x * 1.0
        self.y = y * 1.0
        self.z = 0
      end
    else
      self.x = x * 1.0
      self.y = y * 1.0
      self.z = z * 1.0
    end
    @recomp_len=false
  end
  
  def *(other)
    if other.class.ancestors.include?(Numeric)
      return Vector3d.new(self.x * other, self.y * other, self.z * other)
    else
      
    end
  end
  
  def self.unit_x
    Vector3d.new 1, 0, 0
  end
  
  def self.unit_y
    Vector3d.new 0, 1, 0
  end
  
  def self.unit_z
    Vector3d.new 0, 0, 1
  end
  
end


