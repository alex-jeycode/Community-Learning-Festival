# Community Learning Festival Platform

A decentralized platform for organizing and managing community learning festivals with workshops, seminars, and interactive educational experiences.

## Overview

This smart contract enables organizers to create workshops and participants to register for festival events. All registrations and attendance are recorded on the Stacks blockchain for transparency.

## Features

- **Festival Management**: Enable/disable festival registration periods
- **Workshop Creation**: Organizers create workshops with categories and capacity
- **Participant Registration**: Attendees register for workshops with capacity limits
- **Attendance Tracking**: Mark and verify workshop attendance
- **Transparent Records**: All data stored on blockchain

## Contract Functions

### Public Functions

- `set-festival-status`: Activate or deactivate festival (owner only)
- `create-workshop`: Create a new workshop or seminar
- `register-for-workshop`: Register as a participant
- `mark-attendance`: Confirm attendance at workshop

### Read-Only Functions

- `get-workshop`: Retrieve workshop details
- `get-registration`: Check registration status
- `is-festival-active`: Check if festival is accepting registrations
- `get-workshop-count`: Get total workshops created

## Usage

1. Contract owner activates festival
2. Organizers create workshops
3. Participants register for sessions
4. Attendance is marked and verified

## Technology

- Clarity smart contracts
- Stacks blockchain
- Bitcoin-anchored security