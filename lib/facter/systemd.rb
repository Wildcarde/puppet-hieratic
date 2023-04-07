## this facter module detects whether iptables is currently enabled on the system or not.
# it is used in conjuciton with the firewalld module to determine how to handle 

Facter.add(:systemdInUse) do
    confine :kernel => "Linux"
    setcode do
        systemdInUse = false
          if system('systemctl --version')
            systemdInUse = true
          end
        
    end
end