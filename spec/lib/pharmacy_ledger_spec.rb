require "rails_helper"

RSpec.describe PharmacyLedger do

    let(:patient) { "John" }
    let(:event) { PharmacyLedger::CREATED_EVENT }

    describe "#add_patient" do
        let(:other_patient) { "Jane" }
        before(:each) do
            @ledger = described_class.new
        end

        it "adds a patient with a created event" do
            @ledger.add_patient(patient, event)
            expect(@ledger.patients).to include(patient)
        end

        it "does not add a patient with a non-created event" do
            @ledger.add_patient(patient, "filled")
            expect(@ledger.patients).not_to include(patient)
        end

        it "does not add a patient if the created event is not the first event" do
            @ledger.add_patient(patient, "filled")
            @ledger.add_patient(other_patient, event)
            expect(@ledger.patients).not_to include(patient)
        end

        it "does not process a created event for a patient not yet added" do
            @ledger.add_patient(patient, "filled")
            @ledger.add_patient(other_patient, event)
            expect(@ledger.patients).not_to include(patient)
        end
    end

    describe "#process_created" do
        before(:each) do
            @ledger = described_class.new
        end
        
        it "processes a created event for a patient already added" do
            @ledger.add_patient(patient, event)
            @ledger.process_created(patient, "Aspirin", event)
            expect(@ledger.calculate_total_fills(patient)).to eq(0)
        end

        it "does not process a created event for a patient not yet added" do
            expect(@ledger.process_created(patient, "Aspirin", event)).to be_nil
        end
    end

    describe "#process_filled" do
        before(:each) do
            @ledger = described_class.new
        end

        it "processes a filled event for a patient already added and prescription created" do
            @ledger.add_patient(patient, event)
            @ledger.process_created(patient, "Aspirin", event)
            @ledger.process_filled(patient, "Aspirin", "filled")
            expect(@ledger.calculate_total_fills(patient)).to eq(1)
            expect(@ledger.income(patient)).to eq(PharmacyLedger::PRESCRIPTION_COST)
        end

        it "does not process a filled event for a patient not yet added" do
            @ledger.process_filled(patient, "Aspirin", "filled")
            expect(@ledger.calculate_total_fills(patient)).to be_nil
        end

        it "does not process a filled event for a prescription not yet created" do
            @ledger.add_patient(patient, event)
            @ledger.process_filled(patient, "Aspirin", "filled")
            expect(@ledger.calculate_total_fills(patient)).to eq(0)
        end
    end

    describe "#process_returned" do
        before(:each) do
            @ledger = described_class.new
        end

        it "processes a returned event for a patient already added and prescription filled" do
            @ledger.add_patient(patient, event)
            @ledger.process_created(patient, "Aspirin", event)
            @ledger.process_filled(patient, "Aspirin", "filled")
            @ledger.process_returned(patient, "Aspirin", "returned")
            expect(@ledger.calculate_total_fills(patient)).to eq(0)
            expect(@ledger.income(patient)).to eq(PharmacyLedger::PRESCRIPTION_COST - PharmacyLedger::RETURN_COST)
        end

        it "does not process a returned event for a patient not yet added" do
            @ledger.process_returned(patient, "Aspirin", "returned")
            expect(@ledger.calculate_total_returns(patient)).to be_nil
        end

        it "does not process a returned event for a prescription not yet filled" do
            @ledger.add_patient(patient, event)
            @ledger.process_created(patient, "Aspirin", event)
            @ledger.process_returned(patient, "Aspirin", "returned")
            expect(@ledger.calculate_total_returns(patient)).to eq(0)
            expect(@ledger.income(patient)).to eq(0)
        end
    end
    

end