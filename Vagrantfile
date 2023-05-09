require 'yaml'

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'libvirt'

current_dir    = File.dirname(File.expand_path(__FILE__))
myconfigs        = YAML.load_file("#{current_dir}/Vagrantfile.yaml")

myhostnames = myconfigs['systems']
myinterface = myconfigs['interface']
mybox_image = myconfigs['box_image']


REQUIRED_PLUGINS = %w(vagrant-libvirt)
exit unless REQUIRED_PLUGINS.all? do |plugin|
  Vagrant.has_plugin?(plugin) || (
    puts "The #{plugin} plugin is required. Please install it with:"
    puts "$ vagrant plugin install #{plugin}"
    false
  )
end

Vagrant.configure("2") do |config|
 myhostnames.each do |i,x|
  config.vm.define :"#{i}" do |subconfig|
#   subconfig.vm.box = mybox_image
   subconfig.vm.box = "ingestbot/ubuntu22.04"
   subconfig.vm.box_url = "file://./metadata.json"
   subconfig.vm.hostname = "#{i}"
   subconfig.ssh.username = "vagrant"
   subconfig.ssh.password = "vagrant"
   subconfig.vm.allow_fstab_modification = false
   subconfig.vm.synced_folder ".", "/vagrant", disabled: true
   subconfig.vm.network :public_network, :dev => "#{x}", :mode => "bridge", :type => "bridge"

   subconfig.vm.provider :libvirt do |v, override|
    v.default_prefix = ""
    v.disk_bus = "virtio"
    v.driver = "kvm"
    v.cpus = 2
    v.autostart = true
    v.memory = 2048
    v.machine_virtual_size = 20
   end

   subconfig.vm.provision "shell" do |s|
        s.inline = "/usr/bin/touch /tmp/firstrun"
   end
   subconfig.vm.provision "shell" do |s|
        s.path = "provision/netplan.yaml.eth.sh"
   end
   subconfig.vm.provision "shell" do |s|
        s.path = "provision/ansible.admin.sh"
   end
   subconfig.vm.provision "shell" do |s|
        s.path = "provision/first.run.sh"
   end

  end
 end
end
