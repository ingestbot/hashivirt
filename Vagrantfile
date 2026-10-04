require 'yaml'

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'libvirt'

current_dir = File.dirname(File.expand_path(__FILE__))

# Load configuration
myconfigs = YAML.load_file("#{current_dir}/Vagrantfile.yaml")

# Load per-host VM resource parameters
vm_resources = YAML.load_file("#{current_dir}/Vagrantfile.params.yaml")

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

# Default VM resources
DEFAULT_RESOURCES = {
  memory: 2048,
  cpus: 2,
  disk: 10
}

Vagrant.configure("2") do |config|

  myhostnames.each do |i, x|

    # Get host-specific resources from YAML.
    # YAML gives us string keys, so convert them to symbols.
    host_resources = vm_resources.fetch(i, {}).transform_keys(&:to_sym)

    # Apply defaults, then override with host-specific settings.
    resources = DEFAULT_RESOURCES.merge(host_resources)

    # Debug output so we can verify the values being passed to libvirt.
    # puts "DEBUG #{i}: #{resources.inspect}"

    config.vm.define :"#{i}" do |subconfig|

      subconfig.vm.box = mybox_image
      # subconfig.vm.box = "ingestbot/ubuntu22.04"
      # subconfig.vm.box_url = "file://./metadata.json"

      subconfig.vm.hostname = "#{i}"

      subconfig.ssh.username = "ubuntu"
      subconfig.ssh.password = "ubuntu"

      subconfig.vm.allow_fstab_modification = false

      subconfig.vm.synced_folder ".", "/vagrant", disabled: true

      subconfig.vm.network :public_network,
        :dev => "#{x}",
        :mode => "bridge",
        :type => "bridge"

      subconfig.vm.provider :libvirt do |v|
        v.default_prefix = ""
        v.disk_bus = "virtio"
        v.driver = "kvm"

        v.cpus = resources[:cpus]
        v.memory = resources[:memory]
        v.machine_virtual_size = resources[:disk]

        v.autostart = true
      end

      subconfig.vm.provision "file" do |s|
        s.source = "provision/ansible.admin.ssh.pub.key"
        s.destination = "/tmp/ansible.admin"
      end

      subconfig.vm.provision "shell" do |s|
        s.path = "provision/ansible.admin.sh"
      end

      subconfig.vm.provision "shell" do |s|
        s.path = "provision/netplan.yaml.eth.sh"
      end

    end
  end
end

