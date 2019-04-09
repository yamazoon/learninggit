#! /bin/sh
exec ruby -S -x "$0" "$@"
#! ruby

# Switch Role
require "./aws-ruby-switchrole.rb"

# 出力フォルダ作成
$filename = __FILE__
require "./aws-ruby-makedir.rb"


# IAMクライアント作成
iam = Aws::IAM::Client.new(credentials: $role_credentials)

# インスタンスプロファイルに付いているインラインポリシーを、jsonファイルでごそっと抜いてくる
# 標準出力にも出す
iam.list_instance_profiles().instance_profiles.map do |n|
    profilename = n.roles[0].role_name
    iam.list_role_policies({
      role_name: profilename,
    }).map do |n|
        policyname_list = n.policy_names
        if not policyname_list.empty?
            policyname_list.each do |n|
                policyname = n
                get_role_policy = iam.get_role_policy({
                  role_name: profilename,
                  policy_name: policyname,
                })
                role__name = get_role_policy.role_name
                policy__name = get_role_policy.policy_name
                outputjson = role__name + "--" + policy__name + ".json"
                outjson = URI.decode_www_form_component(get_role_policy.policy_document)
                outputdoc = JSON.pretty_generate(JSON.parse(outjson))
                File.open($folder+ "/" + outputjson, "a") do |f|
                    f.puts outputdoc
                end
                puts
                puts
                puts
                puts
                puts role__name
                puts policy__name
                puts outputdoc
            end
        end
    end
end
