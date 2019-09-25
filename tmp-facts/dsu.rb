REG = /^\d+[.] (\w+), (.+?)\s+[(]\s+Version : (.+?) [)]$/

Facter.add(:firmware_versions) do
  if File.exists? '/sbin/dsu'
    res = {:dsu_installed => true}

    Facter::Core::Execution.execute("sudo dsu -i").each_line do |line|
      line.match(REG) {
        |m|
        key = m[1].gsub(/\s+/,"_").downcase.to_sym
        subkey = m[2].gsub(/[-(),:]/, "").gsub(/\s+/,"_").downcase.to_sym

        if not res.key?(key)
          res[key] = {}
        end

        res[key][subkey] = m[3]
      }
    end

  else
    res = {:dsu_installed => false}
  end

  setcode do
    res
  end
end
