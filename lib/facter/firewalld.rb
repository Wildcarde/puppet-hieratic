## this facter module detects whether iptables is currently enabled on the system or not.
# it is used in conjuciton with the firewalld module to determine how to handle 

### ref: https://stackoverflow.com/questions/18728069/ruby-system-command-check-exit-code

Facter.add(:firewalld_in_use) do
    confine :kernel => "Linux"
    confine :systemdInUse => true
    setcode do
        firewalld_in_use=false
        if system('firewall-cmd --state') #gets return code
            firewalld_in_use=true
        end
        
    end
end

Facter.add(:firewalld_default_zone) do
    confine :firewalld_in_use => true
    setcode do
        firewalld_default_zone="public" # this is the general firewalld spec default
        if :firewalld_in_use
            firewalld_default_zone=`firewall-cmd --get-default-zone`
            firewalld_default_zone=firewalld_default_zone.strip()## required because it can introduce newlines otherwise.
        end
    end
end