#==============================================================================
# ■ Win32APIHelpers
#------------------------------------------------------------------------------
# 　Win32APIを使ったヘルパーメッソッドを提供するモジュール
#==============================================================================
module Win32APIHelpers
  #============================================================================
  # ■ ApiInstance
  #----------------------------------------------------------------------------
  # 　インスタンス化して使用したい場合のクラス
  #============================================================================
  class ApiInstance
    include Win32APIHelpers
  end
  
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
    
    hwnd = getTopWindow
    
    while hwnd do
      
      result = getWindowThreadProcessId(hwnd)
      break if result[:pid] == Process.pid
      
      hwnd = getWindow(hwnd, Constants::GW_HWNDNEXT)
    end
    
    return hwnd
  end
  
  #--------------------------------------------------------------------------
  # ● トップレベルウィンドウのハンドルを取得する
  #--------------------------------------------------------------------------
  def getTopWindow(hwnd = 0)
    f = getAPI(:GetTopWindow)
    return f.call(hwnd)
  end
  
  #--------------------------------------------------------------------------
  # ● 指定ハンドルのウィンドウからみて次のウィンドウのハンドルを取得する
  #--------------------------------------------------------------------------
  def getNextWindow(hwnd, mode = Constants::GW_HWNDNEXT)
    f = getAPI(:GetNextWindow)
    return f.call(hwnd, mode)
  end
  
  #--------------------------------------------------------------------------
  # ● ウィンドウハンドルと関係性を指定して他のウィンドウのハンドルを取得する
  #--------------------------------------------------------------------------
  def getWindow(hwnd, relative)
    f = getAPI(:GetWindow)
    return f.call(hwnd, relative)
  end
  
  #--------------------------------------------------------------------------
  # ● 指定ハンドルのウィンドウのスレッドIDをプロセスIDを取得する
  #--------------------------------------------------------------------------
  def getWindowThreadProcessId(hwnd)
    pid = [0].pack('l')
    f = getAPI(:GetWindowThreadProcessId)
    tid = f.call(hwnd, pid)
    pid = pid.unpack('l')[0]
    return {:tid => tid, :pid => pid}
  end
  
  #--------------------------------------------------------------------------
  # ● カーソルのスクリーン座標を取得する
  #--------------------------------------------------------------------------
  def getCursorPos
    getAPI(:GetCursorPos)
    
    point = [0, 0].pack('l!l!')
    getAPI(:GetCursorPos).call(point)
    point = point.unpack('l!l!')
    return point
  end
  
  #--------------------------------------------------------------------------
  # ● ウィンドウの矩形を取得する
  #--------------------------------------------------------------------------
  def getWindowRect(whnd)
    rect = packLPRECT(0, 0, 0, 0)
    getAPI(:GetWindowRect).call(whnd, rect)
    return unpackLPRECT(rect)
  end
  
  #--------------------------------------------------------------------------
  # ● ウィンドウの矩形を取得する
  #--------------------------------------------------------------------------
  def getClientRect(whnd)
    rect = packLPRECT(0, 0, 0, 0)
    getAPI(:GetClientRect).call(whnd, rect)
    return unpackLPRECT(rect)
  end
  
  def getClientCursorPos(whnd)
    pos = getCursorPos
    wnd = getWindowRect(whnd)
    crt = getClientRect(whnd)
    frame_x = wnd.width - crt.width
    frame_y = wnd.height - crt.height
    lefttop = [wnd.x + frame_x, wnd.y + frame_y]
    return [pos[0] - (wnd.x + frame_x), pos[1] - (wnd.y + frame_y)]
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
  
  def getAPI(f)
    func = f.to_sym
    api = nil
    case func
    when :GetTopWindow
      @@getTopWindow ||= Win32API.new('user32', 'GetTopWindow', 'l', 'l')
      api = @@getTopWindow
    when :GetNextWindow
      @@getNextWindow ||= Win32API.new('user32', 'GetNextWindow', 'li', 'l')
      api = @@getTopWindow
    when :GetWindowThreadProcessId
      @@getWindowThreadProcessId ||= Win32API.new('user32', 'GetWindowThreadProcessId', 'pp', 'l')
      api = @@getWindowThreadProcessId
    when :GetCursorPos
      @@getCursorPos ||= Win32API.new('user32', 'GetCursorPos', 'p', 'l')
      api = @@getCursorPos
    when :GetWindowRect
      @@getWindowRect ||= Win32API.new('user32', 'GetWindowRect', 'lp', 'l')
      api = @@getWindowRect
    when :GetClientRect
      @@getClientRect ||= Win32API.new('user32', 'GetClientRect', 'lp', 'l')
      api = @@getClientRect
    when :GetWindow
      @@getWindow ||= Win32API.new('user32', 'GetWindow', 'li', 'l')
      api = @@getWindow
    end
    
    return api
  end
end