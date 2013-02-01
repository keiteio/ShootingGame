#==============================================================================
# ■ Win32APIHelpers
#------------------------------------------------------------------------------
# 　Win32APIを使ったヘルパーメッソッドを提供するモジュール
#==============================================================================
module Win32APIHelpers
  @@messageBox = nil
  @@getPrivateProfileStringA = nil
  @@findWindowA = nil
  @@getDC = nil
  @@releaseDC = nil
  @@textOut = nil
  @@setTextColor = nil
  @@setBkMode = nil
 
  #--------------------------------------------------------------------------
  # ● メッセージボックス
  #--------------------------------------------------------------------------
  def showMessageBox(message, title="")
    @@messageBox ||= Win32API.new('user32', 'MessageBox', %w(l p p i), 'i')
    @@messageBox.call(0, message, title, 0)
  end

  #--------------------------------------------------------------------------
  # ● INIファイルから値を取得する
  #--------------------------------------------------------------------------
  def getValueFromINIFile(section, key, option = {})
    default = option[:default] ? option[:default] : ""
    buffer_size = option[:buffer_size] ? option[:buffer_size] : 256
    filepath = option[:filepath] ? option[:filepath] : ".\\Game.ini"
    
    @@getPrivateProfileStringA ||= Win32API.new('kernel32', 'GetPrivateProfileStringA', %w(p p p p l p), 'l')
    value = "\0".encode("Windows-31J") * buffer_size
    @@getPrivateProfileStringA.call(section, key, default, value, buffer_size - 1, filepath)
    value = value.encode("UTF-8")
    i = 0
    for i in 0...buffer_size
      if value[i] == "\0"
        break
      end
    end
    return value[0,i]
  end
  
  #--------------------------------------------------------------------------
  # ● ゲーム画面のウィンドウハンドルを取得する
  #--------------------------------------------------------------------------
  def getGameWindow
    # ウィンドウハンドルを取得するためのAPIをロードする
    @@getPrivateProfileStringA ||= Win32API.new('kernel32', 'GetPrivateProfileStringA', %w(p p p p l p), 'l')
    @@findWindowA ||= Win32API.new('user32', 'FindWindowA', %w(p p), 'l')
    # ゲーム名を取得する
    game_name = getValueFromINIFile("Game","Title")
    p game_name
    # ウィンドウハンドルを取得
    @@findWindowA.call("RGSS Player",game_name.encode("Windows-31J"))
  end
  
  #--------------------------------------------------------------------------
  # ● デバイスコンテキストを取得する
  #--------------------------------------------------------------------------
  def getDC(hwnd)
    @@getDC ||= Win32API.new('user32', 'GetDC', %w(l), 'l')
    
    @@getDC.call(hwnd)
  end
  #--------------------------------------------------------------------------
  # ● デバイスコンテキストを解放する
  #--------------------------------------------------------------------------
  def releaseDC(hwnd, hdc)
    @@releaseDC ||= Win32API.new('user32', 'ReleaseDC', %w(l l), 'i')
    
    @@releaseDC.call(hwnd, hdc)
  end
  #--------------------------------------------------------------------------
  # ● 文字を描画する
  #--------------------------------------------------------------------------
  def drawText(hwnd, hdc, text, x, y, color)
    @@setTextColor ||= Win32API.new('gdi32', 'SetTextColor', %w(l i), 'i')
    @@setBkMode ||= Win32API.new('gdi32', 'SetBkMode', %w(l i), 'i')
    @@textOut ||= Win32API.new('gdi32', 'TextOut', %w(l i i p i), 'i')

    r = color.red.to_i
    g = color.green.to_i << 8
    b = color.blue.to_i << 16
    @@setTextColor.call(hdc, r + b + g)
    @@setBkMode.call(hdc, 1)
    @@textOut.call(hdc, x, y, text, text.size);
  end
end
