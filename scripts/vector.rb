#-------------------------------------------------------------------------------
# ■ベクトル計算をするためのクラス。
#-------------------------------------------------------------------------------
class Vector
  def initialize(arg)
    if arg.class.ancestors.include?(Integer)
      @ary = Array.new(arg){ 0 }
    elsif arg.class.ancestors.include?(Array)
      @ary = []
      arg.each do |item|
        if item.class.ancestors.include?(Numeric)
          @ary.push item
        else
          raise_init_error(item)
        end
      end
    elsif arg.class.ancestors.include?(Vector)
      @ary = []
      arg.each do |dim|
        @ary.push dim
      end
    else
      raise_init_error(item)
    end
    @recomp_len=true
  end
  
  def raise_init_error(arg)
    raise ArgumentError.new('"' + arg + '"(' + arg.class.to_s + ") is an invalid argument to initialize " + self.class.to_s + "." )
  end
  protected :raise_init_error
  
  def length_square
    tmp = 0
    @ary.each do |dim|
      tmp += dim * dim
    end
    return tmp
  end
  
  def lensq
    return length_square
  end
  
  def length
    if @recomp_len
      @length = Math.sqrt(self.lensq)
      @recomp_len = false
    end
    return @length
  end
  
  def len
    return self.length
  end
  
  def dims
    return @ary.size
  end
  
  def each(&block)
    @ary.each do |dim|
      block.call(dim)
    end
  end
  
  def []=(index, value)
    if index < @ary.size
      @recomp_len=true if (@ary[index] == value)
      @ary[index]=value
    end
  end
  
  def [](index)
    return @ary[index]
  end
  
  def +(other)
    if other.class.ancestors.include?(Vector)
      vecs = [self.dup, other.dup].sort{ |a,b| a.dims <=> b.dims }
      for i in 0...vecs[0].dims
        vecs[1][i] += vecs[0][i]
      end
      return vecs[1]
    else
      raise StandardError.new("The + operator is available only between Vector classes.\n  #{self.class.to_s} + #{other.class.to_s}")
    end
  end
  
  def -(other)
    if other.class.ancestors.include?(Vector)
      vecs = [self.dup, other.dup].sort{ |a,b| a.dims <=> b.dims }
      for i in 0...vecs[0].dims
        vecs[1][i] -= vecs[0][i]
      end
      return vecs[1]
    else
      raise StandardError.new("The - operator is available only between Vector classes.\n  #{self.class.to_s} - #{other.class.to_s}")
    end
  end
  
  def multiply!(scalar)
    for i in 0...@ary.size
      self[i] *= scalar
    end
    @recomp_len=true
    return nil
  end
  
  def multiply(scalar)
    result = self.class.new(self)
    result.multiply!(scalar)
    return result
  end

  def division!(scalar)
    for i in 0...@ary.size
      self[i] /= scalar * 1.0
    end
    @recomp_len=true
    return nil
  end
  
  def division(scalar)
    result = self.class.new(self)
    result.division!(scalar)
    return result
  end
  
  # dot product
  def self.dot(a, b)
    if self.dims == other.dims
      result = 0
      for i in 0...self.dims
        result += self[i] * other[i]
      end
      return result
    else
      return nil
    end
  end
  
  # cross product
  def self.cross(a, b)
    # it confusing me...
  end
  
  # vector product
  def self.vector(a, b)
    # it confusing me...
  end
  
end

class Vector2d < Vector
  
  def initialize(x, y=nil)
    if x.class == Vector2d
      super x
    else
      super 2
      if y
        self[0] = x
        self[1] = y
      else
        self[0] = x
        self[1] = x
      end
    end
    @recomp_angle=true
  end
  
  def x=(value)
    self[0] = value
    @recomp_len = true
    @recomp_angle=true
  end
  
  def x
    return self[0]
  end
  
  def y=(value)
    self[1] = value
    @recomp_len = true
    @recomp_angle=true
  end
  
  def y
    return self[1]
  end
  
  def rotate!(theta)
    cos0 = Math.cos( ((theta % 360.0) / 180.0) * Math::PI )
    sin0 = Math.sin( ((theta % 360.0) / 180.0) * Math::PI )
    nx = self.x * cos0 - self.y * sin0
    ny = self.x * sin0 + self.y * cos0
    
    self.x = -nx
    self.y = ny
    
    @recomp_len = true
  end
  
  def rotate(theta)
    v = Vector2d.new(self.x, self.y)
    v.rotate! theta
    return v
  end
  
  def unit!
    self.x /= self.len
    self.y /= self.len
    @recomp_len = true
  end
  
  def unit
    v = Vector2d.new(self)
    v.unit!
    return v
  end
  
  def angle
    if @recomp_angle
      @angle = Math.atan2(self.y, self.x) / Math::PI * 180 + 90
      @recomp_angle = false
    end
    return @angle
  end
  
  def angle=(theta)
    self.rotate!(theta - self.angle) if theta != self.angle
    @angle = theta
  end
  
  def self.unit_x
    Vector2d.new(1, 0)
  end
  
  def self.unit_y
    Vector2d.new(0, 1)
  end
  
  # 
  def self.from_rotation(theta, length = 1)
    v = Vector2d.new(length, 0)
    v.rotate! theta
    return v
  end
  
  # cross product
  def self.cross(a, b)
    
  end
end

