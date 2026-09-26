# Expertiza Contribution Fork

This repository is my fork of [Expertiza](https://github.com/expertiza/expertiza), an open-source Ruby on Rails application used for submitting and peer-reviewing learning materials.

## My work in this fork

My contribution focused on refactoring `TeamsController` to better follow the single-responsibility principle. The original controller handled many unrelated decisions inside large actions. The refactor extracted smaller helper methods for team lookup, validation, deletion, inheritance, and transfer workflows.

The goal was to make the controller easier to read, test, and change without altering the application's intended behavior.

## What I learned

- How to navigate a large Rails codebase
- How controller responsibilities can be separated into smaller operations
- How refactoring differs from changing product behavior
- How to work with an established open-source project's conventions
- How to prepare a focused change for review

## Technology

- Ruby on Rails
- MySQL
- RSpec
- JavaScript
- Docker

## Running Expertiza

This fork follows the upstream project's setup and architecture. Because setup requirements change over time, use the current instructions in the [upstream Expertiza repository](https://github.com/expertiza/expertiza) when possible.

The checked-in version also includes Docker configuration and legacy local setup documentation for the environment used when this work was completed.

## Repository status

This fork is preserved to document a specific contribution. It is not maintained as an independent distribution of Expertiza.

## License

Expertiza is distributed under the license included in this repository. Upstream ownership and contribution history remain with the Expertiza project and its contributors.

