require 'aws-sdk'

# 共通変数設定
$accountnum = ARGV[0]
$sessionname = ARGV[1]
$region = ARGV[2]

puts #{$accountnum}
puts #{$sessionname}
puts #{$region}

# 第一引数のROロールにスイッチロールする セッション名は第二引数
$role_credentials = Aws::AssumeRoleCredentials.new(
  client: Aws::STS::Client.new,
  role_arn: "arn:aws:iam::#{$accountnum}:role/RoleRO",
  role_session_name: "#{$sessionname}"
)
