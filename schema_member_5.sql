CREATE TABLE branches (
    branch_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    repository_id UNIQUEIDENTIFIER NOT NULL,
    branch_name VARCHAR(150) NOT NULL,
    is_default BIT DEFAULT 0, -- Trong MSSQL, dùng BIT (0 = FALSE, 1 = TRUE) thay cho BOOLEAN
    created_at DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET(),
    updated_at DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET(),
    
    -- FOREIGN KEY nối đến repositories
    CONSTRAINT fk_branch_repository FOREIGN KEY (repository_id) 
        REFERENCES repositories(repository_id) ON DELETE CASCADE,
        
    -- UNIQUE CONSTRAINT tổ hợp
    CONSTRAINT uk_repository_branch UNIQUE (repository_id, branch_name)
);

CREATE INDEX idx_branches_repository_id ON branches(repository_id);