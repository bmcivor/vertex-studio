# Ticket Standards

This document defines how to write tickets in Taiga for the vertex-studio project.

## Ticket Types

### Epic
Large feature or initiative that spans multiple sprints. Contains multiple user stories.

**When to use:**
- Feature will take more than 2 weeks
- Requires multiple user stories to complete
- High-level business goal

**Example:**
- "GitLab CI/CD Integration"
- "Local LLM Infrastructure"
- "Web Application Hosting Platform"

### User Story
A feature or requirement from the user's perspective. Contains multiple tasks.

**When to use:**
- Deliverable feature that provides user value
- Can be completed in 1-2 sprints
- Has clear acceptance criteria

**Format:**
```
As a [type of user]
I want [some goal]
So that [some reason/benefit]
```

**Example:**
```
Title: Deploy MkDocs documentation server

As a developer
I want project documentation accessible via web browser
So that I can reference setup guides and playbook docs without cloning the repo
```

### Task
A specific unit of work that contributes to a user story.

**When to use:**
- Concrete, actionable work item
- Can be completed in 1-2 days
- Part of a larger user story or standalone

**Example:**
- "Create Ansible role for MkDocs"
- "Write docker-compose.yml for MkDocs"
- "Add MkDocs playbook documentation"

## Ticket Structure

### Title
- Clear, concise, action-oriented
- Start with verb (Create, Deploy, Configure, Fix, Update)
- Specific enough to understand without reading description

**Good:**
- "Deploy Taiga project management platform"
- "Configure SSH key-based authentication"
- "Create Docker installation role"

**Bad:**
- "Taiga" (not descriptive)
- "Need to fix the thing" (vague)
- "Working on deployment stuff" (not specific)

### Description

#### For User Stories:
```
## Context
[Why this work is needed, background information]

## User Story
As a [user type]
I want [goal]
So that [benefit]

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Technical Notes
[Implementation details, dependencies, constraints]

## Resources
- [Links to relevant documentation]
- [Related tickets]
```

#### For Tasks:
```
## Objective
[What needs to be done and why]

## Steps
1. Step 1
2. Step 2
3. Step 3

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Testing
[How to verify the work is complete]
```

### Acceptance Criteria

Must be:
- **Specific**: Clear what "done" means
- **Testable**: Can verify completion
- **Measurable**: Not subjective
- **Complete**: Covers all aspects of the work

**Good:**
- "Taiga accessible at http://192.168.20.15:9000"
- "Bootstrap playbook runs without errors"
- "Docker service is running and enabled on boot"

**Bad:**
- "Everything works" (not specific)
- "Looks good" (not testable)
- "Make it better" (not measurable)

## Workflow States

1. **New** - Just created, not yet triaged
2. **Ready** - Approved, ready to be worked on
3. **In Progress** - Currently being worked on
4. **Review** - Implementation complete, needs review
5. **Testing** - Under testing/verification
6. **Done** - Completed and verified

## Example Tickets

### Example Epic
```
Title: Self-hosted GitLab Platform

Description:
## Context
Need version control, CI/CD, and container registry for development workflow.

## Goals
- Host GitLab CE on lab server
- Configure SSH and HTTPS access
- Set up CI/CD runners
- Configure container registry

## User Stories
- Deploy GitLab CE via Ansible
- Configure GitLab runners
- Set up container registry
- Configure backups
```

### Example User Story
```
Title: Deploy GitLab CE via Ansible

Description:
## Context
GitLab will be our central code repository and CI/CD platform.

## User Story
As a developer
I want GitLab running on the lab server
So that I can manage code and run CI/CD pipelines

## Acceptance Criteria
- [ ] GitLab accessible at http://192.168.20.15:8080
- [ ] Root user can log in
- [ ] Can create new project
- [ ] Can push code via SSH
- [ ] Can push code via HTTPS

## Technical Notes
- Use official GitLab Docker image
- Store data in Docker volumes
- Configure external URL in gitlab.rb
- Port 8080 for HTTP, 2222 for SSH

## Resources
- https://docs.gitlab.com/ee/install/docker.html
```

### Example Task
```
Title: Create Ansible role for GitLab

Description:
## Objective
Create reusable Ansible role to deploy GitLab CE via Docker Compose.

## Steps
1. Create roles/gitlab directory structure
2. Write docker-compose.yml template
3. Create gitlab.rb configuration template
4. Add tasks to deploy and start GitLab
5. Document the role

## Acceptance Criteria
- [ ] Role exists in roles/gitlab/
- [ ] Templates render correctly
- [ ] GitLab containers start successfully
- [ ] Role is idempotent

## Testing
Run `make gitlab` and verify containers are running
```

## Tips for Writing Good Tickets

1. **Be specific**: "Deploy Taiga" not "Set up project management"
2. **Include context**: Why is this work needed?
3. **Define done**: What does success look like?
4. **Link dependencies**: Reference related tickets
5. **Add technical notes**: Help future self understand decisions
6. **Keep it focused**: One clear objective per ticket
7. **Update as you work**: Add findings, blockers, solutions

## Ticket Review Checklist

Before marking a ticket as "Ready":

- [ ] Title is clear and specific
- [ ] Description includes context
- [ ] Acceptance criteria are defined
- [ ] Estimation is assigned
- [ ] Labels/tags are applied
- [ ] Dependencies are linked
- [ ] Assignee is set (if known)
