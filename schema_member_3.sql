CREATE TABLE github_connection_scopes (
    scope_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    connection_id UNIQUEIDENTIFIER NOT NULL,
    scope_value VARCHAR(50) NOT NULL,
    created_at DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET(),
    
    -- FOREIGN KEY nối đến github_connections
    CONSTRAINT fk_scopes_connection FOREIGN KEY (connection_id) 
        REFERENCES github_connections(connection_id) ON DELETE CASCADE,
        
    -- UNIQUE CONSTRAINT tổ hợp 
    CONSTRAINT uk_connection_scope UNIQUE (connection_id, scope_value)
);

CREATE INDEX idx_github_scopes_connection_id ON github_connection_scopes(connection_id);