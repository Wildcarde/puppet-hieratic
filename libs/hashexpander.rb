module Puppet::Parser::Functions
  newfunction(:expand_hash_entries, :type => :rvalue, :doc => <<-EOS
Takes as an argument a hash of hashes and an array of hash index names. If
it finds one of hash names to be in index and to be an array it will expand
the hash.
    EOS
  ) do |arguments|

    raise(Puppet::ParseError, "expand_hash_entries(): Wrong number of arguments " +
      "given (#{arguments.size} and we need 2)") if arguments.size != 2

    # Hash of hashes
    hh = arguments[0]
    # Arrays of names to expand
    arr_expand = arguments[1]

    unless hh.is_a?(Hash) and arr_expand.is_a?(Array)
      raise(Puppet::ParseError, 'expand_hash_entries(): Requires one hash and one array.')
    end

    # Where we will put processed result
    new_hh = hh.clone
    arr_expand.each do |one_expand|
      new_hh.clone.each do |name, entries|
        if entries.has_key?(one_expand) and (entries[one_expand].is_a?(Array) or entries[one_expand].is_a?(Hash))
          if entries[one_expand].is_a?(Array)
            tempexpand = Hash[*entries[one_expand].zip(entries[one_expand]).flatten]
          else
            tempexpand = entries[one_expand]
          end
          # go through expansion and perform it, so loop through values
          tempexpand.each do |n,v|
            new_name = name + " " + n
            new_hh[new_name] = entries.clone
            new_hh[new_name][one_expand] = v
          end
          new_hh.delete(name)
        end
      end
    end
    return new_hh
  end
end
