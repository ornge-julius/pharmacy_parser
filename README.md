# Pharmacy Parser

This is a command-line tool that reads a file of pharmacy prescription
events and prints a report of fills and income for each patient.

## Setup

The project uses Ruby 3.2.2. Run this command to install the dependencies:

```
bundle install
```


## My Overview


## Tooling & Setup

- Built as a Rails-based project, but stripped down to remove unrelated bloat since it's a simple CLI tool, not a full web app.
- Used the **Thor gem** to build the command-line interface, since Thor makes it easy to define commands and pass parameters, aligning with the invocation format required by the project spec.
- Implemented a **rake task** to actually run the tool.
- Can be run via: `bin/run parse <path_to_file>`

## Key Assumptions

- Patient names and drug names are single strings with no spaces.
- Events must be logically ordered — e.g., a "filled" or "returned" event can't be processed unless a corresponding prescription already exists (a patient must be created before a prescription, which must exist before it can be filled or returned).
- Only patients with an actual "created" event get added to the ledger — patients appearing in the data without a created event are ignored.
- Since events lack unique/transaction IDs, the system can't tie a specific "filled" event to a specific "returned" event — it only keeps a running tally rather than one-to-one event matching (a production system would likely need unique event/prescription IDs for that).

## Architecture

Three main files:

**Parser**
- Takes the input file, reads it line by line, splits on spaces to extract patient, prescription/drug, and event type.
- Two methods: `parse` (loops through file, processes events via the ledger) and `parse_and_return` (calls `parse`, then outputs results to standard out).

**Pharmacy Ledger**
- The tool is small and short-lived, so an in-memory hash is enough. A
production system would likely store this data in a database and give
each event a unique ID, so that a `returned` event can point to the
exact `filled` event it cancels. Without event IDs, a running tally
per patient and drug is the simplest substitute.
- Core data structure: a nested hash.
- Top-level key: patient name
- Value: hash with `income` (total revenue from that patient) and `prescriptions` (hash keyed by drug name)
- Each drug entry stores `filled` and `returned` tallies.
- Constants: prescription cost, return cost, created-event string.
- Key methods:
- `initialize` – sets up the ledger.
- `process_filled_event` – checks patient exists and has a prescription for the drug, then increments filled count and income.
- `process_returned_event` – checks patient/prescription exist and that there's at least one filled prescription to return, then decrements filled count and income.
- `process_created_event` – checks patient exists and doesn't already have a prescription for that drug before creating one.
- `add_patient` – adds a new patient only on their first "created" event; includes defensive checks against duplicate additions.
- `patients` – returns list of patient keys.
- Calculation methods for total fills, total returns, and income per patient.
- Design rationale: a simple nested hash (not a database) was chosen since this is a lightweight CLI tool rather than a production system, and since events aren't uniquely tied together, a running tally approach is sufficient.

**CLI**
- `CLI` (`lib/commands/cli.rb`) is a thin Thor wrapper around `Parser`. It
exposes the `bin/run parse FILE_PATH` command. Thor was chosen because
it gives a low-effort way to turn a Ruby method into a command-line
command.


## Testing Strategy

- **Parser tests**: Uses fixtures (input event files + expected output files) in the `spec` directory.
- Happy path: events processed in correct order.
- Edge cases: return before filled, filled before created, return with no filled event.
- **Pharmacy Ledger tests**: Uses a fresh ledger for each test scenario.
- `add_patient`: valid creation, rejecting non-created-event additions, rejecting duplicate patients.
- `process_created`: rejecting creation for patients not yet added, rejecting duplicate prescriptions for the same drug.
- `process_filled`: valid fill for existing patient/prescription, rejecting fills for missing patients or non-existent prescriptions.
- `process_returned`: valid returns, rejecting returns for missing patients or prescriptions with no filled events.


## Usage

Run the tool with a path to an input file:

```
bin/run parse path/to/file.txt
```

If you do not give a path, the tool uses a sample file at
`lib/fixtures/file.txt`.


## Input Format

Each line of the input file has this format:

```
PatientName DrugName EventName
```

The fields are separated by a single space. The file lists events in
the order that they happen. There are three event types:

* `created`: The prescription enters the system.
* `filled`: The prescription is filled. A prescription can have many
  fill events.
* `returned`: A previous fill is returned.

## How Income Works

A fill adds $5 of income. A return reverses that $5 and adds a $1
penalty, for a net $6 debit. This means a prescription that is filled
and then returned nets a $1 loss overall, even if the pharmacy fills
it again later.


## Running Tests

Run the test suite with this command:

```
bundle exec rspec
```

## Known Issues

* The project still contains a full Rails 8 application scaffold
  (`config/`, `app/`, Rails gems in the Gemfile, and `rails_helper`
  based specs). Because of this, `bin/run` loads the entire Rails
  environment just to run the Thor command. A leaner version of this
  tool would remove the Rails scaffold.

