##

Facter.add(:docker_in_use) do
    confine :kernel => "Linux"
    confine :systemdInUse => true
    setcode do
        docker_in_use=false
        if system('systemctl status docker --no-pager') == 0 #return code should be 0 if active
            docker_in_use=true
        end
        
    end
end