module Saltr
  class Help
    def self.topics
      self.instance_methods(false).collect{ |meth| meth.to_s }.join(', ')
    end
    
def top
"""
help topics: #{self.class.topics}

r <cmd.run string>
m <new minion string>
o <new out string>

sys.list_functions test

list-packages
list=packagename
minions=Gos=ub*
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

  end  # Help
end
