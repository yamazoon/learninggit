#! /bin/sh
exec ruby -S -x "$0" "$@"
#! ruby

# Switch Role
require "./aws-ruby-switchrole.rb"

# 出力フォルダ作成
$filename = __FILE__
require "./aws-ruby-makedir.rb"

# EC2クライアントのインスタンス作成
ec2 = Aws::EC2::Client.new(region:"#{$region}", credentials: $role_credentials)

# VPCエンドポイントの情報を、vpcidでソートして内容取得
ec2.describe_vpc_endpoints[0].sort_by!(&:vpc_id).map do |a|
    describe_vpcs = ec2.describe_vpcs({
      vpc_ids: [
        a[:vpc_id], 
      ], 
    })
    $vpc_name = "nothing"
    $cidr = "nothing"
    describe_vpcs.vpcs.map do |b|
        b[:tags].map do |c|
            $vpc_name = c[:value] if c[:key].match(/^Name$/)
        end
    $cidr = b[:cidr_block]
        $subnet_name = "-"
        $subnet_cidr_block = "-"
        $route_table_id = "-"
        outputcsv = "#{$accountnum}" + "--" + "vpcendpoint" + ".csv"
        if a[:route_table_ids].empty?
            outputdoc = [a[:vpc_endpoint_id],a[:vpc_endpoint_type],a[:service_name],$route_table_id,$subnet_name,$subnet_cidr_block,a[:vpc_id],$vpc_name,$cidr].join(",")
            File.open($folder+ "/" + outputcsv, "a") do |z|
                z.puts outputdoc
                puts outputdoc
            end
        else
            a[:route_table_ids].each do |d|
                $route_table_id = d
                route_table = ec2.describe_route_tables({
                  route_table_ids: [
                    $route_table_id,
                  ],
                })
                route_table.map do |e|
                    e[:route_tables].each do |f|
                        f[:associations].each do |g|
                            describe_subnets = ec2.describe_subnets({
                              subnet_ids: [g[:subnet_id]],
                              dry_run: false,
                            })
                            describe_subnets[:subnets].each do |h|
                                h[:tags].map do |i|
                                    $subnet_name = i[:value] if i[:key].match(/^Name$/)
                                end
                                $subnet_cidr_block = h[:cidr_block]
                                outputdoc = [a[:vpc_endpoint_id],a[:vpc_endpoint_type],a[:service_name],$route_table_id,$subnet_name,$subnet_cidr_block,a[:vpc_id],$vpc_name,$cidr].join(",")
                                File.open($folder+ "/" + outputcsv, "a") do |z|
                                    z.puts outputdoc
                                    puts outputdoc
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
