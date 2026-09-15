class PharmacyLedger


    
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
    LEDGER = {}
    PRESCRIPTION_COST = 5
    RETURN_COST = 6
    CREATED_EVENT = 'created'.freeze

    def process_filled(patient, drug, event)
        if LEDGER[patient] && LEDGER[patient][:prescriptions].include?(drug)
            LEDGER[patient][:prescriptions][drug][:filled] += 1
            LEDGER[patient][:income] += PRESCRIPTION_COST
        end

    end

    def process_returned(patient, drug, event)
        if LEDGER[patient] && LEDGER[patient][:prescriptions].include?(drug) && LEDGER[patient][:prescriptions][drug][:filled] > 0
            LEDGER[patient][:prescriptions][drug][:filled] -= 1
            LEDGER[patient][:income] -= RETURN_COST
        end
    end

    def process_created(patient, drug, event)
        unless LEDGER[patient] && LEDGER[patient][:prescriptions].include?(drug)
            LEDGER[patient][:prescriptions][drug] = {filled: 0}
        end
    end

    def add_patient(patient, event)
        unless event != CREATED_EVENT
            LEDGER[patient] = {income: 0, prescriptions: {}}
        end
    end 

    def patients
        LEDGER.keys
    end

    def calculate_total_fills(patient)
        LEDGER[patient][:prescriptions].values.map { |prescription| prescription[:filled] }.sum
    end

    def income(patient)
        LEDGER[patient][:income]
    end

end