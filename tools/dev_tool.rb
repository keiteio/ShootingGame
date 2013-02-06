class DevelopTool
  
  unless $PROGRAM_NAME
    # RGSSの場合
    CONFIG_PATH="../tools/config.rb"
    SCRIPT_PATH="../scripts/"
  else
    # Rubyの場合
    CONFIG_PATH="./tools/config.rb"
    SCRIPT_PATH="./scripts/"
  end
  
  TKOOL_PATH="./data"
  
  ADDITIONAL_SCRIPTS = "Data/AdditionalScripts.rvdata2"
  
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
    # ライブラリの読込
    require "zlib"
    
    # ビルドするスクリプト
    builded = []
    index = 0
    
    # 設定ファイル読み込み
    load_script(CONFIG_PATH, :bind => binding)
    
    # 優先スクリプトファイル読込
    @config.prior_scripts.each do |script|
      filepath = SCRIPT_PATH + script
      
      # データの作成
      builded.push build_data(filepath, index)
      index += 1
    end
    
    # その他スクリプトファイル読込
    Dir.glob(SCRIPT_PATH + "*") do |filepath|
      fname = File.basename(filepath)
      # 読み込み済みスクリプトでなければ実行
      unless @config.prior_scripts.include? fname
        # データの作成
        builded.push build_data(filepath, index)
        index += 1
      end
    end
    
    open(File.join(TKOOL_PATH, ADDITIONAL_SCRIPTS), "wb") do |f|
      Marshal.dump(builded, f)
    end
  end
  
  #--------------------------------------------------------------------------
  # ● ビルド用スクリプトデータを作成する
  #--------------------------------------------------------------------------
  def build_data(filepath, index)
    code = read_file(filepath)
    fname = File.basename filepath
    return { :index => index, :fname => fname, :code => Zlib::Deflate.deflate(code) }
  end
  private :build_data
  
end