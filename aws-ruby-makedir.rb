# 出力フォルダ作成
require "date"
datetime = Time.new()
stringdatetime = datetime.strftime('%Y-%m-%d-%H-%M-%S')
modulename = File.basename($filename, ".*")
$folder =  modulename + "-" + stringdatetime
Dir.mkdir($folder, 0755)
