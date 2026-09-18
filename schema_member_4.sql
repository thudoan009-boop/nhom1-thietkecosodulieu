CREATE TABLE repositories (
    repository_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    workspace_id UNIQUEIDENTIFIER NOT NULL,
    name VARCHAR(150) NOT NULL,
    url VARCHAR(255) NOT NULL,
    default_branch VARCHAR(100) DEFAULT 'main',
    sync_status VARCHAR(20) NOT NULL DEFAULT 'SYNCING',
    last_synced_at DATETIMEOFFSET NULL,
    created_at DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET(),
    updated_at DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET(),
    
    -- FOREIGN KEY nối đến workspaces
    CONSTRAINT fk_repo_workspace FOREIGN KEY (workspace_id) 
        REFERENCES workspaces(workspace_id) ON DELETE CASCADE,
        
    -- CHECK CONSTRAINT kiểm tra trạng thái đồng bộ
    CONSTRAINT chk_repo_sync_status CHECK (sync_status IN ('SYNCING', 'SUCCESS', 'FAILED'))
);

CREATE INDEX idx_repositories_workspace_id ON repositories(workspace_id);