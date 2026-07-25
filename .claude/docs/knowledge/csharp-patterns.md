# C#/.NET implementation rules and patterns

Global rules the agent must follow in any repository built with C#/.NET. If a repository has specific rules in its `CLAUDE.md` that conflict with this document, the specific rules take precedence.

## Stack

Not every service will use all of these. If the solution needs them, it must follow the ones defined here.

| Type | Technology | Version/Docker image |
|---|---|---|
| Language | .NET/C# | .NET 8 |
| SQL database | PostgreSQL  | 14.1-alpine |
| NoSQL database | MongoDB  | 6-jammy |
| Vector database | OpenSearch  | 2.11.1 |
| Cache | Redis | 7-alpine |
| Messaging | RabbitMQ | 3.8-management-alpine |

## Architecture

A variation of Clean Architecture with 4 layers:

```
Project.sln
├── src/
│   ├── Project.Core/           # Entities, interfaces, domain services, DTOs
│   ├── Project.Infrastructure/ # Repository implementations, communication with other services and external APIs
│   ├── Project.Web/            # Endpoints, request & response parameters, middlewares
│   └── Project.SharedKernel/   # Shared types: exceptions, extensions, helpers, utils
├── tests/
│    └── Project.UnitTests/     # Unit tests
│       ├── Core/               # Unit tests for the Core layer
│       ├── Infrastructure/     # Unit tests for the Infrastructure layer
│       ├── SharedKernel/       # Unit tests for the SharedKernel layer
│       └── Workers/            # Tests for worker services and transforms (when present)
├── workers/                    # Directory reserved for workers and their implementations (when present)
│    └── Project.Worker.Name/

```

### Dependency rules between layers

- Core is a dependency of Infrastructure
- Infrastructure is a dependency of Web
- SharedKernel is a dependency of all layers

### What belongs in each layer

**Core**
- Domain entities
- Interfaces
- Domain services
- DTOs

**Infrastructure**
- Repository implementations
- Queries
- Database connection configuration
- Implementation of communication with other services and external APIs

**Web**
- REST endpoints
- Request & response parameters
- Global exception middleware
- Global DI configuration for the project (Program.cs)
- CORS configuration

**SharedKernel**
- Base exception
- Extensions
- Interfaces reused across layers
- Utils

---

## Code conventions

- No implicit `var` when the type is not obvious from the right-hand side of the assignment
- Mandatory suffixes by type: `*Controller`, `*Dto`, `*Service`, `*Exception`
- Entities have no suffix: `Workout`, `Exercise`
- Async/await on every I/O operation — no `.Result` or `.Wait()`
- Records for DTOs and immutable parameters: `public record CreateProjectRequest(string Name, string Description);`
- Lookups and list returns must always use the `OrDefault` variant: instead of `First()`, `Last()`, `Single()` -> `FirstOrDefault()`, `LastOrDefault()`, `SingleOrDefault()`

---

## Tests

- **Mandatory** for all logic in `Core`: services, validations and entity methods, business rules
- **Mandatory** for `extensions` and `utils` classes in `SharedKernel`
- Framework: xUnit
- Naming: `Scenario_ExpectedResult`
  - e.g. `WithoutRoutineId_ReturnsNotFound`
- Dependency interfaces must be mocked with Moq — **never test against a real database**
- Create one test file per public method. Do not test more than one method in the same file
- Always add the `*Tests` suffix to test files
- Use a folder structure that separates tests by layer, type and class
  - e.g. `Project.UnitTests/Core/Services/<ServiceName>Tests/<PublicMethod>Tests.cs`
  - e.g. `Project.UnitTests/SharedKernel/Extensions/StringExtensionTests/ToIntTests.cs`

---

## Error handling

- Whenever throwing an exception, use the **base exception** defined in SharedKernel
- **Never use `try/catch` in controllers** — that is the middleware's responsibility
- **Never let exceptions that are not the base exception leak to the controller** — the global middleware catches everything
- Middleware in `Web` standardizes the error response:
```csharp
internal class ErrorDetails
{
    public int StatusCode { get; set; }
    public string Message { get; set; }
    public ExpandoObject ExtraData { get; set; }
}
```

---

## Logging

- Use the NLog NuGet package (configured via `nlog.config` in the `Web` layer)
- Store logs in MongoDB
- Use structured JSON format for logs
- Every catch must record a log entry
- Do not duplicate logs
- Keep the log message objective; avoid huge log entries

### Never log

- Tokens/API keys
- Passwords
- Personal data (identification documents, full email address, phone number)

### Log levels

| Level       | Use                                 |
| ----------- | ----------------------------------- |
| Debug       | Input/output data                   |
| Information | Main flow                           |
| Warning     | Unexpected but recoverable situations |
| Error       | Failures                            |

---

## Migrations (Entity Framework)

### Naming

The migration name must describe **what changes in the schema**, in PascalCase, with no issue or ticket number. The `Added` suffix is used for insertions; `Removed` for removals; no suffix when the change is an alteration (e.g. `ChangeExerciseCategoryName`).

```
<PascalCaseDescription>[Added|Removed]
```

Examples:

| Correct | Incorrect |
|---|---|
| `WorkoutNotesAdded` | `38299_WorkoutNotes` |
| `ExerciseMuscleGroupAdded` | `12345_ExerciseMuscleGroup` |
| `RoutineArchivedFlagAdded` | `RoutineArchivedFlag_Issue27854` |

### Command

```bash
dotnet ef migrations add <Name> \
  --project src/<Project>.Infrastructure \
  --startup-project src/<Project>.Web
```

---

## Observability

<!-- TODO -->
