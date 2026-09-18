-- Tổng hợp Script DDL cho Phân hệ Auth, Access & Workspace
-- Gộp từ các tệp schema_member_1.sql đến schema_member_5.sql

CREATE TABLE users (
    user_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name NVARCHAR(100) NOT NULL,
    is_active BIT DEFAULT 1,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);

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

CREATE TABLE roles (
    role_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    workspace_id UNIQUEIDENTIFIER NOT NULL,
    role_name VARCHAR(50) NOT NULL,
    description NVARCHAR(255) NULL,
    created_at DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE permissions (
    permission_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    permission_code VARCHAR(100) NOT NULL UNIQUE,
    description NVARCHAR(255) NULL
);

CREATE TABLE user_notification_preferences (
    preference_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    user_id UNIQUEIDENTIFIER NOT NULL,
    email_notifications BIT DEFAULT 1,
    push_notifications BIT DEFAULT 1,
    updated_at DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE role_permissions (
    role_id UNIQUEIDENTIFIER NOT NULL,
    permission_id UNIQUEIDENTIFIER NOT NULL,
    PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE workspace_members (
    workspace_id UNIQUEIDENTIFIER NOT NULL,
    user_id UNIQUEIDENTIFIER NOT NULL,
    role_id UNIQUEIDENTIFIER NOT NULL,
    joined_at DATETIME2 DEFAULT GETDATE(),
    PRIMARY KEY (workspace_id, user_id)
);
GO

-- Thiết lập các ràng buộc Khóa ngoại (FOREIGN KEY)
ALTER TABLE roles ADD CONSTRAINT fk_roles_workspace 
    FOREIGN KEY (workspace_id) REFERENCES workspaces(workspace_id) ON DELETE CASCADE;

ALTER TABLE user_notification_preferences ADD CONSTRAINT fk_preferences_user 
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;

ALTER TABLE role_permissions ADD CONSTRAINT fk_role_permissions_role 
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE;

ALTER TABLE role_permissions ADD CONSTRAINT fk_role_permissions_permission 
    FOREIGN KEY (permission_id) REFERENCES permissions(permission_id) ON DELETE CASCADE;

ALTER TABLE workspace_members ADD CONSTRAINT fk_workspace_members_workspace 
    FOREIGN KEY (workspace_id) REFERENCES workspaces(workspace_id) ON DELETE CASCADE;

ALTER TABLE workspace_members ADD CONSTRAINT fk_workspace_members_user 
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;

ALTER TABLE workspace_members ADD CONSTRAINT fk_workspace_members_role 
    FOREIGN KEY (role_id) REFERENCES roles(role_id);
GO