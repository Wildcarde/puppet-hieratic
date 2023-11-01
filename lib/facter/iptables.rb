## this facter module detects whether iptables is currently enabled on the system or not.
# it is used in conjuciton with the firewalld module to determine how to handle 

Facter.add(:iptablesInUse) do
    confine :kernel => "Linux"
    confine :systemdInUse => true
    setcode do
        iptablesInUse = false
        if system('systemctl status iptables --no-pager')
            iptablesInUse = true
        end
        
    end
end