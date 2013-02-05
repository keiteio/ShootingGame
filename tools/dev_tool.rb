class DevelopTool
  
  CONFIG_PATH="../tools/config.rb"
  SCRIPT_PATH="../scripts/"
  
  class Config
    attr_accessor :prior_scripts
  end
  
  #--------------------------------------------------------------------------
  # ● エラーをバックトレースに分解して、再度エラーメッセージとして投げる
  #--------------------------------------------------------------------------
  def backtrace_raise(e)
    # エラーが出たらバックトレースを表示してそのままリスロー
    str = e.message + "\n\n"
    for bt in e.backtrace
      str += bt + "\n"
    end
    raise str
  end
  
  #--------------------------------------------------------------------------
  # ● スクリプトを安全に評価する
  #--------------------------------------------------------------------------
  def safe_eval(script, param = nil)
    # パラメータ引数分解
    if param
      bind = param[:bind] ? param[:bind] : Kernel::TOPLEVEL_BINDING
      fname = param[:fname] ? param[:fname] : "(eval)"
      lineno = param[:lineno] ? param[:lineno] : 1
    end
    # 実行
    begin
      eval(script, bind, fname, lineno)
    rescue => e
      backtrace_raise(e)
    end
  end
  
  #--------------------------------------------------------------------------
  # ● ファイルを読み込む
  #--------------------------------------------------------------------------
  def read_file(filepath)
    s = ""
    open(filepath, "rb") do |f|
      s = f.read
    end
    return s
  end
  
  #--------------------------------------------------------------------------
  # ● スクリプトをロードする
  #--------------------------------------------------------------------------
  def load_script(filepath, param = nil)
    param = {} unless param
    param[:fname] = File.basename filepath
    # スクリプト実行
    safe_eval( read_file(filepath), param )
  end
  
  #--------------------------------------------------------------------------
  # ● 外部スクリプト読込
  #--------------------------------------------------------------------------
  def load
    # 設定ファイル読み込み
    load_script(CONFIG_PATH, :bind => binding)
    
    # 優先スクリプトの読込
    @config.prior_scripts.each do |script|
      filepath = SCRIPT_PATH + script
      load_script(filepath, :bind => TOPLEVEL_BINDING)
    end
    
    # その他のスクリプトを読み込む
    Dir.glob(SCRIPT_PATH + "*") do |filepath|
      fname = File.basename(filepath)
      # 読み込み済みスクリプトでなければ実行
      unless @config.prior_scripts.include? fname
        load_script(filepath, :bind => TOPLEVEL_BINDING)
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # ● 外部スクリプトのバイナリ化
  #--------------------------------------------------------------------------
  def build
    
  end
  
end