Puppet::Functions.create_function(:fwtofwd) do
    dispatch :fwtofwd do
        param 'Hash', :fw_hash
        param 'String', :zone
        return_type 'Hash'
    end



#, :type=>:rvalue,:doc => <<-EOS
#This takes in a has formatted for the puppet firewall module and outputs a
#    hash compatible with the rich rules firewalld datatype.
#    arg1: hash to transform
#    arg2: zone to use for rich rules
#    return: new hash
#        EOS
    def fwtofwd(fw_hash,zone)

        #raise(Puppet::ParseError, "fw_to_fwd(): wrong number of arguements " +
        #"given (#{arguements.size} and we need 2)") if arguemnts.size != 2

        #hash of hashes of firewall rules
        #fw_hash=arguments[0]
        #zone string name
        #zone=arguments[1]

        # unless fw_hash.is_a?(Hash) and zone.is_a?(String)
        #     Puppet.error('fwtofwd(): requires one hash and one string.')
        #     #raise(Puppet::ParseError, 'fwtofwd(): requires one hash and one string.')
        # end
        
        fwd_hash = Hash.new()
        # break rules out to name + hash of key value pairs
        Puppet.notice("fwtofwd(): Processing Firewall Rules: '#{fw_hash}'")
        fw_hash.each do |rule_name,fw_rule|
            Puppet.notice("processing fw_rule: '#{rule_name}'")
            if fw_rule.is_a?(Hash)
                rr=Hash.new()
                
                rr.merge!(name: rule_name)
                rr.merge!(ensure: 'present')
                rr.merge!(zone: zone) ## this is a bodge that will need to be set to default zone.
                
                if (fw_rule.has_key?('source'))
                    rr.merge!(source: fw_rule['source'])
                end

                if (fw_rule.has_key?('action'))
                    rr.merge!(action: fw_rule['action'])
                else
                    raise(Puppet::ParseError, 'fwtofwd(): action setting required')
                end

                ##handle port and protocol
                #note: this will only handle protocol/port allows at this time
                # service/icmp_block/masquerade/forward_port will require using direct firewalld rules
                protocol=""
                if (fw_rule.has_key?('proto'))
                    protocol=fw_rule['proto']
                else
                    protocol='tcp'
                end
                
                if fw_rule.has_key?('dport')
                    ## make port based rich rule
                    rr.merge!(port: {port: fw_rule['dport'], protocol: protocol})

                else
                    rr.merge!(protocol: protocol)
                    ## make protocol based rich rule, no protocol is specified use tcp
                end
                fwd_rule= {rule_name => rr}
                fwd_hash.merge!(fwd_rule)## append rich rule to firewalld hash
            else
                raise(Puppet::ParseError, 'fwtofwd(): attempted to convert non hash')
            end
        end
        Puppet.notice("fwd_hash: '#{fwd_hash}'")
        return fwd_hash
    end
end
