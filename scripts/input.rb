module Input
  @@api = Win32APIHelpers::ApiInstance.new
  
  @@cursor = []
  
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
  
  alias update_old_Input update
  def self.update
    @@hwnd |= @@api.getGameWindow
    
    update_old_Input
    
    # カーソル位置取得
    @@cursor = @@api.getCursorPos
  end
  
  def self.cursor
    return Vector2d.new(@@cursor[0], @@cursor[1])
  end
  
end