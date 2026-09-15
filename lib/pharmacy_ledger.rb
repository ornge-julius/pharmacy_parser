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
    PRESCRIPTION_COST = 5
    RETURN_COST = 6
    CREATED_EVENT = 'created'.freeze


    def initialize
        @ledger = {}
    end

    def process_filled(patient, drug, event)
        if @ledger[patient] && @ledger[patient][:prescriptions].include?(drug)
            @ledger[patient][:prescriptions][drug][:filled] += 1
            @ledger[patient][:income] += PRESCRIPTION_COST
        end

    end

    def process_returned(patient, drug, event)
        if @ledger[patient] && @ledger[patient][:prescriptions].include?(drug) && @ledger[patient][:prescriptions][drug][:filled] > 0
            @ledger[patient][:prescriptions][drug][:filled] -= 1
            @ledger[patient][:income] -= RETURN_COST
        end
    end

    def process_created(patient, drug, event)
        unless !@ledger[patient] || @ledger[patient][:prescriptions].include?(drug)
            @ledger[patient][:prescriptions][drug] = {filled: 0, returned: 0}
        end
    end

    def add_patient(patient, event)
        # Assumption: We only want patients to show up in the ledger who have at least one created event.
        #             The 'created' event should be the first event for a patient to be added to the ledger.
        unless event != CREATED_EVENT || patients.include?(patient)
            @ledger[patient] = {income: 0, prescriptions: {}}
        end
    end

    def patients
        @ledger.keys
    end

    def calculate_total_fills(patient)
        unless !@ledger[patient]
            @ledger[patient][:prescriptions].values.map { |prescription| prescription[:filled] }.sum
        end
    end

    def calculate_total_returns(patient)
        unless !@ledger[patient]
            @ledger[patient][:prescriptions].values.map { |prescription| prescription[:returned] }.sum
        end
    end

    def income(patient)
        unless !@ledger[patient]
            @ledger[patient][:income]
        end
    end

end