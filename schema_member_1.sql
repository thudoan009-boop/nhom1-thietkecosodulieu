-- 1. Bảng users
CREATE TABLE users (
    user_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET(),
    updated_at DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET(),
    deleted_at DATETIMEOFFSET NULL,
    
    -- Ràng buộc UNIQUE email và CHECK status theo yêu cầu
    CONSTRAINT uk_users_email UNIQUE (email),
    CONSTRAINT chk_user_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'BLOCKED'))
);

-- 2. Bảng user_notification_preferences (Tách từ thuộc tính đa trị)
CREATE TABLE user_notification_preferences (
    preference_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    user_id UNIQUEIDENTIFIER NOT NULL,
    channel VARCHAR(50) NOT NULL,
    created_at DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET(),
    
    -- Khóa ngoại và các ràng buộc UNIQUE, CHECK
    CONSTRAINT fk_notification_user FOREIGN KEY (user_id) 
        REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT uk_user_channel UNIQUE (user_id, channel),
    CONSTRAINT chk_notification_channel CHECK (channel IN ('EMAIL', 'SYSTEM', 'SLACK'))
);

CREATE INDEX idx_user_notification_user_id ON user_notification_preferences(user_id);