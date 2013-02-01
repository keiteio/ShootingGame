module Input
  def self.dir
    case Input.dir8
    when 1
      return [-1 ,  1]
    when 2
      return [ 0 ,  1]
    when 3
      return [ 1 ,  1]
    when 4
      return [-1 ,  0]
    when 6
      return [ 1 ,  0]
    when 7
      return [-1 , -1]
    when 8
      return [ 0 , -1]
    when 9
      return [ 1 , -1]
    end
    return [0,0]
  end
  
end