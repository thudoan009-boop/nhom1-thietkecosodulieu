CREATE TABLE workspaces (
    workspace_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    name VARCHAR(150) NOT NULL,
    description TEXT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET(),
    updated_at DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET(),
    deleted_at DATETIMEOFFSET NULL,
    
    -- UNIQUE CONSTRAINT theo yêu cầu nhiệm vụ
    CONSTRAINT uk_workspace_id_name UNIQUE (workspace_id, name),
    -- CHECK CONSTRAINT theo đặc tả nghiệp vụ
    CONSTRAINT chk_workspace_status CHECK (status IN ('ACTIVE', 'ARCHIVED'))
);