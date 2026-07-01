# Database Folder

Purpose: Repository planning area for persistence-related support files.

Current status: foundation placeholder only.

Runtime persistence implementation belongs in server-owned source after the save system tasks are approved.

## Rules

- Save data is server-authoritative.
- Client code must never write save data.
- Persistence schemas and migrations must follow documentation.
- No save templates, player data, or database logic are implemented in this task.
