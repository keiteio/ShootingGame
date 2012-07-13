require "zlib"

list=[]
open(File.join("tools","filelist.txt"), "rb") do |f|
  list = f.read.lines
end

$scripts=[]
def push_script(index, file_name, code)
  $scripts.push( { :index => index, :file_name => file_name, :code=>Zlib::Deflate.deflate(code) } )
end

index = 0

files = Dir::glob(File.join(".", "scripts", "*.rb"))
list.each do |file_name|
  file_path = File.join(".", "scripts", file_name)
  if files.include?(file_path)
    open(file_path, "rb") do |f|
      push_script(index, file_name, f.read)
    end
    index += 1
    files.delete file_path
  end
end

files.each do |file_name|
  open(file_name, "rb") do |f|
    push_script(index, file_name, f.read)
    index += 1
  end
end

open(File.join("src","Data","ScriptsApd.rvdata2"), "wb") do |f|
  Marshal.dump($scripts, f)
end
