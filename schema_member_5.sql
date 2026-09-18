CREATE TABLE workspace_members (
    member_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    workspace_id UNIQUEIDENTIFIER NOT NULL,
    user_id UNIQUEIDENTIFIER NOT NULL,
    role_id UNIQUEIDENTIFIER NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    joined_at DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET(),
    created_at DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET(),
    updated_at DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET(),
    
    -- Ràng buộc Khóa ngoại
    CONSTRAINT fk_member_workspace FOREIGN KEY (workspace_id) 
        REFERENCES workspaces(workspace_id) ON DELETE CASCADE,
    CONSTRAINT fk_member_user FOREIGN KEY (user_id) 
        REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_member_role FOREIGN KEY (role_id) 
        REFERENCES roles(role_id) ON DELETE NO ACTION,
        
    -- Ràng buộc UNIQUE tổ hợp và CHECK trạng thái
    CONSTRAINT uk_workspace_user UNIQUE (workspace_id, user_id),
    CONSTRAINT chk_member_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'REMOVED'))
);

CREATE INDEX idx_workspace_members_workspace_id ON workspace_members(workspace_id);
CREATE INDEX idx_workspace_members_user_id ON workspace_members(user_id);
CREATE INDEX idx_workspace_members_role_id ON workspace_members(role_id);