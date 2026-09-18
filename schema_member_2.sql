CREATE TABLE github_connections (
    connection_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    user_id UNIQUEIDENTIFIER NOT NULL, -- Sẽ nối FK đến bảng users do thành viên khác tạo
    github_user_id VARCHAR(100) UNIQUE NOT NULL,
    github_username VARCHAR(100) NOT NULL,
    access_token TEXT NOT NULL,
    created_at DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET(),
    updated_at DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET(),
    
    -- FOREIGN KEY nối đến bảng users
    CONSTRAINT fk_github_conn_user FOREIGN KEY (user_id) 
        REFERENCES users(user_id) ON DELETE CASCADE
);

-- Tạo chỉ mục (Index) trên khóa ngoại
CREATE INDEX idx_github_connections_user_id ON github_connections(user_id);