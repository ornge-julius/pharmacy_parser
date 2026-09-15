class Parser

    # Hash to store patient data
    # EXAMPLE
    # {
    #     "patient_name" => {
    #         income: 0,
    #         prescriptions: {
    #             "prescription_name" => {
    #                 filled: 0,
    #                 returned: 0
    #             }
    #         }
    #     }
    # }
    LEDGER = PharmacyLedger.new()
    CREATED = 'created'.freeze
    FILLED = 'filled'.freeze
    RETURNED = 'returned'.freeze
    
    def parse(file_path)
        File.readlines(file_path, chomp: true).each do |line|
            patient, prescription, event = line.split(' ')

            unless LEDGER.patients.include?(patient)
                LEDGER.add_patient(patient, event)
            end
            
            if event == CREATED
                LEDGER.process_created(patient, prescription, event)
            elsif event == FILLED
                LEDGER.process_filled(patient, prescription, event)
            elsif event == RETURNED
                LEDGER.process_returned(patient, prescription, event)
            end
        end
    end

    def parse_and_return(file_path)
        parse(file_path)
        for patient in LEDGER.patients
            total_fills = LEDGER.calculate_total_fills(patient)
            dollar_string = LEDGER.income(patient) >= 0 ? "$#{LEDGER.income(patient)}" : "-$#{LEDGER.income(patient).abs}"
            puts "#{patient}: #{total_fills} fills #{dollar_string} income"
        end
    end
    
end