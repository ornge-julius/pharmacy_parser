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
    CREATED = 'created'.freeze
    FILLED = 'filled'.freeze
    RETURNED = 'returned'.freeze

    def initialize
        @ledger = PharmacyLedger.new
    end

    def parse(file_path)
        File.readlines(file_path, chomp: true).each do |line|
            patient, prescription, event = line.split(' ')

            unless @ledger.patients.include?(patient)
                @ledger.add_patient(patient, event)
            end

            if event == CREATED
                @ledger.process_created(patient, prescription, event)
            elsif event == FILLED
                @ledger.process_filled(patient, prescription, event)
            elsif event == RETURNED
                @ledger.process_returned(patient, prescription, event)
            end
        end
    end

    def parse_and_return(file_path)
        parse(file_path)
        for patient in @ledger.patients
            total_fills = @ledger.calculate_total_fills(patient)
            dollar_string = @ledger.income(patient) >= 0 ? "$#{@ledger.income(patient)}" : "-$#{@ledger.income(patient).abs}"
            puts "#{patient}: #{total_fills} fills #{dollar_string} income"
        end
    end
    
end