## Development Methodology

Follow Kent Beck's Test-Driven Development (TDD) strictly:

### The TDD Cycle (Red-Green-Refactor)

1. **Red**: Write a failing test first
   - Never write production code without a failing test
   - The test should fail for the right reason
   - Run the test and confirm it fails before proceeding

2. **Green**: Write the minimum code to pass
   - Write only enough code to make the test pass
   - Do not anticipate future needs—solve only the current test
   - "Fake it till you make it" is acceptable

3. **Refactor**: Clean up while staying green
   - Remove duplication
   - Improve naming and structure
   - Run tests after each refactor step

### Rules

- **One test at a time**: Complete the full Red-Green-Refactor cycle before writing the next test
- **Small steps**: If unsure, take smaller steps
- **Run tests frequently**: After every change, run the relevant tests
- **No production code without a test**: Every line of production code must be justified by a failing test
- **Triangulation**: Use multiple test cases to drive toward general solutions

### Workflow

When implementing a feature:
1. List the test cases needed (as a checklist)
2. Pick the simplest test case first
3. Complete TDD cycle for each test
4. Cross off completed tests from the checklist
