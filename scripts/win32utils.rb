#==============================================================================
# ■ Win32APIHelpers
#------------------------------------------------------------------------------
# 　Win32APIを使ったヘルパーメッソッドを提供するモジュール
#==============================================================================
module Win32APIHelpers
  
  def packLPRECT(left, top, right, bottom)
    return [left, top, right, bottom].pack('l!l!l!l!')
  end
  
  def unpackLPRECT(pointer)
    rect = pointer.unpack('l!l!l!l!')
    return Rect.new(rect[0], rect[1], rect[2] - rect[0], rect[3] - rect[1])
  end
  
end