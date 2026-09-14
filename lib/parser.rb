# read input file

# for each input line
# Create new patient if needed
# Validate event
    # get patient
    # check if prescription exists or create new
        # If created event then add new prescription to patient collection
        # update tally for prscription if event is filled or returned
            # if filled event, add to filled tally, add to income
            # if returned event
                # if filled > 0
                    # subtract tally
                    # subtract income
                # if filled 0 <=
                    # discard returned event
            

# return to std out the output
    # loof through patient dict
    # format string for stdout
    # print to stdout

# read stdin args

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
    PATIENT_HASH = {}

    def parse(file_path)
        File.readlines(file_path, chomp: true).each do |line|
            patient, prescription, event = line.split(' ')
            # if patient doesnt exist, create them
            if !PATIENT_HASH.include?(patient)
                PATIENT_HASH[patient] = {income: 0, prescriptions: {}}
            end
            
            if event == 'created'
                PATIENT_HASH[patient][:prescriptions][prescription] = { filled: 0, returned: 0 }
            elsif event == 'filled'
                process_filled(patient, prescription)
            elsif event == 'returned'
                process_returned(patient, prescription)  
            end
        end
    end

    def parse_and_return(file_path)
        parse(file_path)
        for patient in PATIENT_HASH.keys
            total_fills = calculate_total_fills(patient)
            dollar_string = PATIENT_HASH[patient][:income] >= 0 ? "$#{PATIENT_HASH[patient][:income]}" : "-$#{PATIENT_HASH[patient][:income]}"
            puts "#{patient}: #{total_fills} fills #{dollar_string} income"
        end
    end
    
    def process_filled(patient, prescription)
        if PATIENT_HASH[patient][:prescriptions].include?(prescription)
            PATIENT_HASH[patient][:prescriptions][prescription][:filled] += 1
            PATIENT_HASH[patient][:income] += 5
        end

    end

    def process_returned(patient, prescription)
        if PATIENT_HASH[patient][:prescriptions][prescription][:filled] > 0
            PATIENT_HASH[patient][:prescriptions][prescription][:filled] -= 1
            PATIENT_HASH[patient][:income] -=1
        end
    end

    def parse_and_return(file_path)
        parse(file_path)
        for patient in PATIENT_HASH.keys
            total_fills = calculate_total_fills(patient)
            dollar_string = PATIENT_HASH[patient][:income] >= 0 ? "$#{PATIENT_HASH[patient][:income]}" : "-$#{PATIENT_HASH[patient][:income]}"
            puts "#{patient}: #{total_fills} fills #{dollar_string} income"
        end
    end

    def calculate_total_fills(patient)
        PATIENT_HASH[patient][:prescriptions].values.map { |prescription| prescription[:filled] }.sum
    end

end