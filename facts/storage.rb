Facter.add(:storage_configuration) do
  if File.exists? '/opt/dell/srvadmin/bin/omreport'
    res = {"omsa_installed" => true}

    controller_num = 0
    while true
      exec = Facter::Core::Execution.execute("sudo /opt/dell/srvadmin/bin/omreport storage pdisk controller=#{controller_num}")

      if $?.exitstatus != 0
        break
      end

      line_num = 0
      controller_key = "controller_#{controller_num}".gsub(/\s+/,"_").downcase

      res[controller_key] = {}

      exec.each_line do |line|
        # Skip the preamble.
        if line_num < 3
          line_num += 1
          next
        end

        split_line = line.split(":", 2).map(&:strip)
        current_key = split_line[0].chomp(".").gsub(/\s+/,"_").downcase
        res[controller_key][current_key] = split_line[1]
      end

      controller_num += 1
    end

  else
    res = {"omsa_installed" => false}
  end

  setcode do
    res
  end
end
