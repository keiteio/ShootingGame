task :run => "run:dev"

namespace :run do
  task :prod do
    system "./data/Game.exe"
  end
  
  task :dev do
    system "./data/Game.exe console test"
  end
end

namespace :build do
  task :script do
    require "./tools/dev_tool.rb"
    
    dev = DevelopTool.new
    dev.build
  end
end