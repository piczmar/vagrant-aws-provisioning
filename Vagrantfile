# based on https://github.com/mitchellh/vagrant-aws
# 1) install puppet locally
# - install modules to local modules directory
# puppet module install puppetlabs/postgresql --force -i modules
# puppet module install puppetlabs/stdlib --force -i modules
# puppet module install puppetlabs/firewall --force -i modules
# puppet module install puppetlabs/apt --force -i modules
# puppet module install ripienaar/concat --force -i modules

# 2)vagrant up --provider aws
# Connect postgres localhost: psql -h localhost -U postgres -W


Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu_linux_14.03"
  config.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
  config.vm.provider :aws do |aws, override|

	config.vm.provision :shell, :inline => "apt-get update --fix-missing"
	config.vm.provision :shell, :inline => "apt-get install puppet-common -y > /dev/null"
	config.vm.provision :puppet do |puppet|
		puppet.options = "--verbose --debug"
		puppet.manifests_path = "manifests"
		puppet.manifest_file = "default.pp"
		puppet.module_path = "modules"
	end

	# install gvm & grails
	config.vm.provision :shell, :inline => "apt-get install unzip -y > /dev/null"
	config.vm.provision :shell, :inline => "curl -s get.gvmtool.net | bash"
	config.vm.provision :shell, :inline => ". ~/.bashrc"
#	config.vm.provision :shell, :inline => "gvm install grails"
	config.vm.provision :shell, :inline => "sudo apt-get install tomcat7 tomcat7-admin -y > /dev/null"

    aws.access_key_id = "secret_key"
    aws.secret_access_key = "secret_access_key"
    aws.keypair_name = "private_key_file"
    aws.instance_type = "t1.micro"
	#aws.instance_type = "m1.small"
  	aws.ami = "ami-8caa1ce4"
	aws.security_groups = ["security_group_name"]
 	aws.tags = {
      'AppType' => 'Grails'
    }
    aws.instance_ready_timeout = 360
    override.ssh.username = "ubuntu"
	override.ssh.private_key_path = "../private_key_file.pem"

    config.vm.synced_folder ".", "/vagrant", type: "rsync", :rsync_excludes => ['bar/', 'foo/']
  end
end

