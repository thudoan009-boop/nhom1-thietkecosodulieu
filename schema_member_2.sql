CREATE TABLE workspaces (
    workspace_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    name VARCHAR(150) NOT NULL,
    description TEXT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET(),
    updated_at DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET(),
    deleted_at DATETIMEOFFSET NULL,
    

    CONSTRAINT uk_workspace_id_name UNIQUE (workspace_id, name),
    CONSTRAINT chk_workspace_status CHECK (status IN ('ACTIVE', 'ARCHIVED'))
);

CREATE TABLE github_connections (
    connection_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    workspace_id UNIQUEIDENTIFIER NOT NULL,
    provider VARCHAR(50) NOT NULL DEFAULT 'GITHUB',
    account_name VARCHAR(100) NOT NULL,
    access_token TEXT NOT NULL,
    sync_status VARCHAR(20) NOT NULL DEFAULT 'IDLE',
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2 NULL,


    CONSTRAINT uk_github_connection UNIQUE (connection_id, provider),
    CONSTRAINT chk_sync_status CHECK (sync_status IN ('IDLE', 'SYNCING', 'SUCCESS', 'FAILED'))
);


CREATE TABLE github_connection_scopes (
    scope_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    connection_id UNIQUEIDENTIFIER NOT NULL,
    scope_value VARCHAR(100) NOT NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),

    CONSTRAINT uk_connection_scope UNIQUE (connection_id, scope_value)
);


CREATE TABLE repositories (
    repository_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    workspace_id UNIQUEIDENTIFIER NOT NULL,
    name VARCHAR(150) NOT NULL,
    url VARCHAR(255) NOT NULL,
    default_branch VARCHAR(50) DEFAULT 'main',
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2 NULL,

    CONSTRAINT uk_repository_name UNIQUE (repository_id, name)
);


CREATE TABLE branches (
    branch_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    repository_id UNIQUEIDENTIFIER NOT NULL,
    name VARCHAR(100) NOT NULL,
    is_protected BIT NOT NULL DEFAULT 0,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),

    CONSTRAINT uk_branch_name UNIQUE (repository_id, name)
);
GO

ALTER TABLE github_connections ADD CONSTRAINT fk_github_connections_workspace 
    FOREIGN KEY (workspace_id) REFERENCES workspaces(workspace_id) ON DELETE CASCADE;

ALTER TABLE github_connection_scopes ADD CONSTRAINT fk_github_scopes_connection 
    FOREIGN KEY (connection_id) REFERENCES github_connections(connection_id) ON DELETE CASCADE;

ALTER TABLE repositories ADD CONSTRAINT fk_repositories_workspace 
    FOREIGN KEY (workspace_id) REFERENCES workspaces(workspace_id) ON DELETE CASCADE;

ALTER TABLE branches ADD CONSTRAINT fk_branches_repository 
    FOREIGN KEY (repository_id) REFERENCES repositories(repository_id) ON DELETE CASCADE;
GO