module Saltr
  class Help
    def self.topics
      self.instance_methods(false).collect{ |meth| meth.to_s }.join(', ')
    end
    
def top
"""
help topics: #{self.class.topics}

l                 # sys.list-modules
l <modulename>    # sys.list-functions modulename
l <functionname>  # sys.doc functionname

r <cmd.run string>
m <new-minion-target>
   m * and G@os:Ubu*    will make a compound minion query
   G=grains, P=grains regexp, L=list of minions
o <new out string>

salt-cloud
salt-key

grains.item ip4_interfaces
"""
end

def ufw
"""
ufw status
ufw allow ssh
ufw allow salt   # on master
ufw allow from 52.6.10.1 to any port 22   # put master's ip address
ufw enable

ufw delete allow from 52.6.10.1 to any port 22
ufw deny apache

ufw app list   # finds from /etc/ufw/applications.d/

log file for intrusion attempts: /var/log/kern.log
"""
end

def o
"""
compact     Display compact output data structure
highstate   Outputter for displaying results of state runs
json_out    Display return data in JSON format
key         Display salt-key output
nested      Recursively display nested data
newline_values_only    Display values only, separated by newlines
no_out      Display no output
no_return   Display output for minions that did not return
overstatestage  Display clean output of an overstate stage
pprint_out  Python pretty-print (pprint)
progress    Display return data as a progress bar
raw         Display raw output data structure
txt         Simple text outputter
virt_query  virt.query outputter
yaml_out    Display return data in YAML format
"""
end

  end  # Help
end
