# Build baseurl

os = platform?("redhat") ? "rhel" : "centos"
ver = node[:kernel][:machine].scan(/(?<=_)\w+/).empty? ? "x86" : "amd64"

yum_repository "mariadb" do
  description "MariaDB"
  baseurl "http://yum.mariadb.org/#{node[:mariadb][:server][:version]}/#{os}#{node[:platform_version].scan(/\d/)[0]}-#{ver}"
  gpgkey  "https://yum.mariadb.org/RPM-GPG-KEY-MariaDB"
  action  :nothing
end.run_action :create

# DO not user mariadb-libs
node.default[:yum][:main][:exclude] = "mariadb-libs"

include_recipe "yum"

