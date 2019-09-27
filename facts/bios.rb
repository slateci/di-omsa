Facter.add(:bios_configuration) do
  if File.exists? '/opt/dell/srvadmin/bin/omreport'
    Facter::Core::Execution.execute("sudo systemctl is-active dsm_sa_datamgrd --quiet")

    # Check if we can run OMSA first.
    if $?.exitstatus != 0
      res = {"omsa_installed" => true}
      res = {"omsa_running" => false}
    end

    current_key = nil
    past_start_block = false

    # UEFI Boot Settings Code
    # 0 - not in UEFI Boot Settings block.
    # 1 - skip title separator.
    # 2 - skip first blank line.
    # 3 - at UefiBootSeq
    # 4 - adding to list
    uefi_code = 0
    uefi_num = 1

    Facter::Core::Execution.execute("sudo /opt/dell/srvadmin/bin/omreport chassis biossetup display=shortnames").each_line do |line|
      # DSU has a bit of a preamble we need to skip.
      if !past_start_block
        if line.strip == "System BIOS Settings"
          past_start_block = true
        end
        next
      end

      # Special case for UEFI Boot Settings.
      if uefi_code > 0
        if uefi_code == 1 or uefi_code == 2
          uefi_code += 1
          next

        elsif uefi_code == 3
          res[current_key]["uefibootseq"] = {}
          uefi_code += 1
          next

        # At the end of the list.
        elsif line.strip == ""
          uefi_code = 0

        else
          split = line.split(". ")[1].split(":").map(&:strip)
          res[current_key]["uefibootseq"][uefi_num] = {
            "enabled?" => split[0] == "Enabled",
            "device" => split[1]
          }
          uefi_num += 1
          next
        end
      end

      # Beginning a new block, mark key as null so we know to grab the next line as the key.
      if line.strip == ""
        current_key = nil
        next

      # Skip the title separator.
      elsif line.start_with?("------------------------------------------")
        next

      # Special case for UEFI Boot Settings because Dell just can't be consistent can they.
      elsif line.start_with?("UEFI Boot Settings")
        uefi_code = 1
      end

      # Set the key for this current block.
      if current_key == nil
        current_key = line.strip.gsub(/\s+/,"_").downcase
        res[current_key] = {}
        next

      # Add to the current block.
      else
        split = line.split(":").map(&:strip)
        res[current_key][split[0]] = split[1]
      end
    end

  else
    res = {"omsa_installed" => false}
  end

  setcode do
    res
  end
end
